# frozen_string_literal: true

require "test_helper"

class MessageServiceTest < ActiveSupport::TestCase
  test "MessageService class exists and can be referenced" do
    assert_equal MessageService, MessageService
  end

  test "MessageService can be instantiated" do
    service = MessageService.new

    assert_instance_of MessageService, service
  end

  test "MessageService responds to new" do
    assert_respond_to MessageService, :new
  end
end
