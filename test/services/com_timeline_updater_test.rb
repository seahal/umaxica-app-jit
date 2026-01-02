# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timelines
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

class ComTimelineUpdaterTest < ActiveSupport::TestCase
  def base_attrs
    {
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: "NEYO",
    }
  end

  test "call always creates a new version" do
    timeline = ComTimeline.create!(base_attrs)

    attrs = {
      response_mode: "html",
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
      position: 1,
      title: "Title",
      description: "Description",
      body: "Body",
      permalink: "permalink_#{SecureRandom.hex(4)}",
    }

    assert_difference "ComTimelineVersion.count", 1 do
      ComTimelineUpdater.call(timeline: timeline, attrs: attrs)
    end
  end
end
