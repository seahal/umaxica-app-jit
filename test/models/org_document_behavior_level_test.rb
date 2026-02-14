# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgDocumentBehaviorLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = OrgDocumentBehaviorLevel.find(OrgDocumentBehaviorLevel::NEYO)
    doc = OrgDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: OrgDocumentStatus::NEYO,
    )

    OrgDocumentBehavior.create!(
      org_document: doc,
      org_document_behavior_event: OrgDocumentBehaviorEvent.find(OrgDocumentBehaviorEvent::CREATED),
      org_document_behavior_level: level,
    )

    assert_no_difference "OrgDocumentBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "org document behaviorsが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = OrgDocumentBehaviorLevel.create!(id: 2)

    assert_difference "OrgDocumentBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = OrgDocumentBehaviorLevel.new(id: 3)
    assert_predicate record, :valid?
  end
end
