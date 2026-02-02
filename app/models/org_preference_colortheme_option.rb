# == Schema Information
#
# Table name: org_preference_colortheme_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_preference_colortheme_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceColorthemeOption < PreferenceRecord
  include CodeIdentifiable

  has_many :org_preference_colorthemes,
           class_name: "OrgPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }
end
