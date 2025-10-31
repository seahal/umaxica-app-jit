export const DOCS_COM_DEFAULT_ORIGIN = "http://docs.com.localhost";

/**
 * Resolves fully-qualified URLs for the corporate docs surface.
 */
export function resolveDocsComUrl(path = "/"): URL {
	return new URL(path, DOCS_COM_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the docs corporate container dataset.
 */
export function readDocsComProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
	};
}
