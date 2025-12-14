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

  belongs_to :user_identity_email_status, optional: true
  belongs_to :user, optional: true

  encrypts :address, deterministic: true
end
