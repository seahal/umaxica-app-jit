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
#  published_at  :datetime         not null
#  expires_at    :datetime         not null
#  position      :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require "test_helper"

class OrgDocumentUpdaterTest < ActiveSupport::TestCase
  fixtures :org_document_statuses

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

  test "call always creates a new version" do
    document = OrgDocument.create!(base_attrs.merge(permalink: "updatable"))

    attrs = {
      permalink: "updatable",
      response_mode: "html",
      published_at: document.published_at,
      expires_at: document.expires_at,
      position: 1,
      title: "Title",
      description: "Description",
      body: "Body",
    }

    assert_difference "OrgDocumentVersion.count", 1 do
      OrgDocumentUpdater.call(document: document, attrs: attrs)
    end
  end
end
