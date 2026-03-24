# Agent Instructions for EMS Project

This repository is a generalized Energy Management System (EMS). It is a hard fork and complete pivot from its original source. When interacting with, refactoring, or writing code for this repository, you must strictly adhere to the following rules:

## 1. Core Identity & Exclusions
* **NO EV Focus:** Do not write code, UI components, or logic specifically for Electric Vehicles or Cars. EVs are treated simply as generic loads.
* **NO Original Repo Ties:** Never reference the `evcc-io` repository. Do not import tools, telemetry, sponsorship checks, or tokens related to the original project.
* **Independence:** This is a fully independent, privacy-first, locally-hosted EMS.

## 2. Architectural Guidelines
* **Device Agnosticism:** The system models power flowing between generic nodes: `Grid`, `Solar (PV)`, `Battery`, and `Load`.
* **Historical Persistence:** State is not just live; it must be recorded. Features should be designed with historical data retrieval in mind.

## 3. UI/UX Philosophy
* **Flow First:** The primary interface is an Energy Flow Chart.
* **Conditional Visibility:** UI elements (Solar, Battery, Grid) must only appear if they are explicitly configured by the user and actively reporting data. Do not show dead or unconfigured nodes.
* **Progressive Disclosure:** The main view shows *live flow only*. Historical data and charts must be hidden by default and only revealed when a user explicitly clicks on a specific node in the flow chart.
* **Clean Design:** Prioritize modern, minimalist data visualization. No cluttered bar charts on the main dashboard.

## 4. Code Quality
* Keep PRs and commits focused strictly on EMS functionality. 
* Prioritize clean API boundaries between the device polling layer, the historical database, and the frontend web server.
