# == Schema Information
#
# Table name: personas
#
#  id            :binary           not null, primary key
#  avatar        :jsonb
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  identifier_id :binary
#
require "test_helper"

class PersonaTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
