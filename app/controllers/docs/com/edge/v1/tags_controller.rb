# typed: false
# frozen_string_literal: true

module Docs
  module Com
    module Edge
      module V1
        class TagsController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(ComDocumentTagMaster) }
          end
        end
      end
    end
  end
end
