# == Schema Information
#
# Table name: personas
#
#  id            :uuid             not null, primary key
#  avatar        :jsonb
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  identifier_id :uuid
#
require "test_helper"

class PersonaTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
