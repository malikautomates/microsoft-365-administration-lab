# Microsoft 365 Administration Laboratory

A full Microsoft 365 tenant, designed, deployed and operated end to end — not a tutorial
walkthrough, but thirteen modules of real administrative work: the scenario, the design
decision, the implementation, the verification evidence, and the faults actually hit along the
way.

**Platform:** Microsoft 365 · Microsoft Entra ID · Exchange Online · Microsoft Teams ·
SharePoint Online · Microsoft Intune · Microsoft Purview
**Tooling:** Microsoft Graph PowerShell SDK · Exchange Online Management v3 · Microsoft Entra
admin center · Microsoft 365 admin center
**Organisation modelled:** `Vortex AI` (fictional), tenant `VortexAI654.onmicrosoft.com`

---

## Scope and approach

This repository is written as operational documentation rather than as a tutorial. Three
conventions apply throughout:

**Every lab states its rationale.** Where more than one valid approach exists, the options
considered and the basis for selection are recorded. Configuration steps without rationale
demonstrate that a procedure was followed; rationale demonstrates that it was understood.

**Every lab ends with verification evidence.** A configuration change is not complete until its
effect has been confirmed. Each lab closes with the commands used to prove the intended state,
together with their output.

**Faults are documented, not omitted.** Where a procedure failed during the build, or a gap
against a documented standard was found on review, the error, the diagnostic path, and the
resolution — or the honest acknowledgement of what's still open — are recorded.

### A note on scope

This is self-directed lab work on a dedicated Microsoft 365 tenant, not production client work.
The scenarios, staff accounts, and departmental structure modelled throughout are fictional,
built to give each lab's configuration a realistic reason to exist rather than to demonstrate
a setting in isolation.

### Tooling note

The MSOnline and Azure AD PowerShell modules were retired during 2025. A significant proportion
of Microsoft 365 lab material published online predates that change and remains written against
modules that no longer function.

This environment uses the Microsoft Graph PowerShell SDK and Exchange Online Management v3
alongside the Microsoft 365 and Entra admin centers, matching how the work was actually done —
PowerShell where it made the intent explicit and repeatable, the admin center where that was
genuinely the faster and more direct path.

Standards common to all labs — tooling, naming, licensing model, and security baseline — are
defined once in [docs/environment.md](docs/environment.md). The sequence in which the labs were
performed, the licence gap that had to be closed first, and the screenshot and redaction
workflow are set out in [docs/execution-plan.md](docs/execution-plan.md).

---

## Laboratory index

### Foundation

| # | Lab | Summary | Status |
|---|---|---|---|
| 00 | [Tenant design and provisioning](labs/00-tenant-design-and-provisioning/) | Assessing an inherited tenant, diagnosing a licence over-assignment, and closing the gap with an E5 trial | Complete |
| 01 | [Identity and licensing](labs/01-identity-and-licensing/) | Staff provisioning, profile attributes, licence review, and building both collaboration and security groups | Complete |
| 02 | [Administrative roles and least privilege](labs/02-admin-roles-least-privilege/) | Custom role authoring, least-privilege helpdesk delegation, and PIM-managed Global Administrator activation | Complete |
| 03 | [Authentication and Conditional Access](labs/03-authentication-conditional-access/) | Security defaults retired in favour of a report-only device-compliance Conditional Access policy | Complete |

### Workloads

| # | Lab | Summary | Status |
|---|---|---|---|
| 04 | [Exchange Online mailbox administration](labs/04-exchange-mailbox-administration/) | Shared mailbox delegation (Full Access, Send As, Send on Behalf), forwarding, and litigation hold | Complete |
| 05 | [Mail flow and threat protection](labs/05-exchange-mail-flow-and-protection/) | A custom anti-phishing policy with named impersonation targets, Safe Links/Attachments, and auto-forward blocking | Complete |
| 06 | [Microsoft Teams administration](labs/06-teams-administration/) | Team-creation governance, meeting and messaging policy, and usage reporting | Complete |
| 07 | [SharePoint and OneDrive administration](labs/07-sharepoint-onedrive-administration/) | Layered external-sharing controls: tenant default, site-level, and per-user overrides | Complete |

### Governance and operations

| # | Lab | Summary | Status |
|---|---|---|---|
| 08 | [Data protection](labs/08-data-protection-dlp-retention/) | A PowerShell-authored sensitivity label, a DLP policy rolled out in simulation mode, and retention policy | Complete |
| 09 | [Device management](labs/09-intune-device-management/) | Intune compliance policy and configuration profile, device enrolment, and pairing compliance with Conditional Access | Complete |
| 10 | [Monitoring, auditing and reporting](labs/10-monitoring-auditing-reporting/) | Audit log search, a volume-threshold alert policy, Secure Score, and usage reporting | Complete |
| 11 | [Lifecycle automation](labs/11-lifecycle-automation/) | A self-service access package, a recurring guest-access review, and an automated leaver workflow | Complete |
| 12 | [Service desk runbook](labs/12-service-desk-runbook/) | The full joiner-to-leaver lifecycle against a real scenario, including a genuine account-lockout support case | Complete |

Status values: `Planned` · `In progress` · `Complete`

---

## Highlights

**PIM-managed Global Administrator, not a standing account.** [Lab 02](labs/02-admin-roles-least-privilege/)
moves the tenant's own Global Administrator assignment from permanent to PIM-eligible, so the
highest-privilege role in the tenant is active only when deliberately activated, for a bounded
window — applied to the account actually running this project, not a hypothetical.

**A named-target anti-phishing policy, authored end to end in PowerShell.** [Lab 05](labs/05-exchange-mail-flow-and-protection/)'s
`New-AntiPhishPolicy` call sets targeted user impersonation protection, mailbox intelligence,
and DMARC-aware spoof handling in one explicit script — not a wizard's hidden defaults.

**DLP shipped in simulation mode, the same discipline as Conditional Access.** [Lab 08](labs/08-data-protection-dlp-retention/)
and [Lab 03](labs/03-authentication-conditional-access/) both bring a new policy up in a
non-blocking evaluation state before enforcement — a deliberate pattern repeated across the
repository rather than a one-off caution.

**A real support case, resolved by the account actually delegated to handle it.** [Lab 12](labs/12-service-desk-runbook/)'s
account-lockout resolution was performed using exactly the Helpdesk Administrator scope
assigned in Lab 02 — the least-privilege delegation validated against a genuine event, not just
a permissions screenshot.

---

## Capability matrix

| Capability | Labs |
|---|---|
| Tenant administration and licensing | 00, 01 |
| Identity and access management | 01, 02, 03 |
| Least-privilege delegation and PIM | 02, 09, 12 |
| Conditional Access and device compliance | 03, 09 |
| Exchange Online administration | 04, 05 |
| Mail flow and threat protection | 05, 12 |
| Teams administration | 06 |
| SharePoint and OneDrive administration | 07 |
| Data loss prevention, sensitivity labels, and retention | 08 |
| Endpoint management | 09 |
| Auditing, alerting, and log analysis | 10, 12 |
| Entitlement management and access reviews | 11 |
| Identity lifecycle automation | 11, 12 |
| Service desk fault diagnosis and resolution | 12 |

---

## Repository structure

```
.
├── README.md                  Repository index
├── docs/
│   ├── environment.md         Design specification: tooling, naming, licensing, security baseline
│   ├── execution-plan.md      Sequence, licence gap analysis, and screenshot workflow
│   ├── naming.md              Organisation naming guide and the values selected
│   └── LAB-TEMPLATE.md        Structure applied to every lab document
├── labs/
│   └── NN-lab-name/
│       ├── README.md          Lab documentation
│       └── images/            Screenshots referenced by the lab document
└── scripts/
    ├── Set-LabName.ps1        Applies the chosen organisation name repository-wide
    └── Test-LabImages.ps1     Reports which lab screenshots are still missing
```

---

## Naming status

The organisation name has been applied repository-wide: `Vortex AI`, tenant
`VortexAI654.onmicrosoft.com`, no custom domain. Selection criteria and the full record of the
values chosen are in [docs/naming.md](docs/naming.md).

---

## Contact

- **Email:** `[CONFIRM: add contact email]`
- **LinkedIn:** `[CONFIRM: add LinkedIn URL]`
