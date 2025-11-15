module Sign
  module App
    module Authentication
      class TelephonesController < ApplicationController
        def new
          @user_telephone = UserIdentityTelephone.new
        end
      end
    end
  end
end
