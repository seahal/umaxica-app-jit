# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_colortheme_options
# Database name: guest
#
#  id :bigint           not null, primary key
#
class CustomerPreferenceColorthemeOption < GuestRecord
  # Fixed IDs - do not modify these values
  SYSTEM = 0
  LIGHT = 1
  DARK = 2
  LEGACY_SYSTEM = 3
  DEFAULTS = [SYSTEM, LIGHT, DARK, LEGACY_SYSTEM].freeze

  has_many :customer_preference_colorthemes,
           class_name: "CustomerPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  self.primary_key = :id

  def name
    case id
    when SYSTEM, LEGACY_SYSTEM then "system"
    when LIGHT then "light"
    when DARK then "dark"
    end
  end

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
