module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile
      include Rotp

      def show
        @contact = ComContact.find_by!(public_id: params[:id])
        @topic = @contact.com_contact_topics.last
      end

      def new
        @contact = ComContact.new
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
        @email = @contact.build_com_contact_email(
          email_address: params.dig(:com_contact, :email_address)
        )

        @telephone = @contact.build_com_contact_telephone(
          telephone_number: params.dig(:com_contact, :telephone_number)
        )

        # TODO: Inject error into @contact here and display error message.
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
          @contact.update!(contact_status_id: "SET_UP")

          # Generate HOTP and save to email record
          token = @email.generate_hotp!

          # Send email with HOTP code
          Email::Com::ContactMailer.with(
            email_address: @email.email_address,
            pass_code: token
          ).create.deliver_later

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
          send_topic_notification(@contact, @topic)
          redirect_to help_com_contact_url(@contact, **help_email_redirect_options), notice: I18n.t("help.com.contacts.update.success")
        else
          render :edit, status: :unprocessable_content
        end
      end

      private

      def send_topic_notification(contact, topic)
        contact_email = contact.com_contact_email

        unless contact_email
          Rails.event.notify("contact.notification.skip",
                             contact_id: contact.public_id,
                             reason: "no email address configured")
          return
        end

        Email::Com::TopicMailer.with(
          contact: contact,
          topic: topic,
          email_address: contact_email.email_address
        ).notice.deliver_later
      rescue StandardError => e
        Rails.event.notify("contact.notification.failed",
                           contact_id: contact.public_id,
                           error_message: e.message)
      end

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
