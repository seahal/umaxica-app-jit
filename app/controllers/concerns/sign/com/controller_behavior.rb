# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module ControllerBehavior
      extend ActiveSupport::Concern

      included do
        include Sign::Com::RouteAliasHelper

        helper Sign::Com::ApplicationHelper
        layout "sign/com/application"
        protect_from_forgery using: :header_or_legacy_token,
                             trusted_origins: ENV.fetch(
                               "SIGN_COM_TRUSTED_ORIGINS",
                               "http://sign.com.localhost,https://sign.com.localhost",
                             )
                               .split(",").map(&:strip),
                             with: :exception
        before_action :enforce_required_telephone_registration!
      end

      class_methods do
        def local_prefixes
          prefixes = Array(super)
          app_prefix = controller_path.sub("/com/", "/app/")
          prefixes.include?(app_prefix) ? prefixes : prefixes + [app_prefix]
        end
      end

      private

      def after_login_path
        return new_sign_com_configuration_telephones_registration_path(ri: params[:ri]) if current_user&.respond_to?(:verified_telephone?) && !current_user.verified_telephone?

        sign_com_configuration_path
      rescue StandardError
        "/"
      end

      def enforce_required_telephone_registration!
        return unless request.format.html?
        return unless current_user&.respond_to?(:verified_telephone?)
        return if current_user.verified_telephone?
        return if telephone_registration_allowed_path?

        redirect_to(new_sign_com_configuration_telephones_registration_path(ri: params[:ri]))
      end

      def telephone_registration_allowed_path?
        [
          "sign/com/configuration/telephones/registrations",
          "sign/com/configuration/outs",
        ].include?(controller_path)
      end
    end
  end
end
