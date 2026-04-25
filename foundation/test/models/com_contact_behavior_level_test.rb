# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComContactBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :com_contact_categories, :com_contact_statuses

  setup do
    ComContactBehaviorLevel.ensure_defaults!
    ComContactBehaviorEvent.ensure_defaults!
  end

  test "has NOTHING constant" do
    assert_equal 0, ComContactBehaviorLevel::NOTHING
  end

  test "can load nothing level from db" do
    level = ComContactBehaviorLevel.find(ComContactBehaviorLevel::NOTHING)

    assert_equal 0, level.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "ComContactBehaviorLevel.count" do
      ComContactBehaviorLevel.ensure_defaults!
    end
  end

  test "restrict_with_error on destroy when behaviors exist" do
    level = ComContactBehaviorLevel.find(ComContactBehaviorLevel::NOTHING)
    contact = ComContact.create!(
      confirm_policy: "1",
      category_id: ComContactCategory::SECURITY_ISSUE,
      status_id: ComContactStatus::NOTHING,
    )

    ComContactBehavior.create!(
      subject_id: contact.id,
      subject_type: "ComContact",
      com_contact_behavior_event: ComContactBehaviorEvent.find(ComContactBehaviorEvent::SUBMITTED),
      com_contact_behavior_level: level,
    )

    assert_no_difference "ComContactBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    expected_message = I18n.t(
      "activerecord.errors.messages.restrict_dependent_destroy.has_many",
      record: "com contact behaviors",
    )

    assert_equal expected_message, level.errors[:base].first
  end

  test "can destroy when no behaviors exist" do
    level = ComContactBehaviorLevel.create!(id: 99)

    assert_difference "ComContactBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = ComContactBehaviorLevel.new(id: 100)

    assert_predicate record, :valid?
  end
end
