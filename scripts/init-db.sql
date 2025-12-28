-- Aegis Database Schema
-- Run this on PostgreSQL initialization

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════
-- INCIDENTS TABLE
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_id VARCHAR(255),
    source VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    status VARCHAR(30) DEFAULT 'open',
    title TEXT NOT NULL,
    service VARCHAR(255),
    description TEXT,
    root_cause TEXT,
    resolution TEXT,
    auto_resolved BOOLEAN DEFAULT FALSE,
    resolved_by VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'
);

-- ═══════════════════════════════════════════════════════════════
-- AGENT EXECUTIONS TABLE
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE agent_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_id UUID REFERENCES incidents(id) ON DELETE CASCADE,
    agent_name VARCHAR(100) NOT NULL,
    input_data JSONB,
    output_data JSONB,
    tool_calls JSONB,
    tokens_used INTEGER,
    duration_ms INTEGER,
    status VARCHAR(20),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- REMEDIATIONS TABLE
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE remediations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_id UUID REFERENCES incidents(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL,
    target VARCHAR(255) NOT NULL,
    namespace VARCHAR(100),
    status VARCHAR(20),
    before_state JSONB,
    after_state JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- INDEXES
-- ═══════════════════════════════════════════════════════════════
CREATE INDEX idx_incidents_status ON incidents(status);
CREATE INDEX idx_incidents_created ON incidents(created_at DESC);
CREATE INDEX idx_incidents_service ON incidents(service);
CREATE INDEX idx_incidents_severity ON incidents(severity);
CREATE INDEX idx_agent_exec_incident ON agent_executions(incident_id);
CREATE INDEX idx_remediations_incident ON remediations(incident_id);

-- ═══════════════════════════════════════════════════════════════
-- Sample Data (for testing)
-- ═══════════════════════════════════════════════════════════════
INSERT INTO incidents (source, severity, status, title, service, description)
VALUES 
    ('grafana', 'warning', 'open', 'High CPU Usage', 'api-server', 'CPU usage at 85% for 10 minutes'),
    ('github', 'info', 'resolved', 'Security vulnerability in dependency', 'frontend', 'lodash CVE detected');

SELECT 'Database initialized successfully!' as message;
