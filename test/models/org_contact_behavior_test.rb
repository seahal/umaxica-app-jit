# typed: false
# frozen_string_literal: true

require "test_helper"

class OrgContactBehaviorTest < ActiveSupport::TestCase
  fixtures :org_contacts, :org_contact_behavior_levels, :org_contact_behavior_events

  test "org_contact getter returns contact when subject_type is OrgContact" do
    contact = org_contacts(:one)
    behavior = OrgContactBehavior.create!(
      subject_type: "OrgContact",
      subject_id: contact.id,
      event_id: OrgContactBehaviorEvent::NOTHING,
      level_id: OrgContactBehaviorLevel::NOTHING,
    )

    assert_equal contact, behavior.org_contact
  end

  test "org_contact getter returns nil when subject_type is not OrgContact" do
    behavior = OrgContactBehavior.create!(
      subject_type: "OtherModel",
      subject_id: 123,
      event_id: OrgContactBehaviorEvent::NOTHING,
      level_id: OrgContactBehaviorLevel::NOTHING,
    )

    assert_nil behavior.org_contact
  end

  test "org_contact= setter sets subject_id and subject_type" do
    contact = org_contacts(:one)
    behavior = OrgContactBehavior.new

    behavior.org_contact = contact

    assert_equal contact.id, behavior.subject_id
    assert_equal "OrgContact", behavior.subject_type
  end
end
