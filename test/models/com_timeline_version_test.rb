# == Schema Information
#
# Table name: com_timeline_versions
#
#  id              :uuid             not null, primary key
#  com_timeline_id :uuid             not null
#  permalink       :string(200)      not null
#  response_mode   :string           not null
#  redirect_url    :string
#  title           :string
#  description     :string
#  body            :text
#  published_at    :datetime         not null
#  expires_at      :datetime         not null
#  edited_by_type  :string
#  edited_by_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_com_timeline_versions_on_com_timeline_id                 (com_timeline_id)
#  index_com_timeline_versions_on_com_timeline_id_and_created_at  (com_timeline_id,created_at)
#  index_com_timeline_versions_on_public_id                       (public_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class ComTimelineVersionTest < ActiveSupport::TestCase
  test "includes Version concern" do
    assert_includes ComTimelineVersion.included_modules, Version
  end

  test "encrypts title, description, and body" do
    record = ComTimelineVersion.create!(
      com_timeline: com_timelines(:one),
      permalink: "permalink_#{SecureRandom.hex(4)}",
      response_mode: "html",
      published_at: Time.zone.parse("2999-01-01 00:00:00"),
      expires_at: Time.zone.parse("2999-12-31 00:00:00"),
      title: "Secret title",
      description: "Secret description",
      body: "Secret body",
    )

    raw_data = ComTimelineVersion.connection.execute(
      "SELECT title, description, body FROM com_timeline_versions WHERE id = '#{record.id}'",
    ).first

    assert_not_equal "Secret title", raw_data["title"] if raw_data
    assert_not_equal "Secret description", raw_data["description"] if raw_data
    assert_not_equal "Secret body", raw_data["body"] if raw_data
  end
  test "validates presence of required fields" do
    version = ComTimelineVersion.new
    assert_not version.valid?
    assert_not_empty version.errors[:permalink]
    assert_not_empty version.errors[:response_mode]
    assert_not_empty version.errors[:published_at]
    assert_not_empty version.errors[:expires_at]
  end
end
