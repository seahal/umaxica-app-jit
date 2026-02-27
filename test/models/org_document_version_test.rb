# typed: false
# == Schema Information
#
# Table name: org_document_versions
# Database name: document
#
#  id              :bigint           not null, primary key
#  body            :text
#  description     :string
#  edited_by_type  :string
#  expires_at      :datetime         not null
#  permalink       :string(200)      not null
#  published_at    :datetime         not null
#  redirect_url    :string
#  response_mode   :string           not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  edited_by_id    :bigint
#  org_document_id :bigint           not null
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_org_document_versions_on_edited_by_id                    (edited_by_id)
#  index_org_document_versions_on_org_document_id_and_created_at  (org_document_id,created_at)
#  index_org_document_versions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_document_id => org_documents.id) ON DELETE => cascade
#

# frozen_string_literal: true

require "test_helper"

class OrgDocumentVersionTest < ActiveSupport::TestCase
  fixtures :org_documents, :org_document_statuses

  test "includes Version concern" do
    assert_includes OrgDocumentVersion.included_modules, Version
  end

  test "encrypts title, description, and body" do
    record = OrgDocumentVersion.create!(
      org_document: OrgDocument.find_by!(slug_id: "org-documents-0000001"),
      permalink: "permalink_#{SecureRandom.hex(4)}",
      response_mode: "html",
      published_at: Time.zone.parse("2999-01-01 00:00:00"),
      expires_at: Time.zone.parse("2999-12-31 00:00:00"),
      title: "Secret title",
      description: "Secret description",
      body: "Secret body",
    )

    raw_data = OrgDocumentVersion.connection.execute(
      "SELECT title, description, body FROM org_document_versions WHERE id = '#{record.id}'",
    ).first

    assert_not_equal "Secret title", raw_data["title"] if raw_data
    assert_not_equal "Secret description", raw_data["description"] if raw_data
    assert_not_equal "Secret body", raw_data["body"] if raw_data
  end
end
