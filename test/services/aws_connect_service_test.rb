# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class AwsConnectServiceTest < ActiveSupport::TestCase
  test "initializes with default region" do
    mock_client = Object.new
    Aws::Connect::Client.stub :new, ->(args) {
      assert_equal({ region: "ap-northeast-1" }, args)
      mock_client
    } do
      service = AwsConnectService.new

      assert_instance_of AwsConnectService, service
    end
  end

  test "initializes with custom region" do
    mock_client = Object.new
    Aws::Connect::Client.stub :new, ->(args) {
      assert_equal({ region: "us-east-1" }, args)
      mock_client
    } do
      service = AwsConnectService.new(region: "us-east-1")

      assert_instance_of AwsConnectService, service
    end
  end
end
