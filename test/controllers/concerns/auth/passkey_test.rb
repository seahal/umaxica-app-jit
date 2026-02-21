# frozen_string_literal: true

require "test_helper"

class TestAuthPasskeyController < ApplicationController
  include Auth::Passkey
end

module Auth
  class PasskeyTest < ActiveSupport::TestCase
    test "Passkey is a module" do
      assert_kind_of Module, Passkey
    end

    test "Passkey can be included in a controller" do
      assert_includes TestAuthPasskeyController.ancestors, Auth::Passkey
    end

    test "including Passkey does not raise errors" do
      assert_nothing_raised do
        Class.new(ApplicationController) do
          include Auth::Passkey
        end
      end
    end

    test "Passkey module is namespaced under Auth" do
      assert defined?(Auth::Passkey)
    end
  end
end
