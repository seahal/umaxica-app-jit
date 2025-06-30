import { jsx as _jsx } from "hono/jsx/jsx-runtime";
const HelloWorld = () => {
	return _jsx("div", { children: _jsx("h1", { children: "Hello, World!" }) });
};
export default HelloWorld;
