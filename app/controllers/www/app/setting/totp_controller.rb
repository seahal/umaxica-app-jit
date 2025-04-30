module Www
  module App
    module Setting
      class TotpController < ApplicationController
        def index
          @utbotp = TimeBasedOneTimePassword.all
        end

        def new
          # make private_key for TOTP
          session[:privacy_key] ||= ROTP::Base32.random_base32
          # generate totp object
          totp = ROTP::TOTP.new(session[:privacy_key])
          # put qrcode of totp objects
          @png = RQRCode::QRCode.new(totp.provisioning_uri("localhost@example.com")).as_png() # ToDo: <= set account_id
          #
          @utbotp = TimeBasedOneTimePassword.new
        end

        def create
          @utbotp = TimeBasedOneTimePassword.new(sample_params)
          @utbotp.private_key = session[:privacy_key]
          @utbotp.id = "0001010101"

          respond_to do |format|
            if ROTP::TOTP.new(@utbotp.private_key).verify(@utbotp.first_token) && @utbotp.save
              session[:privacy_key] = nil
              format.html { redirect_to www_app_setting_totp_index_path, notice: "Sample was successfully created." }
            else
              totp = ROTP::TOTP.new(@utbotp.private_key)
              @png = RQRCode::QRCode.new(totp.provisioning_uri("localhost@example.com")).as_png()
              format.html { render :new, status: :unprocessable_entity }
            end
          end
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_sample
          @sample = TimeBasedOneTimePassword.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def sample_params
          params.expect(time_based_one_time_password: [ :first_token ])
        end
      end
    end
  end
end
