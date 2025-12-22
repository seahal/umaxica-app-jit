module Rotp
  extend ActiveSupport::Concern

  private

    # Generate a new HOTP secret, counter, and corresponding 6-digit pass code for one-time use.
    # All three values should be persisted together so the pass code can be verified later.
    def generate_hotp_code
      sec = ROTP::Base32.random
      hotp = ROTP::HOTP.new(sec)
      counter = rand(1...1000000) * 2
      [ sec, counter, hotp.at(counter) ]
    end

    # Verify the submitted pass code by recreating the HOTP value from the stored secret and counter.
    # Returns true only when the provided code exactly matches the expected value.
    def verify_hotp_code(secret:, counter:, pass_code:)
      hotp = ROTP::HOTP.new(secret)
      hotp.verify(pass_code, counter) == counter
    end
end
