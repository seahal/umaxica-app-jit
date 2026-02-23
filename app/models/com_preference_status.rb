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
  NEYO = 2

  has_many :com_preferences,
           class_name: "ComPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :com_preference_status,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:id) }

  def self.ensure_defaults!
    find_or_create_by!(id: DELETED)
    find_or_create_by!(id: NEYO)
  end
end
