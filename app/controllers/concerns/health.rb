# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  private

  def get_status
    return [ 503, "BOOTING" ] unless Rails.application.initialized?

    [ 200, "OK" ]
  rescue StandardError => e
    Rails.logger.error("[health-check] #{e.class}: #{e.message}") if defined?(Rails) && Rails.logger
    [ 500, "ERROR" ]
  end

  def show_html
    @status, @body = get_status
    render html: @body, status: @status
  end

  def show_json
    @status, @body = get_status
    render json: { status: @body }, status: @status
  end
end
