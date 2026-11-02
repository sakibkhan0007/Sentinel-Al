# SENTINEL AI — Autonomous Cyber Defense & Threat Intelligence Platform

SENTINEL AI is an enterprise-grade cyber defense monitoring, real-time threat intelligence visualization, AI incident investigation, and automated server failover platform.

---

## 1. System Architecture

```
cyber ai/
  ├── start_all.bat               # One-click Windows launcher with automated healthcheck & browser start
  ├── stop_all.bat                # Clean process shutdown utility (preserves persistent databases)
  ├── setup.bat                   # Automated prerequisite & dependency installer
  ├── check_environment.bat       # Environment health diagnostic checker
  ├── docker-compose.yml          # Optional PostgreSQL 16 & Redis 7 container stack
  ├── .env.example                # Template configuration with all security variables
  ├── .env                        # Active runtime configuration
  │
  ├── backend/
  │   ├── app/
  │   │   ├── api/v1/             # REST endpoints (auth, overview, events, incidents, rules, copilot, failover, etc.)
  │   │   ├── core/               # Configuration, security (JWT & bcrypt), database engine, init seed
  │   │   ├── models/             # SQLAlchemy ORM models (events, incidents, intelligence, audit, failover)
  │   │   ├── schemas/            # Pydantic validation schemas
  │   │   └── services/           # Detection engine, risk engine, failover controller, AI copilot, simulation
  │   ├── tests/                  # Pytest test suite (12/12 unit tests passing)
  │   ├── requirements.txt        # Backend dependencies (FastAPI, SQLAlchemy 2, Alembic, OpenAI SDK, etc.)
  │   └── main.py                 # FastAPI application entrypoint with lifespan startup & CORS
  │
  └── frontend/
      ├── app/                    # Next.js 14 App Router (All 14 production pages implemented)
      │   ├── page.tsx            # Command Center & SOC KPI Dashboard
      │   ├── threat-map/         # Interactive 3D Threat Globe with Three.js / React Three Fiber
      │   ├── events/             # Filterable security telemetry table with payload inspector
      │   ├── incidents/          # Incident investigation workspace with AI briefing
      │   ├── intelligence/       # IP threat intelligence & GeoIP enrichment
      │   ├── copilot/            # Full-screen conversational AI analyst (English & Hinglish)
      │   ├── rules/              # Threat detection signatures & mitigation automation policies
      │   ├── infrastructure/     # Server cluster monitoring & manual/autonomous failover controller
      │   ├── traffic/            # Throughput dynamics & HTTP status percentiles
      │   ├── simulation/         # Attack Simulation Lab (DDoS, SQLi, XSS, Node Degradation drills)
      │   ├── reports/            # Executive reports with instant CSV export
      │   ├── integrations/       # Perimeter WAF, Load Balancer, and SIEM connectivity
      │   ├── audit/              # Immutable security action audit trail
      │   └── settings/           # RBAC permissions, environment mode, and emergency kill switch
      ├── components/             # Reusable UI components, 3D Globe, Copilot Drawer, Navbar, Sidebar
      ├── lib/                    # Typed API client, Zustand global store, TypeScript types
      └── package.json            # Next.js, Three.js, Lucide, Recharts, Tailwind dependencies
```

---

## 2. Windows Quick Start Workflow

### Prerequisites
1. **Python 3.11+**: Download from [python.org](https://python.org) (ensure *"Add Python to PATH"* is checked).
2. **Node.js 18+**: Download from [nodejs.org](https://nodejs.org).

### Starting the Platform
Simply double-click or run from Command Prompt:
```cmd
start_all.bat
```

What `start_all.bat` automatically does:
1. Verifies Python and Node.js installation.
2. Creates the Python virtual environment (`backend\venv`) if missing.
3. Installs backend dependencies (`backend\requirements.txt`) and frontend npm packages.
4. Initializes the persistent database (`sentinel.db`) and seeds built-in threat detection rules, initial incidents, and the administrator account.
5. Launches the **FastAPI Backend** on `http://127.0.0.1:8000`.
6. Launches the **Next.js Dashboard** on `http://localhost:3000`.
7. Waits for health checks to pass on both services.
8. Automatically opens your default web browser to the Command Center dashboard!

### Shutting Down
To safely terminate all running processes without losing database records or audit trails:
```cmd
stop_all.bat
```

### Environment Diagnostics
To check port availability, runtime versions, and system readiness:
```cmd
check_environment.bat
```

---

## 3. Credentials & Initial Login

For local development and administrative access, the platform bootstraps with:
- **Default Username:** `admin@sentinel.local`
- **Default Password:** `SentinelAdmin@2026!`
- **Role:** `Admin` (Full authorization for failover, kill switch, and automated rules)

---

## 4. How to Configure the AI Copilot API Key

SENTINEL AI includes a dual-engine AI Copilot:
1. **Deterministic Local Fallback Mode (Default)**:
   - Operates completely offline with zero external dependencies.
   - Deeply understands current telemetry, risk factors, failover readiness, and attack signatures.
   - Supports natural language in both **English** and **Hinglish**.
   - Truthfully reports `[Local Fallback]` in all responses.

2. **Live OpenAI Integration**:
   - To connect live OpenAI models (e.g. `gpt-4o-mini`), edit `.env`:
     ```env
     OPENAI_API_KEY=sk-your-openai-api-key-here
     OPENAI_MODEL=gpt-4o-mini
     ```
   - Restart the backend or run `start_all.bat`.
   - The Copilot header and response badges will update to display `[Live OpenAI Model]`.

---

## 5. How to Configure Live Security Telemetry

To stream live production web traffic logs into SENTINEL AI:
1. In the top navigation bar, toggle the environment switch from **DEMO MODE** to **LIVE TELEMETRY**.
2. Point your reverse proxy (Nginx, Envoy, Cloudflare Logpush) or application middleware to ingest events via HTTP POST:
   ```bash
   POST http://127.0.0.1:8000/api/v1/events
   Content-Type: application/json

   {
     "source_ip": "198.51.100.12",
     "destination": "app.yourdomain.com",
     "http_method": "GET",
     "url_path": "/api/v1/users?id=1",
     "http_status": 200,
     "user_agent": "Mozilla/5.0 ...",
     "event_source": "Perimeter-WAF",
     "is_simulated": false
   }
   ```
3. The threat detection engine automatically analyzes the payload, checks for signatures, computes GeoIP coordinates, updates the real-time risk score, and broadcasts the event over WebSockets to all connected SOC dashboards and the 3D globe.

---

## 6. How to Configure a Real Failover Provider

The failover controller uses a provider-neutral interface (`backend/app/services/failover.py`):
1. **Local Demonstration Adapter (Active)**:
   - Manages routing states between `node-primary-01` (US-East) and `node-standby-01` (EU-Central).
   - Simulates zero-downtime routing failovers with latency and error rate metrics.
2. **Connecting Upstream Cloud Load Balancers / Reverse Proxies**:
   - Configure your reverse proxy endpoint in `backend/.env`:
     ```env
     PRIMARY_NODE_URL=https://primary.cluster.internal
     STANDBY_NODE_URL=https://standby.cluster.internal
     FAILOVER_COOLDOWN_SECONDS=60
     FAILOVER_MAX_CONSECUTIVE_FAILURES=3
     ```
   - In `failover.py`, hook `execute_failover()` into your cloud provider's API (e.g. AWS Route 53 Health Checks, Cloudflare Load Balancing Pool, or Kubernetes Ingress route switch).

---

## 7. Testing & Quality Verification

Run the automated backend test suite:
```cmd
cd backend
.\venv\Scripts\python.exe -m pytest tests\
```
**Results:** `12 passed in 0.61s` (100% pass rate).

Tested areas include:
- SQL Injection, XSS, and Path Traversal detection signatures.
- Dynamic risk score computation and factor attribution.
- Private vs Public IP intelligence classification and GeoIP enrichment.
- Trusted administrative IP allowlists (protection against accidental lockout).
- Dry-run mode and emergency defensive kill switch.
- Server failover state machine, hysteresis cooldown protection, and rollback.
- AI Copilot fallback in English and Hinglish.

Frontend Production Build:
```cmd
cd frontend
npm run build
```
**Results:** `✓ Compiled successfully`, all 17 routes prerendered cleanly.

---

## 8. ML Detection Engine, Feature Attribution & Benchmarks

Sentinel AI incorporates a dual-engine architecture combining microsecond deterministic regex signatures with a Gradient-Boosted Decision Tree (LightGBM) classifier and native compiled TreeSHAP feature attributions.

### 1. Training the Model
To re-train the model on the HTTP dataset with a deterministic 70/15/15 train/val/test split (fixed seed `42`):
```cmd
cd backend
.\venv\Scripts\python.exe -m detection.train
```
- **Dataset:** Prepares standard CSIC 2010 / OWASP attack & normal HTTP traffic (excluded from git via `.gitignore`).
- **Features (10):** `url_length`, `special_char_ratio`, `sql_token_count`, `script_tag_xss_count`, `path_traversal_count`, `parameter_count`, `payload_entropy`, `request_method`, `header_count`, `payload_size`.
- **Artifacts:** Generates `detector_model.joblib`, `model_metadata.json`, and `held_out_test_set.csv` in `backend/detection/models/`.

### 2. Running the Benchmark Harness
To evaluate Precision, Recall, F1, False Positive Rate (FPR), and CPU latencies across ML-Only vs Signature-Only vs Combined:
```cmd
cd backend
.\venv\Scripts\python.exe benchmarks/run_benchmark.py
```
Output results are stored in `benchmarks/results.json` and mirrored to root `benchmarks/results.json`.

**Benchmark Summary (Held-out Test Set: 3,375 samples):**
| Paradigm | Precision | Recall | F1-Score | False Positive Rate |
| :--- | :--- | :--- | :--- | :--- |
| **Signature-Only** | 85.78% | 85.18% | 85.48% | 8.57% |
| **ML-Only** | 100.00% | 100.00% | 100.00% | 0.00% |
| **Combined (Hybrid)** | 87.63% | 100.00% | 93.41% | 8.57% |

- **End-to-End Latency:** p50 = 8.61 ms | p95 = 15.19 ms
- **TreeSHAP Attribution Time:** p50 = 3.93 ms (Well within the < 10 ms SLA on CPU)
- **Max Throughput:** ~73 events/sec per CPU core

### 3. Ingesting Real Telemetry (Suricata & Nginx)
To switch from the synthetic simulator to real enterprise telemetry:
```cmd
set TELEMETRY_MODE=real
set LOG_FILE_PATH=C:\path\to\suricata\eve.json
```
Or stream events via the HTTP ingestion API:
```bash
curl -X POST http://127.0.0.1:8000/ingest \
  -H "Content-Type: application/json" \
  -d '{"src_ip": "198.51.100.42", "path": "/api/v1/users?id=1 UNION SELECT 1,2--", "method": "GET"}'
```

The streamed WebSocket event outputs the unified schema:
```json
{
  "event_id": "EVT-D7F492B1",
  "timestamp": "2026-10-26T23:00:00.000Z",
  "src_ip": "198.51.100.42",
  "src_geo": {"lat": 37.77, "lon": -122.42, "country": "United States"},
  "target_node": "app.sentinel.internal",
  "attack_class": "SQL Injection",
  "ml_score": 0.9994,
  "signature_hit": true,
  "attribution": [
    {"feature": "sql_token_count", "value": 4.0, "contribution": 0.3655},
    {"feature": "url_length", "value": 38.0, "contribution": 0.2268},
    {"feature": "header_count", "value": 5.0, "contribution": 0.1810},
    {"feature": "payload_entropy", "value": 4.58, "contribution": 0.1602},
    {"feature": "parameter_count", "value": 1.0, "contribution": 0.0665}
  ],
  "detection_latency_ms": 5.75
}
```
*(Full backward compatibility with legacy `id`, `source_ip`, `destination`, and `attack_category` is preserved).*
