# == Schema Information
#
# Table name: user_token_kinds
# Database name: token
#
#  id :string           not null, primary key
#
# frozen_string_literal: true

class UserTokenKind < TokenRecord
  # id is a string, manually managed
  self.primary_key = :id
  self.record_timestamps = false

  has_many :user_tokens, dependent: :restrict_with_error
end
