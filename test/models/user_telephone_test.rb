# == Schema Information
#
# Table name: user_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_telephones_on_user_id  (user_id)
#
require "test_helper"

class UserTelephoneTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
