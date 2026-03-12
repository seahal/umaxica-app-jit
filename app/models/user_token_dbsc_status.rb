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
  PENDING = 1
  ACTIVE = 2
  FAILED = 3
  REVOKE = 4
  DEFAULTS = [NOTHING, PENDING, ACTIVE, FAILED, REVOKE].freeze

  has_many :user_tokens, dependent: :restrict_with_error

  def self.ensure_defaults!
    existing_ids = where(id: DEFAULTS).pluck(:id)
    (DEFAULTS - existing_ids).each { |id| create!(id: id) }
  end
end
