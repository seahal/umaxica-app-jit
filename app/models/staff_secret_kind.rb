# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_kinds
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_secret_kinds_on_code  (code) UNIQUE
#

class StaffSecretKind < OperatorRecord
  # Kind constants
  LOGIN = "LOGIN"
  TOTP = "TOTP"

  ALL = [LOGIN, TOTP].freeze

  has_many :staff_secrets, inverse_of: :staff_secret_kind, dependent: :restrict_with_exception

  validates :id, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
