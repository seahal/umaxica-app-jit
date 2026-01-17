# frozen_string_literal: true

module Docs
  module App
    module Edge
      module V1
        class CategoriesController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(AppDocumentCategoryMaster) }
          end
        end
      end
    end
  end
end
