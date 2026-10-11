# GatePass SaaS — Multi-Building Visitor & Security Management Platform

A complete, enterprise-grade, multi-tenant **Visitor & Gate Security SaaS Platform** built with **Flutter**, designed specifically for residential buildings, gated communities, and housing societies in India.

The platform provides an **extremely fast and simple 10–15s interface for security guards**, while offering an isolated, powerful multi-tenant architecture that seamlessly scales from **1 building → 100 buildings → 1,000+ buildings**.

---

## 🏛 Platform Architecture

```
                   ┌────────────────────────────────────────┐
                   │    SUPER ADMIN SAAS PLATFORM (Web)     │
                   │ • Onboard Societies  • Manage Plans    │
                   │ • Platform Metrics   • Feature Gating  │
                   └──────────────────┬─────────────────────┘
                                      │
                   ┌──────────────────┴─────────────────────┐
                   │     SOCIETY / BUILDING ADMIN PANEL     │
                   │ • Dynamic Gates      • Wings & Flats   │
                   │ • Guards & Shifts    • Security Rules  │
                   └──────────────────┬─────────────────────┘
                                      │
              ┌───────────────────────┴───────────────────────┐
              │                                               │
┌─────────────▼───────────────┐               ┌───────────────▼─────────────┐
│      GUARD APPLICATION      │               │    RESIDENT APPLICATION     │
│ • Large Touch UI (10-15s)   │◄─────────────►│ • Instant Approvals         │
│ • Photo Capture & Retake    │  Real-Time    │ • Pre-Approved Passes       │
│ • Cross-Gate QR Scanner     │ Notifications │ • Flat-Isolated History     │
│ • Live Currently Inside     │               │ • Pass QR Sharing           │
│ • Emergency Evacuation View │               │                             │
│ • Offline Queue Durability  │               │                             │
└─────────────────────────────┘               └─────────────────────────────┘
```

---

## ⚡ The 4 Application Modules

### 1. 🛡️ Guard Application (Daily High-Speed Security Console)
- **High-Velocity UI**: Engineered for non-technical security guards using large readable typography, high-contrast action buttons, minimal typing, and dropdown pickers.
- **10–15s New Visitor Flow**:
  1. **Snap Photo**: Integrated viewfinder frame with instant retake and confirmation.
  2. **Mobile Number Lookup**: Automatically detects repeat visitors, auto-filling their name, previous visits count, and destination flat.
  3. **Select Flat & Purpose**: Quick dropdown selection (no manual purpose typing required).
  4. **Automatic Entry Timestamp**: Recorded without manual entry (includes Gate, Guard, Timezone, Society).
  5. **Instant QR Pass Generation**: Generates cryptographically verifiable QR pass.
- **Cross-Gate Exit (Requirement #13)**:
  - Visitor enters at **Gate A - Main Entrance** (10:32 PM).
  - Visitor exits at **Gate B - Parking Gate** (11:48 PM).
  - Gate B guard scans QR pass or searches mobile number.
  - Guard taps **MARK EXIT** → System automatically records Gate B, exit timestamp, exit guard, and marks visit `EXITED`.
- **Currently Inside**: Real-time list of all visitors on the premises (`exit_timestamp IS NULL`).
- **Emergency Evacuation View**: Instant muster list of all temporary individuals (visitors, technicians, delivery, domestic help) with rapid search for crisis situations.
- **Offline-First Resilience**: If gate Wi-Fi/4G drops, app continues operating locally with `● OFFLINE` indicator and auto-syncs when reconnected (`● ONLINE` / `SYNCING...`).

### 2. 🏠 Resident Application
- **Real-Time Visitor Requests**: Instant photo, purpose, name, and gate details with 1-tap `APPROVE` or `REJECT`.
- **Pre-Approved Visitor Passes**: Resident schedules an expected guest or delivery; system produces a pre-approved digital QR pass.
- **Flat-Isolated Visitor History**: Strict data privacy—residents can **only** inspect visitor history for their own flat.

### 3. 🏢 Society / Building Admin Panel
- **Dynamic Unlimited Gates**: Add, edit, rename, and disable gates dynamically (`Gate A - Main Entrance`, `Gate B - Parking`, `Gate C - Service Gate`).
- **Wings & Flats Configuration**: Configure wings (Wing A, B, C) and flats with occupant mapping.
- **Guards & Shift Management**: Assign guards to specific gates and shifts (Morning, Afternoon, Night).
- **Security & Privacy Rules**: Configure whether photos, delivery approvals, or vehicle numbers are mandatory; set data retention and photo auto-purge rules.
- **Subscription Status & Expired Screen**: If a society subscription expires, data is **never destroyed**; access is restricted to renewal until active.

### 4. 🌐 Super Admin SaaS Platform
- **Cross-Tenant SaaS Control**: Create and activate new residential societies.
- **Subscription Tier Configuration**: Manage Basic, Standard, and Premium tiers with dynamic pricing and limits (Gates, Guards, Flats, Storage, Features).
- **Platform Analytics**: Total active subscriptions, revenue metrics, total platform headcount, and system logs.

---

## ♿ Accessibility & Language Preferences

The app includes persistent, app-wide display preferences:

- **Languages:** English, Hindi, and Marathi. Flutter's Material, Widgets, and
  Cupertino controls use the selected locale. The login and accessibility
  settings flows, plus selected guard and resident dashboard labels, have
  application-provided translations; remaining feature copy is still being
  localized and may appear in English.
- **Text size:** Adjustable from 90% to 160%. The app setting composes with,
  rather than replaces, the device's system text scaling.
- **High contrast:** A high-contrast light theme can be enabled manually. The
  app also honors the operating system's high-contrast preference.
- **Persistence:** Language and accessibility preferences are stored locally
  on the device and restored at startup. Storage failures are surfaced in the
  UI; failed writes do not report success.
- **Interaction:** The login feature carousel is user-controlled (no automatic
  rotation), and settings, carousel controls, form labels, and important
  navigation actions expose accessible names and states.

These features are accessibility improvements, not a claim of W3C/WCAG
conformance. Before production sign-off, test every role and workflow with
keyboard-only navigation, screen readers, browser zoom, and a WCAG 2.2 AA
contrast/accessibility audit. Some legacy screens still use fixed colors and
English text and need a broader content pass.

## 🔒 Security & Multi-Tenancy Architecture

| Feature | Implementation Details |
|---|---|
| **Multi-Tenant Isolation** | Every database record and API query is strictly scoped by `tenant_id`. Row Level Security (RLS) ensures Society A can never access Society B data. |
| **No Private PII in QR** | QR codes encode secure tokens (`SECURE-V1:tenant:visitId:signature`) using HMAC-SHA256, rather than exposing resident phone numbers or names in raw text. |
| **Audit Logging** | Every security action (`ENTRY_RECORDED`, `EXIT_RECORDED`, `QR_SCANNED`, `APPROVAL_GRANTED`, `USER_LOGIN`) is logged with timestamp, user, role, and gate. |
| **Tamper-Proof Timestamps** | Guards never manually type timestamps; entry and exit times are recorded automatically at the server/system level. |

---

## 🧪 Comprehensive Automated Test Suite

The project includes an end-to-end automated test suite in `test/security_platform_test.dart` and `test/widget_test.dart`:

```bash
flutter test
```

### Verified Test Cases:
1. `✓ Visitor creation & Repeat Visitor auto-lookup`
2. `✓ Automatic entry timestamp (no manual typing)`
3. `✓ Cross-Gate Exit: Enter Gate A -> Exit Gate B automatically recorded`
4. `✓ QR Identification: Secure visit token without plain PII`
5. `✓ Duplicate / Invalid QR error handling`
6. `✓ Currently-Inside filtering (exitTimestamp is null)`
7. `✓ Strict Multi-Tenant Isolation (Society A != Society B)`
8. `✓ Subscription Status & Feature Gating enforcement`
9. `✓ Role-based access control and gate assignment`
10. `✓ Offline synchronization queue durability`
11. `✓ App UI Rendering & Security Dashboard Button verification`

---

## 🚀 Quick Start & Demo Credentials

### Run Application:
```bash
# 1. Navigate to the project directory
cd "c:\Users\Brijesh\Documents\FLUTTER_DEV\PROJECT\SECURITY PROJECT  CLIENT\security app"

# 2. Run the application (Windows Desktop or Chrome Web)
flutter run -d chrome
# or
flutter run -d windows
```

### Pre-Seeded Demo Roles:
Use the **Demo Role Bar** at the top of the app to switch roles instantly with one tap:

| Role | Name | Society / Context | Details |
|---|---|---|---|
| **Guard (Gate A)** | Ramesh Singh | Sunrise Heights (Gate A - Main Entrance) | Admits visitors, takes photos, generates QR |
| **Guard (Gate B)** | Suresh Patil | Sunrise Heights (Gate B - Parking Gate) | Scans QR, marks cross-gate exit |
| **Resident** | Rajesh Sharma | Sunrise Heights (Flat B-1204, Wing B) | Approves visitors, creates pre-approved passes |
| **Society Admin** | Sunil Nair | Sunrise Heights | Manages gates, wings, flats, guards, subscription |
| **Super Admin** | Aakash Singhal | Antigravity SaaS Platform | Onboards societies, configures SaaS tiers |

---

## 📁 Project Structure

```
lib/
 ├── models/                 # Tenant, User, Gate, Flat, Visitor, Visit, Subscription, AuditLog
 ├── theme/                  # Midnight Security Theme, AppColors, AppTypography
 ├── services/               # MockDatabase, VisitorService, GateService, ResidentService,
 │                           # SubscriptionService, SuperAdminService, QrService, SyncService
 ├── providers/              # Riverpod State Providers & Selectors
 ├── widgets/                # StatusChip, SyncIndicator, CameraCaptureDialog, QrViewDialog,
 │                           # QrScannerDialog, MarkExitDialog, RoleSwitcherBar
 ├── routing/                # AppShell with role-based routing
 ├── features/
 │    ├── guard/             # Dashboard, New Visitor, Currently Inside, Find, Emergency View, History
 │    ├── resident/          # Dashboard, Approvals, Pre-Approved Pass Generator
 │    ├── admin/             # Society Admin Console (KPIs, Gates, Flats, Guards, Subscription)
 │    └── super_admin/       # Platform Orchestration (Societies, Plans, Analytics)
 └── main.dart
backend/
 └── database_schema.sql     # Complete PostgreSQL Schema with RLS and Audit Triggers
docs/
 └── api_spec.md             # REST API Contracts & Endpoint Specifications
.env.example                 # Environment configuration template
```

---

## 📋 Core Journey Verification (Point #40)

1. **Create Society**: Super Admin creates `Sunrise Heights`.
2. **Configure 3 Gates**: Dynamic gates added (`Gate A - Main Entrance`, `Gate B - Parking`, `Gate C - Service Gate`).
3. **Configure Wings & Flats**: Wing B created, Flat `B-1204` mapped to resident `Rajesh Sharma`.
4. **Guard Login at Gate A**: Guard Ramesh Singh logs in at Gate A.
5. **New Visitor Registration**: Guard registers visitor Rajesh Kumar (9876543210, AC Repair, Flat B-1204).
6. **Automatic Entry**: System auto-records entry time (10:32 PM), Gate A, and generates secure QR.
7. **Currently Inside**: Rajesh Kumar appears in Currently Inside.
8. **Open Gate B**: Switch to Guard Suresh Patil at Gate B.
9. **Scan QR**: Camera scans QR or token `VIS-2026-000101`, identifying the active visit.
10. **Mark Exit**: Guard taps MARK EXIT → System automatically records Gate B and exit timestamp.
11. **Disappears from Inside**: Visitor automatically removed from Currently Inside.
12. **Audit History**: Visitor History shows complete log: `Visitor: Rajesh Kumar | Flat: B-1204 | Entry: Gate A (10:32 PM) | Exit: Gate B (11:48 PM) | Status: EXITED`.
13. **Tenant Isolation**: Users from Society A cannot search or access visits from Society B.
