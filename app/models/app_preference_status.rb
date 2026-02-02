# == Schema Information
#
# Table name: app_preference_statuses
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_preference_statuses_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class AppPreferenceStatus < PreferenceRecord
  include CodeIdentifiable

  has_many :app_preferences,
           class_name: "AppPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :app_preference_status,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }
end
