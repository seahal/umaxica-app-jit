NON_CONFUSABLE_ALPHANUMERIC_CHARACTERS = "ABCDEFHIJKMNOPRSTWXY2347"
NON_CONFUSABLE_ALPHANUMERIC_SIZE = NON_CONFUSABLE_ALPHANUMERIC_CHARACTERS.length

module Www
  module App
    module Setting
      class RecoveryCodesController < ApplicationController
        def index
        end

        def new
          @user_recover_code = UserRecoveryCode.new
        end

        def create
          @user_recover_code = UserRecoveryCode.new
          password = 16.times.map { NON_CONFUSABLE_ALPHANUMERIC_CHARACTERS[SecureRandom.random_number(NON_CONFUSABLE_ALPHANUMERIC_SIZE)] }.join
          id = SecureRandom.uuid_v7
        end

        # def show
        # end
        #
        # def edit
        # end
      end
    end
  end
end
