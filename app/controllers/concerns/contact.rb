# frozen_string_literal: true

module Contact
  extend ActiveSupport::Concern

  private

  def clear_contact_session
    set_contact_session
  end

  # FIXME: remove hotp counter
  def set_contact_session(contact_id: nil, contact_email_address: nil, contact_telephone_number: nil, contact_email_checked: nil, contact_telephone_checked: nil, contact_otp_private_key: nil, contact_expires_in: nil, contact_hotp_counter: nil)
    session[:contact_id] = contact_id
    session[:contact_email_checked] = contact_email_checked
    session[:contact_telephone_checked] = contact_telephone_checked
    session[:contact_hotp_counter] = contact_hotp_counter  # FIXME: remove!
    session[:contact_expires_in] = contact_expires_in
    memorize[:contact_email_address] = contact_email_address
    memorize[:contact_telephone_number] = contact_telephone_number
    memorize[:contact_otp_private_key] = contact_otp_private_key
  end

  def check_all_contact_session_not_nil?
    [ session[:contact_id],
     session[:contact_email_address],
     session[:contact_telephone_number],
     session[:contact_email_checked],
     session[:contact_telephone_checked],
     session[:contact_otp_private_key],
     session[:contact_expires_in] ].all?
  end

  def show_error_page
    clear_contact_session
    render template: "www/app/contacts/error", status: :unprocessable_entity and return
  end
end
