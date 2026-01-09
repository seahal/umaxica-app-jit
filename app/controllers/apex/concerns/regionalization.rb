# frozen_string_literal: true

module Apex
  module Concerns
    module Regionalization
      extend ActiveSupport::Concern

      included do
        helper_method :get_language, :get_timezone, :get_region, :get_colortheme
      end

      def get_colortheme
        "sy"
      end

      private

      def default_url_options
        options = super

        tz = params[:tz].presence || params[:timezone]
        lx = params[:lx].presence || params[:lang]
        ri = params[:ri].presence || params[:region]
        ct = params[:ct].presence || params[:colortheme]

        options[:tz] = tz.to_s.downcase if tz.present?
        options[:lx] = lx.to_s.downcase if lx.present?
        options[:ri] = ri.to_s.downcase if ri.present?
        options[:ct] = ct.to_s.downcase if ct.present?

        options
      end

      public

      def get_language
        I18n.locale
      end

      def get_timezone
        Time.zone
      end

      def get_region
        params[:ri].presence || params[:region] || "us"
      end

      private

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
    Regionalization = Apex::Concerns::Regionalization
  end
end
