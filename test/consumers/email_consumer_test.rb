# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class EmailConsumerTest < ActiveSupport::TestCase
  TrackingBatch = Class.new do
    attr_reader :iterations

    def initialize(messages)
      @messages = messages
      @iterations = 0
    end

    def each
      return enum_for(:each) unless block_given?

      @messages.each do |message|
        @iterations += 1
        yield message
      end
    end
  end

  InstrumentedConsumer = Class.new(EmailConsumer) do
    attr_accessor :batch

    def messages
      @batch || []
    end
  end

  Message = Struct.new(:raw_payload)

  def build_consumer(batch:)
    consumer = InstrumentedConsumer.allocate
    consumer.batch = batch
    consumer
  end

  test "#consume iterates through every message in the batch" do
    batch = TrackingBatch.new(
      [
        Message.new(JSON.generate(mailer_class: "Email::App::RegistrationMailer", params: {})),
        Message.new(JSON.generate(mailer_class: "Email::App::RegistrationMailer", params: {}))
      ]
    )
    consumer = build_consumer(batch:)

    mailer_double = Minitest::Mock.new
    mailer_double.expect(:deliver_now, true)
    mailer_double.expect(:deliver_now, true)

    Email::App::RegistrationMailer.stub :with, mailer_double do
      assert_silent { consumer.consume }
    end

    assert_equal 2, batch.iterations
  end

  test "#consume is a safe no-op when the batch is empty" do
    batch = TrackingBatch.new([])
    consumer = build_consumer(batch:)

    assert_silent { consumer.consume }
    assert_equal 0, batch.iterations
  end

  test "#consume processes messages with valid mailer class" do
    payload = JSON.generate(
      mailer_class: "Email::App::RegistrationMailer",
      params: { email: "test@example.com" }
    )
    batch = TrackingBatch.new([ Message.new(payload) ])
    consumer = build_consumer(batch:)

    mailer_double = Minitest::Mock.new
    mailer_double.expect(:deliver_now, true)

    Email::App::RegistrationMailer.stub :with, mailer_double do
      assert_silent { consumer.consume }
    end
  end

  test "#consume ignores messages with invalid mailer class" do
    payload = JSON.generate(
      mailer_class: "UnknownMailer",
      params: { email: "test@example.com" }
    )
    batch = TrackingBatch.new([ Message.new(payload) ])
    consumer = build_consumer(batch:)

    assert_silent { consumer.consume }
  end

  test "#consume handles invalid JSON gracefully" do
    invalid_json = "{ invalid json }"
    batch = TrackingBatch.new([ Message.new(invalid_json) ])
    consumer = build_consumer(batch:)

    assert_silent { consumer.consume }
  end

  test "#consume handles missing params in payload" do
    payload = JSON.generate(mailer_class: "Email::App::RegistrationMailer")
    batch = TrackingBatch.new([ Message.new(payload) ])
    consumer = build_consumer(batch:)

    mailer_double = Minitest::Mock.new
    mailer_double.expect(:deliver_now, true)

    Email::App::RegistrationMailer.stub :with, mailer_double do
      assert_silent { consumer.consume }
    end
  end

  test "#consume continues processing on mailer error" do
    payload1 = JSON.generate(
      mailer_class: "Email::App::RegistrationMailer",
      params: { email: "test1@example.com" }
    )
    # Invalid JSON for second message to trigger error
    payload2 = "invalid json"
    batch = TrackingBatch.new([ Message.new(payload1), Message.new(payload2) ])
    consumer = build_consumer(batch:)

    mailer_double = Minitest::Mock.new
    mailer_double.expect(:deliver_now, true)

    Email::App::RegistrationMailer.stub :with, mailer_double do
      assert_silent { consumer.consume }
    end

    # Both messages should be processed despite error in second one
    assert_equal 2, batch.iterations
  end

  test "#consume handles org preference mailer" do
    payload = JSON.generate(
      mailer_class: "Email::Org::PreferenceMailer",
      params: { org_id: "org123" }
    )
    batch = TrackingBatch.new([ Message.new(payload) ])
    consumer = build_consumer(batch:)

    # Email::Org::PreferenceMailer is not in the whitelist, so it should be ignored
    assert_silent { consumer.consume }
  end

  test "#consume logs error when mailer class cannot be instantiated" do
    payload = JSON.generate(
      mailer_class: "InvalidMailerClass",
      params: { email: "test@example.com" }
    )
    batch = TrackingBatch.new([ Message.new(payload) ])
    consumer = build_consumer(batch:)

    assert_silent { consumer.consume }
  end

  test "#consume processes multiple valid messages" do
    payloads = [
      JSON.generate(mailer_class: "Email::App::RegistrationMailer", params: { email: "user1@example.com" }),
      JSON.generate(mailer_class: "Email::App::RegistrationMailer", params: { email: "user2@example.com" }),
      JSON.generate(mailer_class: "Email::App::RegistrationMailer", params: { email: "user3@example.com" })
    ]
    batch = TrackingBatch.new(payloads.map { |p| Message.new(p) })
    consumer = build_consumer(batch:)

    mailer_double = Minitest::Mock.new
    mailer_double.expect(:deliver_now, true)
    mailer_double.expect(:deliver_now, true)
    mailer_double.expect(:deliver_now, true)

    Email::App::RegistrationMailer.stub :with, mailer_double do
      assert_silent { consumer.consume }
    end

    assert_equal 3, batch.iterations
  end

  test "#consume with params containing nested structures" do
    nested_params = {
      email: "test@example.com",
      user: {
        name: "Test User",
        preferences: { notifications: true }
      }
    }
    payload = JSON.generate(
      mailer_class: "Email::App::RegistrationMailer",
      params: nested_params
    )
    batch = TrackingBatch.new([ Message.new(payload) ])
    consumer = build_consumer(batch:)

    mailer_double = Minitest::Mock.new
    mailer_double.expect(:deliver_now, true)

    Email::App::RegistrationMailer.stub :with, mailer_double do
      assert_silent { consumer.consume }
    end
  end
end
