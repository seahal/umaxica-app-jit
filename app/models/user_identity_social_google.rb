# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_social_googles
#
#  id                                    :uuid             not null, primary key
#  created_at                            :datetime         not null
#  email                                 :string           default(""), not null
#  expires_at                            :integer          not null
#  image                                 :string           default(""), not null
#  provider                              :string           default("google_oauth2"), not null
#  refresh_token                         :string           default(""), not null
#  token                                 :string           default(""), not null
#  uid                                   :string           default(""), not null
#  updated_at                            :datetime         not null
#  user_id                               :uuid             not null
#  user_identity_social_google_status_id :string(255)      default("ACTIVE"), not null
#
# Indexes
#
#  idx_on_user_identity_social_google_status_id_7bdb8753df  (user_identity_social_google_status_id)
#  index_user_identity_social_googles_on_expires_at         (expires_at)
#  index_user_identity_social_googles_on_uid_and_provider   (uid,provider) UNIQUE
#  index_user_identity_social_googles_on_user_id_unique     (user_id) UNIQUE
#

class UserIdentitySocialGoogle < IdentitiesRecord
  belongs_to :user, inverse_of: :user_identity_social_google
  belongs_to :user_identity_social_google_status, optional: true

  validates :token, presence: true
  validates :user_id, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :expires_at, presence: true
  validates :user_identity_social_google_status_id, length: { maximum: 255 }

  def self.find_or_create_from_auth_hash(auth)
    # Find existing identity
    identity = find_or_initialize_by(uid: auth.uid, provider: auth.provider)

    # Update attributes
    identity.email = auth.info.email
    identity.image = auth.info.image
    identity.token = auth.credentials.token
    identity.refresh_token = auth.credentials.refresh_token if auth.credentials.refresh_token.present?
    identity.expires_at = auth.credentials.expires_at

    identity
  end
end
