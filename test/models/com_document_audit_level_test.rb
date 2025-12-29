# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class ComDocumentAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = com_document_audit_levels(:none)
    doc = ComDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: "NEYO",
    )

    ComDocumentAudit.create!(
      com_document: doc,
      com_document_audit_event: com_document_audit_events(:CREATED),
      com_document_audit_level: level,
    )

    assert_no_difference "ComDocumentAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "com document auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = ComDocumentAuditLevel.create!(id: "UNUSED")

    assert_difference "ComDocumentAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
