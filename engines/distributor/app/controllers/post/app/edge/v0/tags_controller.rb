# typed: false
# frozen_string_literal: true

module Jit
  module Distributor
    module Post
      module App
        module Edge
          module V0
            class TagsController < ApplicationController
              def index
                render json: { data: TaxonomyBuilder.build(AppDocumentTagMaster) }
              end
            end
          end
        end
      end
    end
  end
end
