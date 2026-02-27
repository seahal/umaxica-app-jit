# typed: false
# frozen_string_literal: true

module Auth
  class CurrentResourceResolver
    Result =
      Struct.new(
        :resource,
        :session_public_id,
        :payload,
        :failure_reason,
        keyword_init: true,
      ) do
        def success?
          resource.present?
        end
      end

    def initialize(access_token:, request_host:, resource_type:, resource_class:, token_class:, test_env:)
      @access_token = access_token
      @request_host = request_host
      @resource_type = resource_type
      @resource_class = resource_class
      @token_class = token_class
      @test_env = test_env
    end

    def call
      return failure(:blank_access_token) if @access_token.blank?

      payload = Auth::Base::Token.decode(@access_token, host: @request_host)
      return failure(:token_decode_failed) if payload.blank?

      unless Auth::Base::Token.validate_actor_claim!(payload, @resource_type)
        return failure(:actor_mismatch, payload: payload)
      end

      sid = Auth::Base::Token.extract_session_id(payload)
      return failure(:missing_session_id, payload: payload) if sid.blank?
      return failure(:token_session_not_found, payload: payload) unless token_exists?(sid)

      resource = @resource_class.find_by(id: Auth::Base::Token.extract_subject(payload))
      return failure(:resource_not_found, payload: payload, session_public_id: sid) if resource.blank?

      Result.new(resource: resource, session_public_id: sid, payload: payload, failure_reason: nil)
    end

    private

    def token_exists?(session_public_id)
      check_logic =
        lambda do
          scope = @token_class.where(public_id: session_public_id)
          scope =
            if @token_class.column_names.include?("expired_at")
              scope.where(expired_at: nil)
            elsif @token_class.column_names.include?("revoked_at")
              scope.where(revoked_at: nil)
            else
              scope
            end
          scope.exists?
        end

      if @test_env
        TokenRecord.connected_to(role: :writing, &check_logic)
      else
        TokenRecord.connected_to(role: :reading, &check_logic)
      end
    end

    def failure(reason, payload: nil, session_public_id: nil)
      Result.new(
        resource: nil,
        session_public_id: session_public_id,
        payload: payload,
        failure_reason: reason,
      )
    end
  end
end
