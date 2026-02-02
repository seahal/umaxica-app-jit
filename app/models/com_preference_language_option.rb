# == Schema Information
#
# Table name: com_preference_language_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_preference_language_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class ComPreferenceLanguageOption < PreferenceRecord
  include CodeIdentifiable

  has_many :com_preference_languages,
           class_name: "ComPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  self.primary_key = :id
end
