# typed: false
# frozen_string_literal: true

# This rake task was added by annotate_rb gem.

# Can set `ANNOTATERB_SKIP_ON_DB_TASKS` to be anything to skip this
db_reset_task = ARGV.any? { |task| task == "db:migrate:reset" || task == "db:reset" }
if Rails.env.development? && ENV["ANNOTATERB_SKIP_ON_DB_TASKS"].nil? && !db_reset_task
  require "annotate_rb"

  AnnotateRb::Core.load_rake_tasks
end
