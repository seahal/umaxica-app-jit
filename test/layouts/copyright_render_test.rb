require "test_helper"

class CopyrightRenderTest < ActiveSupport::TestCase
  def test_all_html_layouts_render_copyright_partial
    layout_paths =
      Rails.root.glob("app/views/layouts/**/*application.html.erb")
         .reject { |path| path.include?("/mailer/") }

    assert_predicate layout_paths, :any?, "No layout templates found under app/views/layouts"

    missing = layout_paths.reject do |path|
      content = File.read(path)
      content.include?('render "concern/copyright"') || content.include?("render 'concern/copyright'")
    end

    missing_relative = missing.map { |path| path.delete_prefix("#{Rails.root.join("")}") }

    assert_empty missing_relative, "Missing copyright render in: #{missing_relative.join(', ')}"
  end
end
