# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_binding_methods
# Database name: token
#
#  id :bigint           not null, primary key
#
class UserTokenBindingMethod < TokenRecord
  NOTHING = 0
  DBSC = 1
  LEGACY = 2
  DEFAULTS = [NOTHING, DBSC, LEGACY].freeze

  has_many :user_tokens, dependent: :restrict_with_error

  def self.ensure_defaults!
    existing_ids = where(id: DEFAULTS).pluck(:id)
    (DEFAULTS - existing_ids).each { |id| create!(id: id) }
  end
end
