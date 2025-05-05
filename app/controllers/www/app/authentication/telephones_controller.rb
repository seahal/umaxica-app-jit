module Www
  module App
    module Authentication
      class TelephonesController < ApplicationController
        def new
          @user_telephone = UserTelephone.new
        end
      end
    end
  end
end
