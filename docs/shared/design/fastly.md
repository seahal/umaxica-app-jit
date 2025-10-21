# Fastly Multi-Tenant Error Handling

## Overview

Architecture for delivering tenant-specific error pages with Fastly VCL.
Users see the correct page for their domain without a URL change.

## Request Flow

### When a 404 Occurs

1. **User request**
   ```
   User → https://umaxica.com/naisaito
   ```

2. **Fastly forwards to Rails**
   ```
   Fastly → Rails application
   ```

3. **Rails responds with 404**
   ```
   Rails → returns 404 (page not found)
   ```

4. **Fastly VCL handles the error**
   ```
   Fastly VCL → catches 404 in vcl_error
   ```

5. **Fetch static error page**
   ```
   Fastly → retrieves 404.html from Cloudflare
   - umaxica.com → /com/404.html
   - umaxica.app → /app/404.html
   - umaxica.org → /org/404.html
   ```

6. **Deliver to the user**
   ```
   Fastly → serves the 404.html page (no URL change)
   ```

## VCL Implementation Sketch

```vcl
sub vcl_error {
  if (obj.status == 404 || obj.status == 500) {
    # Choose the error page path by domain
    if (req.http.host == "umaxica.com") {
      set bereq.backend = cloudflare_errors;
      set bereq.url = "/com/" + obj.status + ".html";
    } else if (req.http.host == "umaxica.app") {
      set bereq.backend = cloudflare_errors;
      set bereq.url = "/app/" + obj.status + ".html";
    } else if (req.http.host == "umaxica.org") {
      set bereq.backend = cloudflare_errors;
      set bereq.url = "/org/" + obj.status + ".html";
    }
    
    set bereq.http.host = "errors.cloudflare.com";
    restart;
  }
}
```

## Benefits

- **Stable URL**: The browser address bar remains unchanged.
- **Resilience**: Error pages render even if the primary site is down.
- **Performance**: Static files are delivered quickly.
- **Branding**: Each domain can present a tailored error page.
- **Cost efficiency**: Static-file hosting stays inexpensive.

## Candidate Locations for Static Files

- Cloudflare Pages
- AWS S3
- Google Cloud Storage  
- Netlify
- GitHub Pages

## Current Status

- ✅ Domain-specific error pages exist on the Rails side
  - `public/com/404.html`, `public/com/500.html`
  - `public/app/404.html`, `public/app/500.html`
  - `public/org/404.html`, `public/org/500.html`
- ⏳ Fastly VCL configuration still pending
- ⏳ Selecting and configuring the external static host remains TODO
