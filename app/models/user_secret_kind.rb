# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_kinds
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_secret_kinds_on_code  (code) UNIQUE
#
class UserSecretKind < PrincipalRecord
  include CodeIdentifiable

  LOGIN = "LOGIN"
  TOTP = "TOTP"
  RECOVERY = "RECOVERY"
  API = "API"

  has_many :user_secrets, inverse_of: :user_secret_kind, dependent: :restrict_with_exception
end
