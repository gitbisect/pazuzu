require 'json'
require 'aws-sdk-core'

class Pazuzu
  attr_accessor :volume_description, :vol_inst_mapping
  attr_accessor :region

  def initialize(region)
    @region = region || 'us-west-1'
    fetch_the_volumes
    map_volumes_to_instances
    tag_the_volumes
  end
  
  def fetch_the_volumes
    ec2instance = Aws::EC2::Client.new(:region => region)
    resp = ec2instance.describe_volumes({
      filters: [
        {name: 'attachment.status', values: ['attached']}
        # ,
        # {name: 'tag:Name', values: [""]} # this isnt working
      ]
    })
    @volume_description = resp[:volumes]
  end

  def map_volumes_to_instances
    puts "Going to tag #{@volume_description.count} volumes"

    @vol_inst_mapping = {}
    @volume_description.each do |volume|
      vol_inst_mapping[volume.attachments[0].volume_id] = volume.attachments[0].instance_id
    end
  end
  

  def tag_the_volumes
    vol_inst_mapping.each do |vol_id, inst_id|
      ec2instance = Aws::EC2::Client.new(:region => region)
      resp = ec2instance.describe_instances({instance_ids: [inst_id]})
      tags = resp[:reservations][0][:instances][0][:tags]
      tags.each do |tag|
        if tag.key == "Name"
          tag_it_with(vol_id: vol_id, tag: tag.value)
        end
      end
    end

  end

  def tag_it_with(vol_id:, tag:)
    puts "Tagging #{vol_id} with #{tag}"
    ec2instance = Aws::EC2::Client.new(:region => region)
    resp = ec2instance.create_tags({
      resources: [vol_id],
      tags: [
        {
          key: "Name",
          value: tag
        }
      ]
    })
  end

end

pazuzu = Pazuzu.new(ARGV[0])
