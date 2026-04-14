# typed: false
# frozen_string_literal: true

module Docs
  module Org
    module Edge
      module V0
        class CategoriesController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(OrgDocumentCategoryMaster) }
          end
        end
      end
    end
  end
end
