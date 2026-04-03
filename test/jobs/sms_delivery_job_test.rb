# typed: false
# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class SmsDeliveryJobTest < ActiveJob::TestCase
  test "SmsDeliveryJob inherits from ApplicationJob" do
    assert_kind_of ApplicationJob, SmsDeliveryJob.new
  end

  test "queue_as is :default" do
    assert_includes %w(default :default), SmsDeliveryJob.queue_name.to_s
  end

  test "perform delegates to AwsSmsService.send_message" do
    call_args = nil
    AwsSmsService.stub(:send_message, ->(**args) { call_args = args }) do
      SmsDeliveryJob.perform_now(
        to: "+819012345678",
        message: "Your code is 123456",
        subject: "Verification",
      )

      assert_equal "+819012345678", call_args[:to]
      assert_equal "Your code is 123456", call_args[:message]
      assert_equal "Verification", call_args[:subject]
    end
  end

  test "perform without subject delegates to AwsSmsService" do
    call_args = nil
    AwsSmsService.stub(:send_message, ->(**args) { call_args = args }) do
      SmsDeliveryJob.perform_now(
        to: "+819012345678",
        message: "Your code is 123456",
      )

      assert_equal "+819012345678", call_args[:to]
      assert_equal "Your code is 123456", call_args[:message]
      assert_nil call_args[:subject]
    end
  end

  test "retries on Aws::SNS::Errors::ServiceError by re-enqueuing" do
    error = Aws::SNS::Errors::ServiceError.new("test", "Service error")

    AwsSmsService.stub(:send_message, ->(**_args) { raise error }) do
      assert_enqueued_with(job: SmsDeliveryJob) do
        SmsDeliveryJob.perform_now(
          to: "+819012345678",
          message: "test",
        )
      end
    end
  end

  test "retries on Net::OpenTimeout by re-enqueuing" do
    AwsSmsService.stub(:send_message, ->(**_args) { raise Net::OpenTimeout.new("Open timeout") }) do
      assert_enqueued_with(job: SmsDeliveryJob) do
        SmsDeliveryJob.perform_now(
          to: "+819012345678",
          message: "test",
        )
      end
    end
  end

  test "retries on Net::ReadTimeout by re-enqueuing" do
    AwsSmsService.stub(:send_message, ->(**_args) { raise Net::ReadTimeout.new("Read timeout") }) do
      assert_enqueued_with(job: SmsDeliveryJob) do
        SmsDeliveryJob.perform_now(
          to: "+819012345678",
          message: "test",
        )
      end
    end
  end

  test "discards on ArgumentError without re-enqueuing" do
    AwsSmsService.stub(
      :send_message, ->(**_args) {
                       raise ArgumentError, "Invalid phone number"
                     },
    ) do
      assert_no_enqueued_jobs do
        SmsDeliveryJob.perform_now(
          to: "",
          message: "test",
        )
      end
    end
  end

  test "job can be enqueued" do
    assert_enqueued_with(
      job: SmsDeliveryJob,
      args: [
        {
          to: "+819012345678",
          message: "Your code is 123456",
          subject: "Test",
        },
      ],
    ) do
      SmsDeliveryJob.perform_later(
        to: "+819012345678",
        message: "Your code is 123456",
        subject: "Test",
      )
    end
  end
end
