# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id               :uuid             not null, primary key
#  accountable_type :string           not null
#  accountable_id   :uuid             not null
#  email            :string           not null
#  password_digest  :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounts_on_accountable_type_and_accountable_id  (accountable_type,accountable_id) UNIQUE
#  index_accounts_on_email                                (email) UNIQUE
#

class Account < IdentitiesRecord
  delegated_type :accountable, types: %w( Staff User ), dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :accountable_id, uniqueness: { scope: :accountable_type }
  validates :password_digest, presence: true
end
