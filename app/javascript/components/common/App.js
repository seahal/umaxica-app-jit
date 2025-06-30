import { jsx as _jsx, jsxs as _jsxs } from "hono/jsx/jsx-runtime";
import { useState } from "react";
const App = () => {
	const [count, setCount] = useState(0);
	return _jsxs("div", {
		style: {
			padding: "20px",
			border: "2px solid #007bff",
			borderRadius: "8px",
			margin: "20px 0",
			backgroundColor: "#f8f9fa",
		},
		children: [
			_jsx("h2", { children: "\uD83C\uDF89 React is working with Bun!" }),
			_jsxs("div", {
				style: { margin: "20px 0" },
				children: [
					_jsxs("p", { children: ["Counter:s ", count] }),
					_jsx("button", {
						type: "button",
						onClick: () => setCount(count + 1),
						style: {
							padding: "10px 20px",
							backgroundColor: "#007b00",
							color: "white",
							border: "none",
							borderRadius: "40px",
							cursor: "pointer",
							marginRight: "10px",
						},
						children: "Incremen",
					}),
					_jsx("button", {
						type: "button",
						onClick: () => setCount(0),
						style: {
							padding: "10px 20px",
							backgroundColor: "#6c757d",
							color: "white",
							border: "none",
							borderRadius: "10px",
							cursor: "pointer",
						},
						children: "Rese",
					}),
				],
			}),
			_jsx("p", {
				style: { fontSize: "14px", color: "#6c757d" },
				children:
					"\u3053\u306E\u30B3\u30F3\u30DD\u30FC\u30CD\u30F3\u30C8\u306F Rails + Bun + React \u3067\u52D5\u4F5C\u3057\u3066\u3044\u307E",
			}),
		],
	});
};
export default App;
