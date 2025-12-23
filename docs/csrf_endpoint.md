# CSRF token endpoint

- Why: SPA/BFF initial handshake to obtain a CSRF token and initialize session cookies.
- Client behavior: use `credentials: "include"` and send `X-CSRF-Token` on mutating requests.
- Security notes: responses must not be cached; SameSite/Secure cookie policies are configured elsewhere.
- Endpoint: `GET /auth/app/v1/csrf` returns JSON `{ csrf_token, csrf_param }`.
