# typed: false
# frozen_string_literal: true

require "test_helper"

class StylesheetTagsTest < ActiveSupport::TestCase
  test "sign layouts include sign main stylesheet" do
    paths = [
      "app/views/layouts/sign/app/application.html.erb",
      "app/views/layouts/sign/org/application.html.erb",
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read

      assert_match(
        /(stylesheet_link_tag\s+\"sign\/main\")|(\"sign\/main\")/, contents,
        "missing sign/main in #{path}",
      )
    end
  end

  test "help layouts include help main stylesheet" do
    paths = [
      "app/views/layouts/help/app/application.html.erb",
      "app/views/layouts/help/com/application.html.erb",
      "app/views/layouts/help/org/application.html.erb",
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read

      assert_match(/stylesheet_link_tag\s+\"help\/main\"/, contents, "missing help/main in #{path}")
    end
  end

  test "news layouts include news main stylesheet" do
    paths = [
      "app/views/layouts/news/app/application.html.erb",
      "app/views/layouts/news/com/application.html.erb",
      "app/views/layouts/news/org/application.html.erb",
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read

      assert_match(/stylesheet_link_tag\s+\"news\/main\"/, contents, "missing news/main in #{path}")
    end
  end

  test "apex layouts include apex main stylesheet" do
    paths = [
      "app/views/layouts/apex/app/application.html.erb",
      "app/views/layouts/apex/com/application.html.erb",
      "app/views/layouts/apex/org/application.html.erb",
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read

      assert_match(
        /(stylesheet_link_tag\s+\"apex\/main\")|(\"apex\/main\")/, contents,
        "missing apex/main in #{path}",
      )
    end
  end
end
