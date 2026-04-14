# typed: false
# frozen_string_literal: true

return if Rails.env.test?
return unless ENV.fetch("OPEN_TELEMETRY", "false").casecmp?("true")

require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "umaxica-apps-jit"
  c.use_all(
    "OpenTelemetry::Instrumentation::Rdkafka" => { enabled: false },
    "OpenTelemetry::Instrumentation::RubyKafka" => { enabled: false },
  )
end
