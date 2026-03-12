# typed: false
# frozen_string_literal: true

module News
  module App
    module Edge
      module V0
        class CategoriesController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(AppTimelineCategoryMaster) }
          end
        end
      end
    end
  end
end
