module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile
      include Rotp

      def new
        @email_address = ""
        @telephone_number = ""
        @contact_categories = ComContactCategory.all
      end

      def create
        # Cloudflare Turnstile validation
        turnstile_result = cloudflare_turnstile_validation

        # Create contact with nested associations
        @contact = ComContact.new(
          contact_category_title: params.dig(:com_contact, :contact_category_title),
          confirm_policy: params.dig(:com_contact, :confirm_policy)
        )

        # Build associated email and telephone
        @email = @contact.com_contact_emails.build(
          email_address: params.dig(:com_contact, :email_address)
        )

        @telephone = @contact.com_contact_telephones.build(
          telephone_number: params.dig(:com_contact, :telephone_number)
        )

        # TODO: ここを、@contact にエラーを注入して、エラーメッセージを出したい。
        unless turnstile_result["success"]
          @contact.errors.add(:base, "ロボットではないことの確認に失敗しました。もう一度お試しください。")
          @email_address = params.dig(:com_contact, :email_address) || ""
          @telephone_number = params.dig(:com_contact, :telephone_number) || ""
          @contact_categories = ComContactCategory.all
          render :new, status: :unprocessable_entity
          return
        end

        if @contact.save
          # Generate OTP and send email
          sec, counter, token = generate_hotp_code

          # ここに へとｔBlue を保存する処理を追加すること
          Email::Com::ContactMailer.with(
            email_address: @email.email_address,
            pass_code: token
          ).create.deliver_now

          # Redirect with proper host options
          redirect_to new_help_com_contact_email_url(
            contact_id: @contact.public_id,
            **help_email_redirect_options
          ), notice: I18n.t("help.com.contacts.create.success")
        else
          # Validation failed: re-render form with errors
          @email_address = params.dig(:com_contact, :email_address) || ""
          @telephone_number = params.dig(:com_contact, :telephone_number) || ""
          @contact_categories = ComContactCategory.all
          render :new, status: :unprocessable_entity
        end
      end

      private

      def help_email_redirect_options
        {
          host: help_corporate_host,
          port: request.port,
          protocol: request.protocol.delete_suffix("://")
        }.compact
      end

      def help_corporate_host
        ENV["HELP_CORPORATE_URL"].presence || request.host
      end
    end
  end
end
