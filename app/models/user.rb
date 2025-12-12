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
  include Withdrawable
  belongs_to :user_identity_status, optional: true
  has_one :user_identity_apple_auth, dependent: :destroy
  has_one :user_identity_google_auth, dependent: :destroy
  has_many :user_identity_emails, dependent: :destroy
  has_many :user_identity_telephones, dependent: :destroy
  has_many :user_webauthn_credentials, dependent: :destroy
  has_many :user_identity_audits, dependent: :destroy
  has_many :user_tokens, dependent: :destroy # , disable_joins: true
  has_many :user_organizations, dependent: :destroy
  has_many :organizations, through: :user_organizations
  has_many :role_assignments, dependent: :destroy
  has_many :roles, through: :role_assignments

  before_validation :ensure_public_id
  before_create :set_default_status

  validates :public_id, presence: true, uniqueness: true

  def staff?
    false
  end

  def user?
    true
  end

  private

  def ensure_public_id
    self.public_id ||= Nanoid.generate(size: 21)
  end

  def set_default_status
    self.user_identity_status_id ||= UserIdentityStatus::NONE
  end
end
