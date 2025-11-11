module Help
  module Com
    module Contact
      class EmailsController < ApplicationController
        include CloudflareTurnstile

        before_action :set_contact

        # 検証コード入力画面
        def edit
          @contact_email = @contact.com_contact_email

          # セッションチェック
          unless valid_session?(@contact_email)
            redirect_to help_com_root_path,
                        alert: t(".session_expired")
          end
        end

        # 検証コード確認処理
        def update
          @contact_email = @contact.com_contact_email

          unless valid_session?(@contact_email)
            redirect_to help_com_root_path,
                        alert: t(".session_expired")
            return
          end

          verification_code = params.dig(:com_contact_email, :verification_code)

          if @contact_email.verify_code(verification_code)
            # セッションをクリア
            session[:com_contact_email_verification] = nil

            # 次は電話番号の確認へ
            redirect_to edit_help_com_contact_telephone_path(@contact),
                        notice: t(".success")
          else
            # 検証失敗時のエラーメッセージ
            if @contact_email.verifier_attempts_left <= 0
              flash.now[:alert] = t(".max_attempts")
            elsif @contact_email.verifier_expired?
              flash.now[:alert] = t(".expired")
            else
              flash.now[:alert] = t(".invalid_code",
                                   attempts_left: @contact_email.verifier_attempts_left)
            end
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def set_contact
          @contact = ComContact.find(params[:contact_id])
        end

        def valid_session?(contact_email)
          session_data = session[:com_contact_email_verification]
          return false if session_data.nil?

          # セッションデータが一致し、有効期限内であることを確認
          session_data["id"] == contact_email.id &&
            session_data["contact_id"] == @contact.id &&
            session_data["expires_at"].to_i > Time.now.to_i
        end
      end
    end
  end
end
