# frozen_string_literal: true

require "i18n"

def translate(key, **)
  I18n.t(key, **)
end

begin
  puts translate(
    "reproduce_issue.missing_position",
  )
  status = AppPreferenceStatus.create!(id: "TEST_NO_POS")
  puts translate(
    "reproduce_issue.success_created",
    id: status.id,
    position: status.position,
  )
rescue ActiveRecord::RecordInvalid => e
  puts translate(
    "reproduce_issue.expected_error",
    message: e.message,
  )
end

begin
  puts translate("reproduce_issue.duplicate_position")
  # Assuming positions 1..N exist. Try 1.
  status = AppPreferenceStatus.create!(id: "TEST_DUP_POS", position: 1)
  puts translate(
    "reproduce_issue.success_created",
    id: status.id,
    position: status.position,
  )
rescue ActiveRecord::RecordInvalid => e
  puts translate(
    "reproduce_issue.expected_error",
    message: e.message,
  )
rescue ActiveRecord::RecordNotUnique => e
  puts translate(
    "reproduce_issue.expected_db_error",
    message: e.message,
  )
end

puts translate("reproduce_issue.check_positions")
AppPreferenceStatus.order(:position).each do |s|
  puts "#{s.id}: #{s.position}"
end
