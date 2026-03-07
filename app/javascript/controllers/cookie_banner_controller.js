import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { endpoint: String };

  async accept() {
    if (!this.hasEndpointValue || !this.endpointValue) {
      return;
    }

    const csrf = document.querySelector("meta[name='csrf-token']")?.content;
    const response = await fetch(this.endpointValue, {
      method: "PATCH",
      credentials: "same-origin",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": csrf || "",
      },
      body: JSON.stringify({ consented: true }),
    });

    if (!response.ok) {
      return;
    }

    const data = await response.json();
    if (data?.show_banner === false) {
      this.dismiss();
    }
  }

  cancel() {
    this.dismiss();
  }

  dismiss() {
    this.element.closest("turbo-frame")?.remove();
  }
}
