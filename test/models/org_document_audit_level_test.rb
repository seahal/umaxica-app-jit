# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class OrgDocumentAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = org_document_audit_levels(:none)
    doc = OrgDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: "NEYO",
    )

    OrgDocumentAudit.create!(
      org_document: doc,
      org_document_audit_event: org_document_audit_events(:created),
      org_document_audit_level: level,
    )

    assert_no_difference "OrgDocumentAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "org document auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = OrgDocumentAuditLevel.create!(id: "UNUSED")

    assert_difference "OrgDocumentAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
