# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  # TODO(human): Implement lightweight health check for Cloud Run
  # Create a method that provides quick health response without external dependencies
  # This should check Rails.application.initialized? and return 200 OK quickly
  # Use environment variables or request parameters to determine when to use this vs full check

  def show
    # expires_in 1.second, public: true # this page wouldn't include private data

    # FIXME: much more validations requires
    # @status, @body = if !! [UniversalsRecord, IdentitiesRecord, NotificationsRecord, CoresRecord, SessionsRecord, StoragesRecord, MessagesRecord].all?{ it.connection.execute("SELECT 1;") }

    @status, @body = get_status

    case request.path
    when /\/health(?:\.html)?$/
      render html: @body, status: @status
    when /\/health\.json$/
      render json: { status: @body }, status: @status
    else
      raise
    end
  end

  private
  def get_status
    if [ IdentifiersRecord ].all? { it.connection.execute("SELECT 1;") }
      [ 200, "OK" ]
    else
      [ 500, "NG" ]
    end
  end
end
