# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_statuses
# Database name: token
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_token_statuses_on_code  (code) UNIQUE
#

class UserTokenStatus < TokenRecord
  include CodeIdentifiable

  # Status constants
  NEYO = "NEYO"
  has_many :user_tokens, dependent: :restrict_with_error
end
