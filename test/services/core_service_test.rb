# frozen_string_literal: true

require "test_helper"

class CoreServiceTest < ActiveSupport::TestCase
  test ".hello returns the service file path" do
    expected = Rails.root.join("app/services/core_service.rb").to_s

    assert_equal expected, CoreService.hello
  end

  test "#initialize returns an instance without extra setup" do
    assert_instance_of CoreService, CoreService.new
  end
end
