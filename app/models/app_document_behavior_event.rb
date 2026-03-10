# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

class AppDocumentBehaviorEvent < BehaviorRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 0
  CREATED = 1
  DEFAULTS = [NOTHING, CREATED].freeze

  # Placeholder for audit event types; ids are integer constants (e.g., CREATED = 1)
  has_many :app_document_behaviors,
           class_name: "AppDocumentBehavior",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_document_behavior_event,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    return if DEFAULTS.blank?

    existing_ids = where(id: DEFAULTS).pluck(:id)
    missing_ids = DEFAULTS - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end
end
