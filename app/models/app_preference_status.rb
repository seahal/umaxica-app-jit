# typed: false
# == Schema Information
#
# Table name: app_preference_statuses
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceStatus < PreferenceRecord
  # Fixed IDs - do not modify these values
  DELETED = 1
  NOTHING = 2
  has_many :app_preferences,
           class_name: "AppPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :app_preference_status,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    find_or_create_by!(id: DELETED)
    find_or_create_by!(id: NOTHING)
  end
end
