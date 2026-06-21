# Stray Animal Management System – Business Requirements

## Language

- **Document language**: English
- **Spec / Design / Tasks**: English
- **Code & comments**: English

## Background

Metropolitan areas face significant stray animal (dog/cat) problems affecting public health, citizen safety, and animal welfare. A digital system is needed to manage stray animals systematically — from registration, health tracking, sterilization, vaccination, to finding new homes (adoption) — while enabling citizen participation in reporting, caring, and adopting.

## Problem Statement

- No centralized database of stray animals; actual numbers and locations unknown
- Sterilization/vaccination coverage is incomplete; no way to know which animals are done
- Citizens have no convenient channel to report stray animal issues with follow-up
- Adoption process is cumbersome; no central platform to match people with animals
- No post-adoption tracking system for adopted animals
- Limited budget requires efficient resource allocation
- Lack of data for policy planning (are stray populations increasing or decreasing?)

## Goals

1. Build a centralized stray animal database that can identify individual animals
2. Enable citizen participation through sighting reports and problem reporting (crowdsourcing)
3. Track health status, sterilization, and vaccination for each animal
4. Build an adoption system that easily matches people with animals and enables post-adoption follow-up
5. Provide analytics for policy planning and budget allocation
6. Reduce stray animal population humanely (TNR — Trap, Neuter, Return + Adoption)

## Scope

### In Scope

- **Animal Registry** – Database of stray animals (photos, features, coordinates, status, health history)
- **Citizen Reporting** – Report sightings of stray/injured/dangerous animals with photo + location, track status
- **Health & Medical Records** – Record sterilization, vaccination, treatment, appointment scheduling
- **Adoption System** – Animal profiles, adopter screening, matching, post-adoption follow-up
- **Community Features** – Community feeders, volunteers, foster care, donations, lost & found
- **Operations Management** – TNR team dispatch, route planning, shelter management, vet scheduling
- **Analytics & Dashboard** – Stray animal heatmap, sterilization rate, adoption rate, trends, budget

### Out of Scope

- Other stray animal types (birds, rabbits, etc.) — dogs and cats only
- Veterinary clinic/hospital management system
- E-commerce (selling pet supplies)
- Pet insurance
- Integration with microchip reader hardware

## Key Assumptions

1. Photos are the primary method for animal identification (distinctive features, color, markings)
2. Citizens can report via LINE Official Account or web app
3. Volunteer veterinarians or partner clinics handle sterilization/vaccination
4. The municipal government is the primary system administrator
5. Pilot in 5-10 districts initially
6. Sterilized animals are ear-tipped as identification

## Functional Requirements

### FR-01: Animal Registration & Identification
- Register stray animals (dog/cat) with photos, features, coordinates, temperament
- Auto-generated Animal ID
- Duplicate detection from photos (image similarity)
- Editable/updatable records

### FR-02: Citizen Reporting
- Report via web app / LINE Official Account
- Report types: new sighting, injured/sick, aggressive, growing pack, animal cruelty
- Attach photo + pin location + specify urgency
- Workflow: receive report → assign team → take action → notify reporter of outcome
- Gamification: reward points for helpful reporters

### FR-03: Health & Sterilization Tracking
- Medical records per animal (vaccines, sterilization, treatments)
- Next vaccination schedule (auto-remind)
- TNR Campaign management: plan areas, track target vs actual, record results
- Sterilization rate statistics by district

### FR-04: Adoption System
- Animal profiles for adoption (photos, temperament, health, suitable environment)
- Prospective adopters register + screening questionnaire
- Matching: recommend animals suited to lifestyle
- Adoption process: interest → apply → meet → trial period → confirm
- Post-adoption follow-up (1 week, 1 month, 3 months)

### FR-05: Community & Volunteer
- Community feeders: register feeding points, check-in, report status
- Volunteers: register + skills, receive assignments, log hours, badges/certificates
- Foster: temporary care while awaiting adoption
- Donations: money, supplies, sponsor a specific animal

### FR-06: Map & Area Management
- Map showing: stray animal locations (heatmap), feeding points, shelters/clinics, TNR areas
- Divide zones by district/sub-district
- Assign teams per zone, set sterilization targets

### FR-07: Admin & Operations
- Dashboard: animals in system, cases & status, TNR progress, adoption rate, budget
- Workflow: assign tasks to teams/volunteers, track completion, resource allocation
- Reporting: monthly reports per district, KPI tracking, data export

## Non-Functional Requirements

- **Performance**: page load < 3s, map rendering < 2s, support 50,000+ registered animals
- **Usability**: easy for general public, mobile-first, report in 3 steps
- **Security & Privacy**: adopter data confidential, reporters can be anonymous, data privacy compliant, role-based access
- **Scalability**: pilot 5-10 districts → city-wide → nationwide, multi-tenant ready
- **Availability**: uptime > 99.5%, urgent cases processed 24/7, offline capable for field staff

## Success Metrics

| Metric | Target |
|--------|--------|
| Registered animals (Year 1) | > 10,000 |
| Sterilization rate (pilot area) | > 70% |
| Adoption success rate (not returned) | > 80% |
| Citizen reports resolved | > 85% within 72 hours |
| Active volunteers | > 500 |
| Community feeders registered | > 200 points |
| Stray population change (Year 2) | Decrease > 15% |
| Post-adoption follow-up completion | > 90% |

## Target Users

| User | Role | Primary Need |
|------|------|-------------|
| General Public | Reports stray sightings/problems | Easy reporting, trackable outcomes |
| Prospective Adopter | Looking to adopt a pet | Browse animal profiles, easy application |
| Community Feeder | Cares for strays in their area | Register feeding points, report status |
| Volunteer | Helps with trapping/transport/foster | Receive assignments, log work |
| Volunteer Veterinarian | Sterilizes/vaccinates/treats | View schedule, record medical data |
| Municipal Official | Manages the system | Dashboard, reports, resource allocation |
| NGO / Foundation | Supports operations | Data access, coordinate adoptions |
