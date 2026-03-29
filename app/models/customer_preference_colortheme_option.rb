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
  # FIXME: i want to delete nothing, and move system params from 3 to 0
  NOTHING = 0
  LIGHT = 1
  DARK = 2
  SYSTEM = 3

  has_many :customer_preference_colorthemes,
           class_name: "CustomerPreferenceColortheme",
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

    missing_ids.each { |id| create!(id: id) }
  end

  self.primary_key = :id
end
