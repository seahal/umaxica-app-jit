# frozen_string_literal: true

class HealthController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.html { render plain: "OK", status: :ok }
      format.json do
        # JSON format should raise an error as per test expectations
        raise StandardError, "JSON format not supported for health check"
      end
    end
  end

  def kafka
    health_status = {
      status: "ok",
      timestamp: Time.current.iso8601,
      services: check_services
    }

    if health_status[:services].any? { |_, status| status[:status] != "ok" }
      health_status[:status] = "degraded"
    end

    status_code = health_status[:status] == "ok" ? :ok : :service_unavailable
    render json: health_status, status: status_code
  end

  private

  def check_services
    {
      database: check_database_health,
      redis: check_redis_health,
      kafka: check_kafka_health
    }
  end

  def check_database_health
    ActiveRecord::Base.connection.execute("SELECT 1")
    { status: "ok", response_time: measure_time { ActiveRecord::Base.connection.execute("SELECT 1") } }
  rescue StandardError => e
    { status: "error", error: e.message }
  end

  def check_redis_health
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).ping
    { status: "ok", response_time: measure_time { Redis.new.ping } }
  rescue StandardError => e
    { status: "error", error: e.message }
  end

  def check_kafka_health
    return { status: "disabled", message: "Karafka not available" } unless defined?(Karafka)
    return { status: "disabled", message: "Kafka disabled in test environment" } if Rails.env.test?

    # Test producer connection
    test_topic = "health_check"
    test_message = {
      timestamp: Time.current.iso8601,
      check_id: SecureRandom.uuid
    }

    response_time = measure_time do
      Karafka.producer.produce_sync(
        topic: test_topic,
        payload: test_message.to_json,
        headers: { "content-type" => "application/json" }
      )
    end

    { status: "ok", response_time: response_time }
  rescue StandardError => e
    { status: "error", error: e.message }
  end

  def measure_time
    start_time = Time.current
    yield
    ((Time.current - start_time) * 1000).round(2) # milliseconds
  end
end
