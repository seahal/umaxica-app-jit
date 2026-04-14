# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_token_binding_methods
# Database name: token
#
#  id :bigint           not null, primary key
#
class CustomerTokenBindingMethod < TokenRecord
  NOTHING = 0
  DBSC = 1
  LEGACY = 2
  DEFAULTS = [NOTHING, DBSC, LEGACY].freeze

  has_many :customer_tokens, dependent: :restrict_with_error

  def self.ensure_defaults!
    return if DEFAULTS.blank?

    insert_missing_fixed_ids!(DEFAULTS)
  end
end
