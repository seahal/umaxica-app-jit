# typed: false
# frozen_string_literal: true

module News
  module Com
    module Edge
      module V1
        class CategoriesController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(ComTimelineCategoryMaster) }
          end
        end
      end
    end
  end
end
