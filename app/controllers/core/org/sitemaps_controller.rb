# typed: false
# frozen_string_literal: true

module Core
  module Org
    class SitemapsController < ApplicationController
      include ::Sitemap

      def show
        show_xml
      end
    end
  end
end
