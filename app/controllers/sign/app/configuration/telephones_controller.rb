# frozen_string_literal: true

module Sign
  module App
    class Configuration::TelephonesController < ApplicationController
      include Sign::App::TelephoneRegistrable

      before_action :authenticate_user!

      def index
        @user_telephones = current_user.user_telephones
      end

      def new
        @user_telephone = UserTelephone.new
      end

      def edit
        @user_telephone = UserTelephone.find_by(id: params[:id])
      end

      def create
        tel_params = params.expect(user_telephone: [:telephone_number])
        if initiate_telephone_verification(tel_params[:telephone_number])
          redirect_to edit_sign_app_configuration_telephone_path(@user_telephone.id)
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        submitted_code = params[:user_telephone][:pass_code]
        status =
          complete_telephone_verification(params[:id], submitted_code) do |user_telephone|
            user_telephone.user = current_user
            user_telephone.save!
          end

        if status == :success
          redirect_to sign_app_configuration_telephones_path,
                      notice: t("sign.app.configuration.telephone.update.success")
        else
          render :edit, status: :unprocessable_content
        end
      end
    end
  end
end
