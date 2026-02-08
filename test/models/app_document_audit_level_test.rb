# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppDocumentAuditLevelTest < ActiveSupport::TestCase
  fixtures :app_document_audit_levels, :app_document_audit_events, :app_document_statuses

  test "restrict_with_error on destroy when audits exist" do
    level = AppDocumentAuditLevel.find(AppDocumentAuditLevel::NEYO)
    doc = AppDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: AppDocumentStatus::NEYO,
    )

    AppDocumentAudit.create!(
      app_document: doc,
      app_document_audit_event: AppDocumentAuditEvent.find(AppDocumentAuditEvent::CREATED),
      app_document_audit_level: level,
    )

    assert_no_difference "AppDocumentAuditLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "app document auditsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = AppDocumentAuditLevel.create!(id: 2)

    assert_difference "AppDocumentAuditLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = AppDocumentAuditLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
