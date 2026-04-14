# typed: false
# frozen_string_literal: true

require "test_helper"

module Accountable
  class AccountableTest < ActiveSupport::TestCase
    test "staff? raises NotImplementedError by default" do
      test_obj = Object.new
      test_obj.extend(Accountable)

      error =
        assert_raises(NotImplementedError) do
          test_obj.staff?
        end
      assert_match(/must implement staff\?/, error.message)
    end

    test "user? raises NotImplementedError by default" do
      test_obj = Object.new
      test_obj.extend(Accountable)

      error =
        assert_raises(NotImplementedError) do
          test_obj.user?
        end
      assert_match(/must implement user\?/, error.message)
    end

    test "including class must implement staff? and user?" do
      test_user = Object.new
      test_user.extend(Accountable)
      test_user.define_singleton_method(:staff?) do
        true; end

      test_user.define_singleton_method(:user?) do
        true; end

      assert_predicate test_user, :staff?
      assert_predicate test_user, :user?
    end
  end
end
