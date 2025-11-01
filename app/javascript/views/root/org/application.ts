export const ROOT_ORG_DEFAULT_ORIGIN = "http://org.localhost";

/**
 * Resolves fully-qualified URLs for the root staff surface.
 */
export function resolveRootOrgUrl(path = "/"): URL {
	return new URL(path, ROOT_ORG_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the root staff container dataset.
 */
export function readRootOrgProps(
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
