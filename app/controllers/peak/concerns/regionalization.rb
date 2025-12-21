module Peak
  module Concerns
    module Regionalization
      extend ActiveSupport::Concern

      private

      def default_url_options
        options = super

        tz = params[:tz].presence || params[:timezone]
        lx = params[:lx].presence || params[:lang]
        ri = params[:ri].presence || params[:region]

        options[:tz] = tz.to_s.downcase if tz.present?
        options[:lx] = lx.to_s.downcase if lx.present?
        options[:ri] = ri.to_s.downcase if ri.present?

        options
      end

      def set_locale
        I18n.locale = session[:language]&.downcase || I18n.default_locale
      end

      def set_timezone
        Time.zone = session[:timezone] if session[:timezone].present?
      end
    end
  end
end

module Www
  module Concerns
    Regionalization = Peak::Concerns::Regionalization
  end
end
