# frozen_string_literal: true

module ApplicationHelper
  # Authentication helpers are provided by Auth::User and Auth::Staff concerns
  # No need to define them here - they're already available via helper_method

  def page_title(title = nil)
    if title.present?
      content_for :page_title, title
    else
      content_for(:page_title) || t("meta.default_title", default: "")
    end
  end

  def theme_cookie_value
    # Support both symbol and string access, and handle nil
    # Fallback to request.cookies for integration tests where helper cookies might be empty
    raw = (
      cookies[:jit_ct] ||
        cookies["jit_ct"] ||
        request.cookies["jit_ct"] ||
        cookies[:ct] ||
        cookies["ct"] ||
        request.cookies["ct"]
    ).to_s.downcase
    {
      "dr" => "dark",
      "dark" => "dark",
      "li" => "light",
      "light" => "light",
      "sy" => "system",
      "system" => "system",
    }[raw] || "system"
  end

  def theme_html_class
    theme = theme_cookie_value
    classes = ["theme-#{theme}"]
    classes << "dark" if theme == "dark"
    classes.join(" ")
  end

  # Backward-compatible name used by some layouts/tests.
  def theme_class
    theme_html_class
  end
end
