# typed: false
# frozen_string_literal: true

require "test_helper"

module UserSecret::Kinds
  class UserSecretKindsTest < ActiveSupport::TestCase
    class TestModel
      include UserSecret::Kinds

      attr_accessor :user_secret_kind_id
    end

    test "login_secret? returns true for LOGIN kind" do
      model = TestModel.new
      model.user_secret_kind_id = UserSecret::Kinds::LOGIN

      assert_predicate model, :login_secret?
    end

    test "totp_secret? returns true for TOTP kind" do
      model = TestModel.new
      model.user_secret_kind_id = UserSecret::Kinds::TOTP

      assert_predicate model, :totp_secret?
    end

    test "recovery_secret? returns true for RECOVERY kind" do
      model = TestModel.new
      model.user_secret_kind_id = UserSecret::Kinds::RECOVERY

      assert_predicate model, :recovery_secret?
    end

    test "api_secret? returns true for API kind" do
      model = TestModel.new
      model.user_secret_kind_id = UserSecret::Kinds::API

      assert_predicate model, :api_secret?
    end

    test "permanent_secret? returns true for PERMANENT kind" do
      model = TestModel.new
      model.user_secret_kind_id = UserSecret::Kinds::PERMANENT

      assert_predicate model, :permanent_secret?
    end

    test "one_time_secret? returns true for ONE_TIME kind" do
      model = TestModel.new
      model.user_secret_kind_id = UserSecret::Kinds::ONE_TIME

      assert_predicate model, :one_time_secret?
    end

    test "ALL contains LOGIN, TOTP, RECOVERY, and API" do
      assert_includes UserSecret::Kinds::ALL, UserSecret::Kinds::LOGIN
      assert_includes UserSecret::Kinds::ALL, UserSecret::Kinds::TOTP
      assert_includes UserSecret::Kinds::ALL, UserSecret::Kinds::RECOVERY
      assert_includes UserSecret::Kinds::ALL, UserSecret::Kinds::API
    end
  end
end
