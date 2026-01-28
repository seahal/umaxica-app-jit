# frozen_string_literal: true

module Sign::Org::UpsHelper
  def sign_org_recruit_contact_link
    preference_params = default_url_options.slice(:ct, :lx, :ri, :tz)
    link_to(
      t("sign.org.ups.new.recruit_link_text"),
      new_core_org_contact_url(
        {
          host: ENV.fetch("CORE_STAFF_URL", "core.org.localhost"),
          category: "recruit"
        }.merge(preference_params),
      ),
      class: "font-semibold text-slate-900 underline",
    )
  end
end
