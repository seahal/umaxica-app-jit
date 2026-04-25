# typed: false
# frozen_string_literal: true

module Post
  module Org
    module Edge
      module V0
        class TagsController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(OrgDocumentTagMaster) }
          end
        end
      end
    end
  end
end
