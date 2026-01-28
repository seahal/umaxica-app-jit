# frozen_string_literal: true

module Sign
  module App
    # Concern for preventing sign-up when user is already logged in
    # Deletes both auth cookies (access + refresh) before checking current_user
    # Returns 409 Conflict with HTML error page if user still logged in after cookie deletion
    #
    # Usage:
    #   class EmailsController < ApplicationController
    #     include Sign::App::SignUpGuard
    #     prevent_logged_in_signup! only: [:new, :create]
    #   end
    module SignUpGuard
      extend ActiveSupport::Concern

      included do
        # Make helper methods available if needed
        if respond_to?(:helper_method)
          helper_method :sign_up_conflict_message
        end
      end

      class_methods do
        # Declare actions that should prevent logged-in users from signing up
        #
        # @param only [Array<Symbol>] Actions to apply the guard to
        # @param except [Array<Symbol>] Actions to exclude from the guard
        def prevent_logged_in_signup!(only: nil, except: nil)
          prepend_before_action :enforce_logged_out_for_signup!, only: only, except: except
        end
      end

      private

        # Enforces that user must be logged out for sign-up
        # Steps:
        #   1. Delete both auth cookies (access + refresh)
        #   2. Check if current_user still present
        #   3. If yes, render 409 Conflict with HTML error page
        def enforce_logged_out_for_signup!
          # Step 1: Delete auth cookies
          delete_auth_cookies!

          # Step 2: Check if user is still logged in (bypassing cookie check)
          # Remove memoized current_resource to force re-check
          remove_instance_variable(:@current_resource) if defined?(@current_resource)

          # Step 3: If still logged in, return 409 Conflict
          return unless logged_in?

          Rails.event.notify(
            "sign_up.logged_in_user_blocked",
            user_id: current_resource&.id,
            path: request.path,
            method: request.method,
          )

          render_sign_up_conflict
        end

        # Deletes both auth cookies (access and refresh)
        # Uses the same cookie keys as Auth::Base
        def delete_auth_cookies!
          base_names = %w[
            access_token
            refresh_token
            jit_auth_access
            jit_auth_refresh
          ].freeze

          cookie_names = base_names.flat_map do |base|
            [ base, "__Secure-#{base}", "__Host-#{base}" ]
          end.uniq

          cookie_names.each do |name|
            cookies.delete(name)
            cookies.delete(name, path: "/")
          end
        end

        # Renders 409 Conflict with HTML error page
        def render_sign_up_conflict
          @error_message = sign_up_conflict_message
          @sign_in_path = sign_in_path_for_redirect
          @configuration_path = configuration_path_for_redirect

          # Render inline HTML to avoid needing a separate view file
          # rubocop:disable Rails/OutputSafety
          render html: sign_up_conflict_html.html_safe, status: :conflict, layout: false
          # rubocop:enable Rails/OutputSafety
        end

        # Message explaining the conflict
        def sign_up_conflict_message
          I18n.t(
            "sign.app.sign_up.already_logged_in",
            # rubocop:disable I18n/RailsI18n/DecorateString
            default: "You are already logged in. Please sign out before creating a new account.",
            # rubocop:enable I18n/RailsI18n/DecorateString
          )
        end

        # HTML for the conflict page
        # rubocop:disable I18n/RailsI18n/DecorateString
        def sign_up_conflict_html
          <<~HTML
            <!DOCTYPE html>
            <html lang="#{I18n.locale}">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>#{I18n.t('sign.app.sign_up.conflict.title', default: 'Already Logged In')}</title>
              <style>
                body {
                  font-family: system-ui, -apple-system, sans-serif;
                  line-height: 1.6;
                  color: #333;
                  max-width: 600px;
                  margin: 50px auto;
                  padding: 20px;
                }
                .container {
                  border: 1px solid #ddd;
                  border-radius: 8px;
                  padding: 30px;
                  background: #f9f9f9;
                }
                h1 { color: #d9534f; margin-top: 0; }
                .message { margin: 20px 0; }
                .actions { margin-top: 30px; }
                .actions a {
                  display: inline-block;
                  margin-right: 15px;
                  margin-bottom: 10px;
                  padding: 10px 20px;
                  background: #0066cc;
                  color: white;
                  text-decoration: none;
                  border-radius: 4px;
                }
                .actions a:hover { background: #0052a3; }
                .actions a.secondary {
                  background: #6c757d;
                }
                .actions a.secondary:hover { background: #5a6268; }
              </style>
            </head>
            <body>
              <div class="container">
                <h1>#{I18n.t('sign.app.sign_up.conflict.heading', default: 'Already Logged In')}</h1>
                <div class="message">
                  <p>#{@error_message}</p>
                  <p>#{I18n.t('sign.app.sign_up.conflict.explanation', default: 'To create a new account, please sign out of your current account first.')}</p>
                </div>
                <div class="actions">
                  <a href="#{@configuration_path}">#{I18n.t('sign.app.sign_up.conflict.go_to_account', default: 'Go to My Account')}</a>
                  <a href="#{@sign_in_path}" class="secondary">#{I18n.t('sign.app.sign_up.conflict.sign_out', default: 'Sign Out')}</a>
                </div>
              </div>
            </body>
            </html>
          HTML
        end
        # rubocop:enable I18n/RailsI18n/DecorateString

        # Path to sign-in page for redirect
        def sign_in_path_for_redirect
          if respond_to?(:new_sign_app_in_path)
            new_sign_app_in_path
          elsif respond_to?(:new_sign_org_in_path)
            new_sign_org_in_path
          else
            "/in"
          end
        end

        # Path to configuration/dashboard for redirect
        def configuration_path_for_redirect
          if respond_to?(:sign_app_configuration_path)
            sign_app_configuration_path
          elsif respond_to?(:sign_org_configuration_path)
            sign_org_configuration_path
          else
            "/"
          end
        end
    end
  end
end
