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
  # Fixed IDs - do not modify these values
  NOTHING = 0
  ACTIVE = 1
  PENDING = 2
  FAILED = 3
  REVOKE = 4
  DEFAULTS = [NOTHING, ACTIVE, PENDING, FAILED, REVOKE].freeze

  has_many :staff_tokens, dependent: :restrict_with_error

  def self.ensure_defaults!
    return if DEFAULTS.blank?

    insert_missing_fixed_ids!(DEFAULTS)
  end
end
