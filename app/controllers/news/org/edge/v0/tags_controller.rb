# typed: false
# frozen_string_literal: true

module News
  module Org
    module Edge
      module V0
        class TagsController < ApplicationController
          def index
            render json: { data: TaxonomyBuilder.build(OrgTimelineTagMaster) }
          end
        end
      end
    end
  end
end
