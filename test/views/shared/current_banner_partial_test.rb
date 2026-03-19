# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentBannerPartialTest < ActionView::TestCase
  include ActiveSupport::Testing::TimeHelpers

  fixtures :app_banners, :org_banners, :com_banners, :users, :user_statuses, :staffs, :staff_statuses

  test "renders the current banner for a surface" do
    travel_to Time.zone.parse("2026-03-18 00:00:00 UTC") do
      render partial: "shared/current_banner", locals: { surface: :app }

      assert_includes rendered, "App newer banner"
      assert_includes rendered, "App newer banner body"
    end
  end

  test "renders nothing when the current banner is missing" do
    ComBanner.stub :current, ComBanner.none do
      render partial: "shared/current_banner", locals: { surface: :com }

      assert_empty rendered.strip
    end
  end
end
