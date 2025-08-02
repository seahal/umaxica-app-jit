module Auth
  module App
    module Authentication
      class RecoveriesController < ApplicationController
        def new
          @user_recover_code = UserRecoveryCode.new
        end

        def create
        end
      end
    end
  end
end
