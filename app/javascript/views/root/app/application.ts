export const ROOT_APP_DEFAULT_ORIGIN = "http://app.localhost";

/**
 * Resolves fully-qualified URLs for the root app surface.
 */
export function resolveRootAppUrl(path = "/"): URL {
	return new URL(path, ROOT_APP_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the root app container dataset.
 */
export function readRootAppProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		rootServiceUrl: dataset.rootServiceUrl ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
	};
}
