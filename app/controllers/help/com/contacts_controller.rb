module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile

      def show
      end

      def new
        @service_site_contact = ServiceSiteContact.new
        load_contact_categories
      end

      def create
        @service_site_contact = ServiceSiteContact.new(contact_params.merge(ip_address: request.remote_ip))

        if turnstile_passed? && @service_site_contact.save
          redirect_to new_help_com_contact_url, notice: t("help.app.contacts.create.success")
        else
          load_contact_categories
          flash.now[:alert] ||= t("help.app.contacts.create.failure")
          render :new, status: :unprocessable_entity
        end
      end

      private

      def contact_params
        params.require(:service_site_contact).permit(:confirm_policy,
                                                     :contact_category_title,
                                                     :email_address,
                                                     :telephone_number,
                                                     :email_pass_code,
                                                     :telephone_pass_code,
                                                     :title,
                                                     :description)
      end

      def load_contact_categories
        @contact_categories = ContactCategory.order(:title)
      end

      def turnstile_passed?
        result = cloudflare_turnstile_validation
        return true if result["success"]

        Rails.logger.warn("Cloudflare Turnstile verification failed: #{result}")
        @service_site_contact.errors.add(:base, :turnstile, message: t("help.app.contacts.create.turnstile_error"))
        flash.now[:alert] = t("help.app.contacts.create.turnstile_error")
        false
      rescue StandardError => error
        Rails.logger.error("Cloudflare Turnstile verification exception: #{error.message}")
        @service_site_contact.errors.add(:base, :turnstile, message: t("help.app.contacts.create.turnstile_error"))
        flash.now[:alert] = t("help.app.contacts.create.turnstile_error")
        false
      end
    end
  end
end
