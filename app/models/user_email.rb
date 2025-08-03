# == Schema Information
#
# Table name: user_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserEmail < IdentifiersRecord
  include SetId
  include Email
end
