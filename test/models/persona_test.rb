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
    assert_predicate @persona, :valid?
  end

  test "should have timestamps" do
    @persona.save

    assert_not_nil @persona.created_at
    assert_not_nil @persona.updated_at
  end

  test "should have uuid as primary key" do
    @persona.save

    assert_kind_of String, @persona.id
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, @persona.id)
  end

  test "should accept name attribute" do
    @persona.name = "Updated Name"

    assert_equal "Updated Name", @persona.name
  end

  # Model structure tests
  test "should inherit from SpecialitiesRecord" do
    assert_operator Persona, :<, SpecialitiesRecord
  end

  test "should mount avatar uploader" do
    assert_respond_to @persona, :avatar
    assert_respond_to @persona, :avatar=
    assert_respond_to @persona, :remove_avatar
  end

  # Avatar functionality tests
  test "should handle avatar upload" do
    # Test that avatar field exists and can be set
    @persona.avatar = "test_avatar_data"

    assert_not_nil @persona.avatar
  end

  test "should store avatar as JSONB" do
    # The schema shows avatar is a jsonb field
    @persona.save!
    column = Persona.columns_hash["avatar"]

    assert_equal :jsonb, column.type
  end

  # Name validation tests
  test "should allow empty name" do
    @persona.name = nil

    assert_predicate @persona, :valid?
  end

  test "should allow long names" do
    long_name = "a" * 255
    @persona.name = long_name

    assert_predicate @persona, :valid?
    @persona.save!

    assert_equal long_name, @persona.name
  end

  # identifier_id tests
  test "should allow identifier_id to be set" do
    identifier_uuid = SecureRandom.uuid
    @persona.identifier_id = identifier_uuid

    assert_equal identifier_uuid, @persona.identifier_id
  end

  test "should allow nil identifier_id" do
    @persona.identifier_id = nil

    assert_predicate @persona, :valid?
  end

  # Avatar uploader specific tests
  test "should respond to avatar uploader methods" do
    assert_respond_to @persona, :avatar_url
    assert_respond_to @persona, :avatar_identifier
  end

  # JSONB functionality tests
  # test "should handle complex avatar data structure" do
  #   complex_avatar_data = {
  #     "original" => "path/to/original.jpg",
  #     "thumb" => "path/to/thumb.jpg",
  #     "metadata" => {
  #       "size" => 1024,
  #       "type" => "image/jpeg"
  #     }
  #   }
  #
  #   @persona.avatar = complex_avatar_data
  #   @persona.save!
  #
  #   # Test that JSONB data is preserved
  #   reloaded_persona = Persona.find(@persona.id)
  #   assert_equal complex_avatar_data, reloaded_persona.avatar
  # end

  # Database and inheritance tests
  test "should use specialities database connection" do
    assert_equal SpecialitiesRecord.connection, Persona.connection
  end
end
