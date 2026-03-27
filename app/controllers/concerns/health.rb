# typed: false
# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  DATABASE_RECORD_CLASSES = [
    ActivityRecord,
    ApplicationRecord,
    AvatarRecord,
    BehaviorRecord,
    DocumentRecord,
    GuestRecord,
    MessageRecord,
    PublicationRecord,
    NotificationRecord,
    OccurrenceRecord,
    OperatorRecord,
    CommerceRecord,
    PrincipalRecord,
    TokenRecord,
  ].freeze

  DB_ROLES = %i(writing reading).freeze

  included do
    # Skip query canonicalization for health checks if the callback exists
    skip_before_action :canonicalize_query_params, raise: false
    public_strict! if respond_to?(:public_strict!)
  end

  private

  def get_status
    return [503, "BOOTING"] unless Rails.application.initialized?

    errors = check_dependencies

    if errors.empty?
      [200, "OK"]
    else
      [503, "UNHEALTHY", errors]
    end
  rescue StandardError => e
    # Debug print for tests
    if Rails.env.test?
      Rails.event.error(
        "health.check_failed",
        error_class: e.class.name,
        message: e.message,
        exception: e,
      )
    end
    Rails.event.record("health_check.failed", error_class: e.class.name, error_message: e.message)
    [503, "ERROR"]
  end

  def check_dependencies
    errors = []
    check_databases(errors)
    check_redis(errors)
    errors
  end

  def check_databases(errors)
    # Pause Prosopite because we're intentionally querying multiple databases in a loop
    Prosopite.pause if defined?(Prosopite)

    DATABASE_RECORD_CLASSES.each do |klass|
      DB_ROLES.each do |role|
        klass.connected_to(role: role) do
          klass.with_connection { |conn| conn.execute("SELECT 1") }
        rescue StandardError => e
          Rails.event.record(
            "health_check.database_failed", database: klass.name, role: role.to_s,
                                            error_class: e.class.name, error_message: e.message,
          )
          errors << "Database #{klass.name}(#{role}) unavailable"
        end
      end
    end

    errors
  ensure
    Prosopite.resume if defined?(Prosopite)
  end

  def check_redis(errors)
    # Check Redis connectivity if configured (skip in test environment unless mocked)
    if defined?(Redis) && defined?(REDIS_CLIENT) && !Rails.env.test?
      begin
        REDIS_CLIENT.ping
      rescue StandardError => e
        Rails.event.record("health_check.redis_failed", error_class: e.class.name, error_message: e.message)
        errors << "Redis unavailable"
      end
    end
    errors
  end

  def show_html
    @status, @body, @errors = get_status
    timestamp = Time.now.utc.iso8601
    if @errors.present?
      render plain: "#{@body}: #{@errors.join(", ")} (#{timestamp})", status: @status
    else
      render plain: "#{@body} (#{timestamp})", status: @status
    end
  end

  def show_json
    @status, @body, @errors = get_status
    response_body = { status: @body, timestamp: Time.now.utc.iso8601 }
    response_body[:errors] = @errors if @errors.present?
    render json: response_body, status: @status
  end
end
