module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile
      include ROTP

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
          otp_code = @email.generate_verifier!
          Email::Com::ContactMailer.with(
            email_address: @email.email_address,
            pass_code: otp_code
          ).create.deliver_now

          # Success: redirect to email verification
          flash[:notice] = t(".success")
          redirect_to new_help_com_contact_email_path(contact_id: @contact.id)
        else
          # Validation failed: re-render form with errors
          @email_address = params.dig(:com_contact, :email_address) || ""
          @telephone_number = params.dig(:com_contact, :telephone_number) || ""
          @contact_categories = ComContactCategory.all
          render :new, status: :unprocessable_entity
        end
      end
    end
  end
end
