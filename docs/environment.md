# Environment Design Specification

**Document status:** Baseline
**Applies to:** All labs in this repository
**Platform:** Microsoft 365, Microsoft Entra ID, Microsoft Graph PowerShell SDK

---

## 1. Purpose

This document defines the standards governing the Microsoft 365 tenant used throughout this
repository: tenant selection, domain and naming conventions, administrative tooling, licensing
model, and security baseline.

All labs inherit these standards. Where a lab deviates, the deviation is stated explicitly in
that lab's documentation.

> **Naming.** The modelled organisation name has been applied repository-wide. Selection
> criteria and the values chosen are recorded in [naming.md](naming.md).

---

## 2. Administrative tooling

### 2.1 Module selection

The PowerShell modules historically used for Microsoft 365 administration have been retired.
The MSOnline (`MSOL`) and Azure AD (`AzureAD`, `AzureADPreview`) modules were deprecated and
their retirement completed during 2025. Scripts depending on them no longer function.

A significant proportion of Microsoft 365 lab material published online predates this change
and remains written against the retired modules. This environment uses currently supported
tooling throughout.

| Workload | Module | Status |
|---|---|---|
| Identity, groups, licensing, directory objects | `Microsoft.Graph` (Graph PowerShell SDK) | Current |
| Exchange Online | `ExchangeOnlineManagement` v3 | Current |
| Security and compliance | `ExchangeOnlineManagement` (`Connect-IPPSSession`) | Current |
| Microsoft Teams | `MicrosoftTeams` | Current |
| SharePoint Online | `PnP.PowerShell` | Current |
| ~~Identity (legacy)~~ | ~~`MSOnline`, `AzureAD`~~ | **Retired — not used** |

### 2.2 Installation

```powershell
$modules = 'Microsoft.Graph', 'ExchangeOnlineManagement', 'MicrosoftTeams', 'PnP.PowerShell'

foreach ($module in $modules) {
    Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
}

Get-Module -ListAvailable -Name $modules |
    Select-Object Name, Version | Sort-Object Name -Unique
```

> The full `Microsoft.Graph` module installs a large number of sub-modules and is slow to load.
> Where only identity operations are required, `Microsoft.Graph.Users`,
> `Microsoft.Graph.Groups`, and `Microsoft.Graph.Identity.DirectoryManagement` are sufficient
> and load substantially faster.

### 2.3 Least-privilege connection

Graph connections request explicit scopes. Requesting only the scopes a task requires is both
a security control and a demonstrable practice:

```powershell
Connect-MgGraph -Scopes 'User.ReadWrite.All', 'Group.ReadWrite.All', 'Organization.Read.All'
Get-MgContext | Select-Object Account, TenantId, Scopes
```

Consent granted to the Microsoft Graph PowerShell enterprise application is tenant-wide and
persists. Scopes accumulate across sessions unless explicitly reviewed, which is examined in
Lab 02.

---

## 3. Tenant naming

| Object | Convention | Example |
|---|---|---|
| Tenant (initial domain) | `VortexAI654.onmicrosoft.com` | Assigned at tenant creation, immutable |
| Custom domain | None added | This environment runs on the initial `.onmicrosoft.com` domain throughout — the documented fallback in [naming.md](naming.md) §3.2, used deliberately rather than by omission |
| User principal name | `first.last@VortexAI654.onmicrosoft.com` | `grace@VortexAI654.onmicrosoft.com` |
| Administrative account | `first.last.adm@VortexAI654.onmicrosoft.com` | Excluded from Conditional Access break-glass scope |
| Break-glass account | `emergency-access-01@VortexAI654.onmicrosoft.com` | Held on the initial domain deliberately — see section 6 |
| Security group (licensing) | `LIC-<SKU>` | `LIC-BusinessPremium` |
| Security group (access) | `SEC-<Resource>-<RW or RO>` | `SEC-Finance-RW` |
| Distribution group | `DL-<Purpose>` | `DL-AllStaff` |
| Microsoft 365 group / Team | `<Department>` | `Finance` |
| Shared mailbox | `<purpose>@VortexAI654.onmicrosoft.com` | `info@VortexAI654.onmicrosoft.com` |

**Licensing group prefix.** Licence assignment groups are prefixed `LIC-` and are used for no
other purpose. Mixing licence assignment into access groups makes entitlement review
impossible to perform reliably.

---

## 4. Licensing model

### 4.1 Group-based licensing

Licences are assigned to groups, not to individual users. Users receive licences through group
membership.

| Approach | Assessment |
|---|---|
| Direct per-user assignment | Assignment state is invisible without enumerating every user. Deprovisioning is manual and frequently missed. Rejected. |
| **Group-based assignment** | **Selected.** Entitlement is declarative and auditable. Removal from the group reclaims the licence automatically. |

Group-based licensing requires Microsoft Entra ID P1, which is included in Microsoft 365
Business Premium and E3/E5. This is a factor in the tenant selection recorded in Lab 00.

### 4.2 Modelled organisation

The tenant models a small organisation of eight accounts: one administrator and seven staff
across Finance and IT, plus a Support mailbox. This structure drives group design, licensing,
and policy scoping across all labs.

| Account | Role / group | Licence tier |
|---|---|---|
| Muhammed Abdulmalik | Global Administrator | Microsoft 365 E5, Defender for Office 365 (Plan 2), Entra ID P2 |
| Grace Richardson | Finance (Junior Accountant) | Entra ID P2, Microsoft 365 E5 |
| Keith Albalos | Finance | Microsoft 365 E5, Entra ID P2 |
| Wale Adebimpe | IT — later Helpdesk Administrator (Lab 12) | Microsoft 365 E5, Entra ID P2 |
| Frank Dugald | HR, IT | Microsoft 365 E5, Entra ID P2 — offboarded in Lab 12 |
| John Ebuka | Staff — Helpdesk Administrator role holder (Lab 02); department attribute not set | Microsoft 365 E5, Entra ID P2 |
| Samuel Banks | Staff — subject of the account-lockout case (Lab 12); department attribute not set | Entra ID P2, Microsoft 365 E5 |
| Sarah Michealson | Staff — department attribute not set | Entra ID Governance, Entra ID P2, Microsoft 365 E5 |
| Support | Shared mailbox | Entra ID P2 |

Unlicensed accounts are used deliberately in Lab 12 to reproduce licence-related fault
conditions.

---

## 5. Security baseline

The tenant is configured to a defined baseline before any workload configuration begins.
Applying security controls after the fact is a common source of drift.

| Control | Setting | Configured in |
|---|---|---|
| Legacy authentication | Blocked | Lab 03 |
| Multi-factor authentication | Enforced for all users via Conditional Access | Lab 03 |
| Security defaults | Disabled, superseded by Conditional Access | Lab 03 |
| Break-glass accounts | Two, excluded from Conditional Access, monitored | Lab 03 |
| Self-service password reset | Enabled with two methods required | Lab 03 |
| Per-user MFA (legacy) | Not used | — |
| Unified audit log | Enabled and verified | Lab 10 |
| External sharing | Restricted to authenticated guests | Lab 07 |

**Security defaults versus Conditional Access.** Security defaults and Conditional Access are
mutually exclusive; security defaults must be disabled before Conditional Access policies take
effect. Security defaults are appropriate for tenants without Entra ID P1. This environment
uses Conditional Access to demonstrate granular policy design, exclusion handling, and
report-only evaluation.

---

## 6. Break-glass account design

Two emergency access accounts are created on the initial `.onmicrosoft.com` domain and
excluded from all Conditional Access policies.

**Rationale.** A Conditional Access policy that inadvertently blocks all administrators will
lock the tenant out permanently, and Microsoft support recovery is neither immediate nor
guaranteed. Break-glass accounts held on the initial domain remain usable if custom domain
resolution or federation fails.

**Controls applied.** Long random passwords held offline, cloud-only, excluded from Conditional
Access, sign-in alerting configured in Lab 10, and credentials rotated after any use.

This is standard practice in production tenants and is implemented rather than merely
described.

---

## 7. Cost and tenant lifetime

Unlike an on-premises laboratory built on locally hosted virtual machines, a Microsoft 365
tenant is a hosted service with an associated cost and, in the case of trial tenants, an
expiry date.

Tenant options, their costs, and their trade-offs are assessed in
[Lab 00](../labs/00-tenant-design-and-provisioning/), which records the option selected and the
basis for that selection.

**Screenshot policy.** Trial tenants expire and their contents become unrecoverable. All
verification evidence is captured at the time each lab is performed. No lab depends on the
tenant remaining available for evidence to be reproduced.
