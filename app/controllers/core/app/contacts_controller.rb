# typed: false
# frozen_string_literal: true

module Core
  module App
    class ContactsController < Core::App::ApplicationController
      include ::RateLimit

      before_action :authenticate_user!
      before_action :ensure_contact_channels!, only: %i(new create)
      before_action :set_contact, only: :show

      def show
        @topic = @contact.app_contact_topics.order(created_at: :desc).first
      end

      def new
        category_id = validate_category_id(params[:category])
        @contact = AppContact.new(category_id: category_id)
        @contact_categories = AppContactCategory.order(:id)
      end

      def create
        @contact = AppContact.new(
          category_id: params.dig(:app_contact, :category_id),
          confirm_policy: params.dig(:app_contact, :confirm_policy),
        )
        @contact_categories = AppContactCategory.order(:id)

        unless turnstile_stealth_valid?
          render :new, status: :unprocessable_content
          return
        end

        @topic = @contact.app_contact_topics.build(title: topic_title, description: topic_body)
        unless @topic.valid?
          append_topic_errors(@topic)
          render :new, status: :unprocessable_content
          return
        end

        ActiveRecord::Base.transaction do
          @contact.status_id = AppContactStatus::COMPLETED
          @contact.save!

          AppContactEmail.create!(
            app_contact: @contact,
            email_address: canonical_user_email.address,
          )
          AppContactTelephone.create!(
            app_contact: @contact,
            telephone_number: canonical_user_telephone.number,
          )
          @topic.save!
        end

        write_behavior_event(@contact)
        redirect_to(
          main_app_contact_url(@contact, **main_service_redirect_options),
          notice: I18n.t("help.app.contacts.create.success"),
        )
      rescue ActiveRecord::RecordInvalid
        render :new, status: :unprocessable_content
      end

      private

      def validate_category_id(category_param)
        return nil if category_param.blank?

        if AppContactCategory.exists?(id: category_param)
          category_param
        else
          Rails.event.notify(
            "contact.invalid_category",
            category_param: category_param,
            controller: "core/app/contacts",
          )
          nil
        end
      end

      def topic_title
        params.dig(:app_contact, :title).to_s
      end

      def topic_body
        params.dig(:app_contact, :body).presence || params.dig(:app_contact, :description).to_s
      end

      def append_topic_errors(topic)
        topic.errors.full_messages.each do |message|
          @contact.errors.add(:base, message)
        end
      end

      def turnstile_stealth_valid?
        if Jit::Security::TurnstileConfig.stealth_secret_key.blank?
          Rails.event.notify("contact.turnstile.stealth_skipped", controller: "core/app/contacts")
          return true
        end

        result = Jit::Security::TurnstileVerifier.verify(
          token: params["cf-turnstile-response"].to_s,
          remote_ip: request.remote_ip,
          mode: :stealth,
        )
        return true if result["success"]

        @contact.errors.add(:base, I18n.t("turnstile_error"))
        false
      end

      def ensure_contact_channels!
        unless canonical_user_email
          render plain: "email を登録してください", status: :unprocessable_content
          return
        end

        return if canonical_user_telephone

        render plain: "telephone を追加してください", status: :unprocessable_content
      end

      def canonical_user_email
        @canonical_user_email ||=
          begin
            emails = current_user.user_emails.to_a
            verified =
              emails.find do |email|
                [
                  UserEmailStatus::VERIFIED,
                  UserEmailStatus::VERIFIED_WITH_SIGN_UP,
                ].include?(email.user_email_status_id) && email.address.present?
              end
            verified || emails.find { |email| email.address.present? }
          end
      end

      def canonical_user_telephone
        @canonical_user_telephone ||=
          begin
            telephones = current_user.user_telephones.to_a
            verified =
              telephones.find do |telephone|
                [
                  UserTelephoneStatus::VERIFIED,
                  UserTelephoneStatus::VERIFIED_WITH_SIGN_UP,
                ].include?(telephone.user_identity_telephone_status_id) && telephone.number.present?
              end
            verified || telephones.find { |telephone| telephone.number.present? }
          end
      end

      def write_behavior_event(contact)
        Rails.event.record(
          "contact.created",
          controller: "core/app/contacts",
          contact_id: contact.public_id,
          contact_category: contact.category_id,
          user_id: current_user.id,
          ip_address: request.remote_ip,
        )
      rescue StandardError => e
        Rails.event.error(
          "contact.behavior.write_failed",
          controller: "core/app/contacts",
          contact_id: contact.public_id,
          error_class: e.class.name,
          error_message: e.message,
        )
      end

      def main_service_redirect_options
        {
          host: core_service_host,
          port: request.port,
          protocol: request.protocol.delete_suffix("://"),
        }.compact
      end

      def core_service_host
        env_url = ENV["MAIN_SERVICE_URL"].presence
        return request.host unless env_url

        begin
          uri = URI.parse(env_url.start_with?("http") ? env_url : "http://#{env_url}")
          uri.host || env_url.split(":").first
        rescue URI::InvalidURIError
          env_url.split(":").first
        end
      end

      def set_contact
        @contact = AppContact.find_by!(public_id: params[:id])
      end
    end
  end
end
