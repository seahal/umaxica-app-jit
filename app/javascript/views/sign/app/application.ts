export const SIGN_APP_DEFAULT_ORIGIN = "http://sign.app.localhost";

/**
 * Resolves fully-qualified URLs for the sign app surface.
 */
export function resolveSignAppUrl(path = "/"): URL {
	return new URL(path, SIGN_APP_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the sign app container dataset.
 */
export function readSignAppProps(
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
