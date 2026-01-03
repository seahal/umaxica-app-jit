# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timelines
#
#  id            :uuid             not null, primary key
#  permalink     :string(200)      not null
#  response_mode :string           default("html"), not null
#  redirect_url  :string
#  revision_key  :string           not null
#  published_at  :datetime         not null
#  expires_at    :datetime         not null
#  position      :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require "test_helper"

class AppTimelineUpdaterTest < ActiveSupport::TestCase
  fixtures :app_timeline_statuses

  def base_attrs
    {
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
    }
  end

  test "call always creates a new version" do
    timeline = AppTimeline.create!(base_attrs)

    attrs = {
      permalink: "updatable",
      response_mode: "html",
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
      position: 1,
      title: "Title",
      description: "Description",
      body: "Body",
    }

    assert_difference "AppTimelineVersion.count", 1 do
      AppTimelineUpdater.call(timeline: timeline, attrs: attrs)
    end
  end
end
