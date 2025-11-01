export const ROOT_COM_DEFAULT_ORIGIN = "http://com.localhost";

/**
 * Resolves fully-qualified URLs for the root corporate surface.
 */
export function resolveRootComUrl(path = "/"): URL {
	return new URL(path, ROOT_COM_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the root corporate container dataset.
 */
export function readRootComProps(
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
