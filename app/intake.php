<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ARCHR Intake Code Draft</title>
    <link rel="stylesheet" href="assets/intake.css">
</head>

<!--
    ARCHR Home Repair Services Screening Form
    =========================================
    Outer structure:
        <body>
        └── <div class="app-shell">              Centered modal-like container
            ├── <header class="brand">           Logo + title + EN/ES language switcher
            ├── <div class="progress-bar">       JS-driven progress indicator
            └── <main>
                └── <form id="intake-form">
                    ├── <section class="page"> × 14   One page per screen
                    └── <div class="modal">           Income calculator pop-up

    Conditional-visibility attributes:
        data-show-if="name=value"          page is skipped by JS navigation if condition fails
        data-show-when-value="name=value"  sub-block visible only when a field equals a value
        data-show-when-checked="value"     sub-block visible only when a checkbox of that value is checked

    The JS layer (intake.js) handles navigation, language toggling, and
    signature capture. It depends on id, name, and data-* attributes only —
    semantic element choices below can change freely without breaking it.

    Debug mode: append ?debug=true to the URL to bypass required-field
    validation on Next, matching the behavior of the production platform.
-->

<body>
<div class="app-shell" role="dialog" aria-labelledby="app-title">

    <header class="brand">
        <div class="lettermark" aria-hidden="true">A</div>
        <div class="titles">
            <h1 id="app-title">Asheville Regional Coalition for Home Repair</h1>
            <p class="subtitle">Home Repair Services Screening Form</p>
        </div>
        <!-- Language switcher: JS reads data-lang and swaps text nodes / placeholders. -->
        <div class="lang-switch" role="group" aria-label="Language switcher">
            <button type="button" data-lang="eng" class="active" aria-pressed="true">EN</button>
            <button type="button" data-lang="esp" aria-pressed="false">ES</button>
        </div>
    </header>

    <!-- Progress bar — JS sets .progress-bar-fill width based on the visible page count. -->
    <div class="progress-bar" aria-hidden="true">
        <div class="progress-bar-fill" id="progress-bar-fill"></div>
    </div>

    <main>
        <form id="intake-form" action="api/submit.php" method="post" novalidate>
            <!-- Selected language travels with the submission. -->
            <input type="hidden" name="language" id="language" value="eng">

            <!-- Honeypot: real users never see this; bots fill in every field.
                 form-handler.php silently drops any submission where it is set. -->
            <div class="hp-field" aria-hidden="true">
                <label>Leave this field empty
                    <input type="text" name="website" tabindex="-1" autocomplete="off">
                </label>
            </div>

            <!-- Early duplicate-warning banner (populated by intake.js) -->
            <div class="duplicate-warning" id="duplicate-warning" role="status" hidden></div>

            <!-- =====================================================================
                 Page 1 — Welcome & referral routing
                 ---------------------------------------------------------------------
                 Branch point: `isReferral=yes` reveals Page 3 (referrer details);
                 otherwise that page is skipped.
                 ===================================================================== -->
            <section class="page active" id="page-welcome" data-page="welcome">
                <p class="progress">Step 1 &middot; Welcome</p>
                <p>Use the EN / ES toggle at the top of the page at any time to switch between English and Spanish.</p>

                <fieldset class="field">
                    <legend>Are you submitting this on behalf of someone else as a referral?</legend>
                    <div class="radios">
                        <label><input type="radio" name="isReferral" value="yes"> <span>Yes, I am referring someone</span></label>
                        <label><input type="radio" name="isReferral" value="no"> <span>No, I am the applicant</span></label>
                    </div>
                </fieldset>

                <footer class="actions">
                    <span></span>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 2 — About this form & data-sharing consent
                 ---------------------------------------------------------------------
                 `consentAgree` is the gate for cross-partner data sharing. The
                 single-checkbox-inside-a-label pattern below is the accessible
                 idiom for a stand-alone consent control.
                 ===================================================================== -->
            <section class="page" id="page-intro" data-page="intro">
                <p class="progress">Step 2 &middot; About this form</p>
                <h2>Screening Form</h2>
                <p>This screening form will screen you for eligibility to apply for home repair services at any organization within the ARCHR partnership, which includes:</p>
                <ul class="plain">
                    <li>Asheville Habitat for Humanity</li>
                    <li>Community Action Opportunities</li>
                    <li>PODER Emma</li>
                    <li>Asheville Buncombe Community Land Trust</li>
                    <li>Mountain Housing Opportunities</li>
                    <li>Community Housing Coalition of Madison County</li>
                </ul>

                <h3>Data Confidentiality</h3>
                <p>This screening tool requests information about your home repair needs. This information will be shared with the organizations of ARCHR (Asheville Regional Coalition for Home Repair).</p>
                <p>These organizations support offering necessary repairs, accessibility modifications, and weatherization assistance to Western North Carolina homeowners.</p>
                <p>Because of complex eligibility criteria and funding availability across repair organizations, this screening tool helps our organizations identify which one of us is best able to serve you, preventing you from filling out applications for organizations that cannot serve you in the end.</p>
                <p>By submitting this form, you are agreeing to submit this screening and associated information to the organizations of the Asheville Regional Coalition for Home Repair so that we can work together to better serve you. Information will never be shared outside of the ARCHR organizations.</p>
                <p>If you meet the initial criteria, staff from ARCHR will contact you by telephone to set up a home visit to assess the requested repairs and report back to the coalition.</p>

                <div class="field">
                    <label><input type="checkbox" name="consentAgree" value="yes"> I agree to the data sharing terms above.</label>
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 3 — Referrer details   (shown only when isReferral=yes)
                 ===================================================================== -->
            <section class="page" id="page-referrer" data-page="referrer" data-show-if="isReferral=yes">
                <p class="progress">Referral submission</p>
                <h2>Submit referral</h2>
                <p>Tell us who is submitting this referral on behalf of the applicant.</p>

                <div class="field">
                    <label for="referrerName">Your name <span class="req">*</span></label>
                    <input type="text" id="referrerName" name="referrerName">
                </div>
                <div class="field">
                    <label for="referrerOrganization">Your organization</label>
                    <input type="text" id="referrerOrganization" name="referrerOrganization">
                </div>
                <div class="field">
                    <label for="referrerEmail">Your email <span class="req">*</span></label>
                    <input type="email" id="referrerEmail" name="referrerEmail">
                </div>
                <div class="field">
                    <label for="referrerNotes">Referral notes</label>
                    <textarea id="referrerNotes" name="referrerNotes"></textarea>
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 4 — Primary contact information
                 ---------------------------------------------------------------------
                 Collects the applicant's name, DOB, and how staff should reach
                 them. The `.row` wrapper renders side-by-side fields on wider
                 viewports (see Section 6 of style.css).
                 ===================================================================== -->
            <section class="page" id="page-contact" data-page="contact">
                <p class="progress">Primary contact information</p>
                <h2>Primary Contact Information</h2>

                <div class="row">
                    <div class="field">
                        <label for="applicantFirstName">Primary applicant first name <span class="req">*</span></label>
                        <input type="text" id="applicantFirstName" name="applicantFirstName" autocomplete="given-name">
                    </div>
                    <div class="field">
                        <label for="applicantLastName">Primary applicant last name <span class="req">*</span></label>
                        <input type="text" id="applicantLastName" name="applicantLastName" autocomplete="family-name">
                    </div>
                </div>

                <div class="field">
                    <label for="applicantDob">Primary applicant date of birth <span class="req">*</span></label>
                    <input type="date" id="applicantDob" name="applicantDob" autocomplete="bday">
                    <label class="inline-check"><input type="checkbox" name="applicantDobUnknown" value="yes"> Check if primary applicant DOB unknown</label>
                </div>

                <fieldset class="field">
                    <legend>Preferred contact method <span class="req">*</span> &mdash; select all that work</legend>
                    <div class="checks">
                        <label><input type="checkbox" name="preferredContact[]" value="phone"> Phone call</label>
                        <label><input type="checkbox" name="preferredContact[]" value="text"> Text message</label>
                        <label><input type="checkbox" name="preferredContact[]" value="email"> Email</label>
                        <label><input type="checkbox" name="preferredContact[]" value="other"> Other contact method</label>
                    </div>
                </fieldset>

                <div class="row">
                    <div class="field">
                        <label for="homePhone">Home phone</label>
                        <input type="tel" id="homePhone" name="homePhone" autocomplete="home tel">
                    </div>
                    <div class="field">
                        <label for="cellPhone">Cell phone</label>
                        <input type="tel" id="cellPhone" name="cellPhone" autocomplete="mobile tel">
                    </div>
                </div>
                <p><small>One phone number is required, and email is required.</small></p>

                <div class="field">
                    <label for="contactEmail">Email address <span class="req">*</span></label>
                    <input type="email" id="contactEmail" name="contactEmail" autocomplete="email" required>
                </div>
                <div class="field">
                    <label for="otherContactMethod">Other contact method &mdash; please describe how you would like to be contacted</label>
                    <input type="text" id="otherContactMethod" name="otherContactMethod">
                </div>
                <div class="field">
                    <label for="contactNotes">Are there any specific times of day or other details you'd like to add about how to contact you?</label>
                    <textarea id="contactNotes" name="contactNotes"></textarea>
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 5 — Home address, mailing address, dwelling details, household
                 ---------------------------------------------------------------------
                 Branch points on this page:
                   • receivesDifferentMail=yes  → reveals mailing-address sub-block
                   • homeType=mobile            → reveals "own the lot?" sub-block
                 ===================================================================== -->
            <section class="page" id="page-address" data-page="address">
                <p class="progress">Home address &amp; household</p>
                <h2>Home Address</h2>

                <div class="field">
                    <label for="homeAddress">Home address</label>
                    <input type="text" id="homeAddress" name="homeAddress" autocomplete="street-address">
                </div>
                <div class="row-3">
                    <div class="field">
                        <label for="homeCity">City</label>
                        <input type="text" id="homeCity" name="homeCity" autocomplete="address-level2">
                    </div>
                    <div class="field">
                        <label for="homeState">State / Province</label>
                        <input type="text" id="homeState" name="homeState" autocomplete="address-level1">
                    </div>
                    <div class="field">
                        <label for="homeZip">Zip / Postal code</label>
                        <input type="text" id="homeZip" name="homeZip" autocomplete="postal-code">
                    </div>
                </div>

                <fieldset class="field">
                    <legend>Is this your primary residence?</legend>
                    <div class="radios">
                        <label><input type="radio" name="isPrimaryResidence" value="yes"> Yes</label>
                        <label><input type="radio" name="isPrimaryResidence" value="no"> No</label>
                    </div>
                </fieldset>
                <fieldset class="field">
                    <legend>Do you receive mail at a different address?</legend>
                    <div class="radios">
                        <label><input type="radio" name="receivesDifferentMail" value="yes"> Yes</label>
                        <label><input type="radio" name="receivesDifferentMail" value="no"> No</label>
                    </div>
                </fieldset>

                <!-- Mailing address — JS toggles [hidden] when receivesDifferentMail changes. -->
                <div class="sub" data-show-when-value="receivesDifferentMail=yes" hidden>
                    <h3>Mailing address</h3>
                    <div class="field">
                        <label for="mailAddress">Address</label>
                        <input type="text" id="mailAddress" name="mailAddress">
                    </div>
                    <div class="row-3">
                        <div class="field">
                            <label for="mailCity">City</label>
                            <input type="text" id="mailCity" name="mailCity">
                        </div>
                        <div class="field">
                            <label for="mailState">State / Province</label>
                            <input type="text" id="mailState" name="mailState">
                        </div>
                        <div class="field">
                            <label for="mailZip">Zip / Postal</label>
                            <input type="text" id="mailZip" name="mailZip">
                        </div>
                    </div>
                </div>

                <h3>About your home</h3>
                <div class="field">
                    <label for="homeType">Type of home</label>
                    <select id="homeType" name="homeType">
                        <option value="">&mdash; Select &mdash;</option>
                        <option value="traditional">Traditional construction</option>
                        <option value="modular">Modular home</option>
                        <option value="mobile">Mobile home</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="row">
                    <div class="field">
                        <label for="yearBuilt">Year built</label>
                        <input type="number" id="yearBuilt" name="yearBuilt" min="1700" max="2100">
                    </div>
                    <div class="field">
                        <label for="moveInDate">When did you move into this address?</label>
                        <input type="date" id="moveInDate" name="moveInDate">
                    </div>
                </div>

                <fieldset class="field">
                    <legend>Do you own your home? <span class="req">*</span></legend>
                    <div class="radios">
                        <label><input type="radio" name="ownsHome" value="yes"> Yes</label>
                        <label><input type="radio" name="ownsHome" value="no"> No</label>
                    </div>
                </fieldset>

                <!-- Mobile-home-only follow-up. -->
                <div class="sub" data-show-when-value="homeType=mobile" hidden>
                    <fieldset class="field">
                        <legend>Do you own the lot your mobile home is on? <span class="req">*</span></legend>
                        <div class="radios">
                            <label><input type="radio" name="ownsLot" value="yes"> Yes</label>
                            <label><input type="radio" name="ownsLot" value="no"> No</label>
                        </div>
                    </fieldset>
                </div>

                <div class="field">
                    <label for="insuranceProvider">Home owner's insurance provider (optional)</label>
                    <input type="text" id="insuranceProvider" name="insuranceProvider">
                </div>
                <fieldset class="field">
                    <legend>Have you lived in your home for at least 1 year?</legend>
                    <div class="radios">
                        <label><input type="radio" name="livedOneYear" value="yes"> Yes</label>
                        <label><input type="radio" name="livedOneYear" value="no"> No</label>
                    </div>
                </fieldset>

                <div class="row">
                    <div class="field">
                        <label for="householdSize">How many people live in your home full time? <span class="req">*</span></label>
                        <input type="number" id="householdSize" name="householdSize" min="1">
                    </div>
                    <div class="field">
                        <label for="householdAdults">Of those, how many are over 18 years old?</label>
                        <input type="number" id="householdAdults" name="householdAdults" min="0">
                    </div>
                </div>
                <p><small>Count adults and children residing at your home at least 50% of the time.</small></p>

                <fieldset class="field">
                    <legend>Select any that are part of this household (check all that apply):</legend>
                    <div class="checks">
                        <label><input type="checkbox" name="householdAttributes[]" value="single_parent"> Single parent</label>
                        <label><input type="checkbox" name="householdAttributes[]" value="child_under_5"> Child under 5 years old</label>
                        <label><input type="checkbox" name="householdAttributes[]" value="person_over_62"> Person over 62</label>
                        <label><input type="checkbox" name="householdAttributes[]" value="person_with_disability"> Person with disability</label>
                        <label><input type="checkbox" name="householdAttributes[]" value="snap_wic"> Person that receives SNAP/EBT or WIC</label>
                        <label><input type="checkbox" name="householdAttributes[]" value="veteran"> US Armed Forces Veteran</label>
                    </div>
                </fieldset>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 6 — Repair request list (intake-staff facing wording)
                 ---------------------------------------------------------------------
                 The repair table is dynamic — `data-repair-add` appends a new
                 <tr> via JS, `data-repair-clear` resets all rows. The urgent-
                 condition checkboxes feed into prioritization downstream.
                 ===================================================================== -->
            <section class="page" id="page-repair-list" data-page="repair-list">
                <p class="progress">Repair request</p>
                <h2>Add Repair Request</h2>
                <p>Enter a brief description of needed repairs (i.e. "gutters replaced" or "unsafe entry stairs"). If you can, enter an applicant-identified priority rank (e.g. "replace leaking roof | 1", "repaint hallway | 2").</p>

                <table id="repair-table" class="repair-table">
                    <thead>
                        <tr>
                            <th scope="col">Repair need</th>
                            <th scope="col" class="col-priority">Urgency</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><input type="text" name="repairNeed[]" aria-label="Repair need"></td>
                            <td>
                                <select name="repairPriority[]" aria-label="Urgency level">
                                    <option value="">Select urgency</option>
                                    <option value="1">Critical - Immediate danger/uninhabitable</option>
                                    <option value="2">High - Major issue affecting daily life</option>
                                    <option value="3">Medium - Significant but manageable</option>
                                    <option value="4">Low - Minor repair needed</option>
                                </select>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <!-- Row controls — JS hooks via data-repair-add / data-repair-clear. -->
                <div class="button-row">
                    <button type="button" class="secondary" data-repair-add>+ Add row</button>
                    <button type="button" class="ghost" data-repair-clear>Clear</button>
                </div>

                <div class="field field-spaced">
                    <label for="additionalRepairDetails">Enter any additional repair need details</label>
                    <textarea id="additionalRepairDetails" name="additionalRepairDetails"></textarea>
                </div>

                <fieldset class="field">
                    <legend>Check any that apply:</legend>
                    <div class="checks">
                        <label><input type="checkbox" name="urgentConditions[]" value="unable_to_stay"> Applicant is unable to stay in home</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="no_hvac"> Applicant does not have functional heating and/or air conditioning</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="no_potable_water"> Applicant does not have potable water</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="no_bathroom"> Applicant can not use bathroom facilities (toilet/shower/bath)</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="no_kitchen"> Applicant can not use kitchen facilities (stove/oven/refrigerator)</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="open_to_elements"> Applicant's home is open to the elements (rain/wind/animals)</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="no_entry"> Applicant can not get into or out of home</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="accessibility"> Applicant has accessibility need</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="other_issue"> Applicant has an issue not listed</label>
                        <label><input type="checkbox" name="urgentConditions[]" value="eviction_risk"> Applicant is at risk of eviction</label>
                    </div>
                </fieldset>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 7 — Home repair categories (applicant-facing wording)
                 ---------------------------------------------------------------------
                 Each checkbox value here MUST match a `data-show-when-checked`
                 value on Page 8 so the corresponding follow-up block reveals.
                 ===================================================================== -->
            <section class="page" id="page-repair-categories" data-page="repair-categories">
                <p class="progress">Home repair requests</p>
                <h2>Home Repair Requests</h2>
                <p>Please check all boxes that apply to your home:</p>

                <fieldset class="field">
                    <legend class="visually-hidden">Repair categories</legend>
                    <div class="checks">
                        <label><input type="checkbox" name="repairCategory[]" value="unable_to_stay"> I am unable to stay in my home</label>
                        <label><input type="checkbox" name="repairCategory[]" value="no_hvac"> I do not have functional heating and/or air conditioning</label>
                        <label><input type="checkbox" name="repairCategory[]" value="no_potable_water"> I do not have potable water</label>
                        <label><input type="checkbox" name="repairCategory[]" value="no_bathroom"> I can not use bathroom facilities (toilet/shower/bath)</label>
                        <label><input type="checkbox" name="repairCategory[]" value="no_kitchen"> I can not use kitchen facilities (stove/oven/refrigerator)</label>
                        <label><input type="checkbox" name="repairCategory[]" value="open_to_elements"> My home is open to the elements (rain/wind/animals)</label>
                        <label><input type="checkbox" name="repairCategory[]" value="no_entry"> I can not get into or out of my home</label>
                        <label><input type="checkbox" name="repairCategory[]" value="accessibility"> I have an accessibility need</label>
                        <label><input type="checkbox" name="repairCategory[]" value="other_issue"> I have an issue not listed</label>
                        <label><input type="checkbox" name="repairCategory[]" value="eviction_risk"> I am at risk of eviction</label>
                    </div>
                </fieldset>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 8 — Per-category follow-up questions
                 ---------------------------------------------------------------------
                 Every `.sub` here is bound to one Page-7 checkbox via
                 `data-show-when-checked="<value>"`. The block is `hidden` by
                 default and revealed by JS when the matching checkbox is ticked.
                 ===================================================================== -->
            <section class="page" id="page-request-details" data-page="request-details">
                <p class="progress">Request details</p>
                <h2>Request Details</h2>
                <p>Please tell us more about each issue you selected.</p>

                <div class="sub" data-show-when-checked="unable_to_stay" hidden>
                    <h3>Uninhabitable home &mdash; "I am unable to stay in my home"</h3>
                    <div class="field">
                        <label for="detailsUnableToStay">Please describe the issue as best as you can <span class="req">*</span></label>
                        <textarea id="detailsUnableToStay" name="detailsUnableToStay"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="no_hvac" hidden>
                    <h3>Heating and/or air conditioning &mdash; "I do not have functional heating and/or air conditioning"</h3>
                    <div class="field">
                        <label for="detailsHvac">Please describe the issue as best as you can</label>
                        <textarea id="detailsHvac" name="detailsHvac"></textarea>
                    </div>
                    <fieldset class="field">
                        <legend>How do you heat your home? (check all that apply)</legend>
                        <div class="checks">
                            <label><input type="checkbox" name="heatingSource[]" value="woodstove"> Woodstove / fireplace</label>
                            <label><input type="checkbox" name="heatingSource[]" value="gas_propane"> Natural gas / propane</label>
                            <label><input type="checkbox" name="heatingSource[]" value="electric"> Electric</label>
                            <label><input type="checkbox" name="heatingSource[]" value="kerosene"> Kerosene</label>
                        </div>
                    </fieldset>
                </div>

                <div class="sub" data-show-when-checked="no_potable_water" hidden>
                    <h3>Potable water &mdash; "I don't have potable water"</h3>
                    <div class="field">
                        <label for="waterSource">Please select source of water</label>
                        <select id="waterSource" name="waterSource">
                            <option value="">&mdash; Select &mdash;</option>
                            <option value="municipal">City / municipal</option>
                            <option value="well">Well</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="detailsWater">Please describe the issue as best as you can</label>
                        <textarea id="detailsWater" name="detailsWater"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="no_bathroom" hidden>
                    <h3>Bathroom facilities &mdash; "I can not use bathroom facilities"</h3>
                    <div class="field">
                        <label for="detailsBathroom">Please describe the issue as best as you can</label>
                        <textarea id="detailsBathroom" name="detailsBathroom"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="no_kitchen" hidden>
                    <h3>Kitchen facilities &mdash; "I can not use kitchen facilities"</h3>
                    <div class="field">
                        <label for="detailsKitchen">Please describe the issue as best as you can</label>
                        <textarea id="detailsKitchen" name="detailsKitchen"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="open_to_elements" hidden>
                    <h3>Open to the elements &mdash; "My home is open to the elements"</h3>
                    <div class="field">
                        <label for="detailsElements">Please describe the issue as best as you can</label>
                        <textarea id="detailsElements" name="detailsElements"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="no_entry" hidden>
                    <h3>Entry / exit &mdash; "I can not get into or out of my home"</h3>
                    <div class="field">
                        <label for="detailsEntry">Please describe the issue as best as you can</label>
                        <textarea id="detailsEntry" name="detailsEntry"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="accessibility" hidden>
                    <h3>Accessibility need</h3>
                    <div class="field">
                        <label for="detailsAccessibility">Please describe your accessibility need</label>
                        <textarea id="detailsAccessibility" name="detailsAccessibility"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="other_issue" hidden>
                    <h3>Issue not listed</h3>
                    <div class="field">
                        <label for="detailsOther">Please describe the issue</label>
                        <textarea id="detailsOther" name="detailsOther"></textarea>
                    </div>
                </div>

                <div class="sub" data-show-when-checked="eviction_risk" hidden>
                    <h3>At risk of eviction</h3>
                    <div class="field">
                        <label for="detailsEviction">Please describe your situation</label>
                        <textarea id="detailsEviction" name="detailsEviction"></textarea>
                    </div>
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 9 — Tropical Storm Helene routing
                 ---------------------------------------------------------------------
                 `heleneRelated=yes` is the branch gate for Page 10 (FEMA claim
                 history). Answering "no" skips that page entirely.
                 ===================================================================== -->
            <section class="page" id="page-helene" data-page="helene">
                <p class="progress">Hurricane Helene</p>
                <h2>Tropical Storm Helene</h2>

                <fieldset class="field">
                    <legend>Was this issue caused by Tropical Storm Helene?</legend>
                    <div class="radios">
                        <label><input type="radio" name="heleneRelated" value="no"> This request is <strong>NOT</strong> related to damage sustained from Helene</label>
                        <label><input type="radio" name="heleneRelated" value="yes"> This request <strong>is</strong> due to damage sustained from Helene</label>
                    </div>
                </fieldset>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 10 — FEMA claim history   (shown only when heleneRelated=yes)
                 ---------------------------------------------------------------------
                 Nested branches:
                   • femaClaim=yes      → reveals outcome / settlement sub-block
                   • femaRemaining=yes  → reveals remaining-amount field
                 ===================================================================== -->
            <section class="page" id="page-fema" data-page="fema" data-show-if="heleneRelated=yes">
                <p class="progress">FEMA</p>
                <h2>FEMA</h2>

                <fieldset class="field">
                    <legend>Have you filed a claim with FEMA for repairs listed? <span class="req">*</span></legend>
                    <div class="radios">
                        <label><input type="radio" name="femaClaim" value="yes"> Yes</label>
                        <label><input type="radio" name="femaClaim" value="no"> No</label>
                    </div>
                </fieldset>

                <div class="sub" data-show-when-value="femaClaim=yes" hidden>
                    <div class="field">
                        <label for="femaOutcome">What was the outcome of the FEMA claim? <span class="req">*</span></label>
                        <select id="femaOutcome" name="femaOutcome">
                            <option value="">&mdash; Select &mdash;</option>
                            <option value="denied">Denied</option>
                            <option value="settled">Settled</option>
                            <option value="other">Other</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="femaSettlementAmount">What was total FEMA settlement amount? <span class="req">*</span></label>
                        <input type="number" id="femaSettlementAmount" name="femaSettlementAmount" min="0" step="0.01">
                    </div>
                    <fieldset class="field">
                        <legend>Is there any remaining $ from the FEMA settlement amount paid? <span class="req">*</span></legend>
                        <div class="radios">
                            <label><input type="radio" name="femaRemaining" value="yes"> Yes</label>
                            <label><input type="radio" name="femaRemaining" value="no"> No</label>
                        </div>
                    </fieldset>
                    <div class="field" data-show-when-value="femaRemaining=yes" hidden>
                        <label for="femaRemainingAmount">What is the total amount remaining from the FEMA settlement amount? <span class="req">*</span></label>
                        <input type="number" id="femaRemainingAmount" name="femaRemainingAmount" min="0" step="0.01">
                    </div>
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 11 — Homeowner's insurance claim history
                 ---------------------------------------------------------------------
                 Mirrors Page 10's structure for non-FEMA insurance. Outstanding
                 settlement balances are deducted from any ARCHR award.
                 ===================================================================== -->
            <section class="page" id="page-insurance" data-page="insurance">
                <p class="progress">Homeowner's insurance</p>
                <h2>Homeowner's Insurance</h2>

                <fieldset class="field">
                    <legend>Have you filed a claim with your homeowner's insurance for repairs you listed? <span class="req">*</span></legend>
                    <div class="radios">
                        <label><input type="radio" name="insuranceClaim" value="yes"> Yes</label>
                        <label><input type="radio" name="insuranceClaim" value="no"> No</label>
                    </div>
                </fieldset>

                <div class="sub" data-show-when-value="insuranceClaim=yes" hidden>
                    <div class="field">
                        <label for="insuranceOutcome">What was the outcome of the homeowner's insurance claim? <span class="req">*</span></label>
                        <select id="insuranceOutcome" name="insuranceOutcome">
                            <option value="">&mdash; Select &mdash;</option>
                            <option value="denied">Denied</option>
                            <option value="settled">Settled</option>
                            <option value="other">Other</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="insuranceSettlementAmount">What was the total homeowner's insurance settlement amount? <span class="req">*</span></label>
                        <input type="number" id="insuranceSettlementAmount" name="insuranceSettlementAmount" min="0" step="0.01">
                    </div>
                    <fieldset class="field">
                        <legend>Is there any remaining $ from the homeowner's insurance settlement amount paid? <span class="req">*</span></legend>
                        <div class="radios">
                            <label><input type="radio" name="insuranceRemaining" value="yes"> Yes</label>
                            <label><input type="radio" name="insuranceRemaining" value="no"> No</label>
                        </div>
                    </fieldset>
                    <div class="field" data-show-when-value="insuranceRemaining=yes" hidden>
                        <label for="insuranceRemainingAmount">What is the total amount remaining from the homeowner's insurance settlement amount? <span class="req">*</span></label>
                        <input type="number" id="insuranceRemainingAmount" name="insuranceRemainingAmount" min="0" step="0.01">
                    </div>
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 12 — Income information & applicant signature
                 ---------------------------------------------------------------------
                 Branch points:
                   • haveIncome=no              → routes to Page 13 zero-income affidavit
                   • incomeMethod=gross         → single annual-income input
                   • incomeMethod=calculator    → opens income-source modal (bottom of file)
                 The <canvas data-signature> is initialized by SignaturePad in
                 archr-intake.js; the rendered PNG data URL is saved into the
                 hidden `applicantSignature` input on every stroke.
                 ===================================================================== -->
            <section class="page" id="page-income" data-page="income">
                <p class="progress">Income information</p>
                <h2>Add Income Information</h2>

                <fieldset class="field">
                    <legend>Do you receive income? <span class="req">*</span></legend>
                    <div class="radios">
                        <label><input type="radio" name="haveIncome" value="yes"> Yes</label>
                        <label><input type="radio" name="haveIncome" value="no"> No</label>
                    </div>
                </fieldset>

                <div class="sub" data-show-when-value="haveIncome=yes" hidden>
                    <fieldset class="field">
                        <legend>How would you like to record your income?</legend>
                        <div class="radios">
                            <label><input type="radio" name="incomeMethod" value="gross"> Enter gross annual income</label>
                            <label><input type="radio" name="incomeMethod" value="calculator"> Use the $ calculator</label>
                        </div>
                    </fieldset>

                    <div class="field" data-show-when-value="incomeMethod=gross" hidden>
                        <label for="grossAnnualIncome">Please enter gross annual income <span class="req">*</span></label>
                        <input type="number" id="grossAnnualIncome" name="grossAnnualIncome" min="0" step="0.01">
                        <small>Total household income before taxes.</small>
                    </div>

                    <div data-show-when-value="incomeMethod=calculator" hidden>
                        <button type="button" class="secondary" data-open-calc>+ Add income record ($ calculator)</button>
                        <table id="income-records" class="income-records">
                            <thead>
                                <tr>
                                    <th scope="col">Whose</th>
                                    <th scope="col">Source</th>
                                    <th scope="col">Frequency</th>
                                    <th scope="col">Amount</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                    <fieldset class="field">
                        <legend>How do you want to add income documents? <span class="req">*</span></legend>
                        <div class="radios">
                            <label><input type="radio" name="incomeDocsMethod" value="upload_now"> I will upload income documents now</label>
                            <label><input type="radio" name="incomeDocsMethod" value="email_link"> Email me a link to upload income documents</label>
                            <label><input type="radio" name="incomeDocsMethod" value="in_person"> I will present income documents in person at time of property assessment</label>
                        </div>
                    </fieldset>

                    <details>
                        <summary>What counts as proof of income?</summary>
                        <p>Accepted income proof varies based on income source. Examples include recent pay stubs, W-2s, benefits award letters, bank statements, and tax returns.</p>
                    </details>
                </div>

                <!-- Signature pad: canvas + Clear button + hidden PNG store. -->
                <div class="field">
                    <label for="applicantSignature">Enter signature <span class="req">*</span></label>
                    <div class="signature-wrap">
                        <canvas data-signature data-target="applicantSignature" aria-label="Signature pad"></canvas>
                        <button type="button" class="signature-clear" data-signature-clear>Clear</button>
                    </div>
                    <input type="hidden" name="applicantSignature" id="applicantSignature" value="">
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="button" data-next>Next</button>
                </footer>
            </section>

            <!-- =====================================================================
                 Page 13 — Zero-income affidavit   (shown only when haveIncome=no)
                 ---------------------------------------------------------------------
                 Legal attestation page. The second signature canvas writes its
                 PNG into the hidden `zeroIncomeSignature` input. Submit button
                 lives here when this branch is taken — otherwise on Page 14.
                 ===================================================================== -->
            <section class="page" id="page-zero-income" data-page="zero-income" data-show-if="haveIncome=no">
                <p class="progress">Zero income affidavit</p>
                <h2>Zero Income Affidavit</h2>

                <div class="row">
                    <div class="field">
                        <label for="zeroIncomeFirstName">First name</label>
                        <input type="text" id="zeroIncomeFirstName" name="zeroIncomeFirstName" autocomplete="given-name">
                    </div>
                    <div class="field">
                        <label for="zeroIncomeLastName">Last name</label>
                        <input type="text" id="zeroIncomeLastName" name="zeroIncomeLastName" autocomplete="family-name">
                    </div>
                </div>
                <div class="field">
                    <label for="zeroIncomeAddress">Address</label>
                    <input type="text" id="zeroIncomeAddress" name="zeroIncomeAddress" autocomplete="street-address">
                </div>

                <p>I hereby certify that I do not individually receive income from any of the following sources:</p>
                <ol type="a">
                    <li>Wages from employment (including commissions, tips, bonuses, fees, etc.);</li>
                    <li>Income from operation of a business;</li>
                    <li>Rental income from real or personal property;</li>
                    <li>Interest or dividends from assets;</li>
                    <li>Social Security payments, annuities, insurance policies, retirement funds, pensions, or death benefits;</li>
                    <li>Unemployment or disability payments;</li>
                    <li>Public assistance payments;</li>
                    <li>Periodic allowances such as alimony, child support, or gifts received from persons living in my household;</li>
                    <li>Sales from self-employed resources (Avon, Mary Kay, Shaklee, etc.);</li>
                    <li>Any other source not named above.</li>
                </ol>
                <p>Under penalty of perjury, I certify that the information presented in this certification is true and accurate to the best of my knowledge. The undersigned further understand(s) that providing false representations herein constitutes an act of fraud.</p>

                <div class="field">
                    <label for="zeroIncomeSignature">Signature <span class="req">*</span></label>
                    <div class="signature-wrap">
                        <canvas data-signature data-target="zeroIncomeSignature" aria-label="Signature pad"></canvas>
                        <button type="button" class="signature-clear" data-signature-clear>Clear</button>
                    </div>
                    <input type="hidden" name="zeroIncomeSignature" id="zeroIncomeSignature" value="">
                </div>
                <div class="field">
                    <label><input type="checkbox" name="zeroIncomeAgree" value="yes"> I certify the statement above is true.</label>
                </div>

                <footer class="actions">
                    <button type="button" class="secondary" data-prev>Back</button>
                    <button type="submit" data-submit>Submit</button>
                </footer>
                <p class="submit-error" data-submit-error hidden role="alert"></p>
            </section>

            <!-- =====================================================================
                 Page 14 — Submission confirmation
                 ---------------------------------------------------------------------
                 Rendered after submit. The <span data-summary="..."> elements
                 are populated by JS with the matching field's value, giving
                 the applicant a quick read-back of how staff will reach them.
                 ===================================================================== -->
            <section class="page" id="page-submitted" data-page="submitted">
                <p class="progress">Done</p>

                <div class="confirmation-hero">
                    <div class="lettermark lettermark-large" aria-hidden="true">A</div>
                </div>
                <h2 class="text-center">Submission received!</h2>

                <p>Thank you for submitting your application. Your case has been logged and assigned the following reference number:</p>
                <p class="case-reference">Case Number: <strong data-submitted-case>(pending)</strong></p>

                <div class="credentials-box" id="credentials-box">
                    <h3>Your Portal Access</h3>
                    <p><strong>Important:</strong> Save these credentials to access your application dashboard and track your case progress.</p>

                    <div class="credential-item">
                        <label>Username:</label>
                        <div class="credential-value">
                            <code id="username-display">Loading...</code>
                            <button type="button" class="copy-btn" data-copy="username">Copy</button>
                        </div>
                    </div>

                    <div class="credential-item">
                        <label>Password:</label>
                        <div class="credential-value">
                            <code id="password-display">Loading...</code>
                            <button type="button" class="copy-btn" data-copy="password">Copy</button>
                        </div>
                    </div>

                    <div id="credentials-debug" style="margin-top: 1rem; padding: 1rem; background: #ff9800; color: #000; border-radius: 4px;">
                        <p><strong>🐛 Debug Mode:</strong></p>
                        <p id="debug-message">Waiting for credentials...</p>
                        <p><small>Check browser console (F12) for details</small></p>
                    </div>

                    <p><a href="../requestor-portal.php" class="button" data-dashboard-link>Access Your Dashboard &rarr;</a></p>
                    <p><small>A confirmation email with these credentials has been sent to <span data-summary="contactEmail"></span></small></p>
                </div>

                <h3>What happens next?</h3>
                <ol>
                    <li><strong>Eligibility Review:</strong> Our team will review your application to determine eligibility</li>
                    <li><strong>Contact:</strong> A member of an ARCHR Partner Organization will reach out via your preferred contact method</li>
                    <li><strong>Assessment:</strong> If eligible, we'll schedule a home visit to assess the repair needs</li>
                    <li><strong>Service Coordination:</strong> We'll match you with the appropriate ARCHR partner organization</li>
                </ol>

                <h3>Your contact info</h3>
                <ul class="plain">
                    <li><strong>Preferred contact method:</strong> <span data-summary="preferredContact[]"></span></li>
                    <li><strong>Home phone:</strong> <span data-summary="homePhone"></span></li>
                    <li><strong>Cell phone:</strong> <span data-summary="cellPhone"></span></li>
                    <li><strong>Email:</strong> <span data-summary="contactEmail"></span></li>
                </ul>

                <p><a href="https://example.org/archr" target="_blank" rel="noopener">Visit the ARCHR website</a></p>
            </section>

            <!-- =====================================================================
                 Income calculator modal
                 ---------------------------------------------------------------------
                 Hidden by default; JS adds class `open` when `data-open-calc`
                 is clicked. Saving appends a row to the #income-records table
                 above. The fields here are *not* submitted with the form —
                 only the aggregated rows are.
                 ===================================================================== -->
            <div class="modal" id="calc-modal" role="dialog" aria-modal="true" aria-labelledby="calc-title">
                <div class="modal-body">
                    <h2 id="calc-title">Income Calculator</h2>
                    <p>We use this to determine what kind of documentation we need to collect in order to verify eligibility. Enter one (1) source of income at a time.</p>

                    <fieldset class="field">
                        <legend>Whose income are you adding? <span class="req">*</span></legend>
                        <div class="radios">
                            <label><input type="radio" name="calcWhose" value="mine"> Mine</label>
                            <label><input type="radio" name="calcWhose" value="other"> Another household member</label>
                        </div>
                    </fieldset>
                    <div class="field">
                        <label for="calcSource">Source of income <span class="req">*</span></label>
                        <select id="calcSource" name="calcSource">
                            <option value="">&mdash; Select &mdash;</option>
                            <option value="work">Work / job</option>
                            <option value="self_employment">Self-employment</option>
                            <option value="social_security">Social Security</option>
                            <option value="disability">Disability</option>
                            <option value="retirement">Retirement / pension</option>
                            <option value="other">Other</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="calcFrequency">How often is $ received?</label>
                        <select id="calcFrequency" name="calcFrequency">
                            <option value="">&mdash; Select &mdash;</option>
                            <option value="weekly">Weekly</option>
                            <option value="biweekly">Bi-weekly</option>
                            <option value="monthly">Monthly</option>
                            <option value="annually">Annually</option>
                            <option value="other">Other</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="calcAmount">Amount <span class="req">*</span></label>
                        <input type="number" id="calcAmount" name="calcAmount" min="0" step="0.01">
                        <small>Dollar amount received (before taxes).</small>
                    </div>

                    <div class="actions">
                        <button type="button" class="ghost" data-close-calc>Cancel</button>
                        <button type="button" data-save-calc>Save</button>
                    </div>
                </div>
            </div>

        </form>
    </main>
</div>

<!-- Third-party signature library; loaded before our script. -->
<script src="https://cdn.jsdelivr.net/npm/signature_pad@4/dist/signature_pad.umd.min.js"></script>
<script src="assets/intake.js" defer></script>
</body>
</html>