# typed: false
# frozen_string_literal: true

require "test_helper"

module Authentication
  class ClientTest < ActiveSupport::TestCase
    test "is a valid concern module" do
      assert_kind_of Module, Authentication::Client
      assert_kind_of ActiveSupport::Concern, Authentication::Client
    end
  end
end
