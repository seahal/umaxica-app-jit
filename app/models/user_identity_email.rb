# == Schema Information
#
# Table name: user_identity_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_identity_emails_on_user_id  (user_id)
#
class UserIdentityEmail < IdentitiesRecord
  include SetId
  include Email
end
