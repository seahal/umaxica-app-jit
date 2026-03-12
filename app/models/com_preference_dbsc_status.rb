# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_dbsc_statuses
# Database name: preference
#
#  id :bigint           not null, primary key
#
class ComPreferenceDbscStatus < PreferenceRecord
  NOTHING = 0
  PENDING = 1
  ACTIVE = 2
  FAILED = 3
  REVOKE = 4
  DEFAULTS = [NOTHING, PENDING, ACTIVE, FAILED, REVOKE].freeze

  has_many :com_preferences,
           foreign_key: :dbsc_status_id,
           inverse_of: :com_preference_dbsc_status,
           dependent: :restrict_with_error

  def self.ensure_defaults!
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
