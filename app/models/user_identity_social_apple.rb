# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_social_apples
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
class UserIdentitySocialApple < IdentitiesRecord
  belongs_to :user, optional: true
  belongs_to :user_identity_social_apple_status, optional: true

  validates :token, presence: true
  validates :user_id, uniqueness: true, allow_nil: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

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
end
