# frozen_string_literal: true

# == Schema Information
#
# Table name: staffs
#
#  id              :binary           not null, primary key
#  otp_private_key :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Staff < IdentifiersRecord
  has_many :emails, foreign_key: "address"
end
