# typed: false
# frozen_string_literal: true

module News
  module App
    module Edge
      module V0
        class SitemapsController < ApplicationController
          include ::Sitemap

          def show
            show_json
          end
        end
      end
    end
  end
end
