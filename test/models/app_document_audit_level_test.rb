# == Schema Information
#
# Table name: app_document_audit_levels
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class AppDocumentAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = app_document_audit_levels(:none)
    doc = AppDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key"
    )

    AppDocumentAudit.create!(
      app_document: doc,
      app_document_audit_event: app_document_audit_events(:CREATED),
      app_document_audit_level: level
    )

    assert_no_difference "AppDocumentAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "app document auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = AppDocumentAuditLevel.create!(id: "UNUSED")

    assert_difference "AppDocumentAuditLevel.count", -1 do
      assert level.destroy
    end
  end
end
