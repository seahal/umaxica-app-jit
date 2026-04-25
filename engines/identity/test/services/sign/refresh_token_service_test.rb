# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  module Identity
    module Sign
      class RefreshTokenServiceTest < ActiveSupport::TestCase
        fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds, :user_tokens

        setup do
          # UserToken.where(user: users(:one)).delete_all
        end

        test "rotation increments generation counter" do
          token = UserToken.create!(user: users(:one))
          first_refresh = token.rotate_refresh_token!
          result = Jit::Identity::Sign::RefreshTokenService.call(refresh_token: first_refresh)

          new_token = result[:token]

          assert_not_equal token.id, new_token.id
          assert_equal token.refresh_token_generation + 1, new_token.refresh_token_generation
          assert_equal token.refresh_token_family_id, new_token.refresh_token_family_id
          assert_predicate token.reload.rotated_at, :present?
          assert_kind_of Hash, result
          assert_equal new_token, result[:token]
        end

        test "reuse detection revokes all actor tokens" do
          user = users(:one)
          token = UserToken.create!(user: user)
          initial_refresh = token.rotate_refresh_token!
          rotated = Jit::Identity::Sign::RefreshTokenService.call(refresh_token: initial_refresh)
          rotated_refresh = rotated[:refresh_token]

          assert_raises(Jit::Identity::Sign::InvalidRefreshToken) do
            Jit::Identity::Sign::RefreshTokenService.call(refresh_token: initial_refresh)
          end

          token.reload

          assert token.expired_at, "Original token should be revoked"
          assert token.compromised_at, "Compromise timestamp should be recorded"
          assert UserToken.where(user_id: user.id).all?(&:revoked?), "All actor tokens should be revoked"

          assert_raises(Jit::Identity::Sign::InvalidRefreshToken) do
            Jit::Identity::Sign::RefreshTokenService.call(refresh_token: rotated_refresh)
          end
        end

        test "revoked tokens stay invalid without marking compromise" do
          token = user_tokens(:one)
          refresh = token.rotate_refresh_token!
          token.revoke!

          assert_raises(Jit::Identity::Sign::InvalidRefreshToken) do
            Jit::Identity::Sign::RefreshTokenService.call(refresh_token: refresh)
          end

          assert_nil token.reload.compromised_at
        end

        test "scheduled revoked tokens are invalid after revoked_at passes" do
          freeze_time do
            token = UserToken.create!(user: users(:one), revoked_at: 5.minutes.from_now)
            refresh = token.rotate_refresh_token!
            travel 6.minutes

            assert_raises(Jit::Identity::Sign::InvalidRefreshToken) do
              Jit::Identity::Sign::RefreshTokenService.call(refresh_token: refresh)
            end
          end
        end

        test "S2: service uses writing role for lock and update operations" do
          # Verify that ActiveRecord::Base.connected_to is called with role: :writing
          # This ensures SELECT ... FOR UPDATE and UPDATE go to primary database
          original_method = ActiveRecord::Base.method(:connected_to)

          connection_calls = []
          ActiveRecord::Base.define_singleton_method(:connected_to) do |**options, &block|
            connection_calls << options
            original_method.call(**options, &block)
          end

          token = UserToken.create!(user: users(:one))
          refresh = token.rotate_refresh_token!

          Jit::Identity::Sign::RefreshTokenService.call(refresh_token: refresh)

          # Verify that connected_to was called with role: :writing
          assert connection_calls.any? { |opts| opts[:role] == :writing },
                 "RefreshTokenService should use writing role for lock/update operations"
        ensure
          # Restore original method
          ActiveRecord::Base.define_singleton_method(:connected_to, original_method)
        end

        test "S2: no ReadOnlyError occurs during refresh" do
          # This test verifies that refresh operations do not trigger ReadOnlyError
          # even when using SELECT ... FOR UPDATE
          token = UserToken.create!(user: users(:one))
          refresh = token.rotate_refresh_token!

          assert_nothing_raised do
            result = Jit::Identity::Sign::RefreshTokenService.call(refresh_token: refresh)

            assert_kind_of Hash, result
            assert_not_equal token.id, result[:token].id
          end
        end
      end
    end
  end
end
