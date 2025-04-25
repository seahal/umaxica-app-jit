module Www
  module App
    module Setting
      class TotpController < ApplicationController
        def index
          @utbotp = TimeBasedOneTimePassword.all
        end

        def new
          @utbotp = TimeBasedOneTimePassword.new
        end

        def create
          @utbotp = TimeBasedOneTimePassword.new(sample_params)

          respond_to do |format|
            if @utbotp.save
              format.html { redirect_to @utbotp, notice: "Sample was successfully created." }
            else
              format.html { render :new, status: :unprocessable_entity }
            end
          end
        end

        private
        # Use callbacks to share common setup or constraints between actions.
        def set_sample
          @sample = TimeBasedOneTimePassword.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def sample_params
          params.expect(time_based_one_time_password: [ :first_token, :second_token ])
        end
      end
    end
  end
end
