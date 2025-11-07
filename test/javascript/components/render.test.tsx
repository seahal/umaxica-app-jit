import {
	afterAll,
	afterEach,
	beforeAll,
	beforeEach,
	describe,
	expect,
	mock,
	test,
} from "bun:test";
import { createElement } from "react";
import { renderToStaticMarkup } from "react-dom/server";

const originalWindow = (globalThis as { window?: unknown }).window;

const createReactAriaStub = () => {
	const renderChildren = (children: unknown) => {
		if (typeof children === "function") {
			return children({ isSelected: false });
		}

		return children ?? null;
	};

	const asTag =
		(tag: keyof JSX.IntrinsicElements, droppedProps: string[] = []) =>
		(props: Record<string, unknown> = {}) => {
			const { children, className, ...rest } = props;
			const resolvedClassName =
				typeof className === "function"
					? className({ isSelected: false })
					: className;

			const filteredRest = Object.fromEntries(
				Object.entries(rest).filter(
					([key]) => !droppedProps.includes(key as string),
				),
			);

			return createElement(
				tag,
				{ ...filteredRest, className: resolvedClassName },
				renderChildren(children),
			);
		};

	const buttonLike = (props: Record<string, unknown> = {}) => {
		const { children, onPress, ...rest } = props;
		return createElement(
			"button",
			{ ...rest, onClick: onPress },
			renderChildren(children),
		);
	};

	const linkLike = (props: Record<string, unknown> = {}) => {
		const { children, href, className, ...rest } = props;
		const resolvedClassName =
			typeof className === "function"
				? className({ isSelected: false })
				: className;
		return createElement(
			"a",
			{ ...rest, href, className: resolvedClassName },
			renderChildren(children),
		);
	};

	const inputLike = (props: Record<string, unknown> = {}) => {
		const { children, ...rest } = props;
		return createElement("input", rest, renderChildren(children));
	};

	return {
		Button: buttonLike,
		Group: asTag("div"),
		Input: inputLike,
		Label: asTag("label"),
		Link: linkLike,
		SearchField: asTag("form", ["defaultValue"]),
		Tab: asTag("div", ["id"]),
		TabList: asTag("div"),
		TabPanel: asTag("div"),
		Tabs: asTag("div", ["defaultSelectedKey"]),
		Tooltip: asTag("div"),
		TooltipTrigger: asTag("div"),
		Separator: asTag("hr"),
		ToggleButton: asTag("button", ["defaultSelected"]),
	};
};

beforeAll(() => {
	(globalThis as { window?: any }).window = {
		location: { pathname: "/current" },
		innerHeight: 1080,
		scrollTo: () => {},
		alert: () => {},
		open: () => ({}),
	};
});

beforeEach(() => {
	mock.module("react-aria-components", () => createReactAriaStub());
});

afterEach(() => {
	mock.restore();
});

afterAll(() => {
	if (originalWindow === undefined) {
		delete (globalThis as { window?: unknown }).window;
	} else {
		(globalThis as { window?: unknown }).window = originalWindow;
	}
});

describe("component rendering", () => {
	test("HelloWorld.js renders greeting", async () => {
		const { default: HelloWorldJs } = await import(
			"../../../app/javascript/components/concern/HelloWorld.js"
		);

		const markup = renderToStaticMarkup(HelloWorldJs());

		expect(markup).toContain("Hello, World!");
	});

	test("HelloWorld.tsx renders greeting", async () => {
		const { default: HelloWorldTsx } = await import(
			"../../../app/javascript/components/concern/HelloWorld.tsx"
		);

		const markup = renderToStaticMarkup(<HelloWorldTsx />);

		expect(markup).toContain("Hello, World!");
	});

	test("HelpAppLanding renders code name and service URLs", async () => {
		const { default: HelpAppLanding } = await import(
			"../../../app/javascript/components/help/app/Landing.tsx"
		);

		const markup = renderToStaticMarkup(
			<HelpAppLanding
				codeName="Aquila"
				helpServiceUrl="https://help.example"
				docsServiceUrl="https://docs.example"
				newsServiceUrl="https://news.example"
			/>,
		);

		expect(markup).toContain("Aquila");
		expect(markup).toContain("help.example");
		expect(markup).toContain("docs.example");
	});

	test("HelpComLanding renders feature panels", async () => {
		const { default: HelpComLanding } = await import(
			"../../../app/javascript/components/help/com/Landing.tsx"
		);

		const markup = renderToStaticMarkup(<HelpComLanding />);

		expect(markup).toContain("Creator collectives launched");
		expect(markup).toContain("Community spaces");
	});

	test("RootAppLanding renders navigation and links", async () => {
		const { default: RootAppLanding } = await import(
			"../../../app/javascript/components/root/app/Landing.tsx"
		);

		const markup = renderToStaticMarkup(
			<RootAppLanding
				codeName="Aurora"
				rootServiceUrl="https://app.example"
				docsServiceUrl="https://docs.example"
				helpServiceUrl="https://help.example"
				newsServiceUrl="https://news.example"
			/>,
		);

		expect(markup).toContain("Aurora");
		expect(markup).toContain("#solutions");
		expect(markup).toContain("app.example");
	});
});
