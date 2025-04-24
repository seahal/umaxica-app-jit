# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  def show
    expires_in 1.second, public: true # this page wouldn't include private data

    # FIXME: much more validations requires
    # @status, @body = if !! [UniversalsRecord, AccountsRecord, NotificationsRecord, CoresRecord, SessionsRecord, StoragesRecord, MessagesRecord].all?{ it.connection.execute("SELECT 1;") }

    @status, @body = if !![UniversalRecord ].all? { it.connection.execute("SELECT 1;") }
                       [ 200, "OK" ]
    else
                       [ 500, "NG" ]
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
