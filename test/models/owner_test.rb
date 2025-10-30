require "test_helper"

class OwnerTest < ActiveSupport::TestCase
  test "inherits from ApplicationRecord" do
    assert_operator Owner, :<, ApplicationRecord
  end

  test "should have name validation" do
    assert_respond_to Owner, :validators
    name_validators = Owner.validators_on(:name)

    assert name_validators.any? { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator) }
  end
end
