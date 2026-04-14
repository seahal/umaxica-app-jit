# typed: false
# frozen_string_literal: true

require "test_helper"

module SocialAuth
  class BaseErrorTest < ActiveSupport::TestCase
    test "is a subclass of ApplicationError" do
      assert_kind_of ApplicationError, BaseError.new
    end

    test "is a subclass of StandardError" do
      assert_kind_of StandardError, BaseError.new
    end
  end
end
