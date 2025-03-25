module Www
  module App
    module Registration
      class EmailsController < ApplicationController
        #  before_action :set_user_email, only: %i[ show edit update ]

        def new
          @user_email = UserEmail.new
        end

        def create
          @user_email = UserEmail.new(sample_params)
          res = cloudflare_turnstile_validation

          respond_to do |format|
            if res["success"] == true && @user_email.save
              format.html { redirect_to www_app_registration_email_path(Base64.urlsafe_encode64(@user_email.address)), notice: "Sample was successfully created." }
            else
              format.html { render :new, status: :unprocessable_entity }
            end
          end
        end

        def show
        end

        def edit
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_user_email
          @user_email = UserEmail.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def sample_params
          params.expect(user_email: [ :address, :confirm_policy ])
        end

        def cloudflare_turnstile_validation
          res = Net::HTTP.post_form(URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify"),
                                    { "secret" => ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"],
                                      "response" => params["cf-turnstile-response"],
                                      "remoteip" => request.remote_ip })

          JSON.parse(res.body)
        end
      end
    end
  end
end
