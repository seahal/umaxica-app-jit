# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  def show
    expires_in 1.second, public: true # this page wouldn't include private data

    # FIXME: much more validations requires
    # @status, @body = if !! [UniversalsRecord, IdentitiesRecord, NotificationsRecord, CoresRecord, SessionsRecord, StoragesRecord, MessagesRecord].all?{ it.connection.execute("SELECT 1;") }

    # FIXME: hidoi!
    raise unless OpenSearch::Client.new(
      host: File.exist?("/.dockerenv") ? ENV["OPENSEARCH_DEFAULT_URL"] : "localhost:9200",
      user: Rails.application.credentials.OPENSEARCH.USERNAME,
      password: Rails.application.credentials.OPENSEARCH.PASSWORD,
      transport_options: { ssl: { verify: false } },
      log: true
    )

    @status, @body = if !![IdentifiersRecord].all? { it.connection.execute("SELECT 1;") }
                       [200, "OK"]
                     else
                       [500, "NG"]
                     end

    case request.path
    when "/health"
      render html: @body, status: @status
    when "/health.html"
      render html: @body, status: @status
    when "/v1/health"
      render json: { status: @body }, status: @status
    when "/v1/health.json"
      render json: { status: @body }, status: @status
    else
      raise
    end
  end
end
