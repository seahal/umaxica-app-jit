# frozen_string_literal: true

# Shared behavior for locale preference controllers. This concern narrows the
# accepted parameters to language and timezone while reusing the persistence
# logic defined in PreferenceRegions.
module PreferenceLocales
  extend ActiveSupport::Concern

  include PreferenceRegions

  private

  def preference_params
    params.permit(:language, :timezone)
  end
end
