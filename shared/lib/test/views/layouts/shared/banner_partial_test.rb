# typed: false
# frozen_string_literal: true

require "test_helper"

class BannerPartialTest < ActionView::TestCase
  fixtures :app_banners, :com_banners, :users, :user_statuses

  test "renders title and body when title is present" do
    render partial: "layouts/shared/banner", locals: { banner: app_banners(:current_app_banner) }

    assert_includes rendered, "App current banner"
    assert_includes rendered, "App current banner body"
  end

  test "renders body without title heading when title is blank" do
    render partial: "layouts/shared/banner", locals: { banner: com_banners(:untitled_com_banner) }

    assert_includes rendered, "Com untitled banner body"
    assert_not_includes rendered, "<h2>"
  end
end
