# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_levels
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_document_audit_levels_on_code  (code) UNIQUE
#

require "test_helper"

class AppDocumentAuditLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = AppDocumentAuditLevel.find("NEYO")
    doc = AppDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: "NEYO",
    )

    AppDocumentAudit.create!(
      app_document: doc,
      app_document_audit_event: AppDocumentAuditEvent.find("CREATED"),
      app_document_audit_level: level,
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

  test "validates length of id" do
    record = AppDocumentAuditLevel.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
