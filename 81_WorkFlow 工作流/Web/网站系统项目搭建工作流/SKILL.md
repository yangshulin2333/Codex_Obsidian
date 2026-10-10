---
name: premium-local-app-delivery
description: Build polished customer-facing websites, local business systems, admin dashboards, and internal tools that feel premium, deploy easily on Windows, support offline customer deployment, and keep running after reboot. Use when the user asks to make a system, website, app, management platform, customer demo, SQLite/local database app, Windows deployable package, offline deployment package, or a workflow where customers deploy once and later only open a browser URL.
---

# Premium Local App Delivery

## Goal

Deliver a usable system, not just source code. Optimize for a premium customer impression, low-friction Windows deployment, offline customer installation, and post-reboot availability through a browser URL.

## Default Delivery Pattern

Use the simplest stack that satisfies the job:

- For local business systems: prefer Flask + SQLite + server-rendered templates unless the requested UI requires a richer frontend.
- For simple websites: prefer static HTML/CSS/JS if it can run by opening a file; otherwise use a small local web server.
- For dashboards or complex interactions: use the repo's existing framework if present; otherwise choose a common framework conservatively.
- For 3D/game/advanced visual requests: follow the active frontend/game instructions and verify with browser screenshots.

When the user asks for customer deployment on Windows, assume the target customer machine may have no internet unless the user says otherwise.

## Product Polish Rules

Make the first impression customer-ready:

- Use Chinese UI copy by default for this user unless they ask otherwise.
- Keep wording simple and operational; avoid advanced English-heavy UI labels.
- Do not expose implementation details in the UI, such as SQLite, Python, Flask, localhost internals, or "demo" labels.
- Use client-facing language: "企业合同治理平台", "安全合规", "高效协同", "运营中心", "管理平台", "数据看板".
- Include a local logo, favicon, and icon set. Do not rely on external CDNs for core UI assets.
- Make the interface look like a real product: clear navigation, dashboard metrics, polished empty states, consistent buttons, status badges, audit trails, and customer-safe text.
- For admin/business systems, prioritize dense but clean enterprise UI over marketing hero pages.

## Functional Baseline

For management systems, include the practical features users expect unless the request is clearly smaller:

- Auth with a default admin account and password-change path or documented first-login change.
- Core CRUD for the domain entities.
- Dashboard with meaningful metrics and recent activity.
- Search, filters, status labels, and export where useful.
- File upload/download when the domain naturally needs attachments.
- User roles, permissions, and audit logs for enterprise credibility.
- Backup script for the local database and important uploaded files.
- Seed script for realistic sample data when the user wants demos or screenshots.

## Windows Deployment Workflow

Always include scripts that let a non-developer customer deploy:

- `deploy_offline.bat` and `deploy_offline.ps1`: install runtime and dependencies from local files.
- `start.bat`: start local-only service for single-machine use.
- `start_lan.bat`: start LAN service on `0.0.0.0:5000` or the selected port.
- `run_server.ps1`: background server entry used by autostart.
- `install_autostart.bat` and `install_autostart.ps1`: register a Windows scheduled task.
- `uninstall_autostart.bat` and `uninstall_autostart.ps1`: remove the scheduled task.
- `backup_db.bat` or equivalent backup command.
- `build_offline_package.ps1`: create a distributable zip with all code, wheels, runtime installers, and scripts.

For offline deployments:

- Download Python/runtime installers on the builder machine and include them in `offline_installers/`.
- Download dependency wheels into `offline_wheels/`.
- Install dependencies with `pip install --no-index --find-links`.
- Package a single zip such as `ContractManager_Offline.zip`.
- Customer workflow should be: copy zip, extract, double-click `deploy_offline.bat`, optionally run `install_autostart.bat` as administrator, then open the URL.

For "deploy once, later only open browser URL":

- Install a Windows scheduled task named for the product, for example `ContractManagerServer`.
- Run the server in the background at startup.
- Bind LAN deployments to `0.0.0.0:<port>`.
- Document firewall port allowance and fixed-IP recommendation.
- Verify after restart behavior conceptually by confirming the scheduled task exists and the run script can start the service.

## Verification Checklist

Before final response:

- Run syntax/build checks.
- Start the app locally and hit a health endpoint or main page.
- Login with the default admin account if auth exists.
- Visit main pages and verify HTTP 200 responses.
- Use the in-app browser for significant frontend work.
- Check static assets load: logo, favicon, CSS, JS, icon sprite.
- Verify offline package contents: installer, wheels, deploy scripts, autostart scripts.
- If seed data was generated only for demo, state whether the customer package is clean or includes sample data.
- Restart the local service after template or config changes that are cached by the server.

## Final Response Pattern

Keep the final answer operational:

- Give the exact zip path or local URL.
- State the customer deployment steps in 3-5 lines.
- State whether internet is needed on the customer computer.
- State how to enable boot autostart and how to undo it.
- Mention the default admin account and that the password should be changed.
