export const DOCS_ORG_DEFAULT_ORIGIN = "http://docs.org.localhost";

/**
 * Resolves fully-qualified URLs for the docs staff surface.
 */
export function resolveDocsOrgUrl(path = "/"): URL {
	return new URL(path, DOCS_ORG_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the docs staff container dataset.
 */
export function readDocsOrgProps(
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
