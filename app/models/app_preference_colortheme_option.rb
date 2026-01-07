# == Schema Information
#
# Table name: app_preference_colortheme_options
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceColorthemeOption < PreferenceRecord
  self.primary_key = :id

  has_many :app_preference_colorthemes,
           class_name: "AppPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
