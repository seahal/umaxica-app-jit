# frozen_string_literal: true

# == Schema Information
#
# Table name: com_documents
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
#  index_com_documents_on_permalink                    (permalink) UNIQUE
#  index_com_documents_on_published_at_and_expires_at  (published_at,expires_at)
#  index_com_documents_on_status_id                    (status_id)
#

require "test_helper"

class ComDocumentTest < ActiveSupport::TestCase
  def base_attrs
    {
      permalink: "Doc_1",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: "NEYO",
    }
  end

  test "permalink validation rejects slash, accepts underscore, rejects long length" do
    doc = ComDocument.new(base_attrs.merge(permalink: "bad/slug"))
    assert_not doc.valid?

    doc = ComDocument.new(base_attrs.merge(permalink: "good_slug"))
    assert_predicate doc, :valid?

    doc = ComDocument.new(base_attrs.merge(permalink: "a" * 201))
    assert_not doc.valid?
  end

  test "available scope returns published and unexpired documents" do
    now = Time.current
    ids = {}
    ids[:available] =
      ComDocument.create!(
        base_attrs.merge(
          permalink: "available", published_at: now - 1.hour,
          expires_at: now + 1.hour,
        ),
      ).id
    ids[:future] =
      ComDocument.create!(
        base_attrs.merge(
          permalink: "future", published_at: now + 1.hour,
          expires_at: now + 2.hours,
        ),
      ).id
    ids[:expired] =
      ComDocument.create!(
        base_attrs.merge(
          permalink: "expired", published_at: now - 2.hours,
          expires_at: now - 1.hour,
        ),
      ).id

    available = ComDocument.find(ids[:available])

    assert_includes ComDocument.available.pluck(:id), available.id
    assert_not_includes ComDocument.available.pluck(:id), ids[:future]
    assert_not_includes ComDocument.available.pluck(:id), ids[:expired]
  end

  test "redirect_url is required when response_mode is redirect" do
    doc = ComDocument.new(base_attrs.merge(response_mode: "redirect", redirect_url: nil))
    assert_not doc.valid?

    doc = ComDocument.new(base_attrs.merge(response_mode: "redirect", redirect_url: "https://example.com"))
    assert_predicate doc, :valid?
  end

  test "latest_version returns the newest version by created_at" do
    doc = ComDocument.create!(base_attrs.merge(permalink: "versioned"))

    ComDocumentVersion.create!(
      com_document: doc,
      permalink: doc.permalink,
      response_mode: doc.response_mode,
      published_at: doc.published_at,
      expires_at: doc.expires_at,
      created_at: 2.days.ago,
      updated_at: 2.days.ago,
    )

    newest = ComDocumentVersion.create!(
      com_document: doc,
      permalink: doc.permalink,
      response_mode: doc.response_mode,
      published_at: doc.published_at,
      expires_at: doc.expires_at,
      created_at: 1.day.ago,
      updated_at: 1.day.ago,
    )

    assert_equal newest, doc.latest_version
  end

  test "permalink is required and must not be empty" do
    doc = ComDocument.new(base_attrs.merge(permalink: nil))
    assert_not doc.valid?
    doc = ComDocument.new(base_attrs.merge(permalink: ""))
    assert_not doc.valid?
    doc = ComDocument.new(base_attrs.merge(permalink: "   "))
    assert_not doc.valid?
  end

  test "published_at must be before expires_at" do
    doc = ComDocument.new(base_attrs.merge(published_at: 1.day.from_now, expires_at: 1.day.ago))
    assert_not doc.valid?
    assert_not_empty doc.errors[:published_at]
  end

  test "revision_key is ensured before validation" do
    doc = ComDocument.new(base_attrs.merge(revision_key: nil))
    assert_predicate doc, :valid?
    assert_not_nil doc.revision_key
  end

  test "association deletion: destroys dependent versions" do
    doc = ComDocument.create!(base_attrs.merge(permalink: "delete_test"))
    version = ComDocumentVersion.create!(
      com_document: doc,
      permalink: doc.permalink,
      response_mode: doc.response_mode,
      published_at: doc.published_at,
      expires_at: doc.expires_at,
    )
    doc.destroy
    assert_raise(ActiveRecord::RecordNotFound) { version.reload }
  end
end
