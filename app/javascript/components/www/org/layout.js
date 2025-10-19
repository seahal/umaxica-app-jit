import {jsx as _jsx, jsxs as _jsxs} from "hono/jsx/jsx-runtime";

const Layout = (props, title = undefined) => {
    return _jsxs("html", {
        lang: "ja",
        children: [
            _jsx("head", {
                children: _jsxs("title", {children: ["Umaxica | ", title]}),
            }),
            _jsxs("body", {
                children: [
                    _jsx("header", {
                        children: _jsx("h1", {children: "Umaxica(org, edge)"}),
                    }),
                    _jsx("hr", {}),
                    props.children,
                    _jsx("hr", {}),
                    _jsx("footer", {
                        children: _jsx("p", {children: "\u00A9 umaxica"}),
                    }),
                ],
            }),
        ],
    });
};
export default Layout;
