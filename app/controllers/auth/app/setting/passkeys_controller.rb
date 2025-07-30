# frozen_string_literal: true

module Auth
  module App
    module Setting
      class PasskeysController < ApplicationController
        include WebAuthn
        
        before_action :set_passkey, only: [:show, :edit, :update, :destroy]

        def index
          @passkeys = current_user.passkeys.active
        end

        def show
        end

        def new
          @passkey = Passkey.new
        end

        def create
          # WebAuthn credential registration for settings
        end

        def edit
        end

        def update
          if @passkey.update(passkey_params)
            redirect_to auth_app_setting_passkey_path(@passkey), notice: 'Passkey updated successfully.'
          else
            render :edit
          end
        end

        def destroy
          @passkey.deactivate!
          redirect_to auth_app_setting_passkeys_path, notice: 'Passkey removed successfully.'
        end

        private

        def set_passkey
          @passkey = current_user.passkeys.find(params[:id])
        end

        def passkey_params
          params.require(:passkey).permit(:description)
        end

        def current_user
          # TODO: Implement current user logic
          nil
        end
      end
    end
  end
end