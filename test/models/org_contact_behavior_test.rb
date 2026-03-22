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
