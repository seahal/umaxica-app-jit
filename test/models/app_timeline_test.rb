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
#  published_at  :datetime         default("infinity"), not null
#  expires_at    :datetime         default("infinity"), not null
#  position      :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status_id     :string(255)      default("NONE"), not null
#
# Indexes
#
#  index_app_timelines_on_permalink                    (permalink) UNIQUE
#  index_app_timelines_on_published_at_and_expires_at  (published_at,expires_at)
#  index_app_timelines_on_status_id                    (status_id)
#

require "test_helper"

class AppTimelineTest < ActiveSupport::TestCase
  def base_attrs
    {
      permalink: "App_1",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
    }
  end

  test "permalink validation rejects slash, accepts underscore, rejects long length" do
    timeline = AppTimeline.new(base_attrs.merge(permalink: "bad/slug"))
    assert_not timeline.valid?

    timeline = AppTimeline.new(base_attrs.merge(permalink: "good_slug"))
    assert_predicate timeline, :valid?

    timeline = AppTimeline.new(base_attrs.merge(permalink: "a" * 201))
    assert_not timeline.valid?
  end

  test "available scope returns published and unexpired timelines" do
    now = Time.current
    available = AppTimeline.create!(
      base_attrs.merge(
        permalink: "available", published_at: now - 1.hour,
        expires_at: now + 1.hour,
      ),
    )
    AppTimeline.create!(base_attrs.merge(permalink: "future", published_at: now + 1.hour, expires_at: now + 2.hours))
    AppTimeline.create!(base_attrs.merge(permalink: "expired", published_at: now - 2.hours, expires_at: now - 1.hour))

    assert_equal [available.id], AppTimeline.available.pluck(:id)
  end

  test "redirect_url is required when response_mode is redirect" do
    timeline = AppTimeline.new(base_attrs.merge(response_mode: "redirect", redirect_url: nil))
    assert_not timeline.valid?

    timeline = AppTimeline.new(base_attrs.merge(response_mode: "redirect", redirect_url: "https://example.com"))
    assert_predicate timeline, :valid?
  end

  test "latest_version returns the newest version by created_at" do
    timeline = AppTimeline.create!(base_attrs.merge(permalink: "versioned"))

    AppTimelineVersion.create!(
      app_timeline: timeline,
      permalink: timeline.permalink,
      response_mode: timeline.response_mode,
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
      created_at: 2.days.ago,
      updated_at: 2.days.ago,
    )

    newest = AppTimelineVersion.create!(
      app_timeline: timeline,
      permalink: timeline.permalink,
      response_mode: timeline.response_mode,
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
      created_at: 1.day.ago,
      updated_at: 1.day.ago,
    )

    assert_equal newest, timeline.latest_version
  end

  test "permalink is required and must not be empty" do
    timeline = AppTimeline.new(base_attrs.merge(permalink: nil))
    assert_not timeline.valid?
    timeline = AppTimeline.new(base_attrs.merge(permalink: ""))
    assert_not timeline.valid?
    timeline = AppTimeline.new(base_attrs.merge(permalink: "   "))
    assert_not timeline.valid?
  end

  test "published_at must be before expires_at" do
    timeline = AppTimeline.new(base_attrs.merge(published_at: 1.day.from_now, expires_at: 1.day.ago))
    assert_not timeline.valid?
    assert_not_empty timeline.errors[:published_at]
  end

  test "revision_key is ensured before validation" do
    timeline = AppTimeline.new(base_attrs.merge(revision_key: nil))
    assert_predicate timeline, :valid?
    assert_not_nil timeline.revision_key
  end

  test "association deletion: destroys dependent versions" do
    timeline = AppTimeline.create!(base_attrs.merge(permalink: "delete_test"))
    version = AppTimelineVersion.create!(
      app_timeline: timeline,
      permalink: timeline.permalink,
      response_mode: timeline.response_mode,
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
    )
    timeline.destroy
    assert_raise(ActiveRecord::RecordNotFound) { version.reload }
  end
end
