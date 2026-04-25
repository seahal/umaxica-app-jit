# typed: false
# frozen_string_literal: true

if ENV["SKIP_DB"] == "1"
  module SkipDbTests
    def before_setup
      skip("SKIP_DB=1 (database unavailable in this environment)")
    end
  end

  ActiveSupport.on_load(:active_support_test_case) { prepend SkipDbTests }

  if defined?(ActiveRecord::Migration)
    class << ActiveRecord::Migration
      def maintain_test_schema!
      end
    end
  end
end
