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
  def setup
    @persona = Persona.new(name: "Test User")
  end

  test "should be valid with valid attributes" do
    assert @persona.valid?
  end

  test "should have timestamps" do
    @persona.save
    assert_not_nil @persona.created_at
    assert_not_nil @persona.updated_at
  end

  test "should have uuid as primary key" do
    @persona.save
    assert @persona.id.is_a?(String)
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, @persona.id)
  end

  test "should accept name attribute" do
    @persona.name = "Updated Name"
    assert_equal "Updated Name", @persona.name
  end
end
