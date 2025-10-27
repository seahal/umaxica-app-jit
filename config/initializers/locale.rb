require "i18n/backend/fallbacks"

# Allow english requests to transparently reuse japanese strings until proper
# translations are added.
I18n::Backend::Simple.include I18n::Backend::Fallbacks

I18n.load_path += Rails.root.glob("lib/locale/*.{rb,yml}")
I18n.available_locales = [ :en, :ja ]
I18n.default_locale = :ja
I18n.fallbacks = { en: [ :en, :ja ], ja: [ :ja, :en ] }
