# typed: false
# frozen_string_literal: true

require "test_helper"

class FinisherTest < ActiveSupport::TestCase
  class TestController
    include Finisher

    def test_purge_current
      purge_current
    end

    def test_finish_request
      finish_request
    end
  end

  test "purge_current resets Current" do
    controller = TestController.new
    controller.test_purge_current

    assert_nil Current.user
    assert_nil Current.staff
  end

  test "finish_request does not raise" do
    controller = TestController.new

    assert_nothing_raised do
      controller.test_finish_request
    end
  end
end
