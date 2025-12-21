require "test_helper"
require "minitest/mock"

class AwsSmsServiceTest < ActiveSupport::TestCase
  test "validates required parameters (1)" do
    # Avoid AWS connection during initialization using stub
    Aws::SNS::Client.stub :new, Object.new do
      service = AwsSmsService.new

      error = assert_raises(ArgumentError) do
        service.send_message(to: "", message: "Test message")
      end
      assert_match(/Phone number is required/, error.message)
    end
  end

  test "validates required parameters (2)" do
    # Avoid AWS connection during initialization using stub
    Aws::SNS::Client.stub :new, Object.new do
      service = AwsSmsService.new

      error = assert_raises(ArgumentError) do
        service.send_message(to: "", message: "Test message")
      end

      error = assert_raises(ArgumentError) do
        service.send_message(to: "+1234567890", message: "")
      end
      assert_match(/Message is required/, error.message)
    end
  end

  test "sends message via AWS SNS client with default subject" do
    mock_client = Minitest::Mock.new
    expected_params = {
      phone_number: "+819012345678",
      message: "Hello World",
      subject: "SMS"
    }
    mock_client.expect :publish, { message_id: "msg-123" }, [ expected_params ]

    Aws::SNS::Client.stub :new, mock_client do
      service = AwsSmsService.new
      result = service.send_message(to: "+819012345678", message: "Hello World")

      assert_equal "msg-123", result[:message_id]
    end

    assert mock_client.verify
  end

  test "sends message via AWS SNS client with custom subject" do
    mock_client = Minitest::Mock.new
    expected_params = {
      phone_number: "+819012345678",
      message: "Hello World",
      subject: "Important"
    }
    mock_client.expect :publish, { message_id: "msg-456" }, [ expected_params ]

    Aws::SNS::Client.stub :new, mock_client do
      service = AwsSmsService.new
      result = service.send_message(to: "+819012345678", message: "Hello World", subject: "Important")

      assert_equal "msg-456", result[:message_id]
    end

    assert mock_client.verify
  end
end
