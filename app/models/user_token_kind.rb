# == Schema Information
#
# Table name: user_token_kinds
# Database name: token
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_token_kinds_on_code  (code) UNIQUE
#
# frozen_string_literal: true

class UserTokenKind < TokenRecord
  include CodeIdentifiable

  # id is a string, manually managed
  self.primary_key = :id
  self.record_timestamps = false

  has_many :user_tokens, dependent: :restrict_with_error
end
