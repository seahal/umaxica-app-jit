# frozen_string_literal: true

# == Schema Information
#
# Table name: staffs
#
#  id          :binary           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uuid_id     :uuid             not null
#  webauthn_id :string
#
class Staff < IdentifiersRecord
  has_many :emails, foreign_key: "address", dependent: :destroy, inverse_of: :staff
end
