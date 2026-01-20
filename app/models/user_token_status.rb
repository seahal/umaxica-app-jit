# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class UserTokenStatus < TokenRecord
  include StringPrimaryKey

  # Status constants
  NEYO = "NEYO"
  has_many :user_tokens, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
