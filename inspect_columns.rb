# frozen_string_literal: true

begin
  columns = ActiveRecord::Base.connection.columns("user_identity_statuses")
  puts "Columns for user_identity_statuses:"
  columns.each do |c|
    puts "- #{c.name}: #{c.sql_type}"
  end
rescue => e
  puts "Error: #{e.message}"
end
