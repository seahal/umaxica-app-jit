# Engine Extraction Prep - 2026-04-03 Implementation Specification

## Context

This document tracks remaining work for Rails Engine extraction (GitHub #553).

**Status:** Phases 1-3 and 5 are **COMPLETE**. Phase 4 and 6 remain.

---

## Phase 4: Dynamic Sitemap + Robots + Health Improvements

### 4A: `app/controllers/concerns/robots.rb`

```ruby
# BEFORE (entire file)
module Robots
  extend ActiveSupport::Concern

  private

  def show_plain_text
    render plain: robots_txt
  end

  def robots_txt
    "User-agent: *\nDisallow:\n"
  end
end

# AFTER
module Robots
  extend ActiveSupport::Concern

  private

  def show_plain_text
    response.set_header("Cache-Control", "public, max-age=3600, s-maxage=86400")
    render plain: robots_txt
  end

  def robots_txt
    case Current.surface
    when :org
      "User-agent: *\nDisallow: /\n"
    when :app
      "User-agent: *\nDisallow: /configuration\nDisallow: /api\nDisallow: /web\n"
    else
      "User-agent: *\nDisallow:\n"
    end
  end
end
```

### 4B: `app/controllers/concerns/sitemap.rb`

Add a helper method for building sitemap entries:

```ruby
# ADD after sitemap_urls method (line 27)

  def sitemap_entry(loc:, lastmod: nil, changefreq: nil, priority: nil)
    entry = { loc: loc }
    entry[:lastmod] = lastmod.iso8601 if lastmod.respond_to?(:iso8601)
    entry[:changefreq] = changefreq if changefreq
    entry[:priority] = priority if priority
    entry
  end
```

### 4C: `app/controllers/concerns/health.rb`

Fix the `show_json` destructuring bug on line 105:

```ruby
# BEFORE (line 105)
  def show_json
    @status, @body, @errors = get_status
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision }

# AFTER
  def show_json
    @status, @body, @errors, @revision = get_status
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision }
```

Add `Current.surface` to the JSON response (after line 107):

```ruby
# BEFORE
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision }
    response_body[:errors] = @errors if @errors.present?

# AFTER
    response_body = { status: @body, timestamp: Time.now.utc.iso8601, revision: @revision, surface: Current.surface }
    response_body[:errors] = @errors if @errors.present?
```

---

## Phase 6: Dead Code Investigation (Debride - Investigation Only)

### Goal

Run Debride and document findings. Do NOT delete any code.

### Steps

```bash
# Run with default targets
bin/debride > tmp/debride_report.txt 2>&1

# Run with additional targets
bin/debride app/lib >> tmp/debride_report.txt 2>&1
bin/debride app/controllers/concerns >> tmp/debride_report.txt 2>&1

# Verbose mode
DEBRIDE_VERBOSE=1 bin/debride >> tmp/debride_verbose.txt 2>&1
```

### Output

Save the full report to `tmp/debride_report.txt`. Do not modify any code based on results.

---

## Completed Work (Reference)

- ✅ **Phase 1**: `Current.surface`, `Current.realm`, `Current.request_id`, `Current.boundary_key`
  implemented
- ✅ **Phase 2**: Flash boundary validation with `validate_flash_boundary` and `ALLOWED_TRANSITIONS`
- ✅ **Phase 3**: All controller concerns refactored to eliminate `included do` blocks
- ✅ **Phase 5**: All `Rails.logger.*` calls migrated to `Rails.event.*`

---

## Acceptance Criteria

- [ ] `robots.txt` returns surface-specific rules
- [ ] Health JSON endpoint includes `@revision` (bug fix) and `surface`
- [ ] `bundle exec rails test` passes
- [ ] `bundle exec rubocop` passes (or only pre-existing violations)
- [ ] Debride report saved to `tmp/debride_report.txt`

Updated: 2026-04-04
