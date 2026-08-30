# Microsoft 365 Administration Laboratory

A documented Microsoft 365 tenant, designed, deployed and operated end to end. Each lab covers
a task drawn from service desk and Microsoft 365 administration work: the scenario, the design
decision, the implementation, the verification evidence, and the faults encountered.

**Platform:** Microsoft 365 · Microsoft Entra ID · Exchange Online · Microsoft Teams ·
SharePoint Online · Microsoft Intune · Microsoft Purview
**Tooling:** Microsoft Graph PowerShell SDK · Exchange Online Management v3 · PnP.PowerShell
**Organisation modelled:** `{{COMPANY}}` (fictional)

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

**Faults are documented, not omitted.** Where a procedure failed during the build, the error,
the diagnostic path, and the resolution are recorded.

### Tooling note

The MSOnline and Azure AD PowerShell modules were retired during 2025. A significant proportion
of Microsoft 365 lab material published online predates that change and remains written against
modules that no longer function.

This environment uses the Microsoft Graph PowerShell SDK, Exchange Online Management v3, and
PnP.PowerShell throughout. Where a task is genuinely faster in the admin center, the portal
path is given as an alternative rather than as the primary method.

Standards common to all labs — tooling, naming, licensing model, and security baseline — are
defined once in [docs/environment.md](docs/environment.md). The sequence in which the labs are
performed, the licensing required for each, and the evidence capture process are set out in
[docs/execution-plan.md](docs/execution-plan.md).

---

## Laboratory index

### Foundation

| # | Lab | Summary | Status |
|---|---|---|---|
| 00 | [Tenant design and provisioning](labs/00-tenant-design-and-provisioning/) | Tenant tier assessment against cost and capability, custom domain verification, and administrative tooling | Planned |
| 01 | [Identity and licensing](labs/01-identity-and-licensing/) | CSV-driven account provisioning via Graph PowerShell, group-based licence assignment, and dynamic group membership | Planned |
| 02 | [Administrative roles and least privilege](labs/02-admin-roles-least-privilege/) | Directory role assignment, administrative units, delegation scoping, and review of granted Graph consent | Planned |
| 03 | [Authentication and Conditional Access](labs/03-authentication-conditional-access/) | MFA enforcement, legacy authentication blocking, break-glass exclusions, and report-only policy evaluation | Planned |

### Workloads

| # | Lab | Summary | Status |
|---|---|---|---|
| 04 | [Exchange Online mailbox administration](labs/04-exchange-mailbox-administration/) | Shared and resource mailboxes, delegated permissions, retention, and litigation hold | Planned |
| 05 | [Mail flow and threat protection](labs/05-exchange-mail-flow-and-protection/) | Transport rules, connectors, anti-phishing and anti-spam policy, quarantine handling, and message trace | Planned |
| 06 | [Microsoft Teams administration](labs/06-teams-administration/) | Team provisioning, messaging and meeting policy, guest access, and lifecycle governance | Planned |
| 07 | [SharePoint and OneDrive administration](labs/07-sharepoint-onedrive-administration/) | Site provisioning, external sharing controls, permission inheritance, and storage management | Planned |

### Governance and operations

| # | Lab | Summary | Status |
|---|---|---|---|
| 08 | [Data protection](labs/08-data-protection-dlp-retention/) | Sensitivity labels, data loss prevention policy, and retention configuration in Microsoft Purview | Planned |
| 09 | [Device management](labs/09-intune-device-management/) | Intune enrolment, compliance policy, and integration with Conditional Access | Planned |
| 10 | [Monitoring, auditing and reporting](labs/10-monitoring-auditing-reporting/) | Unified audit log search, sign-in log analysis, usage reporting, and alerting on break-glass sign-in | Planned |
| 11 | [Lifecycle automation](labs/11-lifecycle-automation/) | Joiner, mover and leaver runbooks in Graph PowerShell, including licence reclamation and mailbox conversion | Planned |
| 12 | [Service desk fault runbook](labs/12-service-desk-runbook/) | Common Microsoft 365 faults, each deliberately induced, diagnosed, and resolved | Planned |

Status values: `Planned` · `In progress` · `Complete`

---

## Capability matrix

| Capability | Labs |
|---|---|
| Tenant administration and licensing | 00, 01 |
| Identity and access management | 01, 02, 03 |
| Conditional Access and MFA | 03, 09 |
| Exchange Online administration | 04, 05 |
| Mail flow troubleshooting | 05, 12 |
| Teams administration | 06 |
| SharePoint and OneDrive administration | 07 |
| Data loss prevention and retention | 08 |
| Endpoint management | 09 |
| Auditing and log analysis | 10, 12 |
| PowerShell automation | 01, 04, 10, 11 |
| Identity lifecycle management | 01, 11 |
| Fault diagnosis and resolution | 12 |

---

## Repository structure

```
.
├── README.md                  Repository index
├── docs/
│   ├── environment.md         Design specification: tooling, naming, licensing, security baseline
│   ├── execution-plan.md      Sequence, licence gap analysis, and screenshot workflow
│   ├── naming.md              Organisation naming guide and selection criteria
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

The organisation name for this environment has not yet been selected. The repository currently
carries placeholder tokens (`{{COMPANY}}`, `{{ROOT_DOMAIN}}`, `{{TENANT}}`).

Selection criteria and the application procedure are documented in
[docs/naming.md](docs/naming.md). The tenant name in particular is permanent once the tenant is
created and should be chosen deliberately.

---

## Contact

- **Email:** *to be added*
- **LinkedIn:** *to be added*
