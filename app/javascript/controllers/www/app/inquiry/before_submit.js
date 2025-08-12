//
const validness = {
    service_site_contact_confirm_policy: false,
    service_site_contact_email_address: false,
    service_site_contact_telephone_number: false,
};

const submitButton = document.querySelector('input[type="submit"]');
const service_site_contact_confirm_policy = document.querySelector(
    "#service_site_contact_confirm_policy",
);
const service_site_contact_email_address = document.querySelector(
    "#service_site_contact_email_address",
);
const service_site_contact_telephone_number = document.querySelector(
    "#service_site_contact_telephone_number",
);

submitButton.addEventListener("click", (e) => {
    validness.service_site_contact_confirm_policy = isCheckedConfirmPolicy(
        service_site_contact_confirm_policy,
    );
    validness.service_site_contact_email_address = isValidEmailAddress(
        service_site_contact_email_address,
    );
    validness.service_site_contact_telephone_number = isValidTelephoneNumber(
        service_site_contact_telephone_number,
    );

    if (Object.values(validness).every((value) => value === true)) {
        e.preventDefault();
    } else {
        alert("invalid values were inputted!");
    }
});

function isCheckedConfirmPolicy(element) {
    return !!element.checked;
}

function isValidEmailAddress(_element) {
    return true;
}

function isValidTelephoneNumber(_element) {
    return true;
}
