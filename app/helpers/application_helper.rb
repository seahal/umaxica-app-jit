# typed: false
# frozen_string_literal: true

module ApplicationHelper
  # Authentication helpers are provided by Auth::User and Auth::Staff concerns
  # No need to define them here - they're already available via helper_method

  EDGE_HOST_ENV_KEYS = {
    app: "EDGE_SERVICE_URL",
    org: "EDGE_STAFF_URL",
    com: "EDGE_CORPORATE_URL",
  }.freeze

  def page_title(title = nil)
    if title.present?
      content_for :page_title, title
    else
      content_for(:page_title) || t("meta.default_title")
    end
  end

  def theme_cookie_value
    # Support both symbol and string access, and handle nil
    # Fallback to request.cookies for integration tests where helper cookies might be empty
    raw = (
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

  def current_banner_for(surface)
    banner_model_for(surface)&.current&.first
  end

  def edge_host
    surface = request.respond_to?(:host) ? Core::Surface.current(request) : Core::Surface::DEFAULT
    env_key = EDGE_HOST_ENV_KEYS.fetch(surface, EDGE_HOST_ENV_KEYS.fetch(Core::Surface::DEFAULT))

    Core::HostNormalization.normalize(ENV[env_key])
  end

  private

  def banner_model_for(surface)
    case surface.to_sym
    when :app
      AppBanner
    when :org
      OrgBanner
    when :com
      ComBanner
    end
  end
end
