require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

if Rails.env.production? && !ENV["CI"]
  OpenTelemetry::SDK.configure do |c|
    c.service_name = "umaxica-app-jit-core"
    c.use_all # enables all instrumentation!
  end
elsif Rails.env.development?
  # Development environment configuration
  # OpenTelemetry::SDK.configure do |c|
  #   c.service_name = "umaxica-app-jit-core-dev"
  #   c.use_all # enables all instrumentation!
  #
  #   # Configure OTLP exporter to send to OpenTelemetry Collector
  #   # Using HTTP protocol with explicit path
  #   c.add_span_processor(
  #     OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
  #       OpenTelemetry::Exporter::OTLP::Exporter.new(
  #         endpoint: ENV.fetch("OTEL_EXPORTER_OTLP_ENDPOINT", "http://otel-collector:4318/v1/traces"),
  #         headers: {},
  #         compression: "gzip"
  #       )
  #     )
  #   )
  # end
end
