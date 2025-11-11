module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile
      include ROTP

      def new
        @email_address = ""
        @telephone_number = ""
        load_contact_categories
      end

      def create
        passed_turnstile = turnstile_passed_without_contact?

        unless passed_turnstile
          @email_address = params.dig(:com_contact, :email_address) || ""
          @telephone_number = params.dig(:com_contact, :telephone_number) || ""
          load_contact_categories
          render :new, status: :unprocessable_entity
          return
        end

        # Use transaction to ensure all-or-nothing
        ActiveRecord::Base.transaction do
          # First create the contact
          @contact = ComContact.new(
            contact_category_title: params.dig(:com_contact, :contact_category_title),
            public_id: Nanoid.generate
          )
          @contact.confirm_policy = params.dig(:com_contact, :confirm_policy)
          @contact.save!

          # Then create email and telephone records with the contact_id
          @email = ComContactEmail.new(
            com_contact_id: @contact.id,
            email_address: params.dig(:com_contact, :email_address),
            expires_at: 24.hours.from_now
          )
          @email.save!

          @telephone = ComContactTelephone.new(
            com_contact_id: @contact.id,
            telephone_number: params.dig(:com_contact, :telephone_number),
            expires_at: 24.hours.from_now
          )
          @telephone.save!
        end

          # Generate OTP and send email
          otp_code = @email.generate_verifier!
          Email::Com::ContactMailer.with(
            email_address: @email.email_address,
            pass_code: otp_code
          ).create.deliver_now

        # ⇑ rewrite app/controllers/concerns/rotp.rb and use here

        redirect_to edit_help_com_contact_email_path(contact_id: @contact.id), notice: t(".success")
      rescue ActiveRecord::RecordInvalid => e
        # On error, preserve input values
        @email_address = params.dig(:com_contact, :email_address) || ""
        @telephone_number = params.dig(:com_contact, :telephone_number) || ""
        # re-set the contact of privacy confirmation status
        @contact ||= ComContact.new(contact_category_title: params.dig(:com_contact, :contact_category_title))
        @contact.confirm_policy = params.dig(:com_contact, :confirm_policy)
        @contact.errors.add(:base, e.message)
        # re-set the contact of privacy status
        load_contact_categories
        render :new, status: :unprocessable_entity
      end

      private

      def contact_params
        params.require(:com_contact).permit(
          :contact_category_title,
          :confirm_policy,
          :email_address,
          :telephone_number
        )
      end

      def load_contact_categories
        @contact_categories = ComContactCategory.order(:title)
      end

      def turnstile_passed_without_contact?
        result = cloudflare_turnstile_validation
        result["success"]
      end
    end
  end
end
