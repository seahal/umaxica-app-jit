# typed: false
# frozen_string_literal: true

require "test_helper"

module Preference
  class ConsentedBufferTest < ActiveSupport::TestCase
    test "consented_cookie_value returns 1 for truthy values" do
      controller = Class.new do
        include Preference::ConsentedBuffer

        define_method(:test_value) do |v|
          consented_cookie_value(v)
        end
      end.new

      assert_equal "1", controller.test_value("1")
      assert_equal "1", controller.test_value(true)
      assert_equal "1", controller.test_value(1)
    end

    test "consented_cookie_value returns 0 for falsy values" do
      controller = Class.new do
        include Preference::ConsentedBuffer

        define_method(:test_value) do |v|
          consented_cookie_value(v)
        end
      end.new

      assert_equal "0", controller.test_value("0")
      assert_equal "0", controller.test_value(false)
      assert_equal "0", controller.test_value(nil)
      assert_equal "0", controller.test_value("")
    end
  end
end
