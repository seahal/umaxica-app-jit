# typed: false
# frozen_string_literal: true

require "test_helper"

class SignComVerificationBaseIncludedDoTest < ActiveSupport::TestCase
  test "reauth_actor_id method exists" do
    assert Sign::ComVerificationBase::Overrides.private_method_defined?(:reauth_actor_id)
  end

  test "verification_model method exists" do
    assert Sign::ComVerificationBase::Overrides.private_method_defined?(:verification_model)
  end

  test "step_up_supported_methods method exists" do
    assert Sign::ComVerificationBase::Overrides.private_method_defined?(:step_up_supported_methods)
  end

  test "activate_com_verification_base class method exists" do
    assert_includes Sign::ComVerificationBase::ClassMethods.instance_methods(false), :activate_com_verification_base
  end
end
