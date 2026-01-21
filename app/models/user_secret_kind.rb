# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_kinds
#
#  id :string(255)      not null, primary key
#

class UserSecretKind < PrincipalRecord
  include StringPrimaryKey

  # Kind constants
  LOGIN = "LOGIN"
  TOTP = "TOTP"
  RECOVERY = "RECOVERY"
  API = "API"

  ALL = [LOGIN, TOTP, RECOVERY, API].freeze

  has_many :user_secrets, inverse_of: :user_secret_kind, dependent: :restrict_with_exception

  validates :id, uniqueness: { case_sensitive: false }
end
