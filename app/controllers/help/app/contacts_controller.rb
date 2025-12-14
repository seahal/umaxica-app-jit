module Help
  module App
    class ContactsController < ApplicationController
      include CloudflareTurnstile
      include Rotp
      before_action :set_contact, only: %i[show edit]

      def show; end

      def new
        @contact = AppContact.new
        @email_address = ""
        @telephone_number = ""
        @contact_categories = AppContactCategory.all
      end

      def edit
        @contact_categories = AppContactCategory.all
      end

      def create
        # Cloudflare Turnstile validation
        turnstile_result = cloudflare_turnstile_validation

        # Create contact with nested associations
        @contact = AppContact.new(
          contact_category_title: params.dig(:app_contact, :contact_category_title),
          confirm_policy: params.dig(:app_contact, :confirm_policy)
        )

        # Build associated email and telephone
        @email = @contact.app_contact_emails.build(
          email_address: params.dig(:app_contact, :email_address)
        )

        @telephone = @contact.app_contact_telephones.build(
          telephone_number: params.dig(:app_contact, :telephone_number)
        )

        # TODO: ここを、@contact にエラーを注入して、エラーメッセージを出したい。
        unless turnstile_result["success"]
          @contact.errors.add(:base, "ロボットではないことの確認に失敗しました。もう一度お試しください。")
          @email_address = params.dig(:app_contact, :email_address) || ""
          @telephone_number = params.dig(:app_contact, :telephone_number) || ""
          @contact_categories = AppContactCategory.all
          render :new, status: :unprocessable_content
          return
        end

        if @contact.save
          # Update status to SET_UP
          @contact.update!(contact_status_id: "SET_UP")

          # Generate HOTP and save to email record
          token = @email.generate_hotp!

          # Send email with HOTP code
          Email::App::ContactMailer.with(
            email_address: @email.email_address,
            pass_code: token
          ).create.deliver_now

          # Redirect with proper host options
          redirect_to new_help_app_contact_email_url(
                        contact_id: @contact.public_id,
                        **help_email_redirect_options
                      ), notice: I18n.t("help.app.contacts.create.success")
        else
          # Validation failed: re-render form with errors
          @email_address = params.dig(:app_contact, :email_address) || ""
          @telephone_number = params.dig(:app_contact, :telephone_number) || ""
          @contact_categories = AppContactCategory.all
          render :new, status: :unprocessable_content
        end
      end

      private

      def help_email_redirect_options
        {
          host: help_service_host,
          port: request.port,
          protocol: request.protocol.delete_suffix("://")
        }.compact
      end

      def help_service_host
        host_value = ENV["HELP_SERVICE_URL"].presence || request.host
        return request.host if host_value.blank?

        # Extract hostname from URL or host string, removing port if present
        begin
          uri = URI.parse(host_value.start_with?("http") ? host_value : "http://#{host_value}")
          uri.host || host_value.split(":").first
        rescue URI::InvalidURIError
          # If parsing fails, try to extract hostname by removing port
          host_value.split(":").first
        end
      end

      def set_contact
        @contact = AppContact.find_by!(public_id: params[:id])
      end
    end
  end
end
