# typed: false
# frozen_string_literal: true

# FIXME: REWRITE!!!

module Sign
  module Com
    class ApplicationController < ActionController::Base
      include Sign::Com::RouteAliasHelper
      include ::Finisher

      helper Sign::Com::ApplicationHelper

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: ENV.fetch(
                             "SIGN_COM_TRUSTED_ORIGINS",
                             "http://sign.com.localhost,https://sign.com.localhost",
                           )
                             .split(",").map(&:strip),
                           with: :exception

      before_action :enforce_required_telephone_registration!
      after_action :purge_current

      class << self
        def local_prefixes
          prefixes = Array(super)
          app_prefix = controller_path.sub("/com/", "/app/")
          prefixes.include?(app_prefix) ? prefixes : prefixes + [app_prefix]
        end
      end

      private

      def after_login_path
        if current_user&.respond_to?(:verified_telephone?) && !current_user.verified_telephone?
          return new_sign_com_configuration_telephones_registration_path(ri: params[:ri])
        end

        sign_com_configuration_path
      rescue StandardError
        "/"
      end

      def enforce_required_telephone_registration!
        return unless request.format.html?
        return unless current_user&.respond_to?(:verified_telephone?)
        return if current_user.verified_telephone?
        return if telephone_registration_allowed_path?

        redirect_to(
          new_sign_com_configuration_telephones_registration_path(ri: params[:ri]),
          notice: t("sign.app.registration.telephone.create.verification_code_sent", default: nil),
        )
      end

      def telephone_registration_allowed_path?
        allowed = [
          "sign/com/configuration/telephones/registrations",
          "sign/com/configuration/outs",
        ]
        allowed.include?(controller_path)
      end
    end
  end
end
