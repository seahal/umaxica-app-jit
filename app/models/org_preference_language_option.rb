# == Schema Information
#
# Table name: org_preference_language_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_preference_language_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceLanguageOption < PreferenceRecord
  include CodeIdentifiable

  has_many :org_preference_languages,
           class_name: "OrgPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }

  self.primary_key = :id
end
