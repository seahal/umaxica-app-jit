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

  test "base layouts include base main stylesheet" do
    paths = [
      "apps/foundation/app/views/layouts/base/app/application.html.erb",
      "apps/foundation/app/views/layouts/base/com/application.html.erb",
      "apps/foundation/app/views/layouts/base/org/application.html.erb",
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read

      assert_match(
        /(stylesheet_link_tag\s+\"base\/main\")|(\"base\/main\")/, contents,
        "missing base/main in #{path}",
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

  test "acme layouts include acme main stylesheet" do
    paths = [
      "app/views/layouts/acme/app/application.html.erb",
      "app/views/layouts/acme/com/application.html.erb",
      "app/views/layouts/acme/org/application.html.erb",
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read

      assert_match(
        /(stylesheet_link_tag\s+\"acme\/main\")|(\"acme\/main\")/, contents,
        "missing acme/main in #{path}",
      )
    end
  end
end
