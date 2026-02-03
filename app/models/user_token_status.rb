# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#

class UserTokenStatus < TokenRecord
  ACTIVE = 1
  NEYO = 0
  has_many :user_tokens, dependent: :restrict_with_error
end
