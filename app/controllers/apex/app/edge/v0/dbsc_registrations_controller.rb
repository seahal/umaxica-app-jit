# typed: false
# frozen_string_literal: true

module Apex
  module App
    module Edge
      module V0
        class DbscRegistrationsController < ApplicationController
          include ::Preference::WebCookieEndpoint

          skip_before_action :resolve_param_context, raise: false
          skip_before_action :set_region, raise: false
          skip_before_action :set_locale, raise: false
          skip_before_action :set_timezone, raise: false
          skip_before_action :set_color_theme, raise: false
          skip_before_action :enforce_withdrawal_gate!, raise: false
          skip_before_action :transparent_refresh_access_token, raise: false
          skip_before_action :enforce_verification_if_required, raise: false

          skip_forgery_protection

          def create
            response.set_header("Cache-Control", "no-store")

            if request.headers[Preference::IoKeys::Headers::DBSC_SESSION_ID].present?
              handle_bound_cookie_refresh
            else
              handle_registration
            end
          end

          private

          def current_preference_record
            preference, = load_preference_record_from_refresh_token!(create_if_missing: false)
            preference
          end

          def handle_registration
            result = Dbsc::RegistrationService.call(
              record: current_preference_record,
              proof: request.headers[Preference::IoKeys::Headers::DBSC_RESPONSE],
              expected_audience: apex_app_edge_v0_dbsc_registration_url,
            )

            if result[:ok]
              preference = result[:record]
              set_preference_dbsc_cookie!(
                result[:session_id],
                expires_at: preference_dbsc_cookie_expires_at(preference),
              )
              render json: {
                session_identifier: result[:session_id],
                refresh_url: apex_app_edge_v0_dbsc_registration_url,
                scope: {
                  origin: request.base_url,
                  include_site: false,
                },
                credentials: [
                  {
                    type: "cookie",
                    name: Preference::CookieName.dbsc,
                    attributes: dbsc_cookie_attributes_string,
                  },
                ],
              }, status: :created
            else
              render json: { error: "DBSC registration failed", error_code: result[:error_code] },
                     status: :unprocessable_content
            end
          end

          def handle_bound_cookie_refresh
            preference = current_preference_record
            return head :unauthorized if preference.blank?

            session_id = request.headers[Preference::IoKeys::Headers::DBSC_SESSION_ID]
            proof = request.headers[Preference::IoKeys::Headers::DBSC_RESPONSE]

            parsed_session_id = Dbsc::HeaderParser.string_value(session_id)

            if proof.blank?
              challenge = issue_preference_dbsc_challenge_for!(preference)
              response.set_header(
                Preference::IoKeys::Headers::DBSC_CHALLENGE,
                %("#{challenge}";id="#{parsed_session_id}"),
              )
              return head :forbidden
            end

            result = Dbsc::VerificationService.call(
              record: preference, session_id: session_id, proof: proof,
              expected_audience: apex_app_edge_v0_dbsc_registration_url,
            )
            return render json: { error: "DBSC verification failed", error_code: result[:error_code] },
                          status: :unprocessable_content unless result[:ok]

            preference.update!(dbsc_challenge: nil, dbsc_challenge_issued_at: nil)
            set_preference_dbsc_cookie!(
              preference.dbsc_session_id,
              expires_at: preference_dbsc_cookie_expires_at(preference),
            )
            head :no_content
          end

          def dbsc_cookie_attributes_string
            [
              "Path=/",
              ("Domain=#{request.host}"),
              ("Secure" if Rails.env.production?),
              "HttpOnly",
              "SameSite=Lax",
            ].compact.join("; ")
          end
        end
      end
    end
  end
end
