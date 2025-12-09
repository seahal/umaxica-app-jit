# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
class User < IdentitiesRecord
  include Stakeholder
  belongs_to :user_identity_status, optional: true
  has_many :user_identity_emails, dependent: :destroy
  has_many :user_identity_telephones, dependent: :destroy
  has_one :user_identity_apple_auth, dependent: :destroy
  has_one :user_identity_google_auth, dependent: :destroy
  # has_many :user_sessions, dependent: :destroy
  has_many :user_time_based_one_time_password, dependent: :destroy
  has_many :user_webauthn_credentials, dependent: :destroy
  has_many :user_identity_audits, dependent: :destroy
  has_many :user_tokens, dependent: :destroy # , disable_joins: true

  before_validation :ensure_public_id

  validates :public_id, presence: true, uniqueness: true

  def staff?
    false
  end

  def user?
    true
  end

  private

  def ensure_public_id
    self.public_id ||= SecureRandom.uuid
  end
end
