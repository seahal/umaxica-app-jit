# frozen_string_literal: true

module Bff
  module Preference
    module EmailFlow
      extend ActiveSupport::Concern

      included do
        include ::CloudflareTurnstile

        before_action :load_email_preference_request, only: %i[edit update]
      end

      def new
        @email_preference_request = EmailPreferenceRequest.new(context: preference_context)
      end

      def create
        @email_preference_request = EmailPreferenceRequest.new(email_preference_request_params.merge(context: preference_context))

        if turnstile_passed? && @email_preference_request.save
          deliver_email_preference_link(@email_preference_request)
          flash[:notice] = t("bff.#{preference_context}.preference.emails.new.success")
          redirect_to preference_root_path
        else
          flash.now[:alert] ||= t("bff.#{preference_context}.preference.emails.new.failure")
          render :new, status: :unprocessable_content
        end
      end

      def edit
        @email_preferences = @email_preference_request.preferences_with_defaults
      end

      def update
        @email_preferences = normalized_preference_params

        if @email_preference_request.mark_preferences!(@email_preferences)
          flash[:notice] = t("bff.#{preference_context}.preference.emails.edit.success")
          redirect_to preference_root_path
        else
          flash.now[:alert] = t("bff.shared.preference_emails.update_failure")
          render :edit, status: :unprocessable_content
        end
      end

      private

      def email_preference_request_params
        params.fetch(:email_preference_request, ActionController::Parameters.new).permit(:email_address)
      end

      def preference_params
        params.fetch(:email_preference_request, ActionController::Parameters.new).permit(:product_updates, :promotional_messages)
      end

      def normalized_preference_params
        preference_params.to_h.transform_values { |value| ActiveModel::Type::Boolean.new.cast(value) }
      end

      def turnstile_passed?
        result = cloudflare_turnstile_validation
        return true if result["success"]

        append_turnstile_error
        false
      rescue StandardError => error
        Rails.logger.error("Cloudflare Turnstile verification exception: #{error.message}")
        append_turnstile_error
        false
      end

      def append_turnstile_error
        @email_preference_request.errors.add(:base, :turnstile)
        flash.now[:alert] ||= t("bff.shared.preference_emails.turnstile_error")
      end

      def load_email_preference_request
        @email_preference_request = EmailPreferenceRequest.find_by_token(preference_context, params[:id])
        invalid_token unless @email_preference_request&.token_valid?
      end

      def invalid_token
        flash[:alert] = t("bff.shared.preference_emails.token_invalid")
        redirect_to preference_email_new_path
      end

      def preference_root_path
        send("bff_#{preference_context}_preference_path")
      end

      def preference_email_new_path
        send("new_bff_#{preference_context}_preference_email_path")
      end

      def deliver_email_preference_link(request)
        edit_url = preference_email_edit_url(request.raw_token)
        preference_mailer
          .with(preference_request: request, edit_url: edit_url)
          .update_request
          .deliver_now
        request.update!(sent_at: Time.current)
      end

      def preference_context
        raise NotImplementedError, "#{self.class.name} must define #preference_context"
      end

      def preference_email_edit_url(_token)
        raise NotImplementedError, "#{self.class.name} must define #preference_email_edit_url"
      end

      def preference_mailer
        raise NotImplementedError, "#{self.class.name} must define #preference_mailer"
      end
    end
  end
end
