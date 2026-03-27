# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Up
      class EmailsController < Sign::App::Up::EmailsController
        include Sign::Com::ControllerBehavior

        private

        def complete_update_and_redirect
          progress_email_flow!(:update)
          create_welcome_bulletin!(current_resource)
          redirect_to(
            new_sign_com_configuration_telephones_registration_path(ri: params[:ri]),
            notice: t("sign.app.registration.email.update.success"),
          )
        end
      end
    end
  end
end
