# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgContactBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :org_contact_categories, :org_contact_statuses

  setup do
    OrgContactBehaviorLevel.ensure_defaults!
    OrgContactBehaviorEvent.ensure_defaults!
  end

  test "has NOTHING constant" do
    assert_equal 0, OrgContactBehaviorLevel::NOTHING
  end

  test "can load nothing level from db" do
    level = OrgContactBehaviorLevel.find(OrgContactBehaviorLevel::NOTHING)

    assert_equal 0, level.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "OrgContactBehaviorLevel.count" do
      OrgContactBehaviorLevel.ensure_defaults!
    end
  end

  test "restrict_with_error on destroy when behaviors exist" do
    level = OrgContactBehaviorLevel.find(OrgContactBehaviorLevel::NOTHING)
    contact = OrgContact.create!(
      confirm_policy: "1",
      category_id: OrgContactCategory::ORGANIZATION_INQUIRY,
      status_id: OrgContactStatus::NOTHING,
    )

    OrgContactBehavior.create!(
      subject_id: contact.id,
      subject_type: "OrgContact",
      org_contact_behavior_event: OrgContactBehaviorEvent.find(OrgContactBehaviorEvent::SUBMITTED),
      org_contact_behavior_level: level,
    )

    assert_no_difference "OrgContactBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    expected_message = I18n.t(
      "activerecord.errors.messages.restrict_dependent_destroy.has_many",
      record: "org contact behaviors",
    )

    assert_equal expected_message, level.errors[:base].first
  end

  test "can destroy when no behaviors exist" do
    level = OrgContactBehaviorLevel.create!(id: 99)

    assert_difference "OrgContactBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = OrgContactBehaviorLevel.new(id: 100)

    assert_predicate record, :valid?
  end
end
