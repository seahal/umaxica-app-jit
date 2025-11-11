module Help
  module Com
    module Contact
      class TelephonesController < ApplicationController
        include CloudflareTurnstile

        before_action :load_contact

        def new
          # セッションをクリア(セキュリティ対策)
          session[:com_contact_telephone_verification] = nil
          @contact_telephone = @contact.com_contact_telephones.build
        end

        def edit
          @contact_telephone = @contact.com_contact_telephone

          # セッションチェック
          unless valid_session?(@contact_telephone)
            redirect_to help_com_root_path,
                        alert: t(".session_expired")
            nil
          end
        end
        def create
          @contact_telephone = @contact.com_contact_telephones.build(telephone_params)

          if turnstile_passed? && @contact_telephone.save
            # 6桁のOTPを生成
            otp_code = @contact_telephone.generate_otp!

            # セッションに保存
            session[:com_contact_telephone_verification] = {
              id: @contact_telephone.id,
              contact_id: @contact.id,
              expires_at: 10.minutes.from_now.to_i
            }

            # TODO: SMS送信処理を実装
            # SmsService.send_message(
            #   to: @contact_telephone.telephone_number,
            #   message: "Your verification code is: #{otp_code}",
            #   subject: "Contact Verification Code"
            # )

            # 開発環境ではログに出力
            Rails.logger.info("OTP code for #{@contact_telephone.telephone_number}: #{otp_code}") if Rails.env.development?

            redirect_to edit_help_com_contact_telephone_path(@contact, @contact_telephone),
                        notice: t(".success")
          else
            render :new, status: :unprocessable_entity
          end
        end


        def update
          @contact_telephone = @contact.com_contact_telephone

          unless valid_session?(@contact_telephone)
            redirect_to help_com_root_path,
                        alert: t(".session_expired")
            return
          end

          otp_code = params.dig(:com_contact_telephone, :otp_code)

          if @contact_telephone.verify_otp(otp_code)
            session[:com_contact_telephone_verification] = nil

            # 全ての確認が完了したので完了ページへ
            redirect_to help_com_contact_path(@contact),
                        notice: t(".success")
          else
            if @contact_telephone.otp_attempts_left <= 0
              flash.now[:alert] = t(".max_attempts")
            elsif @contact_telephone.otp_expired?
              flash.now[:alert] = t(".expired")
            else
              flash.now[:alert] = t(".invalid_code",
                                   attempts_left: @contact_telephone.otp_attempts_left)
            end
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def load_contact
          @contact = ComContact.find(params[:contact_id])
        end

        def telephone_params
          params.expect(com_contact_telephone: [ :telephone_number ])
        end

        def turnstile_passed?
          result = cloudflare_turnstile_validation
          return true if result["success"]

          @contact_telephone.errors.add(:base, :turnstile,
                                        message: t("help.com.contact.telephones.create.turnstile_error"))
          false
        end

        def valid_session?(contact_telephone)
          session_data = session[:com_contact_telephone_verification]
          return false if session_data.nil?

          session_data["id"] == contact_telephone.id &&
            session_data["contact_id"] == @contact.id &&
            session_data["expires_at"].to_i > Time.now.to_i
        end
      end
    end
  end
end
