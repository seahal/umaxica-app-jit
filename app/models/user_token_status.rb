# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_statuses
# Database name: token
#
#  id :integer          not null, primary key
#

class UserTokenStatus < TokenRecord
  include CodeIdentifiable

  # Status constants
  NEYO = "NEYO"
  has_many :user_tokens, dependent: :restrict_with_error
end
