# typed: false
# frozen_string_literal: true

module News
  module Org
    class SitemapsController < ApplicationController
      include ::Sitemap

      def show
        show_xml
      end
    end
  end
end
