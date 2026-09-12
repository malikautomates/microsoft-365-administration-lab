# Lab 02 — Administrative Roles and Least Privilege

**Objective:** Assign directory roles against the principle of least privilege, using both
standing role assignment and time-bound Privileged Identity Management (PIM) activation.
**Environment:** Microsoft 365 tenant `VortexAI654.onmicrosoft.com`.
**Prerequisites:** Labs 00, 01.
**Duration:** Approximately 45 minutes.

---

## 1. Scenario

A single Global Administrator account is a single point of failure and a standing high-value
target: if it's compromised, everything is compromised. This lab spreads administrative
capability across the roster using the least privilege each task actually needs — a built-in
Helpdesk Administrator role for day-to-day account support, and PIM-managed, time-bound
elevation for the Global Administrator role itself, rather than leaving it permanently active.

---

## 2. Design decisions

| Decision | Options considered | Selected | Rationale |
|---|---|---|---|
| Helpdesk delegation | A custom role scoped to specific permissions; the built-in Helpdesk Administrator role | Built-in Helpdesk Administrator | The built-in role's permission set (password reset, licence and group assignment support, no directory-wide write access) already matched the helpdesk scenario in Lab 12. A custom role was still built once, from scratch, to confirm the mechanism and its permissions editor before deciding it wasn't needed here. |
| Global Administrator activation | Permanent standing assignment; PIM-managed eligible assignment | PIM-managed | A Global Administrator account that's always active is always a target. Making the role PIM-eligible instead means it's activated only when needed, for a bounded window, with the activation itself recorded in the audit log picked up in Lab 10. |

---

## 3. Implementation

### Step 1 — Build and review a custom role

Before relying on the built-in Helpdesk Administrator role, the custom role editor was used to
confirm what a role built from scratch actually exposes — its own permissions tab, separate
from the built-in role's fixed permission set.

![New custom role wizard: name, description, and baseline permissions](images/02-01-custom-role-created.png)

---

### Step 2 — Assign the Helpdesk Administrator role

The built-in Helpdesk Administrator role was assigned directly to John Ebuka, and — visible in
the same session's notifications — to Frank Dugald and to the administrator account.

![Assigning the Helpdesk Administrator role](images/02-03-assign-helpdesk-role.png)

![Assigning the Helpdesk Administrator role, continued](images/02-04-assign-helpdesk-role-2.png)

![Helpdesk Administrator assignment confirmed for Frank Dugald](images/02-05-helpdesk-role-frank.png)

![Active assignments for Helpdesk Administrator: John Ebuka shown, Muhammed Abdulmalik and Frank Dugald confirmed by notification](images/02-02-role-assigned.png)

---

### Step 3 — Move Global Administrator to PIM-managed activation

```powershell
Connect-MgGraph -Scopes 'RoleManagement.ReadWrite.Directory'
```

![Privileged Identity Management overview for Microsoft Entra roles](images/02-06-pim-overview.png)

![Add assignments: Global Administrator role, scoped to the directory, assigned to the administrator account](images/02-07-pim-role-assignment.png)

![PIM role assignment, continued: eligibility and duration settings](images/02-08-pim-role-assignment-2.png)

![Global Administrator PIM assignment confirmed](images/02-09-pim-role-assigned.png)

---

### Step 4 — Incidental Exchange configuration review

While working in the admin centers for this lab, two Exchange settings were reviewed as a
quick sanity check on what already existed in the tenant — properly the subject of Lab 05, but
captured here as they came up.

![Connectors reviewed: none configured, appropriate for a cloud-only tenant with no hybrid relay requirement](images/02-10-connectors-reviewed.png)

![An existing transport rule reviewed: an external-sender warning banner with a trusted-domain exception](images/02-11-existing-rule-review.png)

---

## 4. Verification

| Check | Command | Success criterion |
|---|---|---|
| Helpdesk role assignment | PIM → Helpdesk Administrator → Active assignments | John Ebuka, Frank Dugald, and the administrator listed |
| Global Administrator assignment type | PIM → My roles | Global Administrator shows as **Eligible**, not permanently Active |
| Connectors | Exchange admin center → Connectors | None configured |

```powershell
Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '<HelpdeskAdministratorId>'" |
    Select-Object PrincipalId, DirectoryScopeId
```

---

## 5. Faults encountered

No faults were encountered during this lab.

---

## 6. Capabilities demonstrated

- Custom directory role creation and permission scoping
- Least-privilege delegation using built-in roles matched to the actual task
- Privileged Identity Management: converting a standing Global Administrator assignment to a
  time-bound, eligible one
- Exchange connector and transport rule review

---

## 7. References

| Source | Behaviour confirmed |
|---|---|
| Microsoft Learn — *Assign Microsoft Entra roles in Privileged Identity Management* | Eligible vs. active assignment, and activation duration |
| Microsoft Learn — *Create and assign a custom role* | Custom role permission scoping |

---

## Screenshot checklist

| File | Content |
|---|---|
| `02-01-custom-role-created.png` | New custom role wizard |
| `02-02-role-assigned.png` | Helpdesk Administrator active assignments |
| `02-03-assign-helpdesk-role.png` | Assigning the Helpdesk Administrator role |
| `02-04-assign-helpdesk-role-2.png` | Assigning the Helpdesk Administrator role, continued |
| `02-05-helpdesk-role-frank.png` | Helpdesk Administrator assignment confirmed for Frank Dugald |
| `02-06-pim-overview.png` | PIM overview for Microsoft Entra roles |
| `02-07-pim-role-assignment.png` | Add assignments: Global Administrator via PIM |
| `02-08-pim-role-assignment-2.png` | PIM role assignment, duration/eligibility settings |
| `02-09-pim-role-assigned.png` | Global Administrator PIM assignment confirmed |
| `02-10-connectors-reviewed.png` | Exchange connectors reviewed, none configured |
| `02-11-existing-rule-review.png` | Existing transport rule reviewed |
