# == Schema Information
#
# Table name: user_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserEmail < AccountsRecord
  include EmailAddress
  include SetId
  include Emailable
end
