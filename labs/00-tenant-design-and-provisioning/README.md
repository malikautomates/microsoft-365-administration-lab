# Lab 00 — Tenant Design and Provisioning

**Objective:** Select, provision, and perform initial configuration of a Microsoft 365 tenant,
including custom domain verification and administrative tooling.
**Environment:** Microsoft 365 tenant, `{{TENANT}}.onmicrosoft.com`, custom domain
`{{ROOT_DOMAIN}}`.
**Prerequisites:** None.
**Duration:** Approximately 90 minutes, plus DNS propagation time.

---

## 1. Scenario

`{{COMPANY}}` requires a Microsoft 365 tenant to support eight staff across four departments.
No tenant currently exists. The organisation has no existing identity infrastructure to
synchronise from, so the tenant will be cloud-only.

The immediate task is not configuration but selection. A Microsoft 365 tenant is a paid,
hosted service, and the licence tier chosen determines which administrative capabilities are
available for the remainder of this project. Selecting a tier that excludes Microsoft Entra ID
P1 would make group-based licensing and Conditional Access unavailable, removing two of the
most significant controls from scope.

---

## 2. Design decisions

### 2.1 Tenant option assessment

Three viable options were assessed. Costs are approximate and were current at the time of
writing; Microsoft repriced several Microsoft 365 SKUs during 2025 and regional pricing varies.
Verify current pricing before purchase.

| | **Option A — No cost** | **Option B — Low cost** | **Option C — Full capability** |
|---|---|---|---|
| **Offering** | Microsoft 365 Business Premium trial, or Microsoft 365 Developer Program sandbox where eligible | Microsoft 365 Business Premium, one paid seat | Microsoft 365 E5, one paid seat |
| **Approximate cost** | £0 / $0 | Low tens per user per month | Roughly two to three times Option B |
| **Tenant lifetime** | 30 days (trial); developer sandbox renews on activity where eligible | Indefinite while subscribed | Indefinite while subscribed |
| **Entra ID tier** | P1 | P1 | P2 |
| **Conditional Access** | Yes | Yes | Yes |
| **Group-based licensing** | Yes | Yes | Yes |
| **Intune device management** | Yes | Yes | Yes |
| **Privileged Identity Management** | No | No | **Yes** |
| **Microsoft Purview DLP and sensitivity labels** | Limited | Limited | **Full** |
| **Defender for Office 365** | Plan 1 | Plan 1 | **Plan 2** |
| **Risk** | Tenant and all evidence lost at expiry | Ongoing cost | Ongoing cost, materially higher |

### 2.2 Eligibility constraint on the developer sandbox

The Microsoft 365 Developer Program previously provided a free, renewable E5 sandbox tenant.
Eligibility was narrowed in January 2024 to require an active Visual Studio subscription for
new sign-ups. Eligibility criteria have changed more than once since.

**Verify current eligibility directly before relying on this option.** Where it is available it
is the strongest no-cost choice, because it provides E5 capability rather than Business
Premium. Where it is not, the Business Premium trial remains available without eligibility
conditions.

### 2.3 Decision

| Decision | Selected | Rationale |
|---|---|---|
| Tenant tier | *Record the option selected here* | *Record the reasoning, including whether developer sandbox eligibility was confirmed* |
| Identity model | Cloud-only | No on-premises directory exists. Entra Connect synchronisation would add a dependency without demonstrating additional capability at this scale. |
| Custom domain | Added and verified | Users authenticating as `first.last@{{TENANT}}.onmicrosoft.com` is not representative of production. Custom domain verification is a routine administrative task and is documented here. |
| Licensing model | Group-based | Assessed in [docs/environment.md](../../docs/environment.md), section 4. |

> **Complete section 2.3 before publishing.** The selection and its reasoning are the
> substance of this lab. A reviewer assessing this repository will read the reasoning, not the
> tier.

### 2.4 Cost containment

Where a paid option is selected, the following limit exposure:

- Purchase a **single** seat. Additional modelled users remain unlicensed, which is sufficient
  for every lab except those requiring mailbox or Teams functionality.
- Set the subscription to **not** auto-renew until the lab work is complete.
- Where a trial is used, capture all evidence before expiry. Trial tenant contents are not
  recoverable afterwards.

---

## 3. Implementation

### Step 1 — Provision the tenant

Complete the sign-up for the selected option. During sign-up the initial domain
`{{TENANT}}.onmicrosoft.com` is chosen. This value is permanent and cannot be changed after
creation.

Record it accurately at this point; it appears in every subsequent lab.

![Tenant provisioned and initial domain assigned](images/00-01-tenant-created.png)

---

### Step 2 — Record the tenant baseline

Before any configuration, record the tenant's initial state. This establishes what was
inherited from Microsoft rather than configured.

```powershell
Connect-MgGraph -Scopes 'Organization.Read.All', 'Directory.Read.All'

Get-MgOrganization |
    Select-Object DisplayName, Id, CreatedDateTime,
                  @{ n = 'InitialDomain'; e = { ($_.VerifiedDomains | Where-Object IsInitial).Name } }

Get-MgSubscribedSku |
    Select-Object SkuPartNumber, @{ n = 'Enabled'; e = { $_.PrepaidUnits.Enabled } }, ConsumedUnits
```

`Get-MgSubscribedSku` returns the licence SKUs held by the tenant and their consumption. The
`SkuId` values returned here are required for the group-based licensing configuration in
Lab 01.

![Tenant baseline and subscribed SKUs recorded](images/00-02-tenant-baseline.png)

---

### Step 3 — Add and verify the custom domain

Add `{{ROOT_DOMAIN}}` in the Microsoft 365 admin center under **Settings → Domains → Add
domain**. Microsoft issues a TXT record for ownership verification.

Create the TXT record at the DNS provider hosting `{{ROOT_DOMAIN}}`, then complete
verification.

```powershell
Get-MgDomain | Select-Object Id, IsVerified, IsDefault, AuthenticationType
```

Expected result: `{{ROOT_DOMAIN}}` present with `IsVerified` true.

![Custom domain verified](images/00-03-domain-verified.png)

> **Constraint.** This step requires control of a registered domain and access to its DNS
> records. Where no domain is available, the labs remain valid using the
> `{{TENANT}}.onmicrosoft.com` initial domain throughout. Record that substitution here rather
> than omitting the step silently.

---

### Step 4 — Set the default domain

Setting the custom domain as default ensures new accounts are created with the correct UPN
suffix by default.

```powershell
Update-MgDomain -DomainId '{{ROOT_DOMAIN}}' -IsDefault
Get-MgDomain | Select-Object Id, IsVerified, IsDefault
```

![Custom domain set as tenant default](images/00-04-default-domain.png)

---

### Step 5 — Install administrative tooling

```powershell
$modules = 'Microsoft.Graph', 'ExchangeOnlineManagement', 'MicrosoftTeams', 'PnP.PowerShell'

foreach ($module in $modules) {
    Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
}

Get-Module -ListAvailable -Name $modules |
    Select-Object Name, Version | Sort-Object Name -Unique
```

Confirm each connects:

```powershell
Connect-MgGraph -Scopes 'User.Read.All'
Get-MgContext | Select-Object Account, TenantId, Scopes

Connect-ExchangeOnline -ShowBanner:$false
Get-OrganizationConfig | Select-Object Name, DisplayName

Disconnect-ExchangeOnline -Confirm:$false
Disconnect-MgGraph
```

![Administrative modules installed and connectivity confirmed](images/00-05-modules.png)

---

### Step 6 — Confirm the unified audit log

The unified audit log underpins the auditing work in Lab 10. It is enabled by default in
current tenants, but this should be confirmed rather than assumed.

```powershell
Connect-ExchangeOnline -ShowBanner:$false
Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled
```

Where the result is `False`:

```powershell
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
```

> Audit log ingestion is not retrospective. Events occurring before it is enabled are not
> recorded and cannot be recovered. Confirming this at tenant creation rather than at Lab 10
> is deliberate.

![Unified audit log ingestion confirmed](images/00-06-audit-log.png)

---

## 4. Verification

| Check | Command | Success criterion |
|---|---|---|
| Tenant identity | `Get-MgOrganization` | Display name and tenant ID returned |
| Licence inventory | `Get-MgSubscribedSku` | Purchased SKU present with available units |
| Custom domain | `Get-MgDomain` | `{{ROOT_DOMAIN}}` verified and default |
| Graph connectivity | `Get-MgContext` | Account and granted scopes returned |
| Exchange connectivity | `Get-OrganizationConfig` | Organisation configuration returned |
| Audit ingestion | `Get-AdminAuditLogConfig` | `UnifiedAuditLogIngestionEnabled` is `True` |

```powershell
Connect-MgGraph -Scopes 'Organization.Read.All', 'Domain.Read.All'

Get-MgOrganization | Select-Object DisplayName, Id
Get-MgDomain       | Select-Object Id, IsVerified, IsDefault
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits,
                                    @{ n = 'Enabled'; e = { $_.PrepaidUnits.Enabled } }
```

![Tenant provisioning verified](images/00-07-verification.png)

---

## 5. Faults encountered

> Record faults as they occur. Two are documented below because they are near-universal on
> first tenant provisioning. Remove any that did not occur, and add those that did.

### 5.1 Domain verification fails after the TXT record is created

**Symptom.** Verification in the admin center reports that the TXT record could not be found,
despite the record having been created at the DNS provider.

**Diagnosis.**

```powershell
Resolve-DnsName -Name '{{ROOT_DOMAIN}}' -Type TXT -Server '1.1.1.1'
```

Querying an external resolver directly distinguishes a record that has not yet propagated from
one that was created incorrectly.

**Cause.** Either the record has not propagated within the zone's TTL, or the record name was
entered with the domain appended by the provider, producing
`{{ROOT_DOMAIN}}.{{ROOT_DOMAIN}}`. The second is a common data entry error at providers that
append the zone automatically.

**Resolution.** Where the record resolves externally, wait for the TTL to elapse and retry.
Where it does not, correct the record name and re-query before retrying verification.

---

### 5.2 Connect-MgGraph fails with insufficient privileges

**Symptom.** `Connect-MgGraph` succeeds, but a subsequent cmdlet returns
`Insufficient privileges to complete the operation`.

**Diagnosis.**

```powershell
Get-MgContext | Select-Object -ExpandProperty Scopes
```

**Cause.** The connection was established without the scope required by the cmdlet. Graph
scopes are requested per connection and are not implied by the signed-in account's directory
role.

**Resolution.** Reconnect requesting the required scope. The scope needed by any cmdlet is
listed in its documentation:

```powershell
Get-Help New-MgUser -Full
Connect-MgGraph -Scopes 'User.ReadWrite.All'
```

Administrator consent is required the first time a scope is requested in the tenant.

---

## 6. Capabilities demonstrated

- Microsoft 365 tenant provisioning and licence tier assessment
- Cost and capability analysis against operational requirements
- Custom domain addition and DNS-based ownership verification
- Microsoft Graph PowerShell SDK connection using explicit least-privilege scopes
- Exchange Online PowerShell v3 connectivity
- Unified audit log configuration
- DNS record troubleshooting using external resolvers

---

## 7. References

| Source | Behaviour confirmed |
|---|---|
| Microsoft Learn — *Add a domain to Microsoft 365* | TXT verification record format and process |
| Microsoft Learn — *Microsoft Graph PowerShell overview* | Module scope model and consent behaviour |
| Microsoft Learn — *Assign licenses to users by group membership* | Entra ID P1 requirement for group-based licensing |
| Microsoft Learn — *Turn auditing on or off* | Audit log ingestion is not retrospective |

---

## Screenshot checklist

| File | Content |
|---|---|
| `00-01-tenant-created.png` | Tenant creation confirmation showing the initial domain |
| `00-02-tenant-baseline.png` | `Get-MgOrganization` and `Get-MgSubscribedSku` output |
| `00-03-domain-verified.png` | `Get-MgDomain` showing the custom domain verified |
| `00-04-default-domain.png` | Custom domain set as default |
| `00-05-modules.png` | Installed module versions and successful connections |
| `00-06-audit-log.png` | `UnifiedAuditLogIngestionEnabled` returning `True` |
| `00-07-verification.png` | Combined verification output |
