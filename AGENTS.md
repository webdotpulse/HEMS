# AI Agent Instructions (EMS)

This repository is a generalized **Energy Management System (EMS)**. It monitors and visualizes energy flows between the Grid, Solar (PV), Batteries, and Home consumption. 

## 🚨 CORE DIRECTIVES (STRICT)
1. **NO EV CHARGING:** This project is strictly a general EMS. Do not write, suggest, or re-introduce any code related to Electric Vehicles (EVs), cars, loadpoints, or EV chargers. 
2. **NO SPONSORSHIP/TOKENS:** Do not include any code related to funding, sponsor tokens, or telemetry reporting to external centralized servers.
3. **INDEPENDENT PROJECT:** This is an independent project. Do not reference the original `evcc-io` repository, docs, or branding.

## Architecture
* **Backend:** Go (Golang). Handles meter reading (Modbus, MQTT, REST, etc.), data aggregation, and historical data logging.
* **Frontend:** Vue.js 3, Vite, Tailwind CSS. 
* **API:** The frontend communicates with the backend via REST and WebSockets for real-time updates.

## UI/UX Rules
* **The Energy Flow Chart is the Hero:** The main interface is an interactive Energy Flow diagram. 
* **Dynamic Rendering:** Elements (Grid, PV, Battery, Custom Loads) should *only* be rendered if they are actively configured in the backend.
* **Contextual History:** Do not show a massive global chart by default. Instead, users must **click** on an element in the Energy Flow chart (e.g., the Battery node) to reveal the historical data and charts specifically for that element.
* **Clean & Minimal:** Prioritize data readability.

## Code Style
* **Go:** Idiomatic Go. Use interfaces for meters. Keep the `core/site.go` lean and focused on balancing and metric aggregation.
* **Vue:** Use Composition API (`<script setup>`). Use Tailwind for all styling.
