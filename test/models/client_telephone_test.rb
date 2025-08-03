# == Schema Information
#
# Table name: client_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class ClientTelephoneTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
