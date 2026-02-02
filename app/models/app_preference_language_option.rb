# == Schema Information
#
# Table name: app_preference_language_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_preference_language_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class AppPreferenceLanguageOption < PreferenceRecord
  include CodeIdentifiable

  has_many :app_preference_languages,
           class_name: "AppPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  self.primary_key = :id
end
