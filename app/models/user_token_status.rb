# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class UserTokenStatus < TokensRecord
  include UppercaseId

  has_many :user_tokens, dependent: :restrict_with_error

  # Status constants
  NEYO = "NEYO"
end
