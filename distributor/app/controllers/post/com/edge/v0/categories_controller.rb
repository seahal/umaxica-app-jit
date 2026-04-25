# typed: false
# frozen_string_literal: true

module Post
  module Com
    module Edge
      module V0
        class CategoriesController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(ComDocumentCategoryMaster) }
          end
        end
      end
    end
  end
end
