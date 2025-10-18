# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  # TODO(human): Implement lightweight health check for Cloud Run
  # Create a method that provides quick health response without external dependencies
  # This should check Rails.application.initialized? and return 200 OK quickly
  # Use environment variables or request parameters to determine when to use this vs full check

  private
  def get_status
    if [ IdentifiersRecord ].all? { it.connection.execute("SELECT 1;") }
      [ 200, "OK" ]
    else
      [ 500, "NG" ]
    end
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
