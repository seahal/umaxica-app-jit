# == Schema Information
#
# Table name: org_preference_statuses
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceStatus < PreferenceRecord
  # Fixed IDs - do not modify these values
  DELETED = 1
  NEYO = 2

  has_many :org_preferences,
           class_name: "OrgPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :org_preference_status,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:id) }
end
