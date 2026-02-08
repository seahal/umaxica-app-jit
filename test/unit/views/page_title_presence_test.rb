# frozen_string_literal: true

require "test_helper"

class PageTitlePresenceTest < ActiveSupport::TestCase
  # Pure static analysis test - no database/fixtures needed
  self.use_transactional_tests = false
  self.fixture_table_names = []

  # Patterns that indicate a page title is set
  PAGE_TITLE_PATTERNS = [
    /content_for\s+:page_title/,
    /provide\s*\(\s*:page_title/,
    /<%=?\s*title\s+/,           # meta-tags gem helper
    /set_meta_tags.*title/
  ].freeze

  # Files excluded from page_title requirement with reasons
  EXCLUDED_PATHS = [
    # Email/mailer views: rendered inside mailer layouts (separate title mechanism)
    %r{^app/views/email/}
  ].freeze

  test "all non-partial views have a page_title declaration" do
    view_root = Rails.root.join("app", "views")
    view_files = Dir.glob(view_root.join("**", "*.html.erb")).sort

    # Filter to non-partial, non-layout views
    page_views = view_files.reject do |path|
      relative = path.sub("#{Rails.root}/", "")
      File.basename(path).start_with?("_") ||           # partials
        relative.start_with?("app/views/layouts/") ||    # layouts
        EXCLUDED_PATHS.any? { |pat| relative.match?(pat) }
    end

    missing = []
    page_views.each do |path|
      content = File.read(path)
      has_title = PAGE_TITLE_PATTERNS.any? { |pat| content.match?(pat) }
      relative = path.sub("#{Rails.root}/", "")
      missing << relative unless has_title
    end

    assert missing.empty?,
      "#{missing.size} view(s) missing page_title declaration:\n  #{missing.join("\n  ")}"
  end
end
