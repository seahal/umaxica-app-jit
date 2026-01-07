# == Schema Information
#
# Table name: org_preference_colortheme_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

class OrgPreferenceColorthemeOption < PreferenceRecord
  has_many :org_preference_colorthemes,
           class_name: "OrgPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
end
