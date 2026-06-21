# EV Charging Network Management – Business Requirements

## Language

- **Document language**: English
- **Spec / Design / Tasks**: English
- **Code & comments**: English

## Background

Electric vehicle (EV) adoption is growing rapidly, but the charging station network is insufficient and lacks efficient management systems. A charging station operator needs a system to manage a network of charging stations across the metropolitan area that can monitor status in real-time, support reservations, implement dynamic pricing, and optimize utilization across the entire network.

## Problem Statement

- EV owners don't know which stations are available; they drive around checking, wasting time and energy
- Some stations are constantly congested while others sit idle — uneven utilization
- No booking system means uncertainty whether a spot will be free upon arrival
- Flat-rate pricing doesn't incentivize demand distribution (peak congestion)
- Operators have no visibility into station health (broken chargers, slow charging)
- No data for planning new station locations

## Goals

1. Build a real-time EV charging network management system
2. Let users find available stations & book in advance
3. Use dynamic pricing to distribute demand and increase revenue
4. Monitor charging station health & alert on issues
5. Analyze data for network expansion planning
6. Support load balancing with the electrical grid (smart grid ready)

## Scope

### In Scope

- **Station Network Monitoring** – Track all charging station statuses in real-time across the network
- **User App (Web)** – Find stations (map-based), view status, book, start/stop charging, pay
- **Booking System** – Reserve time slots in advance, grace period, auto-cancel, waitlist
- **Dynamic Pricing** – Price based on peak/off-peak, demand surge, grid signal, subscription plans
- **Payment** – Charge by kWh or time, credit card/digital wallet/corporate billing
- **Smart Grid Integration** – Load balancing during peak grid demand, V2G ready
- **Operator Dashboard** – Network overview, health monitoring, revenue analytics, demand forecasting

### Out of Scope

- Physical hardware installation of charging stations
- Mobile native app (responsive web / PWA)
- Integration with vehicle systems (in-car)
- Home charging management
- Selling/installing charging stations for individuals

## Key Assumptions

1. Charging stations communicate via OCPP (Open Charge Point Protocol)
2. Initial network has 50-100 stations in the metropolitan area
3. Each station has 2-10 connectors (AC and DC)
4. Most users charge at malls, gas stations, office buildings, condos
5. Peak demand: morning (08-10), evening (17-20), midday (11-14 at malls)
6. Base electricity rate follows time-of-use (TOU) tariffs
7. Data simulation for development (simulated OCPP messages)

## Functional Requirements

### FR-01: Station & Charger Management
- Register charging stations (name, location, hours, amenities)
- Manage connectors per station (connector type, power level, status, pricing tier)
- Group stations by zone/owner/partner

### FR-02: Real-time Station Discovery (User)
- Map showing all charging stations with color-coded status
- Filter & sort (connector type, power level, price, distance)
- Station details: available connectors, current price, estimated availability time, reviews
- Recommend stations based on battery %, route, user preferences

### FR-03: Booking System
- Book a connector in advance (max 24 hours, slots 30 min – 4 hours)
- Grace period (15 minutes), auto-cancel if no-show
- Waitlist when station is full
- Anti-hoarding: limit active bookings per user

### FR-04: Charging Session Management
- Start charging (scan QR / tap Start in app)
- Choose charging mode (full 100% / to X% / X minutes / X kWh)
- Real-time monitoring during charge (%, kWh, time, cost)
- Remote stop, notification when nearly complete
- Idle fee after charging completes if vehicle not moved

### FR-05: Dynamic Pricing Engine
- Base rate by charger type (AC cheaper, DC more expensive)
- Dynamic multiplier based on time (TOU), demand level, grid signal
- Subscription plans (pay-per-use, monthly plans with discounts)
- Price transparency: clearly display price before starting

### FR-06: Payment & Billing
- Payment methods: credit/debit card, digital wallet, in-app wallet, corporate billing
- Auto-billing on session end, idle fee, no-show fee
- Invoice & receipt, refund for equipment malfunction

### FR-07: Operator Dashboard & Analytics
- Network overview map with real-time status
- Alerts: charger offline, low performance, error
- Analytics: utilization rate, revenue, demand forecast, utilization heatmap
- Recommendations for new station locations
- User analytics: active users, charging patterns, subscription conversion

## Non-Functional Requirements

- **Performance**: real-time status update < 5s, map load < 3s, support 100,000+ users
- **Reliability**: uptime > 99.9%, zero lost payment transactions, offline mode for stations
- **Security**: HTTPS/TLS, payment PCI DSS compliant, rate limiting & fraud detection
- **Scalability**: support growth from 50 to 1,000+ stations without architecture changes
- **Interoperability**: OCPP compliant, roaming ready (OCPI), open API for partners
- **Usability**: mobile-first, easy-to-use map, multi-language support

## Success Metrics

| Metric | Target |
|--------|--------|
| Station uptime | > 99% |
| Average utilization rate | > 40% |
| Booking no-show rate | < 10% |
| Average idle time (post-charge) | < 15 minutes |
| User satisfaction (NPS) | > 40 |
| Registered users (Year 1) | > 50,000 |
| Revenue per charger per day | > $15 |
| Dynamic pricing uplift | +15% revenue vs flat rate |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| EV Owner (personal) | Charges their vehicle | Find available station, book, charge conveniently, good price |
| Fleet Manager | Manages corporate EV fleet | Consolidated billing, vehicle management, cost control |
| Station Operator | Maintains charging stations | Monitor equipment health, maintenance, revenue |
| Network Owner | Manages entire network | Analytics, expansion planning, pricing strategy |
| Property Owner (mall/condo) | Hosts chargers on premises | Utilization report, revenue share |
