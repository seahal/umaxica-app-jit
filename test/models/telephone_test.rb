# == Schema Information
#
# Table name: telephones
#
#  id             :binary           not null, primary key
#  entryable_type :string
#  number         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  entryable_id   :binary
#
require "test_helper"

class TelephoneTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
