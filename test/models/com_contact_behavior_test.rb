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
