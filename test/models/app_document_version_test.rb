# == Schema Information
#
# Table name: app_document_versions
#
#  id              :uuid             not null, primary key
#  app_document_id :uuid             not null
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
#  index_app_document_versions_on_app_document_id_and_created_at  (app_document_id,created_at)
#  index_app_document_versions_on_public_id                       (public_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class AppDocumentVersionTest < ActiveSupport::TestCase
  test "includes Version concern" do
    assert_includes AppDocumentVersion.included_modules, Version
  end

  test "encrypts title, description, and body" do
    record = AppDocumentVersion.create!(
      app_document: app_documents(:one),
      permalink: "permalink_#{SecureRandom.hex(4)}",
      response_mode: "html",
      published_at: Time.zone.parse("2999-01-01 00:00:00"),
      expires_at: Time.zone.parse("2999-12-31 00:00:00"),
      title: "Secret title",
      description: "Secret description",
      body: "Secret body",
    )

    raw_data = AppDocumentVersion.connection.execute(
      "SELECT title, description, body FROM app_document_versions WHERE id = '#{record.id}'",
    ).first

    assert_not_equal "Secret title", raw_data["title"] if raw_data
    assert_not_equal "Secret description", raw_data["description"] if raw_data
    assert_not_equal "Secret body", raw_data["body"] if raw_data
  end
end
