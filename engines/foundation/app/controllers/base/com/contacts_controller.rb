# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Com
        class ContactsController < Jit::Foundation::Base::Com::ApplicationController
          include ::RateLimit
          include CloudflareTurnstile

          before_action :set_contact, only: :show

          def show
            @topic = @contact.com_contact_topics.order(created_at: :desc).first
          end

          def new
            category_id = validate_category_id(params[:category])
            @contact = ComContact.new(category_id: category_id)
            @contact_categories = ComContactCategory.order(:id)
            @email_address = ""
            @telephone_number = ""
          end

          def create
            turnstile_result = cloudflare_turnstile_validation

            @contact = ComContact.new(
              category_id: params.dig(:com_contact, :category_id),
              confirm_policy: params.dig(:com_contact, :confirm_policy),
            )
            @contact_categories = ComContactCategory.order(:id)

            @email = @contact.build_com_contact_email(
              email_address: params.dig(:com_contact, :email_address),
            )
            @telephone = @contact.build_com_contact_telephone(
              telephone_number: params.dig(:com_contact, :telephone_number),
            )
            @email_address = params.dig(:com_contact, :email_address).to_s
            @telephone_number = params.dig(:com_contact, :telephone_number).to_s
            @topic = @contact.com_contact_topics.build(
              title: params.dig(:com_contact, :title),
              description: params.dig(:com_contact, :body).presence || params.dig(:com_contact, :description),
            )

            unless turnstile_result["success"]
              @contact.errors.add(:base, I18n.t("turnstile_error"))
              render :new, status: :unprocessable_content
              return
            end

            if @contact.save
              @contact.update!(status_id: ComContactStatus::COMPLETED)

              redirect_to(
                foundation.base_com_contact_url(
                  @contact,
                  **base_corporate_redirect_options,
                ), notice: I18n.t("help.com.contacts.create.success"),
              )
            else
              render :new, status: :unprocessable_content
            end
          end

          private

          def set_contact
            @contact = ComContact.find_by!(public_id: params[:id])
          end

          def validate_category_id(category_param)
            return nil if category_param.blank?

            if ComContactCategory.exists?(id: category_param)
              category_param
            else
              Rails.event.notify(
                "contact.invalid_category",
                category_param: category_param,
                controller: "base/com/contacts",
              )
              nil
            end
          end

          def base_corporate_redirect_options
            {
              host: base_corporate_host,
              port: request.port,
              protocol: request.protocol.delete_suffix("://"),
            }.compact
          end

          def base_corporate_host
            env_url = ENV["FOUNDATION_BASE_COM_URL"].presence
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
  end
end
