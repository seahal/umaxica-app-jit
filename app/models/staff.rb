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
  has_secure_password algorithm: :argon2
  has_many :staff_emails, dependent: :destroy

  # Alias for backward compatibility with tests
  alias_method :emails, :staff_emails
end
