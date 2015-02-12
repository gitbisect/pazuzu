require 'json'
require 'aws-sdk-core'

class Pazuzu
  attr_accessor :volume_description, :vol_inst_mapping
  attr_accessor :region

  def initialize(argf)
    @region = 'us-west-1'
    @volume_description = ''
    @vol_inst_mapping = {}
    argf.each_line { |line| @volume_description += line }
    extract
    tag_the_volumes
  end
  

  def extract
    vd = JSON.parse(volume_description)
    vd.each do |key, volumes|
      volumes.each do |volume|
        vol_inst_mapping[volume['VolumeId']] = volume['Attachments'][0]['InstanceId']
      end
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
    # ec2instance
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

pazuzu = Pazuzu.new(ARGF)
