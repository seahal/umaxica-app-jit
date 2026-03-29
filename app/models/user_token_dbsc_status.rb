# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_dbsc_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#
class UserTokenDbscStatus < TokenRecord
  NOTHING = 0
  PENDING = 1 # FIXME: set 2 as PENDING.
  ACTIVE = 2 # FIXME: set 1 as DEFAULT.
  FAILED = 3
  REVOKE = 4
  DEFAULTS = [NOTHING, PENDING, ACTIVE, FAILED, REVOKE].freeze

  has_many :user_tokens, dependent: :restrict_with_error

  # FIXME: remove this method!
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
