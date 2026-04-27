# typed: false
# frozen_string_literal: true

module Jump::ToRedirector
  extend ActiveSupport::Concern

  included do
    skip_before_action :apply_localization_preferences, raise: false
    before_action :disable_cookie_session
  end

  def show
    jump_link_model = self.class::JUMP_LINK_MODEL
    jump_link = jump_link_model.find_by(public_id: params[:public_id])
    return head :not_found if jump_link.blank?

    destination_url =
      RedirectorRecord.connected_to(role: :writing) do
        jump_link.consume_destination_for(user: nil)
      end
    return head :not_found if destination_url.blank?

    response.set_header("Referrer-Policy", "no-referrer")

    Rails.logger.silence do
      redirect_to(destination_url, allow_other_host: true)
    end
  end

  private

  def disable_cookie_session
    request.session_options[:skip] = true
  end
end
