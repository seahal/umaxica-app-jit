# typed: false
# frozen_string_literal: true

module Docs
  module App
    module Edge
      module V1
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
