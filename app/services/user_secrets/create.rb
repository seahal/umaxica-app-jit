# frozen_string_literal: true

module UserSecrets
  class Create
    ACTION = "user_secret.create"
    EVENT_ID = "USER_IDENTITY_SECRET_CREATE"

    Result = Struct.new(:secret, :raw_secret, keyword_init: true)

    def self.call(actor:, user:, params:, raw_secret: nil)
      new(actor: actor, user: user, params: params, raw_secret: raw_secret).call
    end

    def initialize(actor:, user:, params:, raw_secret: nil)
      @actor = actor
      @user = user
      @params = params
      @raw_secret = raw_secret
    end

    def call
      raw_secret = @raw_secret.presence || UserSecret.generate_raw_secret

      # Generate name from raw_secret prefix (first 4 chars)
      # Ignore params[:name] as it's a security risk to allow user-controlled names
      name = raw_secret.first(4)

      secret = @user.user_secrets.new(name: name)
      secret.raw_secret = raw_secret
      secret.password = raw_secret

      # Always set to ACTIVE status (ignore params[:enabled])
      # Always set to UNLIMITED kind (only kind currently issued via UI)
      secret.user_secret_status_id = UserSecret.status_id_for(:active)
      secret.user_secret_kind_id = UserSecretKind::UNLIMITED

      audit_class.transaction do
        UserSecret.transaction do
          secret.save!
          audit_class.create!(
            actor: @actor,
            subject_type: "UserSecret",
            subject_id: secret.id.to_s,
            event_id: EVENT_ID,
            occurred_at: Time.current,
            context: { action: ACTION },
          )
        end
      end

      Result.new(secret: secret, raw_secret: raw_secret)
    end

    private

      def audit_class
        @audit_class ||= @actor.is_a?(Staff) ? StaffAudit : UserAudit
      end
  end
end
