# == Schema Information
#
# Table name: com_document_versions
#
#  id              :uuid             not null, primary key
#  com_document_id :uuid             not null
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
#  index_com_document_versions_on_com_document_id_and_created_at  (com_document_id,created_at)
#  index_com_document_versions_on_public_id                       (public_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class ComDocumentVersionTest < ActiveSupport::TestCase
  test "includes Version concern" do
    assert_includes ComDocumentVersion.included_modules, Version
  end

  test "encrypts title, description, and body" do
    record = ComDocumentVersion.create!(
      com_document: com_documents(:one),
      permalink: "permalink_#{SecureRandom.hex(4)}",
      response_mode: "html",
      published_at: Time.zone.parse("2999-01-01 00:00:00"),
      expires_at: Time.zone.parse("2999-12-31 00:00:00"),
      title: "Secret title",
      description: "Secret description",
      body: "Secret body",
    )

    raw_data = ComDocumentVersion.connection.execute(
      "SELECT title, description, body FROM com_document_versions WHERE id = '#{record.id}'",
    ).first

    assert_not_equal "Secret title", raw_data["title"] if raw_data
    assert_not_equal "Secret description", raw_data["description"] if raw_data
    assert_not_equal "Secret body", raw_data["body"] if raw_data
  end

  test "generates public_id on create" do
    version = ComDocumentVersion.create!(
      com_document: com_documents(:one),
      permalink: "test_#{SecureRandom.hex(4)}",
      response_mode: "html",
      title: "Test",
      body: "Test body",
      published_at: Time.current,
      expires_at: 100.years.from_now,
      edited_by_type: "Staff",
    )

    assert_not_nil version.public_id
    assert_equal 21, version.public_id.length
  end

  test "validates public_id uniqueness" do
    version1 = ComDocumentVersion.create!(
      com_document: com_documents(:one),
      permalink: "test_#{SecureRandom.hex(4)}",
      response_mode: "html",
      title: "Test 1",
      body: "Test body 1",
      published_at: Time.current,
      expires_at: 100.years.from_now,
      edited_by_type: "Staff",
    )

    version2 = ComDocumentVersion.new(
      com_document: com_documents(:one),
      permalink: "test_#{SecureRandom.hex(4)}",
      response_mode: "html",
      title: "Test 2",
      body: "Test body 2",
      published_at: Time.current,
      expires_at: 100.years.from_now,
      edited_by_type: "Staff",
      public_id: version1.public_id,
    )

    assert_not version2.valid?
    assert_includes version2.errors[:public_id], "はすでに存在します"
  end

  test "validates public_id length" do
    version = ComDocumentVersion.new(
      com_document: com_documents(:one),
      permalink: "test_#{SecureRandom.hex(4)}",
      response_mode: "html",
      title: "Test",
      body: "Test body",
      published_at: Time.current,
      expires_at: 100.years.from_now,
      edited_by_type: "Staff",
      public_id: "a" * 22,
    )

    assert_not version.valid?
    assert_includes version.errors[:public_id], "は21文字以内で入力してください"
  end
end
