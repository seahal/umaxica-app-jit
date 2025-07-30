# == Schema Information
#
# Table name: passkeys
#
#  id                 :uuid             not null, primary key
#  active             :boolean
#  authenticator_type :integer
#  nickname           :string
#  public_key         :text
#  sign_count         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  external_id        :string
#  user_id            :bigint           not null
#
# Indexes
#
#  index_passkeys_on_external_id  (external_id) UNIQUE
#  index_passkeys_on_user_id      (user_id)
#
require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
