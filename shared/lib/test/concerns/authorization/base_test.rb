# typed: false
# frozen_string_literal: true

require "test_helper"

module Authorization
  class BaseTest < ActiveSupport::TestCase
    class TestController
      include Authorization::Base

      def test_authorize
        authorize_request!
      end
    end

    test "authorize_request! returns true" do
      controller = TestController.new

      assert controller.test_authorize
    end
  end
end
