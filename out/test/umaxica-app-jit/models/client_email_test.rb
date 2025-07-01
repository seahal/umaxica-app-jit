# == Schema Information
#
# Table name: client_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class ClientEmailTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
