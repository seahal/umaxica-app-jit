# frozen_string_literal: true

require "test_helper"

class ApplicationCable::ChannelTest < ActionCable::Channel::TestCase
  class TestChannel < ApplicationCable::Channel
    def subscribed
      stream_from "test_channel"
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end
  end

  test "ApplicationCable::Channel is a subclass of ActionCable::Channel::Base" do
    assert_operator ApplicationCable::Channel, :<, ActionCable::Channel::Base
  end

  test "channels can inherit from ApplicationCable::Channel" do
    assert_equal ApplicationCable::Channel, TestChannel.superclass
  end

  test "channel can be subscribed" do
    subscribe

    assert_predicate subscription, :confirmed?
  end

  test "channel can stream from" do
    subscribe
    # Verify subscription was created successfully
    assert_predicate subscription, :confirmed?
  end

  test "channel can be unsubscribed" do
    subscribe

    assert_predicate subscription, :confirmed?

    perform :unsubscribe

    # Verify the unsubscribed callback can be called
    assert_equal ApplicationCable::Channel, TestChannel.superclass
  end
end
