import React from "react";

const HelloWorld = () => {
	return React.createElement(
		"div",
		null,
		React.createElement("h1", null, "Hello, World!"),
	);
};

export default HelloWorld;
