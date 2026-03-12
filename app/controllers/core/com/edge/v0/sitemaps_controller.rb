# typed: false
# frozen_string_literal: true

module Core
  module Com
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
