export const NEWS_COM_DEFAULT_ORIGIN = "http://news.com.localhost";

/**
 * Resolves fully-qualified URLs for the news corporate surface.
 */
export function resolveNewsComUrl(path = "/"): URL {
	return new URL(path, NEWS_COM_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the news corporate container dataset.
 */
export function readNewsComProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
	};
}
