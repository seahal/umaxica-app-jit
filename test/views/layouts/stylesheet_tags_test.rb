require "test_helper"

class StylesheetTagsTest < ActiveSupport::TestCase
  test "auth layouts include auth main stylesheet" do
    paths = [
      "app/views/layouts/auth/app/application.html.erb",
      "app/views/layouts/auth/org/application.html.erb"
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read
      assert_match(/stylesheet_link_tag\s+\"auth\/main\"/, contents, "missing auth/main in #{path}")
    end
  end

  test "core layouts include core main stylesheet" do
    paths = [
      "app/views/layouts/core/app/application.html.erb",
      "app/views/layouts/core/com/application.html.erb",
      "app/views/layouts/core/org/application.html.erb"
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read
      assert_match(/stylesheet_link_tag\s+\"core\/main\"/, contents, "missing core/main in #{path}")
    end
  end

  test "help layouts include help main stylesheet" do
    paths = [
      "app/views/layouts/help/app/application.html.erb",
      "app/views/layouts/help/com/application.html.erb",
      "app/views/layouts/help/org/application.html.erb"
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
      "app/views/layouts/news/org/application.html.erb"
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read
      assert_match(/stylesheet_link_tag\s+\"news\/main\"/, contents, "missing news/main in #{path}")
    end
  end

  test "peak layouts include peak main stylesheet" do
    paths = [
      "app/views/layouts/peak/app/application.html.erb",
      "app/views/layouts/peak/com/application.html.erb",
      "app/views/layouts/peak/org/application.html.erb"
    ]

    paths.each do |path|
      contents = Rails.root.join(path).read
      assert_match(/stylesheet_link_tag\s+\"peak\/main\"/, contents, "missing peak/main in #{path}")
    end
  end
end
