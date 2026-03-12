# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_binding_methods
# Database name: preference
#
#  id :bigint           not null, primary key
#
class OrgPreferenceBindingMethod < PreferenceRecord
  NOTHING = 0
  DBSC = 1
  LEGACY = 2
  DEFAULTS = [NOTHING, DBSC, LEGACY].freeze

  has_many :org_preferences,
           foreign_key: :binding_method_id,
           inverse_of: :org_preference_binding_method,
           dependent: :restrict_with_error

  def self.ensure_defaults!
    existing_ids = where(id: DEFAULTS).pluck(:id)
    missing_ids = DEFAULTS - existing_ids
    return if missing_ids.empty?

    if defined?(Prosopite)
      Prosopite.pause { missing_ids.each { |id| create!(id: id) } }
    else
      missing_ids.each { |id| create!(id: id) }
    end
  end
end
