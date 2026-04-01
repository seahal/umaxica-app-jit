# typed: false
# frozen_string_literal: true

require "test_helper"

class SessionTest < ActiveSupport::TestCase
  class DummyController < ApplicationController
    include ::Session
  end

  test "reset_flash returns nil" do
    assert_nil DummyController.new.reset_flash
  end
end
