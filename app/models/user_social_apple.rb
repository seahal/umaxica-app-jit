# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apples
#
#  id                                   :uuid             not null, primary key
#  token                                :string           default(""), not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  user_identity_social_apple_status_id :string(255)      default("ACTIVE"), not null
#  user_id                              :uuid             not null
#  uid                                  :string           default(""), not null
#  email                                :string           default(""), not null
#  image                                :string           default(""), not null
#  refresh_token                        :string           default(""), not null
#  expires_at                           :integer          not null
#  provider                             :string           default("apple"), not null
#  last_authenticated_at                :datetime
#
# Indexes
#
#  idx_on_user_identity_social_apple_status_id_93441f369d  (user_identity_social_apple_status_id)
#  index_user_identity_social_apples_on_user_id_unique     (user_id) UNIQUE
#  index_user_social_apples_on_expires_at                  (expires_at)
#  index_user_social_apples_on_uid_and_provider            (uid,provider) UNIQUE
#

class UserSocialApple < PrincipalRecord
  include SocialIdentifiable

  alias_attribute :user_social_apple_status_id, :user_identity_social_apple_status_id
  belongs_to :user, inverse_of: :user_social_apple
  belongs_to :user_social_apple_status,
             inverse_of: :user_social_apples,
             optional: true,
             foreign_key: :user_identity_social_apple_status_id

  validates :token, presence: true
  validates :user_id, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :expires_at, presence: true
  validates :user_identity_social_apple_status_id, length: { maximum: 255 }

  def self.status_column
    :user_identity_social_apple_status_id
  end

  def self.find_or_create_from_auth_hash(auth)
    # Find existing identity
    identity = find_or_initialize_by(uid: auth.uid, provider: auth.provider)

    # Update attributes
    identity.email = auth.info.email
    # Apple might not provide image in the same way, but keeping consistency
    identity.image = auth.info.image if auth.info.respond_to?(:image)
    identity.token = auth.credentials.token
    identity.refresh_token = auth.credentials.refresh_token if auth.credentials.refresh_token.present?
    identity.expires_at = auth.credentials.expires_at

    identity
  end

  # Extract uid from auth hash with fallback to extra.raw_info.sub
  def self.extract_uid(auth)
    uid = auth.uid
    uid = auth.extra&.raw_info&.sub if uid.blank?
    uid.to_s
  end

  # Update from OmniAuth hash (for link/reauth scenarios)
  def update_from_auth_hash!(auth)
    attrs = {
      email: auth.info.email,
      token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token.presence || refresh_token,
      expires_at: auth.credentials.expires_at,
      last_authenticated_at: Time.current,
    }
    attrs[:image] = auth.info.image if auth.info.respond_to?(:image)
    update!(attrs)
  end
end
