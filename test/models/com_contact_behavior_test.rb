# typed: false
# frozen_string_literal: true

require "test_helper"

class ComContactBehaviorTest < ActiveSupport::TestCase
  fixtures :com_contacts, :com_contact_behavior_levels, :com_contact_behavior_events

  test "com_contact getter returns contact when subject_type is ComContact" do
    contact = com_contacts(:one)
    behavior = ComContactBehavior.create!(
      subject_type: "ComContact",
      subject_id: contact.id,
      event_id: ComContactBehaviorEvent::NOTHING,
      level_id: ComContactBehaviorLevel::NOTHING,
    )

    assert_equal contact, behavior.com_contact
  end

  test "com_contact getter returns nil when subject_type is not ComContact" do
    behavior = ComContactBehavior.create!(
      subject_type: "OtherModel",
      subject_id: 123,
      event_id: ComContactBehaviorEvent::NOTHING,
      level_id: ComContactBehaviorLevel::NOTHING,
    )

    assert_nil behavior.com_contact
  end

  test "com_contact= setter sets subject_id and subject_type" do
    contact = com_contacts(:one)
    behavior = ComContactBehavior.new

    behavior.com_contact = contact

    assert_equal contact.id, behavior.subject_id
    assert_equal "ComContact", behavior.subject_type
  end
end
