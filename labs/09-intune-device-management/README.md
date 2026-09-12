# Lab 09 — Device Management

**Objective:** Confirm Intune as the tenant's MDM authority, build a Windows compliance policy
and a settings-catalog configuration profile, enrol a test device, and pair device compliance
with the Conditional Access policy from Lab 03.
**Environment:** Microsoft 365 tenant `VortexAI654.onmicrosoft.com`, Microsoft Intune.
**Prerequisites:** Labs 00, 01, 03.
**Duration:** Approximately 90 minutes.

---

## 1. Scenario

The Conditional Access policy built in Lab 03 requires a compliant device, which is only
meaningful once Intune actually has a compliance policy to evaluate devices against, and at
least one enrolled device to test it on. This lab builds that side of the pairing: a baseline
compliance policy, a BitLocker-focused configuration profile, one enrolled test device, and the
Intune Administrator role delegated through PIM rather than relying on the Global Administrator
account for day-to-day device management.

---

## 2. Design decisions

| Decision | Options considered | Selected | Rationale |
|---|---|---|---|
| Compliance policy scope | Baseline, low-friction requirements; full security baseline | Baseline | The policy marks a device noncompliant immediately on failure rather than after a grace period, which is appropriate for a small, closely-watched pilot rollout — a wider grace period is a tuning decision for a larger fleet, not a starting default. |
| Enrolment device limit | Unlimited; a capped per-user limit | Capped at 5 | An unbounded personal-device limit makes lost/stolen device response harder to reason about. Five is generous enough not to block a real user while still bounding the fleet. |
| Intune administration | Global Administrator manages devices directly; delegated Intune Administrator role | Delegated, via PIM | Device management is a distinct, frequent task that doesn't need standing Global Administrator rights. Assigning Intune Administrator through PIM (Lab 02's pattern) keeps it time-bound like the Global Administrator role itself. |

---

## 3. Implementation

### Step 1 — Confirm MDM authority

![Tenant status page showing Microsoft Intune as the MDM authority](images/09-01-mdm-authority-status.png)

The tenant status page confirming Microsoft Intune is set as the Mobile Device Management (MDM) authority.

---

### Step 2 — Build the compliance policy

```powershell
# Intune admin center → Devices | Compliance → Create policy → Windows 10 and later
```

![Compliance policy: platform and profile type](images/09-02-compliance-policy-start.png)

The Windows 10/11 compliance policy wizard being started.

![Compliance policy settings: Device Health, Device Properties, System Security](images/09-03-compliance-policy-settings.png)

The compliance settings categories — Device Health, Device Properties, System Security — being configured.

![Actions for noncompliance: mark device noncompliant immediately](images/09-04-compliance-policy-actions.png)

The action for noncompliance set to mark a device noncompliant immediately, rather than after a grace period.

![Compliance policy "Baseline Compliance" created, assigned to all devices](images/09-05-compliance-policy-created.png)

Confirmation that the 'Baseline Compliance' policy was created and assigned to all devices.

---

### Step 3 — Build the configuration profile

The configuration profile was started from **Devices → Configuration → Create policy**,
choosing Windows 10 and later with the settings catalog profile type — a settings-driven
approach rather than a fixed template, used to enforce BitLocker settings (recovery password
rotation and standard-user encryption behaviour) beyond what the compliance policy alone
checks for.

![Create policy panel: Windows 10 and later, settings catalog profile type](images/09-06-intune-policy-create-start.png)

The Create policy panel used to start building the settings-catalog configuration profile that comes next.

![Creating a configuration profile: settings catalog](images/09-07-configuration-profile-start.png)

The configuration profile creation flow, using the settings catalog rather than a fixed template.

![Configuration profile: platform selection](images/09-08-configuration-profile-platform.png)

The profile's target platform being selected.

![Configuration profile settings: BitLocker recovery password rotation and standard-user encryption](images/09-09-configuration-profile-settings.png)

BitLocker settings being configured: recovery password rotation and standard-user encryption behaviour.

![Configuration profile assignments](images/09-10-configuration-profile-assignments.png)

The profile's assignment scope being set.

![Configuration profile review](images/09-11-configuration-profile-review.png)

The completed profile reviewed before creation.

![Configuration profile "Baseline Security Config" created](images/09-12-configuration-profile-created.png)

Confirmation that the 'Baseline Security Config' profile was created.

---

### Step 4 — Cap enrolment and enrol a test device

![Enrollment device limit restrictions: 5 devices per user](images/09-13-enrollment-device-limits.png)

The enrolment device limit restriction, capping each user at 5 enrolled devices.

![Enrolling a test device](images/09-14-enrolling-test-device.png)

A test device being enrolled into Intune.

![Device connected to Intune](images/09-15-device-connected.png)

Confirmation that the device connected successfully.

![Intune admin center before enrolment: no devices](images/09-16-intune-no-devices.png)

The Intune admin center's device list before enrolment, showing zero devices.

![Intune admin center after enrolment: one Windows device shown, personally owned, compliant](images/09-17-intune-device-connected.png)

The same device list after enrolment, showing one Windows device, personally owned, marked Compliant.

---

### Step 5 — Pair device compliance with Conditional Access

![Pairing the compliance policy with the Conditional Access policy from Lab 03](images/09-18-pair-compliance-with-ca.png)

The compliance policy being paired with the Conditional Access policy built in Lab 03.

![Compliance and Conditional Access pairing confirmed](images/09-19-pair-compliance-with-ca-created.png)

Confirmation that the compliance/Conditional Access pairing was applied.

---

### Step 6 — Delegate Intune administration via PIM

```powershell
# Entra PIM → Intune Administrator → Add assignments
```

![Assigning the Intune Administrator role via PIM](images/09-20-intune-admin-role-assignment.png)

The Intune Administrator role being assigned via PIM rather than as a standing assignment.

![Intune Administrator PIM assignment, continued](images/09-21-intune-admin-role-assignment-2.png)

The PIM assignment flow continued.

---

### Step 7 — Register an enterprise application

As a secondary exercise in the Enterprise apps gallery, ServiceNow was added and assigned to
demonstrate app registration and assignment outside of the device-management workflow above.

![Browsing the Microsoft Entra app gallery](images/09-22-enterprise-app-gallery-browse.png)

The Microsoft Entra enterprise app gallery being browsed to register a new application.

![ServiceNow enterprise app added](images/09-23-enterprise-app-added.png)

Confirmation that the ServiceNow application was added.

![Enterprise app assignment](images/09-24-enterprise-app-assignment.png)

The new application assigned to users, completing its registration.

---

## 4. Verification

| Check | Command | Success criterion |
|---|---|---|
| MDM authority | Intune admin center → Tenant status | `Microsoft Intune` |
| Compliance policy | `Get-MgDeviceManagementDeviceCompliancePolicy` | "Baseline Compliance" present, assigned to all devices |
| Configuration profile | `Get-MgDeviceManagementDeviceConfiguration` | "Baseline Security Config" present |
| Device enrolled | Intune admin center → Devices → All devices | 1 device, compliance state `Compliant` |
| CA/compliance pairing | Conditional Access → "Device compliance app policy" | Grant control requires device compliance |

---

## 5. Faults encountered

No faults were encountered during this lab.

---

## 6. Capabilities demonstrated

- Intune compliance policy design and noncompliance action configuration
- Settings-catalog configuration profile authoring (BitLocker enforcement)
- Device enrolment limit governance
- Conditional Access and Intune compliance pairing
- Delegated Intune administration via Privileged Identity Management
- Enterprise application registration and assignment

---

## 7. References

| Source | Behaviour confirmed |
|---|---|
| Microsoft Learn — *Create a compliance policy in Microsoft Intune* | Noncompliance action timing and device health checks |
| Microsoft Learn — *Use Conditional Access with Intune* | Compliance-based Conditional Access grant control |
| Microsoft Learn — *Settings catalog in Microsoft Intune* | BitLocker configuration profile options |

---

## Screenshot checklist

| File | Content |
|---|---|
| `09-01-mdm-authority-status.png` | MDM authority confirmed as Microsoft Intune |
| `09-02-compliance-policy-start.png` | Compliance policy platform/profile type |
| `09-03-compliance-policy-settings.png` | Compliance policy settings |
| `09-04-compliance-policy-actions.png` | Actions for noncompliance |
| `09-05-compliance-policy-created.png` | Compliance policy created |
| `09-06-intune-policy-create-start.png` | Create policy panel: Windows 10 and later, settings catalog |
| `09-07-configuration-profile-start.png` | Creating a configuration profile |
| `09-08-configuration-profile-platform.png` | Configuration profile platform selection |
| `09-09-configuration-profile-settings.png` | BitLocker configuration settings |
| `09-10-configuration-profile-assignments.png` | Configuration profile assignments |
| `09-11-configuration-profile-review.png` | Configuration profile review |
| `09-12-configuration-profile-created.png` | Configuration profile created |
| `09-13-enrollment-device-limits.png` | Enrollment device limit restrictions |
| `09-14-enrolling-test-device.png` | Enrolling a test device |
| `09-15-device-connected.png` | Device connected |
| `09-16-intune-no-devices.png` | Intune admin center, no devices |
| `09-17-intune-device-connected.png` | Intune admin center, device enrolled |
| `09-18-pair-compliance-with-ca.png` | Pairing compliance with Conditional Access |
| `09-19-pair-compliance-with-ca-created.png` | Pairing confirmed |
| `09-20-intune-admin-role-assignment.png` | Assigning Intune Administrator via PIM |
| `09-21-intune-admin-role-assignment-2.png` | PIM assignment, continued |
| `09-22-enterprise-app-gallery-browse.png` | Browsing the Entra app gallery |
| `09-23-enterprise-app-added.png` | ServiceNow app added |
| `09-24-enterprise-app-assignment.png` | Enterprise app assignment |
