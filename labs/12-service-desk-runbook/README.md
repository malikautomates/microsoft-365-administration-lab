# Lab 12 — Service Desk Runbook

**Objective:** Run the full joiner-to-leaver lifecycle end to end against a real scenario — onboard
a new hire, delegate day-to-day support to a helpdesk administrator, resolve a genuine
account-lockout support case, and offboard a departing employee — closing the loop the
automated lifecycle workflow in Lab 11 only starts.
**Environment:** Microsoft 365 tenant `VortexAI654.onmicrosoft.com`.
**Prerequisites:** All previous labs.
**Duration:** Approximately 90 minutes.

---

## 1. Scenario

This lab is where every other lab's configuration gets exercised against real events rather than
reviewed in isolation: a new employee (Grace Richardson) joins Finance and needs an account,
licence, and group access; a helpdesk administrator (Wale Adebimpe) is delegated enough access
to run day-to-day support without Global Administrator rights, including resolving a genuine
case where a user couldn't sign in; and a departing employee (Frank Dugald) is offboarded
through the fuller manual runbook that Lab 11's automated lifecycle workflow deliberately leaves
to a human.

---

## 2. Design decisions

| Decision | Options considered | Selected | Rationale |
|---|---|---|---|
| New-hire licensing | Direct licence assignment; group-based assignment | Group-based | Unlike the direct assignment used for the initial roster in Lab 01, this onboarding assigns the licence through group membership — the declarative, auditable pattern `docs/environment.md` recommends, demonstrated here against a real onboarding event rather than a synthetic one. |
| Offboarding order | Reset password first; contain access first, reset password last | Contain first | Blocking sign-in and revoking sessions stops the account being used *immediately*, before the slower steps (licence removal, mailbox conversion) complete. Resetting the password last is a final belt-and-suspenders step once the account is already contained, not the first line of defence. |
| Helpdesk delegation scope | Give the helpdesk admin Global Administrator; give it the specific roles the job needs | Specific roles | Wale Adebimpe's helpdesk account was assigned AI Administrator, Helpdesk Administrator, and Teams Administrator — enough to onboard users, reset passwords, and manage Teams, without directory-wide write access. |

---

## 3. Implementation

### Step 1 — Onboard a new hire: Grace Richardson

![Active users before onboarding](images/12-01-active-users-baseline.png)

![New user basics: name and username](images/12-02-new-user-basics-review.png)

![Optional settings: Job title "Junior Accountant", Department "Finance"](images/12-03-new-user-optional-settings.png)

![Grace Richardson added to active users](images/12-04-new-user-created-confirmation.png)

![Manager assigned: Keith Albalos](images/12-05-new-user-manager-assigned.png)

---

### Step 2 — Licence the new hire through group membership

![Grace's account shown unlicensed immediately after creation](images/12-06-new-user-unlicensed-state.png)

![Decision to use group-based licensing rather than direct assignment](images/12-07-new-user-license-group-based-choice.png)

![Licence applied to Grace through group membership](images/12-08-new-user-license-applied.png)

---

### Step 3 — Add to the Finance group and verify

![Adding Grace to the Finance group](images/12-09-new-user-added-finance-group.png)

![Finance group membership confirmed](images/12-10-new-user-finance-group-confirmed.png)

![Finance group members: Grace Richardson, Keith Albalos, Muhammed Abdulmalik](images/12-11-finance-group-members-verification.png)

![Group membership assignment, general view](images/12-12-assigning-group-membership.png)

![Welcome information on using Microsoft apps sent to the new hire](images/12-13-onboarding-welcome-info-sent.png)

---

### Step 4 — Delegate support to a helpdesk administrator

Wale Adebimpe was assigned AI Administrator, Helpdesk Administrator, and Teams Administrator —
enough to run the rest of this lab's support tasks without standing Global Administrator access.

![Assigning Wale Adebimpe the required helpdesk admin roles](images/12-14-helpdesk-admin-roles-assigned.png)

![Helpdesk administrator's own admin center home page](images/12-15-helpdesk-admin-home.png)

![Helpdesk administrator performing a new-user onboarding task](images/12-16-helpdesk-admin-onboarding-task.png)

![Welcome message received on the helpdesk admin account's first sign-in](images/12-17-helpdesk-admin-first-signin-message.png)

![Setting up multi-factor authentication for the new helpdesk admin account](images/12-18-helpdesk-admin-mfa-setup.png)

![Microsoft Authenticator added as the sign-in method](images/12-19-helpdesk-admin-authenticator-added.png)

---

### Step 5 — Device registration

![Registering a device to the tenant](images/12-20-device-registration.png)

![Device setup in progress](images/12-21-device-setup-wait.png)

![Device registration complete](images/12-22-device-registration-complete.png)

![Assigning the device](images/12-23-assigning-device.png)

---

### Step 6 — A genuine support case: account lockout

A user reported being unable to access their account. The helpdesk administrator diagnosed it
as a password issue and resolved it directly, rather than escalating.

![Helping a user who can't access their account](images/12-24-helpdesk-password-reset-scenario.png)

![Password reset completed](images/12-25-helpdesk-password-reset-done.png)

---

### Step 7 — Message center triage

Message center items were reviewed and logged as they arrived, distinguishing items that need
action from ones that don't.

![A real message center item under review](images/12-26-message-center-real-item.png)

![Message center response log: a low-priority Teams feature update, logged with no action required](images/12-27-message-center-response-log.png)

The full log is kept alongside this README at
[`Message-Center-Response-Log.docx`](Message-Center-Response-Log.docx).

---

### Step 8 — Offboard a departing employee: Frank Dugald

Access was contained first, in order, before the slower cleanup steps.

![Beginning Frank Dugald's offboarding](images/12-28-offboard-frank-start.png)

![Blocking sign-in](images/12-29-offboard-frank-block-signin.png)

![Sign-in blocked, confirmed](images/12-30-offboard-frank-block-signin-done.png)

![Revoking active sessions](images/12-31-offboard-frank-revoke-session.png)

![Sessions revoked, confirmed](images/12-32-offboard-frank-revoke-session-done.png)

![Removing licences](images/12-33-offboard-frank-remove-license.png)

![Licences removed, confirmed](images/12-34-offboard-frank-remove-license-done.png)

![Converting the mailbox to a shared mailbox, so correspondence remains accessible to the team](images/12-35-offboard-frank-convert-mailbox.png)

![Mailbox conversion complete](images/12-36-offboard-frank-convert-mailbox-done.png)

![Resetting the password as a final containment step](images/12-37-offboard-frank-reset-password.png)

---

## 4. Verification

| Check | Command | Success criterion |
|---|---|---|
| New hire provisioned | `Get-MgUser -UserId grace@...` | Account present, licensed, Finance group member |
| Helpdesk admin scoped correctly | `Get-MgUserMemberOf -UserId wale@...` | AI Administrator, Helpdesk Administrator, Teams Administrator only — no Global Administrator |
| Lockout case resolved | Admin center → Wale's activity | Password reset performed, user confirmed able to sign in |
| Frank fully offboarded | `Get-MgUser -UserId frank@...` | Account disabled, 0 assigned licences, mailbox type `Shared` |

---

## 5. Faults encountered

### 5.1 User unable to access their account

**Symptom.** A user reported being unable to sign in.

**Diagnosis.** The helpdesk administrator reviewed the account's sign-in state and determined
the issue was password-related rather than a block, licence, or Conditional Access denial.

**Cause.** `[CONFIRM: exact root cause — expired password vs. forgotten password]`.

**Resolution.** Password reset by the helpdesk administrator, using exactly the Helpdesk
Administrator role scope assigned in Step 4 rather than requiring Global Administrator
escalation — the least-privilege delegation from Lab 02 paying off against a real support
request.

---

## 6. Capabilities demonstrated

- End-to-end joiner onboarding: account creation, group-based licensing, department group
  membership, manager assignment
- Least-privilege helpdesk delegation and its use against a real support case
- Account lockout diagnosis and resolution
- Message center triage and response logging
- End-to-end leaver offboarding: sign-in block, session revocation, licence reclamation,
  mailbox conversion, and password reset, performed in a deliberate containment-first order
- Device registration and assignment

---

## 7. References

| Source | Behaviour confirmed |
|---|---|
| Microsoft Learn — *Convert a mailbox to a shared mailbox* | Mailbox conversion preserves existing mail for delegated access |
| Microsoft Learn — *Revoke user access in Microsoft Entra ID* | Session revocation forces re-authentication within the documented window |
| Microsoft Learn — *Helpdesk Administrator role permissions* | Password reset scope without directory-wide access |

---

## Screenshot checklist

| File | Content |
|---|---|
| `12-01-active-users-baseline.png` | Active users before onboarding |
| `12-02-new-user-basics-review.png` | New user basics |
| `12-03-new-user-optional-settings.png` | Job title and department set |
| `12-04-new-user-created-confirmation.png` | Grace Richardson added |
| `12-05-new-user-manager-assigned.png` | Manager assigned |
| `12-06-new-user-unlicensed-state.png` | Account unlicensed initially |
| `12-07-new-user-license-group-based-choice.png` | Group-based licensing decision |
| `12-08-new-user-license-applied.png` | Licence applied via group |
| `12-09-new-user-added-finance-group.png` | Added to Finance group |
| `12-10-new-user-finance-group-confirmed.png` | Finance group membership confirmed |
| `12-11-finance-group-members-verification.png` | Finance group members |
| `12-12-assigning-group-membership.png` | Group membership assignment |
| `12-13-onboarding-welcome-info-sent.png` | Welcome information sent |
| `12-14-helpdesk-admin-roles-assigned.png` | Helpdesk admin roles assigned |
| `12-15-helpdesk-admin-home.png` | Helpdesk admin's own home page |
| `12-16-helpdesk-admin-onboarding-task.png` | Helpdesk admin performing onboarding |
| `12-17-helpdesk-admin-first-signin-message.png` | First sign-in welcome message |
| `12-18-helpdesk-admin-mfa-setup.png` | MFA setup |
| `12-19-helpdesk-admin-authenticator-added.png` | Authenticator added |
| `12-20-device-registration.png` | Device registration |
| `12-21-device-setup-wait.png` | Device setup in progress |
| `12-22-device-registration-complete.png` | Device registration complete |
| `12-23-assigning-device.png` | Assigning the device |
| `12-24-helpdesk-password-reset-scenario.png` | Account-lockout support case |
| `12-25-helpdesk-password-reset-done.png` | Password reset completed |
| `12-26-message-center-real-item.png` | Message center item under review |
| `12-27-message-center-response-log.png` | Message center response log |
| `12-28-offboard-frank-start.png` | Beginning offboarding |
| `12-29-offboard-frank-block-signin.png` | Blocking sign-in |
| `12-30-offboard-frank-block-signin-done.png` | Sign-in blocked |
| `12-31-offboard-frank-revoke-session.png` | Revoking sessions |
| `12-32-offboard-frank-revoke-session-done.png` | Sessions revoked |
| `12-33-offboard-frank-remove-license.png` | Removing licences |
| `12-34-offboard-frank-remove-license-done.png` | Licences removed |
| `12-35-offboard-frank-convert-mailbox.png` | Converting mailbox to shared |
| `12-36-offboard-frank-convert-mailbox-done.png` | Mailbox conversion complete |
| `12-37-offboard-frank-reset-password.png` | Final password reset |
