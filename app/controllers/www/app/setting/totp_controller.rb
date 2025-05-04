module Www
  module App
    module Setting
      class TotpController < ApplicationController
        def index
          @utbotp = TimeBasedOneTimePassword.all
        end

        def new
          # make private_key for TOTP
          session[:private_key] ||= ROTP::Base32.random_base32
          # generate totp object
          totp = ROTP::TOTP.new(session[:private_key])
          # put qrcode of totp objects
          @png = RQRCode::QRCode.new(totp.provisioning_uri("umaxica")).as_png() # ToDo: <= set account_id
          #
          @utbotp = TimeBasedOneTimePassword.new
        end

        def create
          @utbotp = TimeBasedOneTimePassword.new(sample_params)
          @utbotp.private_key = session[:private_key]
          @utbotp.id = SecureRandom.uuid_v7

          if ROTP::TOTP.new(@utbotp.private_key).verify(@utbotp.first_token) && @utbotp.save
            session[:private_key] = nil
            redirect_to www_app_setting_totp_index_path, notice: "TOTP was successfully created."
          else
            @utbotp.valid?
            totp = ROTP::TOTP.new(@utbotp.private_key)
            @png = RQRCode::QRCode.new(totp.provisioning_uri("umaxica")).as_png()
            render :new, status: :unprocessable_entity
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
        params.expect(time_based_one_time_password: [:first_token])
      end
    end
  end
end
