# typed: false
# frozen_string_literal: true

if ENV["RAILS_ENV"] == "test" && ENV["COVERAGE"] != "false"
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter,
    ],
  )

  SimpleCov.start "rails" do
    enable_coverage :branch
    filters.clear
    add_filter ".bundle/"
    add_filter "vendor/"
    add_filter "app/views/"
    add_filter "test/"
    add_filter "config/"
    add_filter "db/"
    add_filter "bin/"
    add_filter "docs/"
    add_filter "log/"
    add_filter "docker/"
    add_filter "dependency/"
    add_filter "public/"
    add_filter "node_modules/"

    # Redundant schema files
    add_filter "db/schema.rb"
    add_filter "db/activity_schema.rb"
    add_filter "db/avatar_schema.rb"
    add_filter "db/behavior_schema.rb"
    add_filter "db/billing_schema.rb"
    add_filter "db/cable_schema.rb"
    add_filter "db/default_schema.rb"
    add_filter "db/document_schema.rb"
    add_filter "db/guest_schema.rb"
    add_filter "db/search_schema.rb"
    add_filter "db/message_schema.rb"
    add_filter "db/news_schema.rb"
    add_filter "db/notification_schema.rb"
    add_filter "db/occurrence_schema.rb"
    add_filter "db/operator_schema.rb"
    add_filter "db/preference_schema.rb"
    add_filter "db/principal_schema.rb"
    add_filter "db/finder_schema.rb"
    add_filter "db/queue_schema.rb"
    add_filter "db/storage_schema.rb"
    add_filter "db/token_schema.rb"
  end
end
