# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppContactBehaviorLevelTest < ActiveSupport::TestCase
  fixtures :app_contact_categories, :app_contact_statuses

  setup do
    AppContactBehaviorLevel.ensure_defaults!
    AppContactBehaviorEvent.ensure_defaults!
  end

  test "has NOTHING constant" do
    assert_equal 0, AppContactBehaviorLevel::NOTHING
  end

  test "can load nothing level from db" do
    level = AppContactBehaviorLevel.find(AppContactBehaviorLevel::NOTHING)

    assert_equal 0, level.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "AppContactBehaviorLevel.count" do
      AppContactBehaviorLevel.ensure_defaults!
    end
  end

  test "restrict_with_error on destroy when behaviors exist" do
    level = AppContactBehaviorLevel.find(AppContactBehaviorLevel::NOTHING)
    contact = AppContact.create!(
      confirm_policy: "1",
      category_id: AppContactCategory::APPLICATION_INQUIRY,
      status_id: AppContactStatus::NOTHING,
    )

    AppContactBehavior.create!(
      subject_id: contact.id,
      subject_type: "AppContact",
      app_contact_behavior_event: AppContactBehaviorEvent.find(AppContactBehaviorEvent::SUBMITTED),
      app_contact_behavior_level: level,
    )

    assert_no_difference "AppContactBehaviorLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    expected_message = I18n.t(
      "activerecord.errors.messages.restrict_dependent_destroy.has_many",
      record: "app contact behaviors",
    )

    assert_equal expected_message, level.errors[:base].first
  end

  test "can destroy when no behaviors exist" do
    level = AppContactBehaviorLevel.create!(id: 99)

    assert_difference "AppContactBehaviorLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = AppContactBehaviorLevel.new(id: 100)

    assert_predicate record, :valid?
  end
end
