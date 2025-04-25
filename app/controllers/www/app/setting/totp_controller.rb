module Www
  module App
    module Setting
      class TotpController < ApplicationController
        def index
          @utbotp = UserTimeBasedOneTimePassword.all
        end

        def new
          @utbotp = UserTimeBasedOneTimePassword.new
        end
      end
    end
  end
end
