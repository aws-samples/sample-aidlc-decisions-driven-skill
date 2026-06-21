# Predictive Maintenance for Oil Rig with Local LLM – Business Requirements

## Language

- **Document language**: English
- **Spec / Design / Tasks**: English
- **Code & comments**: English

## Background

The company operates oil and gas drilling operations with multiple rigs (offshore and onshore). Each rig has critical equipment running 24/7 under extreme conditions. A predictive maintenance system is needed to reduce unplanned downtime (costing $500K–$1M/day for an offline offshore rig) and mitigate safety and environmental risks.

The system must monitor multiple rigs from a Central Control Room. The first phase will use **simulated data** since IoT hardware/software is not yet installed, and will use a **Local LLM** for anomaly analysis and failure prediction.

## Problem Statement

- Cannot monitor multiple rigs from a single point; no organization-wide equipment health overview
- Drilling equipment suffers unplanned breakdowns causing massive revenue loss ($500K–$1M/day)
- Safety risk — certain equipment (e.g., BOP) failures can lead to catastrophic accidents or blowouts
- Environmental risk — leaks can cause marine pollution
- Reactive maintenance is extremely expensive, especially offshore where logistics are complex
- No early warning system; cannot prepare spare parts and technicians in advance
- No IoT infrastructure exists yet; must prove concept with simulated data first

## Goals

1. Build a Predictive Maintenance prototype for Oil Rigs using Local LLM to analyze simulated sensor data
2. Support multi-rig monitoring from a Central Control Room
3. Simulate IoT sensor data reflecting real drilling equipment behavior
4. Have the LLM predict equipment risk and recommend maintenance plans
5. Build a basic Digital Twin of drilling rigs
6. Prepare architecture for connecting real IoT hardware in the future

## Scope

### In Scope

- **Multi-Rig Management** – Manage multiple rigs from a centralized dashboard
- **Data Simulation Module** – Simulate sensor data for 4 equipment types:
  - **Mud Pump**: pressure, flow rate, stroke rate, vibration, temperature
  - **Top Drive**: torque, RPM, vibration, temperature, current draw
  - **BOP (Blowout Preventer)**: hydraulic pressure, accumulator pressure, response time, temperature
  - **Drawworks**: brake temperature, line tension, drum speed, vibration
- **Local LLM Integration** – Use local LLM to analyze sensor data patterns
- **Anomaly Detection** – Detect abnormal values from simulated data
- **Failure Prediction** – Predict Remaining Useful Life (RUL) of equipment
- **Maintenance Recommendation** – Recommend maintenance plans with spare parts preparation
- **Basic Digital Twin** – Display equipment status in real-time
- **Alert System** – Alerts prioritized by safety impact

### Out of Scope

- Installing actual IoT hardware/sensors on rigs
- Connecting to real SCADA/DCS systems
- Mobile application
- Integration with existing ERP/CMMS systems
- Well control / drilling parameter optimization
- Crew scheduling management

## Key Assumptions

1. Using Local LLM (e.g., Ollama) for development and testing
2. Simulated data has patterns reflecting real behavior:
   - Normal operation under various loads (tripping, drilling, circulating)
   - Gradual degradation (e.g., mud pump liner wear)
   - Sudden anomaly (e.g., BOP hydraulic leak)
   - Environmental impact (waves, wind, temperature)
3. Primary users are Drilling Engineers, Maintenance Engineers, and Rig Managers
4. Simulated equipment types are the highest-criticality items with greatest safety impact

## Functional Requirements

### FR-01: Multi-Rig Management
- Register and manage multiple rigs (name, type, location, operational status)
- Dashboard overview of all rigs with equipment health status
- Drill-down into individual rig details
- Compare KPIs across rigs (downtime, anomaly rate, NPT)

### FR-02: Data Simulation Engine
- Generate simulated time-series sensor data for 4 equipment types
- Simulate both normal and abnormal scenarios
- Separate operating conditions by rig and mode (drilling/tripping/idle)
- Adjustable parameters (anomaly frequency, noise level)

### FR-03: Local LLM Analysis
- Send sensor data to LLM for analysis and response:
  - Risk level (Low / Medium / High / Critical)
  - Expected anomaly type
  - Root cause analysis
  - Maintenance recommendation + spare parts needed
  - Remaining Useful Life (RUL)
  - Safety impact assessment

### FR-04: Anomaly Detection & Alert
- Detect out-of-threshold values (threshold-based) and abnormal patterns (LLM-based)
- Prioritize alerts by safety criticality, production impact, environmental risk
- Display severity levels (Green / Yellow / Orange / Red)

### FR-05: Maintenance Scheduling
- Recommend maintenance schedule based on predictions
- Consider offshore logistics lead time and drilling windows
- Recommend spare parts to prepare

### FR-06: Digital Twin Visualization
- Schematic equipment layout of the rig
- Real-time status, time-series graphs, prediction timeline
- Operational status display (drilling/tripping/standby)

### FR-07: Reporting & Analytics
- Daily/weekly status summary
- Anomaly history, predicted vs actual comparison
- NPT report and cost savings summary

## Non-Functional Requirements

- **Performance**: real-time streaming >= 1 data point/second/equipment, LLM response < 30s
- **Safety & Security**: encryption, authentication, safety-critical alert redundancy, audit trail
- **Extensibility**: ready to switch to real IoT data, easy to add rigs/equipment, swappable LLM model
- **Usability**: easy to use, color-coded status per industry standards
- **Reliability**: zero missed critical alerts, fallback to threshold-based if LLM unresponsive

## Success Metrics

| Metric | Target |
|--------|--------|
| Anomaly detection accuracy (simulated) | > 85% |
| False positive rate | < 15% |
| LLM prediction response time | < 30s |
| Critical alert miss rate | 0% |
| Equipment coverage | 4 types |
| NPT reduction (projected) | > 20% |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| Drilling Engineer | Plans and controls drilling operations | Know in advance which equipment will fail |
| Maintenance Engineer | Maintains rig equipment | Prepare spare parts and plan repairs in advance |
| Rig Manager | Manages the rig | Reduce NPT, allocate resources |
| HSE Officer | Safety oversight | Monitor safety-critical equipment |
| Operations Manager (Shore-based) | Oversees multiple rigs | Compare performance across rigs |
