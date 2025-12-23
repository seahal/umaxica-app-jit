require "test_helper"

class ComDocumentAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = com_document_audit_levels(:none)
    doc = ComDocument.new
    doc.save!(validate: false)

    ComDocumentAudit.create!(
      com_document: doc,
      com_document_audit_event: com_document_audit_events(:CREATED),
      com_document_audit_level: level
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
