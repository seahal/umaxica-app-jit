# frozen_string_literal: true

# == Schema Information
#
# Table name: org_documents
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
#  index_org_documents_on_permalink                    (permalink) UNIQUE
#  index_org_documents_on_published_at_and_expires_at  (published_at,expires_at)
#  index_org_documents_on_status_id                    (status_id)
#

require "test_helper"

class OrgDocumentTest < ActiveSupport::TestCase
  def base_attrs
    {
      permalink: "Org_1",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: "NEYO",
    }
  end

  test "permalink validation rejects slash, accepts underscore, rejects long length" do
    doc = OrgDocument.new(base_attrs.merge(permalink: "bad/slug"))
    assert_not doc.valid?

    doc = OrgDocument.new(base_attrs.merge(permalink: "good_slug"))
    assert_predicate doc, :valid?

    doc = OrgDocument.new(base_attrs.merge(permalink: "a" * 201))
    assert_not doc.valid?
  end

  test "available scope returns published and unexpired documents" do
    now = Time.current
    available = OrgDocument.create!(
      base_attrs.merge(
        permalink: "available", published_at: now - 1.hour,
        expires_at: now + 1.hour,
      ),
    )
    OrgDocument.create!(base_attrs.merge(permalink: "future", published_at: now + 1.hour, expires_at: now + 2.hours))
    OrgDocument.create!(base_attrs.merge(permalink: "expired", published_at: now - 2.hours, expires_at: now - 1.hour))

    assert_equal [available.id], OrgDocument.available.pluck(:id)
  end

  test "redirect_url is required when response_mode is redirect" do
    doc = OrgDocument.new(base_attrs.merge(response_mode: "redirect", redirect_url: nil))
    assert_not doc.valid?

    doc = OrgDocument.new(base_attrs.merge(response_mode: "redirect", redirect_url: "https://example.com"))
    assert_predicate doc, :valid?
  end

  test "latest_version returns the newest version by created_at" do
    doc = OrgDocument.create!(base_attrs.merge(permalink: "versioned"))

    OrgDocumentVersion.create!(
      org_document: doc,
      permalink: doc.permalink,
      response_mode: doc.response_mode,
      published_at: doc.published_at,
      expires_at: doc.expires_at,
      created_at: 2.days.ago,
      updated_at: 2.days.ago,
    )

    newest = OrgDocumentVersion.create!(
      org_document: doc,
      permalink: doc.permalink,
      response_mode: doc.response_mode,
      published_at: doc.published_at,
      expires_at: doc.expires_at,
      created_at: 1.day.ago,
      updated_at: 1.day.ago,
    )

    assert_equal newest, doc.latest_version
  end
end
