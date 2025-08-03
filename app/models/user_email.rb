# == Schema Information
#
# Table name: user_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_emails_on_user_id  (user_id)
#
class UserEmail < IdentifiersRecord
  include SetId
  include Email
end
