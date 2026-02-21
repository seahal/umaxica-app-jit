# frozen_string_literal: true

require "test_helper"

class FinisherTest < ActiveSupport::TestCase
  class DummyController < ApplicationController
    include ::Finisher
  end

  test "append_after_action registers finish_request" do
    callbacks = DummyController._process_action_callbacks
    callback = callbacks.find { |c| c.kind == :after && c.filter == :finish_request }

    assert_predicate callback, :present?, "Expected :finish_request to be registered as an after_action"
  end
end
