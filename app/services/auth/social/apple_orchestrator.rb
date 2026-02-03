# frozen_string_literal: true

module Auth
  module Social
    # @deprecated This class is deprecated and no longer used.
    # Apple social login now uses the unified SocialAuthService flow (same as Google).
    # This class is kept for backward compatibility and reference only.
    #
    # Historical note:
    # Previously, Apple social login was handled separately via this orchestrator,
    # but it has been unified with Google's implementation in SocialAuthService
    # to reduce code duplication and improve maintainability.
    class AppleOrchestrator
      Result =
        Struct.new(
          :success,
          :action,
          :user,
          :identity,
          :existing_account,
          :error_key,
          :error_context,
          :flash_key,
          :redirect_to,
          keyword_init: true,
        ) do
          def success?
            success
          end
        end

      NormalizedAuth = Struct.new(:uid, :provider, :auth_hash, keyword_init: true)

      def initialize(auth_hash:, current_user:)
        @auth_hash = auth_hash
        @current_user = current_user
      end

      def call
        return failure("errors.social_auth.missing_auth_hash") if @auth_hash.blank?

        normalized = normalize_auth_hash(@auth_hash)
        return failure("errors.social_auth.missing_uid") if normalized.uid.blank?

        PrincipalRecord.transaction do
          if @current_user
            link_with_current_user(normalized)
          else
            sign_in_or_sign_up(normalized)
          end
        end
      rescue ActiveRecord::RecordNotUnique => e
        Rails.event.notify(
          "social_auth.identity_conflict",
          provider: "apple",
          error: e.message,
        )
        failure("errors.social_auth.identity_conflict")
      end

      private

      def sign_in_or_sign_up(normalized)
        identity = UserSocialApple.lock.find_by(uid: normalized.uid, provider: normalized.provider)

        if identity
          user = identity.user || create_user_for_identity(identity)
          identity.update_from_auth_hash!(@auth_hash)
          return success(
            action: :sign_in,
            user: user,
            identity: identity,
            existing_account: true,
          )
        end

        user = ::User.new(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
        identity = build_identity_for_user(user, normalized)

        user.save!
        identity.save!
        identity.touch_authenticated!

        success(
          action: :sign_up,
          user: user,
          identity: identity,
          existing_account: false,
        )
      end

      def link_with_current_user(normalized)
        existing_for_user = @current_user.user_social_apple

        if existing_for_user
          if existing_for_user.uid != normalized.uid
            Rails.event.notify(
              "social_auth.apple.uid_mismatch",
              user_id: @current_user.id,
              uid_prefix: normalized.uid.to_s.first(8),
            )
            return failure("errors.social_auth.identity_conflict")
          end

          existing_for_user.update_from_auth_hash!(@auth_hash)
          reactivate_identity!(existing_for_user)
          return success(action: :link, user: @current_user, identity: existing_for_user)
        end

        identity = UserSocialApple.lock.find_by(uid: normalized.uid, provider: normalized.provider)

        if identity
          if identity.user_id != @current_user.id
            return failure(
              "errors.social_auth.linked_to_another_user",
              provider: SocialIdentifiable.normalize_provider(normalized.provider),
            )
          end

          identity.update_from_auth_hash!(@auth_hash)
          reactivate_identity!(identity)
          return success(action: :link, user: @current_user, identity: identity)
        end

        identity = build_identity_for_user(@current_user, normalized)
        identity.save!
        identity.touch_authenticated!

        Rails.event.notify(
          "social_auth.linked",
          user_id: @current_user.id,
          provider: normalized.provider,
        )

        success(action: :link, user: @current_user, identity: identity)
      end

      def create_user_for_identity(identity)
        user = ::User.new(status_id: UserStatus::UNVERIFIED_WITH_SIGN_UP)
        assign_identity_to_user(user, identity)
        user.save!
        identity.update!(user: user)
        user
      end

      def build_identity_for_user(user, normalized)
        identity = UserSocialApple.new(
          uid: normalized.uid,
          provider: normalized.provider,
          image: dig_auth(@auth_hash, :info, :image).presence || "",
          token: dig_auth(@auth_hash, :credentials, :token).presence || "",
          refresh_token: dig_auth(@auth_hash, :credentials, :refresh_token).presence || "",
          expires_at: dig_auth(@auth_hash, :credentials, :expires_at) || 0,
        )
        assign_identity_to_user(user, identity)
        identity
      end

      def assign_identity_to_user(user, identity)
        user.user_social_apple = identity
        identity.user = user
      end

      def reactivate_identity!(identity)
        return if identity.user_identity_social_apple_status_id == UserSocialAppleStatus::ACTIVE

        identity.update!(UserSocialApple.status_column => UserSocialAppleStatus::ACTIVE)
      end

      def normalize_auth_hash(auth_hash)
        NormalizedAuth.new(
          uid: extract_uid(auth_hash),
          provider: extract_provider(auth_hash),
          auth_hash: auth_hash,
        )
      end

      def extract_provider(auth_hash)
        provider = auth_hash["provider"] || auth_hash[:provider]
        provider = auth_hash.provider if provider.blank? && auth_hash.respond_to?(:provider)
        provider.to_s.presence || "apple"
      end

      def extract_uid(auth_hash)
        uid = auth_hash["uid"] || auth_hash[:uid]
        uid = auth_hash.uid if uid.blank? && auth_hash.respond_to?(:uid)

        if uid.blank?
          raw_info = dig_auth(auth_hash, :extra, :raw_info)
          uid = raw_info&.dig("sub") || raw_info&.dig(:sub)
        end

        if uid.blank?
          id_info = dig_auth(auth_hash, :extra, :id_info)
          uid = id_info&.dig("sub") || id_info&.dig(:sub)
        end

        if uid.blank?
          uid = extract_uid_from_id_token(auth_hash)
        end

        uid.to_s.presence
      end

      def extract_uid_from_id_token(auth_hash)
        id_token = dig_auth(auth_hash, :credentials, :id_token)
        return nil if id_token.blank?

        payload = JWT.decode(id_token, nil, false).first
        payload["sub"]
      rescue JWT::DecodeError => e
        Rails.logger.warn("[Auth::Social::AppleOrchestrator] Failed to decode id_token: #{e.message}")
        nil
      end

      def dig_auth(hash, *keys)
        memo = hash
        keys.each do |key|
          return nil if memo.nil?

          memo =
            if memo.respond_to?(:key?) && memo.key?(key)
              memo[key]
            elsif memo.respond_to?(:key?) && memo.key?(key.to_s)
              memo[key.to_s]
            elsif memo.respond_to?(:key?) && memo.key?(key.to_sym)
              memo[key.to_sym]
            else
              memo.respond_to?(:[]) ? memo[key] : nil
            end
        end
        memo
      end

      def success(**attrs)
        Result.new({ success: true }.merge(attrs))
      end

      def failure(error_key, **context)
        Result.new(success: false, error_key: error_key, error_context: context)
      end
    end
  end
end
