module Regionalization
    extend ActiveSupport::Concern

    private

    def set_locale
        I18n.locale = session[:language]&.downcase || I18n.default_locale
    end

    def set_timezone
        Time.zone = session[:timezone] if session[:timezone].present?
    end
end
