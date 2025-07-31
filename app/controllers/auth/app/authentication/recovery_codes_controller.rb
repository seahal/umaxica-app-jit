module Auth
  module App
    module Authentication
      class RecoveryCodesController < ApplicationController
        def new
          @user_recover_code = UserRecoveryCode.new
        end
      end
    end
  end
end
