# typed: false
# frozen_string_literal: true

require "test_helper"

class RobotsTest < ActiveSupport::TestCase
  class TestController < ApplicationController
    include Robots

    def show
      show_plain_text
    end
  end

  test "robots_txt keeps the org homepage visible and blocks private areas" do
    controller = TestController.new
    Current.surface = :org

    result = controller.send(:robots_txt)

    assert_includes result, "Allow: /"
    assert_includes result, "Disallow: /configuration"
    assert_includes result, "Disallow: /contacts"
    assert_includes result, "Disallow: /edge"
    assert_includes result, "Disallow: /emergency"
    assert_includes result, "Disallow: /web"
    assert_not_includes result, "Disallow: /\n"
  end

  test "robots_txt keeps the app homepage visible and blocks private areas" do
    controller = TestController.new
    Current.surface = :app

    result = controller.send(:robots_txt)

    assert_includes result, "Allow: /"
    assert_includes result, "Disallow: /configuration"
    assert_includes result, "Disallow: /contacts"
    assert_includes result, "Disallow: /edge"
    assert_includes result, "Disallow: /web"
  end

  test "robots_txt returns allow all for other surfaces" do
    controller = TestController.new
    Current.surface = :com

    result = controller.send(:robots_txt)

    assert_includes result, "Allow: /"
    assert_includes result, "Disallow:"
    assert_not_includes result, "Disallow: /\n"
  end
end
