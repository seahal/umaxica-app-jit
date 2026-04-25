# typed: false
# frozen_string_literal: true

require "test_helper"

module StaffSecret::Kinds
  class StaffSecretKindsTest < ActiveSupport::TestCase
    class TestModel
      include StaffSecret::Kinds

      attr_accessor :staff_secret_kind_id
    end

    test "login_secret? returns true for LOGIN kind" do
      model = TestModel.new
      model.staff_secret_kind_id = StaffSecret::Kinds::LOGIN

      assert_predicate model, :login_secret?
    end

    test "login_secret? returns false for other kind" do
      model = TestModel.new
      model.staff_secret_kind_id = StaffSecret::Kinds::TOTP

      assert_not model.login_secret?
    end

    test "totp_secret? returns true for TOTP kind" do
      model = TestModel.new
      model.staff_secret_kind_id = StaffSecret::Kinds::TOTP

      assert_predicate model, :totp_secret?
    end

    test "totp_secret? returns false for other kind" do
      model = TestModel.new
      model.staff_secret_kind_id = StaffSecret::Kinds::LOGIN

      assert_not model.totp_secret?
    end

    test "recovery_secret? always returns false" do
      model = TestModel.new
      model.staff_secret_kind_id = StaffSecret::Kinds::LOGIN

      assert_not model.recovery_secret?
    end

    test "permanent_secret? returns true for PERMANENT kind" do
      model = TestModel.new
      model.staff_secret_kind_id = StaffSecret::Kinds::PERMANENT

      assert_predicate model, :permanent_secret?
    end

    test "one_time_secret? returns true for ONE_TIME kind" do
      model = TestModel.new
      model.staff_secret_kind_id = StaffSecret::Kinds::ONE_TIME

      assert_predicate model, :one_time_secret?
    end

    test "ALL contains LOGIN and TOTP" do
      assert_includes StaffSecret::Kinds::ALL, StaffSecret::Kinds::LOGIN
      assert_includes StaffSecret::Kinds::ALL, StaffSecret::Kinds::TOTP
    end
  end
end
