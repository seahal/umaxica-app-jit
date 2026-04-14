# typed: false
# frozen_string_literal: true

require "test_helper"

module Org
  class RegistrationPolicyTest < ActiveSupport::TestCase
    fixtures :organization_invitations

    test "allowed? returns true for valid invitation" do
      invitation = organization_invitations(:one)

      assert RegistrationPolicy.allowed?(
        invitation_code: invitation.code,
        email: invitation.email,
      )
    end

    test "allowed? returns false for blank invitation code" do
      assert_not RegistrationPolicy.allowed?(invitation_code: "", email: "test@example.com")
      assert_not RegistrationPolicy.allowed?(invitation_code: nil, email: "test@example.com")
      assert_not RegistrationPolicy.allowed?(invitation_code: "   ", email: "test@example.com")
    end

    test "allowed? returns false for invalid invitation code" do
      assert_not RegistrationPolicy.allowed?(invitation_code: "nonexistent-code")
    end

    test "validate! raises InvitationRequiredError when code is blank" do
      assert_raises(RegistrationPolicy::InvitationRequiredError) do
        RegistrationPolicy.validate!(invitation_code: "")
      end

      assert_raises(RegistrationPolicy::InvitationRequiredError) do
        RegistrationPolicy.validate!(invitation_code: nil)
      end

      assert_raises(RegistrationPolicy::InvitationRequiredError) do
        RegistrationPolicy.validate!(invitation_code: "   ")
      end
    end

    test "validate! raises InvalidInvitationError for invalid code" do
      assert_raises(RegistrationPolicy::InvalidInvitationError) do
        RegistrationPolicy.validate!(invitation_code: "nonexistent-code")
      end
    end

    test "validate! returns invitation when valid" do
      invitation = organization_invitations(:one)

      result = RegistrationPolicy.validate!(
        invitation_code: invitation.code,
        email: invitation.email,
      )

      assert_equal invitation, result
    end

    test "consume! validates and consumes invitation" do
      invitation = organization_invitations(:one)

      result = RegistrationPolicy.consume!(
        invitation_code: invitation.code,
        email: invitation.email,
      )

      assert_equal invitation, result
      assert_predicate invitation.reload, :consumed?
    end

    test "consume! raises InvitationRequiredError when code is blank" do
      assert_raises(RegistrationPolicy::InvitationRequiredError) do
        RegistrationPolicy.consume!(invitation_code: "")
      end
    end

    test "consume! raises InvalidInvitationError for invalid code" do
      assert_raises(RegistrationPolicy::InvalidInvitationError) do
        RegistrationPolicy.consume!(invitation_code: "nonexistent-code")
      end
    end

    test "consume! raises InvitationConsumedError when invitation already consumed" do
      invitation = organization_invitations(:one)
      # Consume the invitation first
      invitation.consume!

      assert_predicate invitation, :consumed?

      # Attempting to consume again should fail with InvitationConsumedError
      assert_raises(RegistrationPolicy::InvitationConsumedError) do
        RegistrationPolicy.consume!(
          invitation_code: invitation.code,
          email: invitation.email,
        )
      end
    end
  end
end
