require "test_helper"

class UserPasskeyTest < ActiveSupport::TestCase
  test "belongs to user" do
    association = UserPasskey.reflect_on_association(:user)
    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "validates presence and uniqueness of webauthn_id" do
    validators = UserPasskey.validators_on(:webauthn_id)

    assert validators.any? { |validator| validator.is_a?(ActiveModel::Validations::PresenceValidator) }
    assert validators.any? { |validator| validator.is_a?(ActiveRecord::Validations::UniquenessValidator) }
  end

  test "validates presence of public_key and description" do
    public_key_validators = UserPasskey.validators_on(:public_key)
    description_validators = UserPasskey.validators_on(:description)

    assert public_key_validators.any? { _1.is_a?(ActiveModel::Validations::PresenceValidator) }
    assert description_validators.any? { _1.is_a?(ActiveModel::Validations::PresenceValidator) }
  end

  test "validates numericality of sign_count" do
    validators = UserPasskey.validators_on(:sign_count)

    assert validators.any? { _1.is_a?(ActiveModel::Validations::PresenceValidator) }
    assert validators.any? { _1.is_a?(ActiveModel::Validations::NumericalityValidator) }
  end
end
