# == Schema Information
#
# Table name: com_preference_statuses
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_preference_statuses_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class ComPreferenceStatus < PreferenceRecord
  include CodeIdentifiable

  has_many :com_preferences,
           class_name: "ComPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :com_preference_status,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  before_validation { self.id = id&.upcase }
end
