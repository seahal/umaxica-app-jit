# == Schema Information
#
# Table name: com_preference_language_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

class ComPreferenceLanguageOption < PreferenceRecord
  self.primary_key = :id

  has_many :com_preference_languages,
           class_name: "ComPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
