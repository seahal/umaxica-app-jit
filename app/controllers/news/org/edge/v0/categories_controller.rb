# typed: false
# frozen_string_literal: true

module News
  module Org
    module Edge
      module V0
        class CategoriesController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(OrgTimelineCategoryMaster) }
          end
        end
      end
    end
  end
end
