# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#  user_identity_email_status_id :string
#
# Indexes
#
#  index_user_identity_emails_on_user_id  (user_id)
#  index_user_identity_emails_on_user_identity_email_status_id  (user_identity_email_status_id)
#
class UserIdentityEmail < IdentitiesRecord
  include SetId
  include Email
  include Turnstile

  MAX_EMAILS_PER_USER = 4

  belongs_to :user_identity_email_status, optional: true
  belongs_to :user, optional: true

  encrypts :address, deterministic: true

  validate :enforce_user_email_limit, on: :create

  private

  def enforce_user_email_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_EMAILS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum emails per user (#{MAX_EMAILS_PER_USER})")
  end
end
