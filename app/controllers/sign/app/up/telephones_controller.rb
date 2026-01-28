# frozen_string_literal: true

module Sign
  module App
    module Up
      class TelephonesController < ApplicationController
        include Sign::App::TelephoneRegistrable
        include Sign::App::SignUpGuard

        prevent_logged_in_signup! only: %i[new create]

        def show
        end

        def new
          @user_telephone = UserTelephone.new
        end

        def edit
          @user_telephone = UserTelephone.find_by(id: params["id"])
          if @user_telephone.blank? ||
             @user_telephone.otp_expired? ||
             @user_telephone.user_telephone_status_id != "UNVERIFIED_WITH_SIGN_UP"
            redirect_params = build_notice_params(t("sign.app.registration.telephone.edit.session_expired"))
            flash[:notice] = redirect_params.delete(:notice)
            redirect_to new_sign_app_up_telephone_path(redirect_params)
          end
        end

        def create
          telephone_params = params.expect(user_telephone: [ :number, :confirm_policy, :confirm_using_mfa ])
          preserve_redirect_parameter

          if initiate_telephone_verification(
            telephone_params[:number],
            confirm_policy: telephone_params[:confirm_policy],
            confirm_using_mfa: telephone_params[:confirm_using_mfa],
          )
            redirect_params = build_notice_params(t("sign.app.registration.telephone.create.verification_code_sent"))
            flash[:notice] = redirect_params.delete(:notice)
            redirect_to edit_sign_app_up_telephone_path(@user_telephone, redirect_params)
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          submitted_code = params.dig("user_telephone", "pass_code")
          status =
            complete_telephone_verification(params["id"], submitted_code) do |user_telephone|
              ActiveRecord::Base.transaction do
                @user = User.create!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)
                user_telephone.user = @user
                audit = UserAudit.new(actor: @user, event_id: "SIGNED_UP_WITH_TELEPHONE")
                audit.user = @user
                audit.save!
                user_telephone.save!
              end

              log_in(@user, record_login_audit: false)
            end

          case status
          when :success
            redirect_with_notice(sign_app_configuration_path, t("sign.app.registration.telephone.update.success"))
          when :already_verified
            render plain: t("sign.app.registration.telephone.update.already_verified"), status: :conflict
          when :session_expired
            redirect_params = build_alert_params(t("sign.app.registration.telephone.update.session_expired"))
            flash[:alert] = redirect_params.delete(:alert)
            redirect_to new_sign_app_up_telephone_path(redirect_params)
          when :locked
            redirect_params = build_alert_params(t("sign.app.registration.telephone.update.attempts_exceeded"))
            flash[:alert] = redirect_params.delete(:alert)
            redirect_to new_sign_app_up_telephone_path(redirect_params)
          when :invalid_code
            render :edit, status: :unprocessable_content
          end
        end
      end
    end
  end
end
