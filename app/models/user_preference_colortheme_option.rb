# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preference_colortheme_options
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserPreferenceColorthemeOption < PrincipalRecord
  # Fixed IDs - do not modify these values
  NOTHING = 0
  LIGHT = 1
  DARK = 2
  SYSTEM = 3

  has_many :user_preference_colorthemes,
           class_name: "UserPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when LIGHT then "light"
    when DARK then "dark"
    when SYSTEM then "system"
    end
  end

  DEFAULTS = [NOTHING, LIGHT, DARK, SYSTEM].freeze

  def self.ensure_defaults!
    return if DEFAULTS.blank?

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
