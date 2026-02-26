# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComDocumentBehaviorLevelTest < ActiveSupport::TestCase
  test "restrict_with_error on destroy when audits exist" do
    level = ComDocumentBehaviorLevel.find(ComDocumentBehaviorLevel::NOTHING)
    doc = ComDocument.create!(
      permalink: "audit_doc",
      response_mode: "html",
      published_at: 1.hour.ago,
      expires_at: 1.hour.from_now,
      position: 0,
      revision_key: "rev_key",
      status_id: ComDocumentStatus::NOTHING,
    )

    ComDocumentBehavior.create!(
      com_document: doc,
      com_document_behavior_event: ComDocumentBehaviorEvent.find(ComDocumentBehaviorEvent::CREATED),
      com_document_behavior_level: level,
    )

    assert_no_difference "ComDocumentBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    expected_message = I18n.t(
      "activerecord.errors.messages.restrict_dependent_destroy.has_many",
      record: "com document behaviors",
    )

    assert_equal expected_message, level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = ComDocumentBehaviorLevel.create!(id: 2)

    assert_difference "ComDocumentBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = ComDocumentBehaviorLevel.new(id: 3)

    assert_predicate record, :valid?
  end
end
