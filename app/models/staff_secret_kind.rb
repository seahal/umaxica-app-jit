# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_kinds
#
#  id :string(255)      not null, primary key
#

class StaffSecretKind < OperatorRecord
  include StringPrimaryKey

  # Kind constants
  LOGIN = "LOGIN"
  TOTP = "TOTP"

  ALL = [LOGIN, TOTP].freeze

  has_many :staff_secrets, inverse_of: :staff_secret_kind, dependent: :restrict_with_exception

  validates :id, uniqueness: { case_sensitive: false }
end
