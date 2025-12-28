# frozen_string_literal: true

# Patch for InertiaRails compatibility with Rails 8.2+
# Rails 8.2 changed ActionDispatch::DebugExceptions#render_for_browser_request signature to take 3 args.
# InertiaRails 3.15 only accepts 2.

Rails.application.config.to_prepare do
  if defined?(InertiaRails::InertiaDebugExceptions)
    module InertiaRails
      module InertiaDebugExceptions
        def render_for_browser_request(request, wrapper, *_args)
          template = create_template(request, wrapper)
          file = "rescues/#{wrapper.rescue_template}"

          if request.xhr? && !request.headers["X-Inertia"]
            body = template.render(template: file, layout: false, formats: [:text])
            format = "text/plain"
          else
            body = template.render(template: file, layout: "rescues/layout")
            format = "text/html"
          end

          render(wrapper.status_code, body, format)
        end
      end
    end
  end
end
