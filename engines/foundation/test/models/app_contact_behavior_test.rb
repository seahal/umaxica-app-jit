# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_behaviors
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
#  index_app_contact_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_app_contact_behaviors_on_event_id                     (event_id)
#  index_app_contact_behaviors_on_level_id                     (level_id)
#  index_app_contact_behaviors_on_subject_id                   (subject_id)
#  index_app_contact_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => app_contact_behavior_events.id)
#  fk_rails_...  (level_id => app_contact_behavior_levels.id)
#

require "test_helper"

class AppContactBehaviorTest < ActiveSupport::TestCase
  fixtures :app_contact_categories, :app_contact_statuses

  setup do
    AppContactBehaviorEvent.ensure_defaults!
    AppContactBehaviorLevel.ensure_defaults!
  end

  test "loads model and associations" do
    assert_equal "app_contact_behaviors", AppContactBehavior.table_name

    refl = AppContactBehavior.reflect_on_association(:app_contact)

    assert_not_nil refl, "expected belongs_to :app_contact association"
    assert_equal :belongs_to, refl.macro

    refl_level = AppContactBehavior.reflect_on_association(:app_contact_behavior_level)

    assert_not_nil refl_level, "expected belongs_to :app_contact_behavior_level association"
    assert_equal :belongs_to, refl_level.macro
  end

  test "validates subject_id presence" do
    behavior = AppContactBehavior.new(
      subject_type: "AppContact",
      event_id: AppContactBehaviorEvent::SUBMITTED,
      level_id: AppContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_predicate behavior.errors[:subject_id], :any?
  end

  test "validates subject_type presence" do
    behavior = AppContactBehavior.new(
      subject_id: 123,
      event_id: AppContactBehaviorEvent::SUBMITTED,
      level_id: AppContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_predicate behavior.errors[:subject_type], :any?
  end

  test "app_contact helper method returns nil when subject_type is not AppContact" do
    behavior = AppContactBehavior.new(
      subject_id: 123,
      subject_type: "SomeOtherType",
      event_id: AppContactBehaviorEvent::SUBMITTED,
      level_id: AppContactBehaviorLevel::NOTHING,
    )

    assert_nil behavior.app_contact
  end

  test "app_contact helper method resolves when subject_type is AppContact" do
    contact = AppContact.create!(
      confirm_policy: "1",
      category_id: AppContactCategory::APPLICATION_INQUIRY,
      status_id: AppContactStatus::NOTHING,
    )
    behavior = AppContactBehavior.create!(
      subject_id: contact.id,
      subject_type: "AppContact",
      event_id: AppContactBehaviorEvent::SUBMITTED,
      level_id: AppContactBehaviorLevel::NOTHING,
    )

    assert_equal contact, behavior.app_contact
  end

  test "app_contact= helper method sets subject_id and subject_type" do
    test_id = 123

    contact = AppContact.new
    contact.define_singleton_method(:id) { test_id }

    behavior = AppContactBehavior.new
    behavior.app_contact = contact

    assert_equal test_id, behavior.subject_id
    assert_equal "AppContact", behavior.subject_type
  end

  test "rejects unknown event_id before database foreign key enforcement" do
    behavior = AppContactBehavior.new(
      subject_id: 123,
      subject_type: "AppContact",
      event_id: 999_999,
      level_id: AppContactBehaviorLevel::NOTHING,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:event_id], "must reference an existing app_contact_behavior_event"
  end

  test "rejects unknown level_id before database foreign key enforcement" do
    behavior = AppContactBehavior.new(
      subject_id: 123,
      subject_type: "AppContact",
      event_id: AppContactBehaviorEvent::SUBMITTED,
      level_id: 999_999,
    )

    assert_not behavior.valid?
    assert_includes behavior.errors[:level_id], "must reference an existing app_contact_behavior_level"
  end
end
