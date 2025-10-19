# frozen_string_literal: true

require "json"

module Theme
  extend ActiveSupport::Concern

  ALLOWED_THEMES = %w[system dark light].freeze
  DEFAULT_THEME = "system"

  included do
    before_action :assign_current_theme, only: :edit
  end

  def edit
  end

  def update
    resolved_theme = normalize_theme(params[:theme])

    if resolved_theme.nil?
      flash.now[:alert] = I18n.t("apex.#{preference_scope}.preferences.themes.invalid")
      assign_current_theme
      render :edit, status: :unprocessable_content
    else
      persist_theme!(resolved_theme)
      flash[:notice] = I18n.t("apex.#{preference_scope}.preferences.themes.updated", theme: I18n.t("themes.#{resolved_theme}"))
      redirect_to action: :edit
    end
  end

  private

  def assign_current_theme
    @theme = current_theme
  end

  def current_theme
    normalize_theme(session[:theme]) ||
      normalize_theme(cookies.signed[theme_cookie_key]) ||
      DEFAULT_THEME
  end

  def normalize_theme(candidate)
    normalized = candidate.to_s.downcase
    normalized if ALLOWED_THEMES.include?(normalized)
  end

  def persist_theme!(theme)
    session[:theme] = theme
    assign_current_theme

    cookies.permanent.signed[theme_cookie_key] = {
      value: theme,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }

    persist_app_preferences_cookie!(theme) if preference_scope == "app"
  end

  def preference_scope
    @preference_scope ||= controller_path.split("/")[1]
  end

  def theme_cookie_key
    :"apex_#{preference_scope}_theme"
  end

  def persist_app_preferences_cookie!(theme)
    keys = Apex::App::RootsController::PREFERENCE_KEYS
    defaults = Apex::App::RootsController::DEFAULT_PREFERENCES
    cookie_key = Apex::App::RootsController::PREFERENCE_COOKIE_KEY

    resolved = defaults.dup

    raw_preferences = cookies.signed[cookie_key]
    if raw_preferences.present?
      begin
        parsed = JSON.parse(raw_preferences)
        if parsed.is_a?(Hash)
          parsed.slice(*keys).each do |key, value|
            normalized = value.to_s.downcase
            resolved[key] = normalized.presence || defaults[key]
          end
        end
      rescue JSON::ParserError, TypeError
        # ignore malformed cookie
      end
    end

    resolved["ct"] = theme

    cookies.permanent.signed[cookie_key] = {
      value: resolved.to_json,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end
end
