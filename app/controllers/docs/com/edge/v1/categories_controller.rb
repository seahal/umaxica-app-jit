# frozen_string_literal: true

module Docs
  module Com
    module Edge
      module V1
        class CategoriesController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(ComDocumentCategoryMaster) }
          end
        end
      end
    end
  end
end
