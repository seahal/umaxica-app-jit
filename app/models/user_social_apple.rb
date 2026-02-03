# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apples
# Database name: principal
#
#  id                                   :bigint           not null, primary key
#  expires_at                           :integer          not null
#  image                                :string           default(""), not null
#  last_authenticated_at                :datetime
#  provider                             :string           default("apple"), not null
#  refresh_token                        :string           default(""), not null
#  token                                :string           default(""), not null
#  uid                                  :string           default(""), not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  user_id                              :bigint           not null
#  user_identity_social_apple_status_id :bigint           default(1), not null
#
# Indexes
#
#  idx_on_user_identity_social_apple_status_id_93441f369d  (user_identity_social_apple_status_id)
#  index_user_identity_social_apples_on_user_id_unique     (user_id) UNIQUE WHERE (user_id IS NOT NULL)
#  index_user_social_apples_on_expires_at                  (expires_at)
#  index_user_social_apples_on_uid_and_provider            (uid,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (user_identity_social_apple_status_id => user_social_apple_statuses.id)
#

class UserSocialApple < PrincipalRecord
  include SocialIdentifiable

  alias_attribute :user_social_apple_status_id, :user_identity_social_apple_status_id
  attribute :user_identity_social_apple_status_id, default: UserSocialAppleStatus::ACTIVE

  belongs_to :user, inverse_of: :user_social_apple
  belongs_to :user_social_apple_status,
             inverse_of: :user_social_apples,
             optional: true,
             foreign_key: :user_identity_social_apple_status_id

  validates :token, presence: true
  validates :user_id, uniqueness: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :expires_at, presence: true
  validates :user_identity_social_apple_status_id, numericality: { only_integer: true }

  def self.status_column
    :user_identity_social_apple_status_id
  end

  def self.status_class
    UserSocialAppleStatus
  end

  def self.find_or_create_from_auth_hash(auth)
    # Find existing identity
    identity = find_or_initialize_by(uid: auth.uid, provider: auth.provider)

    # Update attributes
    # Apple might not provide image in the same way, but keeping consistency
    identity.image = auth.info.respond_to?(:image) ? (auth.info.image.presence || "") : ""
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
      token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token.presence || refresh_token,
      expires_at: auth.credentials.expires_at,
      last_authenticated_at: Time.current,
    }
    attrs[:image] =
      auth.info.respond_to?(:image) ? (auth.info.image.presence || image.presence || "") : (image.presence || "")
    update!(attrs)
  end
end
