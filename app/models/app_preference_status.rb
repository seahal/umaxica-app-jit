# typed: false
# == Schema Information
#
# Table name: app_preference_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceStatus < PrincipalRecord
  # Fixed IDs - do not modify these values
  DELETED = 1
  NOTHING = 2 # FIXME: set 0 as null value
  has_many :app_preferences,
           class_name: "AppPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :app_preference_status,
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
