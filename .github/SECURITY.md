# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| develop | :white_check_mark: |

## Reporting a Vulnerability

We take the security of our application seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do NOT Disclose Publicly

Please do not create a public GitHub issue for security vulnerabilities.

### 2. Report Privately

Report security vulnerabilities through GitHub's Security Advisories:
- Go to the repository's Security tab
- Click "Report a vulnerability"
- Fill in the vulnerability details

Alternatively, you can email security concerns to: [Your Security Email]

### 3. Provide Details

Please include the following information in your report:
- Type of vulnerability
- Full paths of source files related to the vulnerability
- Location of the affected source code (tag/branch/commit/direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### 4. Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Varies based on severity
  - Critical: Within 7 days
  - High: Within 30 days
  - Medium: Within 60 days
  - Low: Within 90 days

## Security Measures

Our application implements the following security measures:

### Authentication & Authorization
- Multi-factor authentication (WebAuthn, TOTP)
- OAuth integration (Apple, Google)
- Password hashing with Argon2
- Session management with secure tokens
- Role-based access control (Pundit)

### Data Protection
- Encryption at rest for sensitive data
- Encryption in transit (TLS)
- Secure credential management with Rails credentials

### Infrastructure Security
- Regular dependency updates and audits
- Automated security scanning (Brakeman, CodeQL, Semgrep, Trivy)
- Secret leak detection (Gitleaks)
- Container vulnerability scanning
- SBOM generation for supply chain security

### Application Security
- Rate limiting (Rack::Attack)
- Input validation and sanitization
- CSRF protection
- SQL injection prevention (ActiveRecord)
- XSS protection
- Secure headers configuration

### Monitoring & Logging
- Structured logging with OpenTelemetry
- Security event tracking
- Audit trails for sensitive operations

## Security Update Process

1. Security vulnerabilities are reviewed by the security team
2. Patches are developed and tested in a private branch
3. CVE identifiers are requested if applicable
4. Security advisories are published
5. Patches are released and announced
6. Affected users are notified

## Dependency Security

We use automated tools to monitor and update dependencies:
- **Bundler Audit**: Ruby gem vulnerability checking
- **Bun Audit**: JavaScript package vulnerability checking
- **Dependabot**: Automated dependency updates
- **License Finder**: License compliance checking

## Compliance

Our security practices align with:
- OWASP Top 10
- NIST Cybersecurity Framework
- SOC 2 Type II principles (in progress)

## Bug Bounty Program

We currently do not have a bug bounty program. However, we deeply appreciate responsible disclosure and will acknowledge security researchers who report valid vulnerabilities.

## Contact

For security-related questions or concerns:
- Security Email: [Your Security Email]
- Security Advisories: Use GitHub Security tab

---

Last Updated: 2025-12-26
