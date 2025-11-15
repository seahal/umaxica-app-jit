# frozen_string_literal: true

module Health
  extend ActiveSupport::Concern

  included do
    # Skip query canonicalization for health checks if the callback exists
    begin
      skip_before_action :canonicalize_query_params
    rescue ArgumentError
      # Callback doesn't exist, ignore
    end
  end

  private

  def get_status
    return [ 503, "BOOTING" ] unless Rails.application.initialized?

    errors = check_dependencies

    if errors.empty?
      [ 200, "OK" ]
    else
      [ 422, "UNHEALTHY", errors ]
    end
  rescue StandardError => e
    Rails.logger.error("[health-check] #{e.class}: #{e.message}") if defined?(Rails) && Rails.logger
    [ 500, "ERROR" ]
  end

  def check_dependencies
    errors = []

    # # Check database connectivity
    # begin
    #   ActiveRecord::Base.connection.execute("SELECT 1")
    # rescue StandardError => e
    #   errors << "Database connection failed: #{e.message}"
    # end
    #
    # Check Redis connectivity if configured (skip in test environment)
    if defined?(Redis) && defined?(REDIS_CLIENT) && !Rails.env.test?
      begin
        REDIS_CLIENT.ping
      rescue StandardError => e
        errors << "Redis connection failed: #{e.message}"
      end
    end

    errors
  end

  def show_html
    @status, @body, @errors = get_status
    if @errors
      render html: "#{@body}: #{@errors.join(', ')}", status: @status
    else
      render html: @body, status: @status
    end
  end

  def show_json
    @status, @body, @errors = get_status
    response_body = { status: @body }
    response_body[:errors] = @errors if @errors
    render json: response_body, status: @status
  end
end
