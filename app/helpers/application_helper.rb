# frozen_string_literal: true

module ApplicationHelper
  # Authentication helpers are provided by Auth::User and Auth::Staff concerns
  # No need to define them here - they're already available via helper_method
  def theme_cookie_value
    raw = cookies["jit_ct"].to_s.downcase
    raw = cookies["ct"].to_s.downcase if raw.empty?
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
end
