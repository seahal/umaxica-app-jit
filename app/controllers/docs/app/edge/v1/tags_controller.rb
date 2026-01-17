# frozen_string_literal: true

module Docs
  module App
    module Edge
      module V1
        class TagsController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(AppDocumentTagMaster) }
          end
        end
      end
    end
  end
end
