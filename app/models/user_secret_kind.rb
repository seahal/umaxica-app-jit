# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_kinds
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserSecretKind < PrincipalRecord
  LOGIN = 1
  TOTP = 2
  RECOVERY = 3
  API = 4
  PERMANENT = LOGIN
  ONE_TIME = RECOVERY
  ALLOWED_FOR_SECRET_SIGN_IN = [PERMANENT, ONE_TIME].freeze
  ALL = [LOGIN, TOTP, RECOVERY, API].freeze

  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :id, uniqueness: true

  has_many :user_secrets, inverse_of: :user_secret_kind, dependent: :restrict_with_exception
end
