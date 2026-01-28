module Sign
  module Org
    module Configuration
      class SecuritiesController < ApplicationController
        REVIEWED_AT_SESSION_KEY = :sign_org_configuration_security_reviewed_at

        def edit
          @security_cards = build_security_cards
          @reviewed_at = session[REVIEWED_AT_SESSION_KEY]
        end

        def update
          session[REVIEWED_AT_SESSION_KEY] = Time.zone.now
          flash[:notice] = t("controller.sign.org.configuration.security.update.success")
          redirect_to edit_sign_org_configuration_security_path
        end

        private

          def build_security_cards
            [
              security_card(
                title_key: "controller.sign.org.configuration.security.cards.passkeys.title",
                description_key: "controller.sign.org.configuration.security.cards.passkeys.description",
                path: sign_org_configuration_passkeys_path,
                enabled: passkeys_count.positive?,
                stats: passkeys_count,
                stats_label: t("controller.sign.org.configuration.security.cards.passkeys.stats_label")
              ),
              security_card(
                title_key: "controller.sign.org.configuration.security.cards.secrets.title",
                description_key: "controller.sign.org.configuration.security.cards.secrets.description",
                path: sign_org_configuration_secrets_path,
                enabled: secrets_count.positive?,
                stats: secrets_count,
                stats_label: t("controller.sign.org.configuration.security.cards.secrets.stats_label")
              ),
              security_card(
                title_key: "controller.sign.org.configuration.security.cards.sessions.title",
                description_key: "controller.sign.org.configuration.security.cards.sessions.description",
                path: sign_org_configuration_sessions_path,
                enabled: active_session_count.positive?,
                stats: active_session_count,
                stats_label: t("controller.sign.org.configuration.security.cards.sessions.stats_label")
              )
            ]
          end

          def security_card(title_key:, description_key:, path:, enabled:, stats: nil, stats_label: nil)
            {
              title: t(title_key),
              description: t(description_key),
              path: path,
              enabled: enabled,
              stats: stats,
              stats_label: stats_label
            }
          end

          def passkeys_count
            current_staff.staff_passkeys.count
          end

          def secrets_count
            current_staff.staff_secrets.count
          end

          def active_session_count
            current_staff.staff_tokens.where(revoked_at: nil, compromised_at: nil).count
          end
      end
    end
  end
end
