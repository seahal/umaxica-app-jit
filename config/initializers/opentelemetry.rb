# typed: false
# frozen_string_literal: true

return if Rails.env.test?

require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "umaxica-apps-jit"
  c.use_all
end
