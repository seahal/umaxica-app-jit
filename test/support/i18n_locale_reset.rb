# frozen_string_literal: true

# Ensure tests are order-independent by resetting the I18n locale for each test.
#
# Some tests assert Japanese validation messages, and a previous test may switch the
# locale to :en without resetting it. This hook forces the default locale at the
# start of each test and restores the prior locale afterwards.
class ActiveSupport::TestCase
  def run(*args, &)
    I18n.with_locale(I18n.default_locale) do
      Time.use_zone(Rails.application.config.time_zone) do
        super
      end
    end
  end
end
