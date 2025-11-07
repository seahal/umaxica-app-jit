# frozen_string_literal: true

require "test_helper"

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
        Message.new(Marshal.dump(mailer: "One")),
        Message.new(Marshal.dump(mailer: "Two"))
      ]
    )
    consumer = build_consumer(batch:)

    assert_silent { consumer.consume }
    assert_equal 2, batch.iterations
  end

  test "#consume is a safe no-op when the batch is empty" do
    batch = TrackingBatch.new([])
    consumer = build_consumer(batch:)

    assert_silent { consumer.consume }
    assert_equal 0, batch.iterations
  end
end
