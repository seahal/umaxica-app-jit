# typed: false
# frozen_string_literal: true

module News
  module Com
    module Edge
      module V0
        class TagsController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(ComTimelineTagMaster) }
          end
        end
      end
    end
  end
end
