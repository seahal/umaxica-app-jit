export const APEX_ORG_DEFAULT_ORIGIN = "http://org.localhost";

/**
 * Resolves fully-qualified URLs for the apex staff surface.
 */
export function resolveApexOrgUrl(path = "/"): URL {
	return new URL(path, APEX_ORG_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the apex staff container dataset.
 */
export function readApexOrgProps(
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
