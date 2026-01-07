# frozen_string_literal: true

require "active_support/all"
require "action_controller"

puts "OpenTelemetry defined?: #{defined?(OpenTelemetry).inspect}"

puts "Subscribers to unpermitted_parameters.action_controller:"
ActiveSupport::Notifications.notifier.listeners_for("unpermitted_parameters.action_controller").each do |listener|
  puts " - #{listener.inspect}"
end

puts "Starting param check"
params = ActionController::Parameters.new({ region: "US", foo: "bar" })
puts "Params created"
permitted = params.permit(:region)
puts "Params permitted: #{permitted.inspect}"
