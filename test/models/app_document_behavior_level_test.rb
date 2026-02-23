# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppDocumentBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :app_document_behavior_levels, :app_document_behavior_events, :app_document_statuses

  test "restrict_with_error on destroy when audits exist" do
    level = AppDocumentBehaviorLevel.find(AppDocumentBehaviorLevel::NEYO)
    doc = AppDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: AppDocumentStatus::NEYO,
    )

    AppDocumentBehavior.create!(
      app_document: doc,
      app_document_behavior_event: AppDocumentBehaviorEvent.find(AppDocumentBehaviorEvent::CREATED),
      app_document_behavior_level: level,
    )

    assert_no_difference "AppDocumentBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "app document behaviorsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = AppDocumentBehaviorLevel.create!(id: 2)

    assert_difference "AppDocumentBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = AppDocumentBehaviorLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
