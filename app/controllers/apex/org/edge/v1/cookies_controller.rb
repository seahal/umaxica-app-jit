# typed: false
# frozen_string_literal: true

module Apex
  module Org
    module Edge
      module V1
        class CookiesController < ApplicationController
          public_strict!
          include ::Preference::WebCookieEndpoint

          skip_before_action :set_preferences_cookie, raise: false
          skip_before_action :resolve_param_context, raise: false
          skip_before_action :set_region, raise: false
          skip_before_action :set_locale, raise: false
          skip_before_action :set_timezone, raise: false
          skip_before_action :set_color_theme, raise: false
          skip_before_action :enforce_verification_if_required, raise: false

          def show
            render json: { show_banner: show_banner? }, status: :ok
          end

          def update
            apply_consented_update_from_request!
            set_consented_buffer_cookie!
            render json: { show_banner: show_banner? }, status: :ok
          end
        end
      end
    end
  end
end
