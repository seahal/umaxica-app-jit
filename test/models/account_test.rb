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

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "Account has delegated_type accountable" do
    assert_respond_to Account.new, :accountable
  end

  test "Account supports User and Staff as accountable types" do
    assert_includes Account.accountable_types, "User"
    assert_includes Account.accountable_types, "Staff"
  end
end
