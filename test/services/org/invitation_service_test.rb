# typed: false
# frozen_string_literal: true

require "test_helper"

module Org
  class InvitationServiceTest < ActiveSupport::TestCase
    fixtures :organizations, :staffs, :organization_invitations

    test "create returns success when invitation is saved" do
      org = organizations(:one)
      staff = staffs(:one)

      result = InvitationService.create(
        organization_id: org.id,
        email: "new-invite@example.com",
        invited_by: staff,
      )

      assert_predicate result, :success?
      assert_not_nil result.invitation
      assert_not_nil result.code
      assert_nil result.error
    end

    test "create returns failure when invitation is invalid" do
      org = organizations(:one)
      staff = staffs(:one)

      result = InvitationService.create(
        organization_id: org.id,
        email: "",
        invited_by: staff,
      )

      assert_not_predicate result, :success?
      assert_nil result.invitation
      assert_nil result.code
      assert_not_nil result.error
    end

    test "create downcases and strips email" do
      org = organizations(:one)
      staff = staffs(:one)

      result = InvitationService.create(
        organization_id: org.id,
        email: "  UpperCase@Example.COM  ",
        invited_by: staff,
      )

      assert_predicate result, :success?
      assert_equal "uppercase@example.com", result.invitation.email
    end

    test "create uses default role_id of 0" do
      org = organizations(:one)
      staff = staffs(:one)

      result = InvitationService.create(
        organization_id: org.id,
        email: "role-test@example.com",
        invited_by: staff,
      )

      assert_predicate result, :success?
      assert_equal 0, result.invitation.role_id
    end

    test "create uses custom role_id" do
      org = organizations(:one)
      staff = staffs(:one)

      result = InvitationService.create(
        organization_id: org.id,
        email: "custom-role@example.com",
        invited_by: staff,
        role_id: 2,
      )

      assert_predicate result, :success?
      assert_equal 2, result.invitation.role_id
    end

    test "validate returns success for valid invitation" do
      invitation = organization_invitations(:one)

      result = InvitationService.validate(code: invitation.code)

      assert_predicate result, :success?
      assert_equal invitation, result.invitation
    end

    test "validate returns failure for invalid code" do
      result = InvitationService.validate(code: "nonexistent-code")

      assert_not_predicate result, :success?
      assert_nil result.invitation
      assert_equal "Invalid or expired invitation code", result.error
    end

    test "validate with email filter" do
      invitation = organization_invitations(:one)

      result = InvitationService.validate(code: invitation.code, email: invitation.email)

      assert_predicate result, :success?
    end

    test "validate with mismatched email returns failure" do
      invitation = organization_invitations(:one)

      result = InvitationService.validate(code: invitation.code, email: "wrong@example.com")

      assert_not_predicate result, :success?
    end

    test "consume returns success and consumes invitation" do
      invitation = organization_invitations(:one)

      result = InvitationService.consume(code: invitation.code)

      assert_predicate result, :success?
      assert_predicate invitation.reload, :consumed?
    end

    test "consume returns failure for invalid code" do
      result = InvitationService.consume(code: "nonexistent-code")

      assert_not_predicate result, :success?
      assert_equal "Invalid or expired invitation code", result.error
    end
  end
end
