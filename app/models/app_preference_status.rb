# == Schema Information
#
# Table name: app_preference_statuses
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class AppPreferenceStatus < PreferenceRecord
  include StringPrimaryKey

  has_many :app_preferences,
           class_name: "AppPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :app_preference_status,
           dependent: :restrict_with_error
end
