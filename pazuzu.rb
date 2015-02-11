require 'json'
require 'aws-sdk-core'

class Pazuzu
  attr_accessor :volume_description, :vol_inst_mapping

  def initialize(argf)
    @volume_description = ''
    @vol_inst_mapping = {}
    argf.each_line { |line| @volume_description += line }
    extract
    puts vol_inst_mapping
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
    ec2instance = Aws::EC2::Client.new(:region => "us-west-1")
    resp = ec2instance.describe_instances({instance_ids: ['i-08d193cb']})
    tags = resp[:reservations][0][:instances][0][:tags]
    tags.each do |tag|
      if tag.key == "Name"
        tag_it_with(tag.value)
      end
    end

    # @nodes.each do |n|
    #   Log.info("Tagging #{n.fqdn} for #{n.instance_id}")
    #   resp = @ec2.create_tags({
    #     resources: [n.instance_id],
    #     tags: [
    #       {
    #         key: "Name",
    #         value: vol_inst_mapping[instance_id]
    #       }
    #     ]
    #   })
    # end
  end

  def tag_it_with(tag)
    
  end

end

pazuzu = Pazuzu.new(ARGF)
