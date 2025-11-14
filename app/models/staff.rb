# frozen_string_literal: true

# == Schema Information
#
# Table name: staffs
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
class Staff < IdentitiesRecord
  has_many :staff_emails, dependent: :destroy
  has_many :emails, class_name: "StaffEmail", dependent: :destroy
end
