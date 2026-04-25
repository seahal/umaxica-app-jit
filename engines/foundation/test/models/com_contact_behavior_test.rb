# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_behaviors
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
#  index_com_contact_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_com_contact_behaviors_on_event_id                     (event_id)
#  index_com_contact_behaviors_on_level_id                     (level_id)
#  index_com_contact_behaviors_on_subject_id                   (subject_id)
#  index_com_contact_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => com_contact_behavior_events.id)
#  fk_rails_...  (level_id => com_contact_behavior_levels.id)
#

require "test_helper"

class ComContactBehaviorTest < ActiveSupport::TestCase
  fixtures :com_contact_categories, :com_contact_statuses

  setup do
    ComContactBehaviorEvent.ensure_defaults!
    ComContactBehaviorLevel.ensure_defaults!
  end

  test "loads model and associations" do
    assert_equal "com_contact_behaviors", ComContactBehavior.table_name

    refl = ComContactBehavior.reflect_on_association(:com_contact)

    assert_not_nil refl, "expected belongs_to :com_contact association"
    assert_equal :belongs_to, refl.macro

    refl_level = ComContactBehavior.reflect_on_association(:com_contact_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :com_contact_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "validates subject_id presence" do
    behavior = ComContactBehavior.new(
      subject_type: "ComContact",
      event_id: ComContactBehaviorEvent::SUBMITTED,
      level_id: ComContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_predicate behavior.errors[:subject_id], :any?
  end

  test "validates subject_type presence" do
    behavior = ComContactBehavior.new(
      subject_id: 123,
      event_id: ComContactBehaviorEvent::SUBMITTED,
      level_id: ComContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_predicate behavior.errors[:subject_type], :any?
  end

  test "com_contact helper method returns nil when subject_type is not ComContact" do
    behavior = ComContactBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      event_id: ComContactBehaviorEvent::SUBMITTED,
      level_id: ComContactBehaviorLevel::NOTHING,
    )

    assert_nil behavior.com_contact
  end

  test "com_contact helper method resolves when subject_type is ComContact" do
    contact = ComContact.create!(
      confirm_policy: "1",
      category_id: ComContactCategory::SECURITY_ISSUE,
      status_id: ComContactStatus::NOTHING,
    )
    behavior = ComContactBehavior.create!(
      subject_id: contact.id,
      subject_type: "ComContact",
      event_id: ComContactBehaviorEvent::SUBMITTED,
      level_id: ComContactBehaviorLevel::NOTHING,
    )

    assert_equal contact, behavior.com_contact
  end

  test "com_contact= helper method sets subject_id and subject_type" do
    test_id = 123

    contact = ComContact.new
    contact.define_singleton_method(:id) { test_id }

    behavior = ComContactBehavior.new
    behavior.com_contact = contact

    assert_equal test_id, behavior.subject_id
    assert_equal "ComContact", behavior.subject_type
  end

  test "rejects unknown event_id before database foreign key enforcement" do
    behavior = ComContactBehavior.new(
      subject_id: 123,
      subject_type: "ComContact",
      event_id: 999_999,
      level_id: ComContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:event_id], "must reference an existing com_contact_behavior_event"
  end

  test "rejects unknown level_id before database foreign key enforcement" do
    behavior = ComContactBehavior.new(
      subject_id: 123,
      subject_type: "ComContact",
      event_id: ComContactBehaviorEvent::SUBMITTED,
      level_id: 999_999,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:level_id], "must reference an existing com_contact_behavior_level"
  end
end
