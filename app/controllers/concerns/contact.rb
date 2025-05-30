# frozen_string_literal: true

module Contact
  extend ActiveSupport::Concern

  private

  def clear_contact_session
    set_contact_session
  end

  def set_contact_session(contact_email_address: nil, contact_telephone_number: nil, contact_email_checked: nil, contact_telephone_checked: nil, contact_otp_private_key: nil, contact_expires_in: nil, contact_hotp_counter: nil)
    session[:contact_email_address] = contact_email_address
    session[:contact_telephone_number] = contact_telephone_number
    session[:contact_email_checked] = contact_email_checked
    session[:contact_telephone_checked] = contact_telephone_checked
    session[:contact_otp_private_key] = contact_otp_private_key
    session[:contact_hotp_counter] = contact_hotp_counter
    session[:contact_expires_in] = contact_expires_in
  end

  def check_all_contact_session_not_nil?
    [ session[:contact_email_address],
    session[:contact_telephone_number],
    session[:contact_email_checked],
    session[:contact_telephone_checked],
    session[:contact_otp_private_key],
    session[:contact_expires_in],
    session[:contact_hotp_counter] ].all? { it.nil? == false }
  end
end
