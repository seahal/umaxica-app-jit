# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_dbsc_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#
class StaffTokenDbscStatus < TokenRecord
  NOTHING = 0
  PENDING = 1
  ACTIVE = 2
  FAILED = 3
  REVOKE = 4
  DEFAULTS = [NOTHING, PENDING, ACTIVE, FAILED, REVOKE].freeze

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
