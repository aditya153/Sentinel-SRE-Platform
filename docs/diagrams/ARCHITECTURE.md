# Aegis System Architecture

## Complete Data Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              AEGIS ARCHITECTURE                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                           EVENT SOURCES                                  │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │   GitHub     │  │   Grafana    │  │  Kubernetes  │  │    Slack     │ │ │
│  │  │  Webhooks    │  │   Alerts     │  │   Events     │  │   Commands   │ │ │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │ │
│  └─────────┼─────────────────┼─────────────────┼─────────────────┼─────────┘ │
│            │                 │                 │                 │            │
│            └────────────────┬┴─────────────────┴────────────────┘            │
│                             ▼                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                    NODE.JS EVENT DISPATCHER (:3001)                      │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │
│  │  │  Webhook    │  │  Signature  │  │   Event     │  │  Socket.io  │    │ │
│  │  │  Receiver   │  │  Validator  │  │ Normalizer  │  │   Emitter   │    │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │ │
│  └───────────────────────────────┬─────────────────────────────────────────┘ │
│                                  │                                            │
│                                  ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                          APACHE KAFKA                                    │ │
│  │  incidents │ deployments │ compliance │ remediations │ notifications   │ │
│  └───────────────────────────────┬─────────────────────────────────────────┘ │
│                                  │                                            │
│         ┌────────────────────────┼────────────────────────┐                  │
│         ▼                        ▼                        ▼                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                    FASTAPI AGENT GATEWAY (:8000)                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │
│  │  │   Kafka     │  │    Crew     │  │   Agent     │  │    REST     │    │ │
│  │  │  Consumer   │  │ Orchestrator│  │  Lifecycle  │  │     API     │    │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │ │
│  └───────────────────────────────┬─────────────────────────────────────────┘ │
│                                  │                                            │
│                                  ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                         CREWAI AGENT SWARM                               │ │
│  │                                                                          │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │ │
│  │  │   Triage    │ │    Log      │ │   Metric    │ │    Fixer    │       │ │
│  │  │   Agent     │ │  Analyst    │ │  Correlator │ │   Agent     │       │ │
│  │  │             │ │             │ │             │ │             │       │ │
│  │  │ • Severity  │ │ • Parse     │ │ • Query     │ │ • Restart   │       │ │
│  │  │ • Priority  │ │ • Patterns  │ │ • Correlate │ │ • Rollback  │       │ │
│  │  │ • Route     │ │ • RCA       │ │ • Anomalies │ │ • Scale     │       │ │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘       │ │
│  │                                                                          │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                        │ │
│  │  │  Security   │ │ Compliance  │ │ PostMortem  │                        │ │
│  │  │  Auditor    │ │  Checker    │ │   Writer    │                        │ │
│  │  │             │ │             │ │             │                        │ │
│  │  │ • SAST      │ │ • Policy    │ │ • Report    │                        │ │
│  │  │ • CVE scan  │ │ • SOC2/GDPR │ │ • Timeline  │                        │ │
│  │  │ • Secrets   │ │ • Drift     │ │ • RCA doc   │                        │ │
│  │  └─────────────┘ └─────────────┘ └─────────────┘                        │ │
│  └───────────────────────────────┬─────────────────────────────────────────┘ │
│                                  │                                            │
│                                  ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        MCP TOOL SERVER (:8001)                           │ │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐     │ │
│  │  │ GitHub │ │  K8s   │ │ Prom   │ │ Slack  │ │  Jira  │ │Terraform│     │ │
│  │  │  Tool  │ │  Tool  │ │  Tool  │ │  Tool  │ │  Tool  │ │  Tool  │     │ │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘     │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                           DATA LAYER                                     │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │  PostgreSQL  │  │    Redis     │  │    Qdrant    │  │  TimescaleDB │ │ │
│  │  │   Primary    │  │    Cache     │  │   Vectors    │  │  Time-Series │ │ │
│  │  │              │  │              │  │              │  │              │ │ │
│  │  │ • Incidents  │  │ • State      │  │ • Logs embed │  │ • Metrics    │ │ │
│  │  │ • Runs       │  │ • Sessions   │  │ • Similar    │  │ • Trends     │ │ │
│  │  │ • Audit      │  │ • Pub/Sub    │  │ • Learning   │  │ • History    │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        OBSERVABILITY                                     │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │ │
│  │  │  Prometheus  │  │   Grafana    │  │    Loki      │  │   Jaeger     │ │ │
│  │  │   Metrics    │  │  Dashboards  │  │    Logs      │  │   Tracing    │ │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                      REACT DASHBOARD (:3000)                             │ │
│  │  Real-time Incidents │ Agent Activity │ Control Panel │ Analytics       │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Agent Workflow (Incident Response)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INCIDENT RESPONSE FLOW                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  STEP 1: DETECT                                                              │
│  ─────────────────                                                           │
│  Grafana Alert: "High Memory Usage on api-server (95%)"                     │
│         │                                                                    │
│         ▼                                                                    │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ TRIAGE AGENT                                                          │   │
│  │ Input: Alert data                                                     │   │
│  │ Tool: prometheus_query("container_memory_usage_bytes")                │   │
│  │ Output: severity=CRITICAL, action=INVESTIGATE                         │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│         │                                                                    │
│         ▼                                                                    │
│  STEP 2: INVESTIGATE                                                         │
│  ────────────────────                                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ LOG ANALYST AGENT                                                     │   │
│  │ Input: Service name, time range                                       │   │
│  │ Tool: loki_query('{app="api-server"} |= "error"')                     │   │
│  │ Output: "OutOfMemoryError 47 times, heap exhaustion in /api/reports"  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│         │                                                                    │
│         ▼                                                                    │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ METRIC CORRELATOR AGENT                                               │   │
│  │ Input: Time range, affected service                                   │   │
│  │ Tool: prometheus_query("rate(http_requests_total[5m])")               │   │
│  │ Output: "Spike in traffic 10min ago, correlates with memory rise"     │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│         │                                                                    │
│         ▼                                                                    │
│  STEP 3: FIX                                                                 │
│  ────────────                                                                │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ FIXER AGENT                                                           │   │
│  │ Decision: Restart deployment (immediate relief)                       │   │
│  │ Tool: kubernetes_restart_deployment("production", "api-server")       │   │
│  │ Verification: kubernetes_get_pods() - All pods healthy ✓              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│         │                                                                    │
│         ▼                                                                    │
│  STEP 4: DOCUMENT                                                            │
│  ──────────────────                                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ POSTMORTEM WRITER AGENT                                               │   │
│  │ Generates incident report:                                            │   │
│  │ - Root Cause: Memory leak in /api/reports endpoint                    │   │
│  │ - Impact: 95% memory usage, potential OOM crash                       │   │
│  │ - Resolution: Deployment restarted                                    │   │
│  │ - Follow-up: Review memory allocation in reports service              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│         │                                                                    │
│         ▼                                                                    │
│  STEP 5: NOTIFY                                                              │
│  ─────────────                                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ NOTIFICATIONS                                                         │   │
│  │ - Slack: #incidents channel updated                                   │   │
│  │ - Dashboard: Real-time update via Socket.io                           │   │
│  │ - Database: Incident saved with full audit trail                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  TOTAL TIME: ~3-5 minutes (vs 45+ minutes manual)                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Database Schema

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DATABASE SCHEMA                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                          INCIDENTS                                    │   │
│  ├──────────────────────────────────────────────────────────────────────│   │
│  │ id              UUID PRIMARY KEY                                      │   │
│  │ alert_id        VARCHAR(255)                                          │   │
│  │ source          VARCHAR(50)      -- 'grafana', 'github', 'k8s'        │   │
│  │ severity        VARCHAR(20)      -- 'critical', 'warning', 'info'     │   │
│  │ status          VARCHAR(30)      -- 'open', 'investigating', 'resolved'│  │
│  │ title           TEXT                                                  │   │
│  │ service         VARCHAR(255)                                          │   │
│  │ root_cause      TEXT                                                  │   │
│  │ resolution      TEXT                                                  │   │
│  │ auto_resolved   BOOLEAN                                               │   │
│  │ resolved_by     VARCHAR(255)     -- 'agent' or 'human:username'       │   │
│  │ created_at      TIMESTAMPTZ                                           │   │
│  │ resolved_at     TIMESTAMPTZ                                           │   │
│  │ metadata        JSONB                                                 │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│                           │ 1:N                                              │
│                           ▼                                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                      AGENT_EXECUTIONS                                 │   │
│  ├──────────────────────────────────────────────────────────────────────│   │
│  │ id              UUID PRIMARY KEY                                      │   │
│  │ incident_id     UUID FK → incidents                                   │   │
│  │ agent_name      VARCHAR(100)     -- 'triage', 'log_analyst', 'fixer'  │   │
│  │ input_data      JSONB                                                 │   │
│  │ output_data     JSONB                                                 │   │
│  │ tool_calls      JSONB            -- MCP tools used                    │   │
│  │ tokens_used     INTEGER                                               │   │
│  │ duration_ms     INTEGER                                               │   │
│  │ status          VARCHAR(20)      -- 'success', 'failed', 'timeout'    │   │
│  │ created_at      TIMESTAMPTZ                                           │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│                           │ 1:N                                              │
│                           ▼                                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                       REMEDIATIONS                                    │   │
│  ├──────────────────────────────────────────────────────────────────────│   │
│  │ id              UUID PRIMARY KEY                                      │   │
│  │ incident_id     UUID FK → incidents                                   │   │
│  │ action_type     VARCHAR(50)      -- 'rollback', 'scale', 'restart'    │   │
│  │ target          VARCHAR(255)     -- 'deployment/api-server'           │   │
│  │ namespace       VARCHAR(100)                                          │   │
│  │ status          VARCHAR(20)                                           │   │
│  │ before_state    JSONB                                                 │   │
│  │ after_state     JSONB                                                 │   │
│  │ created_at      TIMESTAMPTZ                                           │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Service Ports

| Service | Port | Protocol |
|---------|------|----------|
| Frontend | 3000 | HTTP |
| Event Dispatcher | 3001 | HTTP/WS |
| Agent Gateway | 8000 | HTTP |
| MCP Server | 8001 | HTTP |
| PostgreSQL | 5432 | TCP |
| Redis | 6379 | TCP |
| Kafka | 9092 | TCP |
| Prometheus | 9090 | HTTP |
| Grafana | 3002 | HTTP |
| Qdrant | 6333 | HTTP |
