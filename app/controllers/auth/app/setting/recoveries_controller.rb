# frozen_string_literal: true

module Auth
  module App
    module Setting
      class RecoveriesController < ApplicationController
        BASE58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
        BASE58_SIZE = BASE58.size

        before_action :set_user_recovery_code, only: %i[ show edit update destroy ]

        # GET /recoveries or /recoveries.json
        def index
          @user_recovery_codes = UserRecoveryCode.all
        end

        # GET /recoveries/1 or /recoveries/1.json
        def show
        end

        # GET /recoveries/new
        def new
          @user_recovery_code = UserRecoveryCode.new
          session[:user_recovery_code] = generate_base58_string
        end

        # GET /recoveries/1/edit
        def edit
        end

        # POST /recoveries or /recoveries.json
        def create
          @user_recovery_code = UserRecoveryCode.new(user_recovery_code_params)
          @user_recovery_code.recovery_code = session[:user_recovery_code]

          respond_to do |format|
            if @user_recovery_code.save
              format.html { redirect_to auth_app_setting_recovery_path(@user_recovery_code), notice: "User recovery code was successfully created." }
              format.json { render :show, status: :created, location: auth_app_setting_recovery_path(@user_recovery_code) }
            else
              format.html { render :new, status: :unprocessable_content }
              format.json { render json: @user_recovery_code.errors, status: :unprocessable_content }
            end
          end
        end

        # PATCH/PUT /recoveries/1 or /recoveries/1.json
        def update
          respond_to do |format|
            if @user_recovery_code.update(user_recovery_code_params)
              format.html { redirect_to auth_app_setting_recovery_path(@user_recovery_code), notice: "User recovery code was successfully updated." }
              format.json { render :show, status: :ok, location: auth_app_setting_recovery_path(@user_recovery_code) }
            else
              format.html { render :edit, status: :unprocessable_content }
              format.json { render json: @user_recovery_code.errors, status: :unprocessable_content }
            end
          end
        end

        # DELETE /recoveries/1 or /recoveries/1.json
        def destroy
          @user_recovery_code.destroy!

          respond_to do |format|
            format.html { redirect_to auth_app_setting_recoveries_path, status: :see_other, notice: "User recovery code was successfully destroyed." }
            format.json { head :no_content }
          end
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_user_recovery_code
          @user_recovery_code = UserRecoveryCode.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def user_recovery_code_params
          params.expect(user_recovery_code: [:confirm_create_recovery_code])
        end

        def generate_base58_string
          result = String.new(capacity: 24)
          24.times { result << BASE58[SecureRandom.random_number(BASE58_SIZE)] }
          result
        end
      end
    end
  end
end
