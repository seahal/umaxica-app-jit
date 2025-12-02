import {Controller} from "@hotwired/stimulus";

// Connects to data-controller="cookie-toggle"
export default class extends Controller {
    static targets = ["checkbox", "status"];

    connect() {
        console.log("Cookie toggle controller connected!");
        console.log("Status target exists:", this.hasStatusTarget);
        console.log("Checkbox targets count:", this.checkboxTargets.length);
        this.updateStatus();
    }

    toggle(event) {
        console.log("Toggle called", event.target.checked);
        this.updateStatus();
    }

    updateStatus() {
        if (this.hasStatusTarget) {
            const checkedCount = this.checkboxTargets.filter(
                (cb) => cb.checked,
            ).length;
            const totalCount = this.checkboxTargets.length;
            this.statusTarget.textContent = `${checkedCount} / ${totalCount} cookies enabled`;
            console.log(`Updated status: ${checkedCount} / ${totalCount}`);
        } else {
            console.error("Status target not found!");
        }
    }
}
