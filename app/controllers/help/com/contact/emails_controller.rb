module Help
  module Com
    module Contact
      class EmailsController < ApplicationController
        def new
          render plain: "aaa"
        end

        def create
          # Implementation for creating/verifying contact emails goes here
        end
      end
    end
  end
end
