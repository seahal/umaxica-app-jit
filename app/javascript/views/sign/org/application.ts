export const SIGN_ORG_DEFAULT_ORIGIN = "http://sign.org.localhost";

/**
 * Resolves fully-qualified URLs for the sign staff surface.
 */
export function resolveSignOrgUrl(path = "/"): URL {
	return new URL(path, SIGN_ORG_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the sign staff container dataset.
 */
export function readSignOrgProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		signServiceUrl: dataset.signServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
	};
}
