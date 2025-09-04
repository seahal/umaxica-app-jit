# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  # TODO(human): Implement lightweight health check for Cloud Run
  # Create a method that provides quick health response without external dependencies
  # This should check Rails.application.initialized? and return 200 OK quickly
  # Use environment variables or request parameters to determine when to use this vs full check

  def show
    expires_in 1.second, public: true # this page wouldn't include private data

    # In test environment, avoid hitting external services and DB checks.
    if Rails.env.test?
      @status, @body = [ 200, "OK" ]
    elsif Rails.env.production?
      # Keep health checks lightweight and avoid external dependencies in production
      @status, @body = [ 200, "OK" ]
    else
      # FIXME: much more validations requires
      # @status, @body = if !! [UniversalsRecord, IdentitiesRecord, NotificationsRecord, CoresRecord, SessionsRecord, StoragesRecord, MessagesRecord].all?{ it.connection.execute("SELECT 1;") }

      # FIXME: hidoi!
      raise unless OpenSearch::Client.new(
        host: File.exist?("/.dockerenv") ? ENV["OPENSEARCH_DEFAULT_URL"] : "localhost:9200",
        user: Rails.application.credentials.OPENSEARCH.USERNAME,
        password: Rails.application.credentials.OPENSEARCH.PASSWORD,
        transport_options: { ssl: { verify: false } },
        log: false
      )

      @status, @body = if !![ IdentifiersRecord ].all? { it.connection.execute("SELECT 1;") }
                         [ 200, "OK" ]
      else
                         [ 500, "NG" ]
      end
    end

    case request.path
    when /\/health(?:\.html)?$/
      render html: @body, status: @status
    when /\/health\.json$/
      render json: { status: @body }, status: @status
    else
      raise
    end
  end
end
