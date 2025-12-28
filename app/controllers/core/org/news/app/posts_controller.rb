# frozen_string_literal: true

module Core
  module Org
    module News
      module App
        class PostsController < Core::Org::NewsController
          def index
            head :ok
          end

          def show
            head :ok
          end

          def new
            head :ok
          end

          def edit
            head :ok
          end

          def create
            head :ok
          end

          def update
            head :ok
          end

          def destroy
            head :ok
          end
        end
      end
    end
  end
end
