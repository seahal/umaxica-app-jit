module Help
  module Com
    module Contact
      class TelephonesController < ApplicationController
        include CloudflareTurnstile

        before_action :load_contact

        def edit
          Rails.logger.debug { "DEBUG: edit action called, @contact = #{@contact.inspect}" }
          # セッションから telephone ID を取得
          @contact_telephone = load_contact_telephone_from_session
          Rails.logger.debug { "DEBUG: @contact_telephone = #{@contact_telephone.inspect}" }

          # セッションチェック
          unless @contact_telephone && valid_session?(@contact_telephone)
            redirect_to help_com_root_path,
                        alert: t(".session_expired")
            nil
          end
        end

        def update
          # セッションから telephone ID を取得
          @contact_telephone = load_contact_telephone_from_session

          unless @contact_telephone && valid_session?(@contact_telephone)
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
          Rails.logger.debug { "DEBUG: loaded @contact = #{@contact.inspect}, class = #{@contact.class}" }
        end

        def load_contact_telephone_from_session
          session_data = session[:com_contact_telephone_verification]
          return nil if session_data.nil?

          # セッションから ID を取得して、該当する telephone を探す
          telephone_id = session_data["id"]
          @contact.com_contact_telephones.find_by(id: telephone_id)
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
