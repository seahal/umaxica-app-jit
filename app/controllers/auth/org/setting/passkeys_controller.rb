# frozen_string_literal: true

module Auth
  module Org
    module Setting
      class PasskeysController < ApplicationController
        include WebAuthn

        before_action :set_passkey, only: [ :show, :edit, :update, :destroy ]

        def index
          @passkeys = current_staff.staff_webauthn_credentials.active
        end

        def show
        end

        def new
          @passkey = StaffWebauthnCredential.new
        end

        def create
          # WebAuthn credential registration for staff
        end

        def edit
        end

        def update
          if @passkey.update(passkey_params)
            redirect_to auth_org_setting_passkey_path(@passkey), notice: "Passkey updated successfully."
          else
            render :edit
          end
        end

        def destroy
          @passkey.deactivate!
          redirect_to auth_org_setting_passkeys_path, notice: "Passkey removed successfully."
        end

        private

        def set_passkey
          @passkey = current_staff.staff_webauthn_credentials.find(params[:id])
        end

        def passkey_params
          params.require(:staff_webauthn_credential).permit(:nickname)
        end

        def current_staff
          # TODO: Implement current staff logic
          nil
        end
      end
    end
  end
end
