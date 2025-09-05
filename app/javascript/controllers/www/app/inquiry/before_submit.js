// Minimal client-side guard for the inquiry form
// - Ensures policy checkbox is checked before submit

(() => {
	if (typeof document === "undefined") return;
	const form = document.querySelector("form[action$='/help/app/inquiries']");
	if (!form) return;

	form.addEventListener("submit", (e) => {
		const policy = form.querySelector(
			"input[name='service_site_contact[confirm_policy]']",
		);
		if (policy && !policy.checked) {
			e.preventDefault();
			alert("利用規約への同意が必要です。");
			policy.focus();
		}
	});
})();
