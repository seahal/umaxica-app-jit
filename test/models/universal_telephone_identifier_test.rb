# == Schema Information
#
# Table name: universal_telephone_identifiers
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UniversalTelephoneIdentifierTest < ActiveSupport::TestCase
  def setup
    @universal_telephone_identifier = UniversalTelephoneIdentifier.new
  end

  test "should be valid" do
    assert_predicate @universal_telephone_identifier, :valid?
  end

  test "should inherit from UniversalRecord" do
    assert_kind_of UniversalRecord, @universal_telephone_identifier
  end

  test "should have timestamps" do
    # Test that the model includes created_at and updated_at
    assert_respond_to @universal_telephone_identifier, :created_at
    assert_respond_to @universal_telephone_identifier, :updated_at
  end

  test "should have id attribute" do
    assert_respond_to @universal_telephone_identifier, :id
  end
end
