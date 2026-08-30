# Execution Plan

**Document status:** Working document
**Purpose:** Sequence for performing Labs 00 to 12 against an existing tenant and capturing
the required evidence.

---

## 1. Before anything else: confirm what the tenant actually holds

The licence tier determines which labs are possible. Do not plan around an assumption.

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Connect-MgGraph -Scopes 'Organization.Read.All', 'Directory.Read.All'

Get-MgSubscribedSku |
    Select-Object SkuPartNumber,
                  @{ n = 'Enabled';   e = { $_.PrepaidUnits.Enabled } },
                  ConsumedUnits,
                  @{ n = 'Available'; e = { $_.PrepaidUnits.Enabled - $_.ConsumedUnits } } |
    Format-Table -AutoSize
```

### Reading the result

| `SkuPartNumber` | Product | Entra ID tier |
|---|---|---|
| `O365_BUSINESS_PREMIUM` | Microsoft 365 **Business Standard** | Free |
| `SPB` | Microsoft 365 **Business Premium** | P1 |
| `SPE_E3` | Microsoft 365 E3 | P1 |
| `SPE_E5` | Microsoft 365 E5 | P2 |
| `AAD_PREMIUM` | Entra ID P1 (standalone add-on) | P1 |
| `AAD_PREMIUM_P2` | Entra ID P2 (standalone add-on) | P2 |
| `EMS` / `EMSPREMIUM` | Enterprise Mobility + Security E3 / E5 | P1 / P2 |

> **Naming trap.** Microsoft 365 **Business Standard** carries the SKU part number
> `O365_BUSINESS_PREMIUM`. The string contains the word "premium" but the product is Standard,
> and it does **not** include Entra ID P1. Business *Premium* is `SPB`. This single naming
> collision causes more incorrect capability assumptions than any other in Microsoft 365
> licensing.

Record the output. It is the first screenshot of Lab 00.

---

## 2. Capability gap on Business Standard

Assuming the tenant holds Business Standard only, with no add-on:

| Lab | Feasible on Business Standard | Blocking dependency |
|---|---|---|
| 00 — Tenant design | **Yes** (adapted, see §4) | — |
| 01 — Identity and licensing | **Partial** | Group-based licensing and dynamic groups require P1 |
| 02 — Roles and least privilege | **Partial** | Administrative units require P1; PIM requires P2 |
| 03 — Conditional Access | **No** | Conditional Access requires P1 |
| 04 — Exchange mailboxes | **Yes** | — |
| 05 — Mail flow and protection | **Partial** | Exchange Online Protection included; Defender for Office 365 is not |
| 06 — Teams administration | **Yes** | — |
| 07 — SharePoint and OneDrive | **Yes** | — |
| 08 — Data protection | **No** | Purview DLP and sensitivity labels require P1-tier licensing or above |
| 09 — Device management | **No** | Intune is not included in Business Standard |
| 10 — Monitoring and auditing | **Partial** | Sign-in log retention is limited without P1 |
| 11 — Lifecycle automation | **Yes** (minus group licensing) | — |
| 12 — Service desk runbook | **Yes** (adapted fault set) | — |

Six labs complete as written, four partial, three blocked.

### Closing the gap

| | **Option A — No cost** | **Option B — Low cost** | **Option C — Purchase** |
|---|---|---|---|
| **Action** | Activate a Microsoft 365 E5 trial on the existing tenant | Add Entra ID P1 as a standalone add-on, one seat | Buy a Business Premium or E5 seat |
| **Cost** | £0 / $0 for 30 days | Single-digit per user per month | Business Premium: low tens. E5: roughly 2–3× that |
| **Unlocks** | Everything: P2, Intune, Purview, Defender P2, PIM | Conditional Access, group-based licensing, dynamic groups, administrative units | Business Premium: all but PIM and full Purview. E5: everything |
| **Leaves blocked** | Nothing | Intune, Purview DLP, Defender | Depends on tier |
| **Risk** | Expires in 30 days; capture evidence inside the window | Ongoing cost, still no Intune or Purview | Ongoing cost |

**Recommendation: Option A.** A trial subscription stacks alongside the existing Business
Standard licence on the same tenant. It unlocks all thirteen labs at no cost, and the
screenshots remain valid evidence permanently after the trial lapses. The constraint is
scheduling: all thirteen labs must be executed inside the window.

Activate from the Microsoft 365 admin center under **Billing → Purchase services**, filtering
for trials. Trial availability, seat count, and whether a payment method is required vary by
tenant and region — verify in your own admin center. Where a payment method is required,
disable auto-renewal immediately after activation.

> Record whichever option you take, and why, in Lab 00 §2.3. That reasoning is the part a
> reviewer reads.

---

## 3. Screenshot workflow

The screenshots are the portfolio. The prose is scaffolding around them.

### Capture

| Situation | Method |
|---|---|
| Portal page, static | `Win` + `Shift` + `S`, rectangular snip |
| Menu or flyout that closes on keypress | Snipping Tool app, set **Delay** to 3 or 5 seconds, then open the menu |
| PowerShell output | Maximise the console first so tables do not wrap, then snip the window including its title bar |

### Console readability

Wrapped table output is unreadable in a screenshot and is the most common defect in this kind
of portfolio. Before capturing PowerShell output:

```powershell
# Widen the buffer so Format-Table does not wrap.
$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(200, 3000)
```

Maximise the window, and pipe to `Format-Table -AutoSize` where a table is being shown.

### Naming and placement

Every lab README ends with a screenshot checklist. Filenames there match the image references
in the document exactly. Save each capture as PNG, with the exact filename, directly into:

```
labs/NN-lab-name/images/
```

A filename mismatch produces a broken image on GitHub. Verify with the checker in §6.

### Redaction

The tenant is a test environment, but some values should still not be published:

| Redact | Reason |
|---|---|
| Tenant ID (GUID) | Identifies the tenant to anyone reading |
| Your real administrator UPN or personal email | Personal data, and an authentication target |
| Subscription, billing, or invoice identifiers | Account data |
| Any real password, token, or secret | Never publish, even from a test tenant |

Use a **solid filled rectangle**, not a blur. Blur and pixelation are sometimes reversible.

Fictional lab user names (`dana.okoye@…`) need no redaction — that is the point of using them.

### Consistency

Use the same console theme, window size, and browser zoom throughout. A consistent visual
across thirteen labs reads as deliberate work; inconsistent captures read as screenshots
collected ad hoc.

---

## 4. Adapting Lab 00 to an existing tenant

Lab 00 is written as a provisioning lab. The tenant already exists, so the objective shifts
from provisioning to **assessment and baselining**. This is a legitimate and arguably stronger
framing: documenting and baselining an inherited tenant is closer to real administrative work
than creating one from scratch.

Amend Lab 00 as follows:

| Section | Change |
|---|---|
| Objective | "Assess, baseline and document an existing Microsoft 365 tenant, and close identified capability gaps." |
| §1 Scenario | The tenant was inherited. Current state is undocumented. The task is to establish what exists before changing anything. |
| §2.1 | Keep the tier assessment. Record the actual tier found, and the gap analysis from §2 of this document. |
| §2.3 | Record which gap-closing option was taken and why. |
| Step 1 | Replace "Provision the tenant" with "Record the inherited tenant state" — the `Get-MgSubscribedSku` output from §1 above. |
| Step 3 | Custom domain: if one is already verified, screenshot the verified state and note it was pre-existing. If not, perform the addition as written. |

Do not delete the provisioning steps silently. State that the tenant pre-existed. A reviewer
who sees an honest note about scope is better impressed than one who spots a gap.

---

## 5. Execution sequence

Dependencies are real. Labs later in the sequence consume objects created earlier.

### Phase 1 — Foundation (do first, in order)

| Lab | Prerequisite | Time | Screenshots | Notes |
|---|---|---|---|---|
| 00 | None | 45 min | 7 | Adapted per §4. Confirm audit log ingestion is on **before** anything else — audit is not retrospective |
| 01 | 00 | 60 min | 8 | Create the eight `users.csv` accounts. Group licensing requires the P1 uplift |
| 02 | 01 | 45 min | ~6 | Assign directory roles. Create both break-glass accounts here |
| 03 | 02 | 90 min | ~8 | **Highest risk lab.** See §5.1 |

### Phase 2 — Workloads (order flexible)

| Lab | Prerequisite | Time | Screenshots | Notes |
|---|---|---|---|---|
| 04 | 01 | 60 min | ~8 | Shared and resource mailboxes, delegation |
| 05 | 04 | 75 min | ~8 | Transport rules, message trace. Send real test mail between lab accounts |
| 06 | 01 | 60 min | ~7 | Teams provisioning and policy |
| 07 | 01 | 60 min | ~7 | Sites, external sharing, permission inheritance |

### Phase 3 — Governance

| Lab | Prerequisite | Time | Screenshots | Notes |
|---|---|---|---|---|
| 08 | 04, 07 | 75 min | ~8 | Requires the licence uplift. Test DLP with fictional data only |
| 09 | 03 | 90 min | ~8 | Requires Intune. Enrol a spare VM, not your workstation |
| 10 | 00, 03 | 60 min | ~7 | Audit log search, sign-in analysis, break-glass alerting |

### Phase 4 — Operations (do last)

| Lab | Prerequisite | Time | Screenshots | Notes |
|---|---|---|---|---|
| 11 | 01, 04 | 75 min | ~8 | Joiner/mover/leaver runbooks. Offboard one of the eight accounts |
| 12 | All | 90 min | ~10 | **Induces faults deliberately.** Run last, after all evidence is captured |

Approximate total: 14 to 16 hours. Across a 30-day trial that is comfortable; across four
focused days it is achievable.

### 5.1 Lab 03 is the one that can lock you out

Conditional Access misconfiguration is the single realistic way to lose access to the tenant
permanently. Three controls, in this order, every time:

1. **Create two break-glass accounts first** (Lab 02), on the `.onmicrosoft.com` initial
   domain, with long random passwords stored offline.
2. **Exclude both from every policy** before enabling it. Not after.
3. **Create every policy in report-only mode first.** Review the impact in
   **Entra admin center → Conditional Access → Insights and reporting** before switching to
   On.

Keep a signed-in private browser session open on a break-glass account while enabling any
policy. Screenshot the report-only evaluation — that evidence demonstrates the practice, and
it is exactly what a reviewer is looking for.

---

## 6. Verify before publishing

After each lab, confirm every referenced screenshot exists:

```powershell
.\scripts\Test-LabImages.ps1          # all labs
.\scripts\Test-LabImages.ps1 -Lab 01  # one lab
```

The script reports missing images per lab, and flags orphaned files that no README
references. A lab pushed with missing images renders broken-image icons on GitHub.

Then update that lab's status in the root `README.md` index from `Planned` to `Complete`, and
commit:

```powershell
git add .
git commit -m "Lab 01: identity and licensing, with verification evidence"
git push
```

Commit per lab rather than in one batch. The commit history then shows sustained work over
time, which is itself signal.

---

## 7. Standing rules

1. **Capture as you go.** Re-creating a screenshot after the fact means re-doing the step.
   Trial tenants expire and take unrecoverable state with them.
2. **Record faults when they happen.** Section 5 of each lab is the highest-value section in
   the document and cannot be reconstructed from memory.
3. **Never fabricate evidence.** A screenshot that does not match a claim is the one defect
   that ends an interview. Where something did not work, document that it did not work.
4. **Fictional users only.** No real personal data in any capture.
5. **Complete the design decision tables.** Where a table has a placeholder, fill it in before
   marking the lab complete.
