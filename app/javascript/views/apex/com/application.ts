export const APEX_COM_DEFAULT_ORIGIN = "http://com.localhost";

/**
 * Resolves fully-qualified URLs for the apex corporate surface.
 */
export function resolveApexComUrl(path = "/"): URL {
	return new URL(path, APEX_COM_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the apex corporate container dataset.
 */
export function readApexComProps(
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
