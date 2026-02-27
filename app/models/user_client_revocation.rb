# typed: false
# == Schema Information
#
# Table name: user_client_revocations
# Database name: principal
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_client_revocations_on_client_id              (client_id)
#  index_user_client_revocations_on_user_id_and_client_id  (user_id,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

class UserClientRevocation < PrincipalRecord
  belongs_to :user, inverse_of: :user_client_revocations
  belongs_to :client, inverse_of: :user_client_revocations

  validates :client_id, uniqueness: { scope: :user_id }
end
