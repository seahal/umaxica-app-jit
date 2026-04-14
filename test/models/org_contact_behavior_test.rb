# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_behaviors
# Database name: behavior
#
#  id           :bigint           not null, primary key
#  actor_type   :string
#  expires_at   :datetime
#  occurred_at  :datetime
#  subject_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  actor_id     :bigint
#  event_id     :bigint           not null
#  level_id     :bigint           not null
#  subject_id   :bigint           not null
#
# Indexes
#
#  index_org_contact_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_org_contact_behaviors_on_event_id                     (event_id)
#  index_org_contact_behaviors_on_level_id                     (level_id)
#  index_org_contact_behaviors_on_subject_id                   (subject_id)
#  index_org_contact_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => org_contact_behavior_events.id)
#  fk_rails_...  (level_id => org_contact_behavior_levels.id)
#

require "test_helper"

class OrgContactBehaviorTest < ActiveSupport::TestCase
  fixtures :org_contact_categories, :org_contact_statuses

  setup do
    OrgContactBehaviorEvent.ensure_defaults!
    OrgContactBehaviorLevel.ensure_defaults!
  end

  test "loads model and associations" do
    assert_equal "org_contact_behaviors", OrgContactBehavior.table_name

    refl = OrgContactBehavior.reflect_on_association(:org_contact)

    assert_not_nil refl, "expected belongs_to :org_contact association"
    assert_equal :belongs_to, refl.macro

    refl_level = OrgContactBehavior.reflect_on_association(:org_contact_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :org_contact_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "validates subject_id presence" do
    behavior = OrgContactBehavior.new(
      subject_type: "OrgContact",
      event_id: OrgContactBehaviorEvent::SUBMITTED,
      level_id: OrgContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_predicate behavior.errors[:subject_id], :any?
  end

  test "validates subject_type presence" do
    behavior = OrgContactBehavior.new(
      subject_id: 123,
      event_id: OrgContactBehaviorEvent::SUBMITTED,
      level_id: OrgContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_predicate behavior.errors[:subject_type], :any?
  end

  test "org_contact helper method returns nil when subject_type is not OrgContact" do
    behavior = OrgContactBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      event_id: OrgContactBehaviorEvent::SUBMITTED,
      level_id: OrgContactBehaviorLevel::NOTHING,
    )

    assert_nil behavior.org_contact
  end

  test "org_contact helper method resolves when subject_type is OrgContact" do
    contact = OrgContact.create!(
      confirm_policy: "1",
      category_id: OrgContactCategory::ORGANIZATION_INQUIRY,
      status_id: OrgContactStatus::NOTHING,
    )
    behavior = OrgContactBehavior.create!(
      subject_id: contact.id,
      subject_type: "OrgContact",
      event_id: OrgContactBehaviorEvent::SUBMITTED,
      level_id: OrgContactBehaviorLevel::NOTHING,
    )

    assert_equal contact, behavior.org_contact
  end

  test "org_contact= helper method sets subject_id and subject_type" do
    test_id = 123

    contact = OrgContact.new
    contact.define_singleton_method(:id) { test_id }

    behavior = OrgContactBehavior.new
    behavior.org_contact = contact

    assert_equal test_id, behavior.subject_id
    assert_equal "OrgContact", behavior.subject_type
  end

  test "rejects unknown event_id before database foreign key enforcement" do
    behavior = OrgContactBehavior.new(
      subject_id: 123,
      subject_type: "OrgContact",
      event_id: 999_999,
      level_id: OrgContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:event_id], "must reference an existing org_contact_behavior_event"
  end

  test "rejects unknown level_id before database foreign key enforcement" do
    behavior = OrgContactBehavior.new(
      subject_id: 123,
      subject_type: "OrgContact",
      event_id: OrgContactBehaviorEvent::SUBMITTED,
      level_id: 999_999,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:level_id], "must reference an existing org_contact_behavior_level"
  end
end
