# typed: false
# frozen_string_literal: true

module Core
  module Org
    class ContactsController < Core::Org::ApplicationController
      include ::RateLimit

      before_action :authenticate_staff!
      before_action :ensure_contact_channels!, only: %i(new create)
      before_action :set_contact, only: :show

      def show
        @topic = @contact.org_contact_topics.order(created_at: :desc).first
      end

      def new
        category_id = validate_category_id(params[:category])
        @contact = OrgContact.new(category_id: category_id)
        @contact_categories = OrgContactCategory.order(:id)
      end

      def create
        @contact = OrgContact.new(
          category_id: params.dig(:org_contact, :category_id),
          confirm_policy: params.dig(:org_contact, :confirm_policy),
        )
        @contact_categories = OrgContactCategory.order(:id)

        unless turnstile_stealth_valid?
          render :new, status: :unprocessable_content
          return
        end

        @topic = @contact.org_contact_topics.build(title: topic_title, description: topic_body)
        unless @topic.valid?
          append_topic_errors(@topic)
          render :new, status: :unprocessable_content
          return
        end

        ActiveRecord::Base.transaction do
          @contact.status_id = OrgContactStatus::SET_UP
          @contact.save!

          OrgContactEmail.create!(
            org_contact: @contact,
            email_address: canonical_staff_email.address,
          )
          OrgContactTelephone.create!(
            org_contact: @contact,
            telephone_number: canonical_staff_telephone.number,
          )
          @topic.save!
        end

        write_behavior_event(@contact)
        redirect_to(
          core_org_contact_url(@contact, **core_staff_redirect_options),
          notice: I18n.t("help.org.contacts.create.success"),
        )
      rescue ActiveRecord::RecordInvalid
        render :new, status: :unprocessable_content
      end

      private

      def validate_category_id(category_param)
        return nil if category_param.blank?

        if OrgContactCategory.exists?(id: category_param)
          category_param
        else
          Rails.event.notify(
            "contact.invalid_category",
            category_param: category_param,
            controller: "core/org/contacts",
          )
          nil
        end
      end

      def topic_title
        params.dig(:org_contact, :title).to_s
      end

      def topic_body
        params.dig(:org_contact, :body).presence || params.dig(:org_contact, :description).to_s
      end

      def append_topic_errors(topic)
        topic.errors.full_messages.each do |message|
          @contact.errors.add(:base, message)
        end
      end

      def turnstile_stealth_valid?
        if Jit::Security::TurnstileConfig.stealth_secret_key.blank?
          Rails.event.notify("contact.turnstile.stealth_skipped", controller: "core/org/contacts")
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
        unless canonical_staff_email
          render plain: "email を登録してください", status: :unprocessable_content
          return
        end

        return if canonical_staff_telephone

        render plain: "telephone を追加してください", status: :unprocessable_content
      end

      def canonical_staff_email
        @canonical_staff_email ||=
          begin
            emails = current_staff.staff_emails.to_a
            verified =
              emails.find do |email|
                email.staff_identity_email_status_id == StaffEmailStatus::VERIFIED && email.address.present?
              end
            verified || emails.find { |email| email.address.present? }
          end
      end

      def canonical_staff_telephone
        @canonical_staff_telephone ||=
          begin
            telephones = current_staff.staff_telephones.to_a
            verified =
              telephones.find do |telephone|
                telephone.staff_identity_telephone_status_id == StaffTelephoneStatus::VERIFIED &&
                  telephone.number.present?
              end
            verified || telephones.find { |telephone| telephone.number.present? }
          end
      end

      def write_behavior_event(contact)
        OrgContactBehavior.create!(
          org_contact: contact,
          actor: current_staff,
          occurred_at: Time.current,
          subject_type: "OrgContact",
        )
      rescue StandardError => e
        Rails.event.notify(
          "contact.behavior.write_failed",
          controller: "core/org/contacts",
          contact_id: contact.public_id,
          error_class: e.class.name,
          error_message: e.message,
        )
      end

      def set_contact
        @contact = OrgContact.find_by!(public_id: params[:id])
      end

      def core_staff_redirect_options
        {
          host: core_staff_host,
          port: request.port,
          protocol: request.protocol.delete_suffix("://"),
        }.compact
      end

      def core_staff_host
        env_url = ENV["CORE_STAFF_URL"].presence
        return request.host unless env_url

        begin
          uri = URI.parse(env_url.start_with?("http") ? env_url : "http://#{env_url}")
          uri.host || env_url.split(":").first
        rescue URI::InvalidURIError
          env_url.split(":").first
        end
      end
    end
  end
end
