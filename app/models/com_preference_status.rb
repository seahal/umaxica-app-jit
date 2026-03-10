# typed: false
# == Schema Information
#
# Table name: com_preference_statuses
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class ComPreferenceStatus < PreferenceRecord
  # Fixed IDs - do not modify these values
  DELETED = 1
  NOTHING = 2
  has_many :com_preferences,
           class_name: "ComPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :com_preference_status,
           dependent: :restrict_with_error

  DEFAULTS = [DELETED, NOTHING].freeze

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
