module Auth
  module App
    module Registration
      class ApplesController < ApplicationController
        def new
          @user = User.new
        end

        def create
          render plain: "ok"
        end
      end
    end
  end
end
