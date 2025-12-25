module Help
  module Org
    class ContactsController < ApplicationController
      include CloudflareTurnstile
      include Rotp

      before_action :set_contact, only: [ :show, :edit, :update ]

      def show
        @topic = @contact.org_contact_topics.last
      end

      def new
        @contact = OrgContact.new
        @contact_categories = OrgContactCategory.order(:description)
      end

      def edit
        @contact_categories = OrgContactCategory.order(:description)
        @topic = @contact.org_contact_topics.build
      end

      def create
        turnstile_result = cloudflare_turnstile_validation

        @contact = OrgContact.new(
          category_id: params.dig(:org_contact, :category_id),
          confirm_policy: params.dig(:org_contact, :confirm_policy)
        )
        @contact_categories = OrgContactCategory.order(:description)

        @contact_email = @contact.org_contact_emails.build(
          email_address: params.dig(:org_contact, :email_address)
        )

        @contact.org_contact_telephones.build(
          telephone_number: params.dig(:org_contact, :telephone_number)
        )

        unless turnstile_result["success"]
          @contact.errors.add(:base, "ロボットではないことの確認に失敗しました。もう一度お試しください。")
          @email_address = params.dig(:org_contact, :email_address) || ""
          @telephone_number = params.dig(:org_contact, :telephone_number) || ""
          render :new, status: :unprocessable_content
          return
        end

        if @contact.save
          @contact.update!(status_id: "SET_UP")

          verification_code = @contact_email.generate_verifier!

          Email::Org::ContactMailer.with(
            email_address: @contact_email.email_address,
            pass_code: verification_code
          ).create.deliver_later

          redirect_to new_help_org_contact_email_url(
            contact_id: @contact.public_id,
            **help_staff_redirect_options
          ), notice: I18n.t("help.org.contacts.create.success")
        else
          @email_address = params.dig(:org_contact, :email_address) || ""
          @telephone_number = params.dig(:org_contact, :telephone_number) || ""
          render :new, status: :unprocessable_content
        end
      end

      def update
        @topic = @contact.org_contact_topics.build(topic_params)

        if @topic.save
          send_topic_notification(@contact, @topic)

          redirect_to help_org_contact_url(@contact, **help_staff_redirect_options),
                      notice: I18n.t("help.org.contacts.update.success")
        else
          render :edit, status: :unprocessable_content
        end
      end

      private

        def send_topic_notification(contact, topic)
          contact_email = contact.org_contact_emails.order(created_at: :desc).first

          unless contact_email
            Rails.event.notify("contact.notification.skip",
                               contact_id: contact.public_id,
                               reason: "no email address configured")
            return
          end

          Email::Org::TopicMailer.with(
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
          params.expect(org_contact_topic: [ :title, :description ])
        end

        def set_contact
          @contact = OrgContact.find_by!(public_id: params[:id])
        end

        def help_staff_redirect_options
          {
            host: help_staff_host,
            port: request.port,
            protocol: request.protocol.delete_suffix("://")
          }.compact
        end

        def help_staff_host
          host_value = ENV["HELP_STAFF_URL"].presence || request.host
          return request.host if host_value.blank?

          begin
            uri = URI.parse(host_value.start_with?("http") ? host_value : "http://#{host_value}")
            uri.host || host_value.split(":").first
          rescue URI::InvalidURIError
            host_value.split(":").first
          end
        end
    end
  end
end
