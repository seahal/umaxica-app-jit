require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

if !Rails.env.test? && !ENV["CI"]
  OpenTelemetry::SDK.configure do |c|
    c.service_name = "umaxica-app-jit"
    c.use_all # enables all instrumentation!
  end
end
