# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#
class OrgContactBehaviorEvent < BehaviorRecord
  self.record_timestamps = false

  NOTHING = 1
  CREATED = 2
  UPDATED = 3
  DELETED = 4

  has_many :org_contact_behaviors,
           class_name: "OrgContactBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_contact_behavior_event,
           dependent: :restrict_with_error
end
