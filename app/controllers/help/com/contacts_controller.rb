module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile

      def show
      end

      def new
        @contact = ComContact.new
        @contact_categories = ComContactCategory.all
      end

      def create
        @contact = ComContact.new(contact_params)
        if @contact.save
          redirect_to new_help_com_contact_url, notice: t("ja.help.com.contacts.create.success")
        else
          load_contact_categories
          flash.now[:alert] ||= t("ja.help.com.contacts.create.failure")
          render :new, status: :unprocessable_entity
        end
      end

      private

      def contact_params
        params.expect(com_contact: [ :confirm_policy,
                                                     :contact_category_title,
                                                     :contact_status_title,
                                                     :email_address,
                                                     :telephone_number,
                                                     :email_pass_code,
                                                     :telephone_pass_code,
                                                     :title,
                                                     :description ])
      end

      def load_contact_categories
        @contact_categories = ComContactCategory.order(:title)
      end

      def turnstile_passed?
        result = cloudflare_turnstile_validation
        return true if result["success"]

        Rails.logger.warn("Cloudflare Turnstile verification failed: #{result}")
        @com_contact.errors.add(:base, :turnstile, message: t("help.app.contacts.create.turnstile_error"))
        flash.now[:alert] = t("help.app.contacts.create.turnstile_error")
        false
      rescue StandardError => error
        Rails.logger.error("Cloudflare Turnstile verification exception: #{error.message}")
        @com_contact.errors.add(:base, :turnstile, message: t("help.app.contacts.create.turnstile_error"))
        flash.now[:alert] = t("help.app.contacts.create.turnstile_error")
        false
      end
    end
  end
end
