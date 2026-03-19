# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_binding_methods
# Database name: token
#
#  id :bigint           not null, primary key
#
class StaffTokenBindingMethod < TokenRecord
  NOTHING = 0
  DBSC = 1
  LEGACY = 2
  DEFAULTS = [NOTHING, DBSC, LEGACY].freeze

  has_many :staff_tokens, dependent: :restrict_with_error

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
