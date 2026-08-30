# Organisation Naming Guide

**Document status:** Action required
**Owner:** Repository author

---

## 1. Purpose

This laboratory models a fictional organisation. All documentation and scripts reference that
organisation by name. This document defines the three values that must be selected, the
constraints applying to each, and the procedure for applying them.

The organisation name has not been selected. Until it is, the repository carries placeholder
tokens.

---

## 2. Values to be selected

| Token | Description | Constraints |
|---|---|---|
| `{{COMPANY}}` | Display name of the modelled organisation | Used in prose only. No technical constraint. |
| `{{ROOT_DOMAIN}}` | Custom domain added to the tenant, and the UPN suffix | Must be a domain you control, with access to its DNS records. See section 3.2. |
| `{{TENANT}}` | Initial tenant name, excluding `.onmicrosoft.com` | Globally unique, permanent, cannot be changed after tenant creation. See section 3.1. |

### Worked example

| Token | Value |
|---|---|
| `{{COMPANY}}` | `Example Freight` |
| `{{ROOT_DOMAIN}}` | `examplefreight.ca` |
| `{{TENANT}}` | `examplefreight` |

Producing the initial domain `examplefreight.onmicrosoft.com` and user principal names in the
form `dana.okoye@examplefreight.ca`.

---

## 3. Selection constraints

### 3.1 The tenant name is permanent

The initial domain `{{TENANT}}.onmicrosoft.com` is assigned during tenant creation and cannot
subsequently be changed. It remains visible in the tenant indefinitely, appears in service
URLs, and cannot be removed even after a custom domain is added and made default.

It must also be globally unique across all Microsoft 365 tenants. A preferred name may already
be taken, and this is only discoverable at sign-up.

**Select this value deliberately rather than accepting a value typed during sign-up.**

### 3.2 The custom domain must be controlled

Adding a custom domain requires creating a TXT record in that domain's DNS zone to prove
ownership. This requires:

- A registered domain, and
- Access to the DNS provider hosting its zone.

Where neither is available, the labs remain valid using the `{{TENANT}}.onmicrosoft.com`
initial domain throughout. Lab 00 records this substitution explicitly rather than omitting the
step.

A domain already in use for live email must not be used. Adding it to a Microsoft 365 tenant
and changing MX records will interrupt mail delivery.

### 3.3 Names to avoid

- Names matching a registered trademark, given that this repository is published publicly.
- Names identical to a real organisation, which can create the impression that production
  infrastructure is being documented.
- Reserved values (`www`, `admin`, `portal`, `microsoft`, `office`, `login`), which are
  rejected at sign-up.

### 3.4 Consistency with related work

Where a separate on-premises Active Directory laboratory exists, using the same organisation
name across both presents them as one coherent environment. Where they are intended to stand
as independent pieces of work, use distinct names.

---

## 4. Application procedure

```powershell
cd <repository root>

.\scripts\Set-LabName.ps1 `
    -Company    'Example Freight' `
    -RootDomain 'examplefreight.ca' `
    -Tenant     'examplefreight'
```

Run with `-WhatIf` first to review the files that would be modified without writing changes.

The script validates the tenant name format and rejects reserved values before writing.

---

## 5. Post-application verification

```powershell
Select-String -Path .\* -Pattern '\{\{[A-Z_]+\}\}' -Recurse
```

The command should return no results.
