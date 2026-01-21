# == Schema Information
#
# Table name: staff_one_time_password_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class StaffOneTimePasswordStatus < OperatorRecord
  include StringPrimaryKey

  # Status constants
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"

  has_many :staff_one_time_passwords, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
