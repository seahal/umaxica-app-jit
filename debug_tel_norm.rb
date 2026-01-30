# frozen_string_literal: true

require_relative "config/environment"

t = TelephoneOccurrence.new(body: "+819012345678", public_id: "test_debug_1")
t.validate
puts "Valid? #{t.valid?}"
puts "Errors: #{t.errors.full_messages}"

t2 = TelephoneOccurrence.new(body: "0081 90 1234 5678", public_id: "test_debug_2")
t2.validate
puts "T2 Body: #{t2.body}"
puts "T2 Valid? #{t2.valid?}"
puts "T2 Errors: #{t2.errors.full_messages}"
