# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timelines
# Database name: news
#
#  id                 :bigint           not null, primary key
#  expires_at         :datetime         default(Infinity), not null
#  lock_version       :integer          default(0), not null
#  position           :integer          default(0), not null
#  published_at       :datetime         default(Infinity), not null
#  redirect_url       :string
#  response_mode      :string           default("html"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  latest_revision_id :bigint
#  latest_version_id  :bigint
#  slug_id            :string(32)       default(""), not null
#  status_id          :bigint           default(1), not null
#
# Indexes
#
#  index_org_timelines_on_latest_revision_id           (latest_revision_id) UNIQUE
#  index_org_timelines_on_latest_version_id            (latest_version_id) UNIQUE
#  index_org_timelines_on_published_at_and_expires_at  (published_at,expires_at)
#  index_org_timelines_on_slug_id                      (slug_id)
#  index_org_timelines_on_status_id                    (status_id)
#
# Foreign Keys
#
#  fk_org_timelines_on_status_id  (status_id => org_timeline_statuses.id)
#  fk_rails_...                   (latest_revision_id => org_timeline_revisions.id) ON DELETE => nullify
#  fk_rails_...                   (latest_version_id => org_timeline_versions.id) ON DELETE => nullify
#

require "test_helper"

class OrgTimelineTest < ActiveSupport::TestCase
  def base_attrs
    {
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      status_id: OrgTimelineStatus::NEYO,
    }
  end

  # permalink has been removed from org_timelines table
  # test "permalink validation rejects slash, accepts underscore, rejects long length" do
  #   timeline = OrgTimeline.new(base_attrs.merge(permalink: "bad/slug"))
  #   assert_not timeline.valid?
  #
  #   timeline = OrgTimeline.new(base_attrs.merge(permalink: "good_slug"))
  #   assert_predicate timeline, :valid?
  #
  #   timeline = OrgTimeline.new(base_attrs.merge(permalink: "a" * 201))
  #   assert_not timeline.valid?
  # end

  test "available scope returns published and unexpired timelines" do
    now = Time.current
    available = OrgTimeline.create!(
      base_attrs.merge(
        published_at: now - 1.hour,
        expires_at: now + 1.hour,
      ),
    )
    OrgTimeline.create!(base_attrs.merge(published_at: now + 1.hour, expires_at: now + 2.hours))
    OrgTimeline.create!(base_attrs.merge(published_at: now - 2.hours, expires_at: now - 1.hour))

    assert_includes OrgTimeline.available.pluck(:id), available.id
  end

  test "redirect_url is required when response_mode is redirect" do
    timeline = OrgTimeline.new(base_attrs.merge(response_mode: "redirect", redirect_url: nil))
    assert_not timeline.valid?

    timeline = OrgTimeline.new(base_attrs.merge(response_mode: "redirect", redirect_url: "https://example.com"))
    assert_predicate timeline, :valid?
  end

  test "latest_version returns the newest version by created_at" do
    timeline = OrgTimeline.create!(base_attrs)

    OrgTimelineVersion.create!(
      org_timeline: timeline,
      permalink: "versioned",
      response_mode: timeline.response_mode,
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
      created_at: 2.days.ago,
      updated_at: 2.days.ago,
    )

    newest = OrgTimelineVersion.create!(
      org_timeline: timeline,
      permalink: "versioned",
      response_mode: timeline.response_mode,
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
      created_at: 1.day.ago,
      updated_at: 1.day.ago,
    )

    assert_equal newest, timeline.latest_version
  end

  # permalink has been removed from org_timelines table
  # test "permalink is required and must not be empty" do
  #   timeline = OrgTimeline.new(base_attrs.merge(permalink: nil))
  #   assert_not timeline.valid?
  #   timeline = OrgTimeline.new(base_attrs.merge(permalink: ""))
  #   assert_not timeline.valid?
  #   timeline = OrgTimeline.new(base_attrs.merge(permalink: "   "))
  #   assert_not timeline.valid?
  # end

  test "published_at must be before expires_at" do
    timeline = OrgTimeline.new(base_attrs.merge(published_at: 1.day.from_now, expires_at: 1.day.ago))
    assert_not timeline.valid?
    assert_not_empty timeline.errors[:published_at]
  end

  # revision_key has been removed from org_timelines table
  # test "revision_key is ensured before validation" do
  #   timeline = OrgTimeline.new(base_attrs.merge(revision_key: nil))
  #   assert_predicate timeline, :valid?
  #   assert_not_nil timeline.revision_key
  # end

  test "association deletion: destroys dependent versions" do
    timeline = OrgTimeline.create!(base_attrs)
    version = OrgTimelineVersion.create!(
      org_timeline: timeline,
      permalink: "delete_test",
      response_mode: timeline.response_mode,
      published_at: timeline.published_at,
      expires_at: timeline.expires_at,
    )
    timeline.destroy
    assert_raise(ActiveRecord::RecordNotFound) { version.reload }
  end
end
