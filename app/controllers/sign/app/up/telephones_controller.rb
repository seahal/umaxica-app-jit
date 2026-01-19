# frozen_string_literal: true

class Sign::App::Up::TelephonesController < ApplicationController
  include Sign::App::TelephoneRegistrable
  include Auth::RedirectParameterHandling
  include Auth::PreAuthenticationGuards
  include Auth::SessionAuthentication

  before_action :ensure_not_logged_in_for_registration

  def new
    @user_telephone = UserTelephone.new
  end

  def edit
    @user_telephone = UserTelephone.find_by(id: params[:id])
  end

  def create
    tel_params = params.expect(user_telephone: [:telephone_number])
    if initiate_telephone_verification(tel_params[:telephone_number])
      redirect_params = build_notice_params(t("sign.app.registration.telephone.create.verification_code_sent"))
      redirect_to edit_sign_app_up_telephone_path(@user_telephone.id, redirect_params)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    submitted_code = params[:user_telephone][:pass_code]
    status =
      complete_telephone_verification(params[:id], submitted_code) do |user_telephone|
        ActiveRecord::Base.transaction do
          @user = User.create!(status_id: "VERIFIED_WITH_SIGN_UP")
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
      redirect_with_notice("/", t("sign.app.registration.telephone.update.success"))
    else
      redirect_to new_sign_app_up_telephone_path, alert: t("sign.app.registration.telephone.update.failed")
    end
  end
end
