# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_statuses
# Database name: token
#
#  id :string(255)      default(""), not null, primary key
#
# Indexes
#
#  index_user_token_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserTokenStatus < TokenRecord
  include StringPrimaryKey

  # Status constants
  NEYO = "NEYO"
  has_many :user_tokens, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
