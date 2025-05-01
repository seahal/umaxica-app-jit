# == Schema Information
#
# Table name: client_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ClientEmail < AccountsRecord
  include SetId
  include Email
end
