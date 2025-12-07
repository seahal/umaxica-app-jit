# app/services/connect_outbound_service.rb

class AwsConnectService
  def initialize(region: "ap-northeast-1")
    @client = Aws::Connect::Client.new(region: region)
  end

  def start_call(instance_id:, contact_flow_id:, destination_phone_number:, source_phone_number: nil, attributes: {})
  end
end
