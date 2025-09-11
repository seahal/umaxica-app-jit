# Security Policy

## Supported Versions

- We support the latest code on the `main` branch.
- Security fixes land on `main` and are released as part of normal updates.
- No long‑term support branches are currently maintained.

## Report a Vulnerability

Please do not open public issues for security reports.

- Use GitHub Security Advisories (private):
  - https://github.com/seahal/umaxica-app-jit/security/advisories/new
- Include: clear description, impact, affected commit/version, and minimal PoC or reproduction steps. Logs and configuration details are helpful when available.

Acknowledgement and timeline

- Acknowledge within 3 business days; initial triage update within 7 business days.
- For valid issues, we will develop a fix and coordinate disclosure. Depending on complexity and coordination needs, remediation may require up to 90 days.

Disclosure and credit

- We prefer coordinated disclosure. We will credit reporters in release notes unless you request otherwise.
- When appropriate, we will request a CVE and include references in the security advisory.

## Scope

In scope

- Vulnerabilities in this repository’s code and default configuration.
- Security issues that can be exploited without special privileges or that enable privilege escalation, sensitive data exposure, or remote code execution.

Out of scope (examples)

- Vulnerabilities in third‑party services or dependencies not maintained here (report upstream; feel free to link that in your advisory).
- Pure best‑practice suggestions without demonstrable security impact.
- Denial of service via excessive resource consumption, rate‑limiting bypass that requires unrealistic volumes, or social engineering of maintainers.

## Safe Harbor

We support good‑faith research. If you:

- Make a good‑faith effort to avoid privacy violations, destruction of data, and interruption or degradation of our services; and
- Only test on local environments or your own deployments (do not target production systems you do not control);

then we will not pursue legal action. If in doubt, ask first via a private advisory.

## Dependencies

- We use automation such as Dependabot, Brakeman, and Bundler Audit to track known issues.
- If the vulnerability is primarily in an upstream dependency, please report it upstream and optionally open an advisory here with links to the upstream report so we can track impact and mitigation.

## Contact and Questions

- For non‑sensitive security questions, open a discussion or issue.
- For sensitive matters, use the private advisory link above.

Thank you for helping keep users safe.
