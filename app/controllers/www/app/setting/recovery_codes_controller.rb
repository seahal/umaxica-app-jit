NON_CONFUSABLE_ALPHANUMERIC_CHARACTERS = "ABCDEFHIJKMNOPRSTWXY2347"
NON_CONFUSABLE_ALPHANUMERIC_SIZE = NON_CONFUSABLE_ALPHANUMERIC_CHARACTERS.length

module Www
  module App
    module Setting
      class RecoveryCodesController < ApplicationController
        def index
          @user_recover_code = UserRecoveryCode.all
        end

        def new
          @user_recover_code = UserRecoveryCode.new
        end

        def create
          @user_recover_code = UserRecoveryCode.new(id: SecureRandom.uuid_v7, confirm_create_recovery_code: params[:user_recovery_code][:confirm_create_recovery_code])
          @user_recover_code.password = 16.times.map { NON_CONFUSABLE_ALPHANUMERIC_CHARACTERS[SecureRandom.random_number(NON_CONFUSABLE_ALPHANUMERIC_SIZE)] }.join
          argon2 = Argon2::Password.new()
          @user_recover_code.password_digest = argon2.create(@user_recover_code.password)
          if @user_recover_code.save
            redirect_to www_app_setting_recovery_codes_path(@user_recover_code), notice: "Sample was successfully created."
          else
            render :new
          end
        end

        def show
        end

        def delete
        end
      end
    end
  end
end
