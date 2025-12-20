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
  include Account
  include Withdrawable
  include HasRoles
  include ::PublicId

  belongs_to :user_identity_status, optional: true
  has_one :user_identity_apple_auth, dependent: :destroy
  has_one :user_identity_google_auth, dependent: :destroy
  has_many :user_identity_emails, dependent: :destroy
  has_many :user_identity_telephones, dependent: :destroy
  has_many :user_identity_secrets, dependent: :destroy
  has_many :emails, class_name: "UserIdentityEmail", dependent: :destroy
  has_many :phones, class_name: "UserIdentityTelephone", dependent: :destroy
  has_many :user_recovery_codes, dependent: :destroy
  has_one :user_time_based_one_time_password, class_name: "UserIdentityOneTimePassword", dependent: :destroy
  has_many :user_identity_passkeys, dependent: :destroy
  has_many :user_webauthn_credentials, dependent: :destroy
  has_many :user_identity_audits, dependent: :destroy
  has_many :user_tokens, dependent: :destroy # , disable_joins: true
  has_many :user_memberships, dependent: :destroy
  has_many :workspaces, through: :user_memberships
  has_many :user_organizations, dependent: :destroy
  has_many :staff_identity_audits, as: :actor, dependent: :destroy

  before_create :set_default_status

  def staff?
    false
  end

  def user?
    true
  end

  private

  def set_default_status
    self.user_identity_status_id ||= UserIdentityStatus::NONE
  end
end
