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
  has_one :user_identity_social_apple,
          dependent: :destroy
  has_one :user_identity_social_google,
          dependent: :destroy
  has_many :user_identity_emails,
           dependent: :destroy
  has_many :user_identity_telephones,
           dependent: :destroy
  has_many :user_identity_secrets,
           dependent: :destroy
  has_many :user_recovery_codes,
           dependent: :destroy
  has_many :user_identity_passkeys,
           dependent: :destroy
  has_many :user_identity_audits,
           dependent: :destroy
  has_many :user_tokens,
           dependent: :destroy # , disable_joins: true
  has_many :user_memberships,
           dependent: :destroy
  has_many :workspaces,
           through: :user_memberships
  has_many :user_workspaces,
           dependent: :destroy
  has_many :staff_identity_audits,
           as: :actor,
           dependent: :destroy

  def staff?
    false
  end

  def user?
    true
  end
end
