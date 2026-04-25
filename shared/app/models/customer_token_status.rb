# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_token_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#
class CustomerTokenStatus < TokenRecord
  NOTHING = 0
  ACTIVE = 1
  EXPIRED = 2

  has_many :customer_tokens, dependent: :restrict_with_error
end
