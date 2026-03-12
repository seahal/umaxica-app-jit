# typed: false
# frozen_string_literal: true

module News
  module App
    module Edge
      module V0
        class TagsController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(AppTimelineTagMaster) }
          end
        end
      end
    end
  end
end
