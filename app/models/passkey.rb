# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: passkeys
# Database name: principal
#
#  id            :uuid             not null, primary key
#  public_key    :text             not null
#  sign_count    :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  credential_id :string           not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_passkeys_on_credential_id  (credential_id) UNIQUE
#  index_passkeys_on_user_id        (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Passkey < PrincipalRecord
  belongs_to :user

  validates :credential_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
