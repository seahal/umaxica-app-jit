# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Help
      module Com
<<<<<<< HEAD
        class ContactsController < ApplicationController
=======
        class ContactsController < Core::Org::ApplicationController
>>>>>>> 98bd02f0f ([CheckPoint] renamimg from main to core.)
          public_strict!

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
