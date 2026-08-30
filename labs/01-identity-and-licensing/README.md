# Lab 01 — Identity and Licensing

**Objective:** Provision user accounts from a controlled source file and assign licences
through group membership rather than direct assignment.
**Environment:** Microsoft 365 tenant `{{TENANT}}.onmicrosoft.com`, custom domain
`{{ROOT_DOMAIN}}`.
**Prerequisites:** Lab 00.
**Duration:** Approximately 60 minutes.

---

## 1. Scenario

`{{COMPANY}}` has eight staff across four departments requiring Microsoft 365 accounts. The
organisation has one paid licence seat available and expects headcount to change.

Two requirements shape the approach. Account creation must be repeatable, because the same
process will be used for future joiners in Lab 11. Licence assignment must be auditable,
because the organisation needs to establish who holds a licence and why without inspecting
each account individually.

---

## 2. Design decisions

| Decision | Options considered | Selected | Rationale |
|---|---|---|---|
| Account creation method | Admin center form; CSV with Graph PowerShell | CSV with Graph PowerShell | The form is not repeatable and produces inconsistent attribute population. A source file makes the intended state explicit and reviewable before execution. |
| Licence assignment | Direct per-user; group-based | Group-based | Direct assignment leaves no record of intent and is routinely missed during offboarding. Group membership is declarative and reclaims the licence automatically on removal. |
| Group membership type | Assigned; dynamic | Assigned for licensing, dynamic for departments | Dynamic membership on a licensing group risks consuming licences unintentionally when an attribute changes. Department groups carry no licence and are safe to make dynamic. |
| Usage location | Set at creation; set before licensing | Set at creation | Licence assignment fails without it. Setting it at creation removes an ordering dependency. See section 5.1. |
| Initial password | Static shared value; per-user random | Per-user random, change required at first sign-in | A shared initial password is a credential distribution problem and appears in the source file in plain text. |

---

## 3. Implementation

### Step 1 — Define the source file

Account intent is defined in `users.csv` rather than typed at the console. The file is
reviewable, version-controlled, and reusable.

```csv
FirstName,LastName,Department,JobTitle,UsageLocation,LicenceGroup
Dana,Okoye,Finance,Financial Controller,CA,LIC-BusinessPremium
Adam,Whitfield,Finance,Accounts Assistant,CA,
Priya,Raman,Operations,Operations Manager,CA,
Sam,Achebe,Operations,Dispatcher,CA,
Elena,Kovacs,Operations,Dispatcher,CA,
Tomas,Lindqvist,Executive,Managing Director,CA,
Ruth,Mensah,Field,Driver,CA,
Ben,Carter,Field,Driver,CA,
```

Only one account is assigned to a licensing group, reflecting the single purchased seat. The
remaining accounts are created unlicensed. This is deliberate: unlicensed accounts are used in
Lab 12 to reproduce licence-related fault conditions.

> **Names in this file are fictional.** They exist to model departmental structure. No real
> personal data is present in this repository.

---

### Step 2 — Connect with the required scopes

```powershell
Connect-MgGraph -Scopes 'User.ReadWrite.All',
                        'Group.ReadWrite.All',
                        'Organization.Read.All',
                        'Directory.ReadWrite.All'

Get-MgContext | Select-Object Account, TenantId, Scopes
```

![Graph connection established with explicit scopes](images/01-01-connect.png)

---

### Step 3 — Create the accounts

The script below is idempotent: an account that already exists is reported and skipped rather
than causing a failure. This matters because the script is re-run in Lab 11.

```powershell
$domain = '{{ROOT_DOMAIN}}'
$users  = Import-Csv -Path '.\users.csv'

foreach ($user in $users) {
    $upn = '{0}.{1}@{2}' -f $user.FirstName.ToLower(), $user.LastName.ToLower(), $domain

    $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "skip    $upn (already exists)" -ForegroundColor Yellow
        continue
    }

    # 16-character random initial password, changed at first sign-in.
    $password = -join ((33..126) | Get-Random -Count 16 | ForEach-Object { [char]$_ })

    $params = @{
        DisplayName       = '{0} {1}' -f $user.FirstName, $user.LastName
        GivenName         = $user.FirstName
        Surname           = $user.LastName
        UserPrincipalName = $upn
        MailNickname      = '{0}.{1}' -f $user.FirstName.ToLower(), $user.LastName.ToLower()
        Department        = $user.Department
        JobTitle          = $user.JobTitle
        UsageLocation     = $user.UsageLocation
        AccountEnabled    = $true
        PasswordProfile   = @{
            Password                             = $password
            ForceChangePasswordNextSignIn        = $true
            ForceChangePasswordNextSignInWithMfa = $false
        }
    }

    New-MgUser @params | Out-Null
    Write-Host "created $upn" -ForegroundColor Green
}
```

> The generated passwords are not written to disk or to the transcript. Because
> `ForceChangePasswordNextSignIn` is set, the initial value must be delivered to each user
> through an out-of-band channel and is reset on first use. In a production process this
> handoff is the control point that matters most.

![Accounts created from the source file](images/01-02-users-created.png)

---

### Step 4 — Identify the licence SKU

The `SkuId` is a GUID specific to the tenant's subscription and must be read from the tenant
rather than assumed.

```powershell
Get-MgSubscribedSku |
    Select-Object SkuPartNumber, SkuId,
                  @{ n = 'Enabled';   e = { $_.PrepaidUnits.Enabled } },
                  @{ n = 'Available'; e = { $_.PrepaidUnits.Enabled - $_.ConsumedUnits } }
```

![Subscribed SKUs and available units](images/01-03-skus.png)

---

### Step 5 — Create the licensing group and assign the licence

```powershell
$sku = Get-MgSubscribedSku | Where-Object SkuPartNumber -eq 'SPB'   # Business Premium

$group = New-MgGroup -DisplayName     'LIC-BusinessPremium' `
                     -Description     'Licence assignment: Microsoft 365 Business Premium' `
                     -MailEnabled:$false `
                     -SecurityEnabled `
                     -MailNickname    'lic-businesspremium'

Set-MgGroupLicense -GroupId $group.Id `
                   -AddLicenses    @(@{ SkuId = $sku.SkuId }) `
                   -RemoveLicenses @()
```

Replace `SPB` with the `SkuPartNumber` returned in Step 4. The value differs by subscription:
`SPB` for Business Premium, `SPE_E3` and `SPE_E5` for the enterprise tiers.

![Licensing group created and licence attached](images/01-04-licence-group.png)

---

### Step 6 — Add members and confirm inheritance

```powershell
$user  = Get-MgUser  -Filter "userPrincipalName eq 'dana.okoye@{{ROOT_DOMAIN}}'"
$group = Get-MgGroup -Filter "displayName eq 'LIC-BusinessPremium'"

New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
```

Licence assignment through a group is processed asynchronously and is not instantaneous. Allow
a short interval before verifying.

```powershell
Get-MgUserLicenseDetail -UserId $user.Id | Select-Object SkuPartNumber

Get-MgUser -UserId $user.Id -Property 'assignedLicenses','licenseAssignmentStates' |
    Select-Object -ExpandProperty LicenseAssignmentStates |
    Select-Object SkuId, AssignedByGroup, State, Error
```

`AssignedByGroup` returning the group's object ID confirms the licence was inherited rather
than assigned directly. A null value indicates direct assignment, which is the condition this
design exists to avoid.

![Licence inherited through group membership](images/01-05-licence-inherited.png)

---

### Step 7 — Create dynamic department groups

Department groups carry no licence and are populated automatically from the `department`
attribute set in Step 3.

```powershell
$departments = 'Finance', 'Operations', 'Executive', 'Field'

foreach ($dept in $departments) {
    New-MgGroup -DisplayName                 "SEC-$dept" `
                -Description                 "Dynamic membership: $dept department" `
                -MailEnabled:$false `
                -SecurityEnabled `
                -MailNickname                "sec-$($dept.ToLower())" `
                -GroupTypes                  'DynamicMembership' `
                -MembershipRule              "(user.department -eq `"$dept`")" `
                -MembershipRuleProcessingState 'On' | Out-Null

    Write-Host "created SEC-$dept" -ForegroundColor Green
}
```

Dynamic membership requires Microsoft Entra ID P1. Rule evaluation is asynchronous and
typically completes within a few minutes of group creation.

![Dynamic department groups created](images/01-06-dynamic-groups.png)

---

## 4. Verification

| Check | Command | Success criterion |
|---|---|---|
| Accounts created | `Get-MgUser` | Eight accounts present with correct UPN suffix |
| Attributes populated | `Get-MgUser -Property department,jobTitle` | Department and job title set on every account |
| Usage location set | `Get-MgUser -Property usageLocation` | No account with a null usage location |
| Licence consumed | `Get-MgSubscribedSku` | `ConsumedUnits` incremented by one |
| Licence inherited | `licenseAssignmentStates` | `AssignedByGroup` populated, `State` is `Active` |
| Dynamic membership | `Get-MgGroupMember` | Members present matching the department rule |

```powershell
Get-MgUser -All -Property 'displayName','userPrincipalName','department','jobTitle','usageLocation' |
    Select-Object DisplayName, UserPrincipalName, Department, JobTitle, UsageLocation |
    Sort-Object Department, DisplayName |
    Format-Table -AutoSize

$group = Get-MgGroup -Filter "displayName eq 'SEC-Operations'"
Get-MgGroupMember -GroupId $group.Id |
    ForEach-Object { (Get-MgUser -UserId $_.Id).UserPrincipalName }
```

![All accounts with attributes populated](images/01-07-verify-users.png)

![Dynamic group membership resolved](images/01-08-verify-dynamic.png)

---

## 5. Faults encountered

### 5.1 Licence assignment fails with a usage location error

**Symptom.** Adding the user to the licensing group produced a licence assignment state of
`Error` rather than `Active`:

```powershell
Get-MgUser -UserId $user.Id -Property 'licenseAssignmentStates' |
    Select-Object -ExpandProperty LicenseAssignmentStates
```

The error reported was `UsageLocationRequired`.

**Diagnosis.**

```powershell
Get-MgUser -UserId $user.Id -Property 'usageLocation' | Select-Object UsageLocation
```

The attribute was null.

**Cause.** Microsoft 365 licences cannot be assigned without a usage location, because service
availability differs by country. The requirement applies equally to direct and group-based
assignment, but with group-based assignment the failure surfaces in the assignment state
rather than as an immediate error, so it is easily missed.

**Resolution.** Set the usage location, after which the assignment state resolves to `Active`
without further action:

```powershell
Update-MgUser -UserId $user.Id -UsageLocation 'CA'
```

The account creation script in Step 3 sets `UsageLocation` at creation specifically to prevent
this condition.

---

### 5.2 Dynamic group membership rule accepted but no members added

**Symptom.** `SEC-Finance` was created successfully with no error, but `Get-MgGroupMember`
returned nothing after several minutes.

**Diagnosis.**

```powershell
Get-MgGroup -Filter "displayName eq 'SEC-Finance'" `
            -Property 'membershipRule','membershipRuleProcessingState','groupTypes' |
    Select-Object MembershipRule, MembershipRuleProcessingState, GroupTypes
```

`MembershipRuleProcessingState` returned `Paused`.

**Cause.** A dynamic group created without `-MembershipRuleProcessingState 'On'` is created in
a paused state. The rule is stored but not evaluated. No error is raised.

**Resolution.**

```powershell
Update-MgGroup -GroupId $group.Id -MembershipRuleProcessingState 'On'
```

> A second cause produces identical symptoms: a rule referencing an attribute that is null on
> every user. Confirm the attribute is populated before concluding the rule is at fault.

---

## 6. Capabilities demonstrated

- User provisioning at scale using the Microsoft Graph PowerShell SDK
- Idempotent scripting with pre-flight existence checks
- Group-based licence assignment and inheritance verification
- Dynamic group membership rule authoring and troubleshooting
- Microsoft 365 licence SKU identification and consumption tracking
- Secure initial credential handling
- Diagnosis of asynchronous assignment failures via licence assignment state

---

## 7. References

| Source | Behaviour confirmed |
|---|---|
| Microsoft Learn — *Assign licenses to users by group membership* | Asynchronous processing and `AssignedByGroup` behaviour |
| Microsoft Learn — *Dynamic membership rules for groups* | Rule syntax and processing state semantics |
| Microsoft Learn — *Microsoft 365 product names and service plan identifiers* | `SkuPartNumber` to product mapping |
| `Get-Help New-MgUser -Full` | Required scopes and parameter set |

---

## Screenshot checklist

| File | Content |
|---|---|
| `01-01-connect.png` | `Get-MgContext` showing account and granted scopes |
| `01-02-users-created.png` | Script output showing accounts created |
| `01-03-skus.png` | `Get-MgSubscribedSku` with available units |
| `01-04-licence-group.png` | Licensing group created with licence attached |
| `01-05-licence-inherited.png` | `AssignedByGroup` populated, state `Active` |
| `01-06-dynamic-groups.png` | Dynamic department groups created |
| `01-07-verify-users.png` | All accounts with attributes populated |
| `01-08-verify-dynamic.png` | Resolved dynamic group membership |
