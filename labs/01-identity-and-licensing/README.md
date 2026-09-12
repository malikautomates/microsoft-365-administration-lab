# Lab 01 — Identity and Licensing

**Objective:** Provision staff accounts, assign licences, and build the group structure —
both collaboration groups and a dedicated security group — that later labs depend on.
**Environment:** Microsoft 365 tenant `VortexAI654.onmicrosoft.com`.
**Prerequisites:** Lab 00.
**Duration:** Approximately 75 minutes.

---

## 1. Scenario

`Vortex AI` needed staff accounts created, licensed, and organised into groups before any
security or collaboration policy could be scoped to them. Two accounts (Frank Dugald, Samuel
Banks) were provisioned directly in this lab against an existing baseline of three staff
accounts (John Ebuka, Keith Albalos, Wale Adebimpe) already present in the tenant. The rest of
the roster is picked up in Lab 12's onboarding runbook, which documents the same process for a
brand-new starter end to end.

`users.csv` in this folder records the full modelled roster and its intended department, job
title, and licensing-group attributes. `[CONFIRM: ...]` markers there flag the fields not
directly confirmed by a screenshot in this lab.

---

## 2. Design decisions

| Decision | Options considered | Selected | Rationale |
|---|---|---|---|
| Account creation method | Microsoft 365 admin center **Add a user** wizard; CSV import via Graph PowerShell | Admin center wizard | For a handful of accounts, the wizard is faster and its intent is directly reviewable on screen. A CSV-driven, idempotent Graph PowerShell script — the approach `users.csv` is designed for — is the better fit for a larger or repeated roster, and is the model Lab 11's lifecycle workflows build on instead. |
| Licence assignment | Direct per-user; group-based | Direct, in this lab | The roster here is small enough that direct assignment is reviewable at a glance from the Licenses page. Group-based assignment is introduced deliberately in Lab 12, once the licensing security group already exists, so its declarative benefit over direct assignment can be demonstrated against a real onboarding event rather than a synthetic one. |
| Group model | A single group type for everything; separate collaboration and security groups | Separate | `Finance`, `HR`, and `IT` are Microsoft 365 Groups / Teams — built for department collaboration (a shared mailbox, files, a Team). `Vortex-Security` is a dedicated cloud security group, scoped purely to resource access. Mixing the two would make an access review (Lab 11) unable to tell "who collaborates in Finance" apart from "who Finance's access policy actually applies to." |

---

## 3. Implementation

### Step 1 — Orient in the admin centers

The Microsoft 365 admin center and the Entra admin center were both used through this lab —
the former for user and licence management, the latter for identity and group configuration.

![Microsoft 365 admin center home page](images/01-01-entra-admin-center-home.png)

![Entra admin center overview: 4 users, 2 groups, 1 device, Identity Secure Score 73.68%](images/01-02-tenant-overview.png)

![Admin account overview: roles, groups, and last sign-in for the Global Administrator](images/01-03-admin-account-overview.png)

---

### Step 2 — Add staff accounts

New accounts were created through **Users → Active users → Add a user**, capturing basic
identity and optional profile details at creation time.

![Add a user wizard, basics step](images/01-04-add-user-start.png)

![Optional settings step of the wizard, showing the contact-info fields left as placeholder data](images/01-05-new-user-basic-info.png)

![Frank Dugald created](images/01-06-user-created-frank.png)

![Samuel Banks created](images/01-07-user-created-samuel.png)

Before these two were added, the tenant already held three staff accounts — John Ebuka, Keith
Albalos, and Wale Adebimpe — alongside the administrator.

![All users at that point: John Ebuka, Keith Albalos, Muhammed Abdulmalik, Wale Adebimpe](images/01-08-all-users-created.png)

---

### Step 3 — Review and edit profile attributes

The **Identity** and **Contact Information** panels in the Entra admin center's user properties
page are where job title, department, and contact fields are reviewed and edited.

![Admin account's Identity and Contact Information panels](images/01-09-admin-user-properties.png)

The **Manage contact information** dialog was used to demonstrate setting Job title and
Department — shown here against the administrator's own profile (Job title "HR Manager",
Department "HR").

![Manage contact information dialog: job title and department fields](images/01-10-user-department-attribute.png)

The same fields were set for staff accounts, including Wale Adebimpe's department (IT) and
Keith Albalos's contact information.

![Wale Adebimpe's department set to IT](images/01-11-user-department-it-wale.png)

![Keith Albalos's contact information](images/01-12-user-contact-info-keith.png)

---

### Step 4 — Review licensing

```powershell
Get-MgSubscribedSku |
    Select-Object SkuPartNumber, SkuId,
                  @{ n = 'Enabled';   e = { $_.PrepaidUnits.Enabled } },
                  @{ n = 'Available'; e = { $_.PrepaidUnits.Enabled - $_.ConsumedUnits } }
```

![Licensing overview in the Microsoft 365 admin center](images/01-13-licensing-overview.png)

![Entra admin center Licenses \| All products: Entra ID P2 at 0 of 25 assigned, Business Standard over-assigned at 4 of 1](images/01-14-licensing-page.png)

The Business Standard over-assignment identified while baselining the tenant in Lab 00 carried
through here directly: the administrator's own account shows Business Standard fully consumed
(0 of 1 available), with the Microsoft 365 E5 trial's Entra ID P2 assigned alongside it instead.

![Administrator's own Licenses and apps tab: Business Standard and Entra ID P2 both assigned](images/01-15-licensing-detail.png)

![License usage report: Entra ID P1 and P2 both provisioned at 25 seats each](images/01-16-licence-usage.png)

---

### Step 5 — Build the group structure

`Finance` and `IT` (Microsoft 365 Groups / Teams) were created alongside the pre-existing `HR`
and `All Company` groups, giving each modelled department a collaboration space.

![Active teams and groups: All Company, Finance, HR, IT](images/01-17-groups-overview.png)

![Creating a security group](images/01-18-creating-security-group.png)

![Security group created](images/01-19-security-group-created.png)

A dedicated security group, `Vortex-Security`, was created separately from the collaboration
groups above, scoped purely to resource access rather than department membership.

![Vortex-Security group overview: Assigned membership, 2 direct members, Security type](images/01-20-security-group-info.png)

![Finance group created](images/01-21-finance-group-created.png)

---

### Step 6 — Verify membership management

Adding and removing group members was exercised directly to confirm the mechanics before
relying on them elsewhere.

![Adding members to a security group](images/01-22-adding-group-members.png)

![Member added confirmation](images/01-23-member-added.png)

![Members can also be removed — the removal control in the same panel](images/01-24-member-removal-option.png)

![Member removed from the security group](images/01-25-member-removed.png)

---

### Step 7 — Password reset and service health

```powershell
Connect-MgGraph -Scopes 'UserAuthenticationMethod.ReadWrite.All'
```

![Resetting Keith Albalos's password from the admin center](images/01-26-password-reset-keith.png)

![Password reset completed for Keith Albalos](images/01-27-password-reset-keith-done.png)

The Service health dashboard was checked as a closing step, confirming no active incidents were
affecting the workloads just configured.

![Service health dashboard, no active incidents](images/01-28-service-health-dashboard.png)

---

## 4. Verification

| Check | Command | Success criterion |
|---|---|---|
| Accounts created | Admin center → Active users | Frank Dugald and Samuel Banks present alongside the pre-existing roster |
| Attributes populated | User Properties → Identity / Contact Information | Job title and department set on demonstrated accounts |
| Licences assigned | Licenses → All products | Entra ID P2 consumption reflects assigned seats |
| Groups created | Active teams and groups | `Finance`, `IT` present as Teams; `Vortex-Security` present as a Security group |
| Group membership | Group → Members | Add and remove operations both confirmed working |

---

## 5. Faults encountered

No new faults were observed during this lab. The Business Standard licence over-assignment
identified while baselining the tenant (Lab 00 §5.1) is visible again here in the licensing
screenshots — the fault was diagnosed and its resolution (the Microsoft 365 E5 trial) decided
there, not repeated as a separate fault in this lab.

---

## 6. Capabilities demonstrated

- User provisioning via the Microsoft 365 admin center
- Profile attribute management (job title, department, contact information)
- Licence assignment review and interpretation of over-assignment warnings
- Group design: separating collaboration groups (Microsoft 365 Groups / Teams) from a
  dedicated security group scoped to resource access
- Group membership management: adding and removing members with verification

---

## 7. References

| Source | Behaviour confirmed |
|---|---|
| Microsoft Learn — *Microsoft 365 groups vs. security groups* | When to use a Microsoft 365 Group versus a dedicated security group |
| Microsoft Learn — *Assign licenses to users by group membership* | Direct vs. group-based assignment trade-offs, picked up in Lab 12 |

---

## Screenshot checklist

| File | Content |
|---|---|
| `01-01-entra-admin-center-home.png` | Microsoft 365 admin center home page |
| `01-02-tenant-overview.png` | Entra admin center tenant overview |
| `01-03-admin-account-overview.png` | Administrator account overview |
| `01-04-add-user-start.png` | Add a user wizard, basics step |
| `01-05-new-user-basic-info.png` | Optional settings step, placeholder contact fields |
| `01-06-user-created-frank.png` | Frank Dugald created |
| `01-07-user-created-samuel.png` | Samuel Banks created |
| `01-08-all-users-created.png` | Pre-existing staff roster before this lab's additions |
| `01-09-admin-user-properties.png` | Identity and Contact Information panels |
| `01-10-user-department-attribute.png` | Manage contact information dialog |
| `01-11-user-department-it-wale.png` | Wale Adebimpe's department set to IT |
| `01-12-user-contact-info-keith.png` | Keith Albalos's contact information |
| `01-13-licensing-overview.png` | Licensing overview |
| `01-14-licensing-page.png` | Entra Licenses \| All products |
| `01-15-licensing-detail.png` | Administrator's own licence assignment |
| `01-16-licence-usage.png` | License usage report |
| `01-17-groups-overview.png` | Active teams and groups |
| `01-18-creating-security-group.png` | Creating a security group |
| `01-19-security-group-created.png` | Security group created |
| `01-20-security-group-info.png` | Vortex-Security group overview |
| `01-21-finance-group-created.png` | Finance group created |
| `01-22-adding-group-members.png` | Adding members to a security group |
| `01-23-member-added.png` | Member added confirmation |
| `01-24-member-removal-option.png` | Member removal control |
| `01-25-member-removed.png` | Member removed |
| `01-26-password-reset-keith.png` | Password reset in progress |
| `01-27-password-reset-keith-done.png` | Password reset completed |
| `01-28-service-health-dashboard.png` | Service health dashboard |
