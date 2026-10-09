# GatePass SaaS - REST API Specification & Architecture Contracts

Version: `v1.0.0`  
Protocol: `HTTPS`  
Data Format: `JSON`  
Authentication: `Bearer <JWT_TOKEN>`  
Multi-Tenant Header: `X-Tenant-ID: <tenant_id>`  

---

## 1. Authentication & Session APIs

### `POST /api/v1/auth/login`
Authenticates a Guard, Resident, Society Admin, or Super Admin.

**Request Body:**
```json
{
  "email": "guard.gatea@sunriseheights.com",
  "password": "StrongPassword123!",
  "assigned_gate_code": "GATE-A"
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 86400,
  "user": {
    "id": "user_guard_gate_a",
    "name": "Ramesh Singh",
    "email": "guard.gatea@sunriseheights.com",
    "role": "guard",
    "tenant_id": "tenant_sunrise",
    "assigned_gate_id": "gate_sunrise_a",
    "assigned_gate_name": "Gate A - Main Entrance"
  },
  "tenant": {
    "id": "tenant_sunrise",
    "name": "Sunrise Heights Cooperative Society",
    "subscription_status": "active",
    "subscription_expires_at": "2027-10-06T00:00:00Z"
  }
}
```

---

## 2. Visitor Management & 10–15s Entry APIs

### `GET /api/v1/visitors/lookup?phone=9876543210`
Fast check for repeat visitors before displaying entry fields.

**Response (200 OK):**
```json
{
  "found": true,
  "visitor": {
    "id": "vis_rk_01",
    "name": "Rajesh Kumar",
    "phone": "9876543210",
    "photo_url": "https://storage.security.io/photos/vis_rk_01.jpg",
    "vehicle_number": "MH-43-AK-2024",
    "visitor_type": "technician",
    "total_visits": 3,
    "last_visited_flat": "B-1204",
    "is_blocked": false
  }
}
```

### `POST /api/v1/visits/entry`
Admit a new or returning visitor. **The backend automatically computes and records the entry timestamp and generates the cryptographic QR token.**

**Request Body:**
```json
{
  "visitor_name": "Rajesh Kumar",
  "visitor_phone": "9876543210",
  "visitor_photo_url": "https://storage.security.io/photos/vis_temp_123.jpg",
  "flat_id": "flat_b_1204",
  "flat_number": "B-1204",
  "wing_name": "Wing B",
  "visitor_type": "technician",
  "purpose": "repair",
  "custom_purpose": "AC Repair & Servicing",
  "vehicle_number": "MH-43-AK-2024",
  "entry_gate_id": "gate_sunrise_a"
}
```

**Response (201 Created):**
```json
{
  "id": "VIS-2026-000101",
  "tenant_id": "tenant_sunrise",
  "visitor_name": "Rajesh Kumar",
  "flat_number": "B-1204",
  "entry_gate_name": "Gate A - Main Entrance",
  "entry_guard_name": "Ramesh Singh",
  "entry_timestamp": "2026-10-06T10:32:00+05:30",
  "status": "inside",
  "approval_status": "approved",
  "secure_visit_token": "SECURE-V1:tenant_sunrise:VIS-2026-000101:8A9F1B2C3D4E"
}
```

---

## 3. Cross-Gate Exit & QR Verification APIs

### `POST /api/v1/visits/verify-qr`
Decodes and identifies active visit from scanned QR token. Does not leak private PII in QR payload.

**Request Body:**
```json
{
  "qr_token": "SECURE-V1:tenant_sunrise:VIS-2026-000101:8A9F1B2C3D4E"
}
```

**Response (200 OK):**
```json
{
  "valid": true,
  "visit": {
    "id": "VIS-2026-000101",
    "visitor_name": "Rajesh Kumar",
    "visitor_photo_url": "https://storage.security.io/photos/vis_rk_01.jpg",
    "flat_number": "B-1204",
    "wing_name": "Wing B",
    "purpose": "repair",
    "entry_timestamp": "2026-10-06T10:32:00+05:30",
    "entry_gate_name": "Gate A - Main Entrance",
    "status": "inside"
  }
}
```

### `POST /api/v1/visits/{id}/exit`
Marks cross-gate exit. **Automatically records exit timestamp and exit guard.**

**Request Body:**
```json
{
  "exit_gate_id": "gate_sunrise_b"
}
```

**Response (200 OK):**
```json
{
  "id": "VIS-2026-000101",
  "visitor_name": "Rajesh Kumar",
  "entry_gate_name": "Gate A - Main Entrance",
  "entry_timestamp": "2026-10-06T10:32:00+05:30",
  "exit_gate_name": "Gate B - Parking Gate",
  "exit_guard_name": "Suresh Patil",
  "exit_timestamp": "2026-10-06T11:48:15+05:30",
  "status": "exited"
}
```

---

## 4. Currently Inside & Emergency Evacuation APIs

### `GET /api/v1/visits/currently-inside`
Lists all active visits where `exit_timestamp IS NULL`.

### `GET /api/v1/visits/emergency-muster`
High-speed endpoint optimized for crisis evacuation headcounts.

---

## 5. Dynamic Gate Management APIs

### `GET /api/v1/gates`
### `POST /api/v1/gates`
Add gate dynamically (e.g. `Gate A`, `Gate B`, `Gate C`, `Main Gate`, etc.).
### `PATCH /api/v1/gates/{id}`
Rename or toggle active status of a gate.

---

## 6. Offline Queue Synchronization API

### `POST /api/v1/sync/batch`
Replays locally stored entries recorded during network disconnection.

**Request Body:**
```json
{
  "client_device_id": "TAB-GATE-A-01",
  "operations": [
    {
      "action": "recordEntry",
      "entity_id": "VIS-2026-000105",
      "payload": { ... },
      "client_timestamp": "2026-10-06T10:45:00Z"
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "synced_count": 1,
  "conflicts": [],
  "server_time": "2026-10-06T10:45:02Z"
}
```
