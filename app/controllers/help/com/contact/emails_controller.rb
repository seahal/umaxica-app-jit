module Help
  module Com
    module Contact
      class EmailsController < ApplicationController
        include CloudflareTurnstile

        before_action :set_contact

        def new
          @contact_email = @contact.com_contact_emails.build
          render plain: placeholder_message(:new)
        end
        # 検証コード入力画面
        def edit
          # セッションから email ID を取得
          @contact_email = load_contact_email_from_session

          # セッションチェック
          unless @contact_email && valid_session?(@contact_email)
            redirect_to help_com_root_path,
                        alert: t(".session_expired")
          end
        end

        def create
          render plain: placeholder_message(:create), status: :created
        end

        # 検証コード確認処理
        def update
          # セッションから email ID を取得
          @contact_email = load_contact_email_from_session

          unless @contact_email && valid_session?(@contact_email)
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

        def placeholder_message(action)
          "Corporate contact email #{action} pending for contact #{@contact.id}"
        end

        def load_contact_email_from_session
          session_data = session[:com_contact_email_verification]
          return nil if session_data.nil?

          # セッションから ID を取得して、該当する email を探す
          email_id = session_data["id"]
          @contact.com_contact_emails.find_by(id: email_id)
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
