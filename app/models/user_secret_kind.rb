# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_kinds
# Database name: principal
#
#  id :integer          not null, primary key
#
class UserSecretKind < PrincipalRecord
  include CodeIdentifiable

  LOGIN = "LOGIN"
  TOTP = "TOTP"
  RECOVERY = "RECOVERY"
  API = "API"

  has_many :user_secrets, inverse_of: :user_secret_kind, dependent: :restrict_with_exception
end
