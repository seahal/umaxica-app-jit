module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile
      include Rotp

      def show
      end
      def show
        @contact = ComContact.find_by!(public_id: params[:id])
        @topic = @contact.com_contact_topics.last
      end
      def new
        @email_address = "" # todo: remove if not used
        @telephone_number = "" # todo: remove if not used
        @contact_categories = ComContactCategory.all
      end


      def edit
        @contact = ComContact.find_by!(public_id: params[:id])
        @topic = @contact.com_contact_topics.build
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
          render :new, status: :unprocessable_content
          return
        end

        if @contact.save
          # Update status to SET_UP
          @contact.update!(contact_status_title: "SET_UP")

          # Generate HOTP and save to email record
          token = @email.generate_hotp!

          # Send email with HOTP code
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
          render :new, status: :unprocessable_content
        end
      end


      def update
        @contact = ComContact.find_by!(public_id: params[:id])
        @topic = @contact.com_contact_topics.build(topic_params)

        if @topic.save
          redirect_to help_com_contact_url(@contact, **help_email_redirect_options), notice: I18n.t("help.com.contacts.update.success")
        else
          render :edit, status: :unprocessable_content
        end
      end

      private

      def topic_params
        params.expect(com_contact_topic: [ :title, :description ])
      end

      def help_email_redirect_options
        {
          host: help_corporate_host,
          port: request.port,
          protocol: request.protocol.delete_suffix("://")
        }.compact
      end

      def help_corporate_host
        host_value = ENV["HELP_CORPORATE_URL"].presence || request.host
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
    end
  end
end
