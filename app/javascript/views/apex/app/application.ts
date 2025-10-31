export const APEX_APP_DEFAULT_ORIGIN = "http://app.localhost";

/**
 * Resolves fully-qualified URLs for the apex app surface.
 */
export function resolveApexAppUrl(path = "/"): URL {
	return new URL(path, APEX_APP_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the apex app container dataset.
 */
export function readApexAppProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		apexServiceUrl: dataset.apexServiceUrl ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
	};
}
