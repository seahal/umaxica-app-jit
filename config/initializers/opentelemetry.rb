require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

if Rails.env.production? && !ENV["CI"]
  OpenTelemetry::SDK.configure do |c|
    c.service_name = "umaxica-app-jit-core"
    c.use_all # enables all instrumentation!
  end
end
