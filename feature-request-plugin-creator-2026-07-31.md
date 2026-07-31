# RHDH Plugin Creator Template with Dev Spaces Integration

## Engineering Brief

What to build: A Backstage Software Template ("Plugin Creator") that scaffolds new RHDH dynamic plugins with a fully pre-configured OpenShift Dev Spaces workspace — including enterprise rhdh-local integration, dynamic plugin export tooling, and a one-click PR workflow.

Who it's for: Backstage plugin developers at enterprises using Red Hat Developer Hub who need to create, test, and ship dynamic plugins without manually configuring development environments.

Why it's needed: Creating a new RHDH dynamic plugin today requires significant manual effort — bootstrapping the project structure, configuring the build toolchain, setting up a local RHDH instance for testing, and wiring up the dynamic plugin export pipeline. This template eliminates that friction entirely and includes an AI-assisted development experience via the preloaded Plugin Creation AI Skill.

Done looks like:

- A developer can go from "I need a new plugin" to writing business logic in under 5 minutes
- The scaffolded plugin compiles, runs, and exports as a dynamic plugin without additional setup
- The developer can test their plugin inside a real RHDH instance (rhdh-local) from within Dev Spaces
- The developer can push their work and create a pull request without leaving the IDE

## Feature Overview

A Backstage Software Template that scaffolds production-ready RHDH dynamic plugins with an integrated OpenShift Dev Spaces development environment — significantly reducing plugin development setup time while ensuring every plugin follows enterprise standards from day one. The workspace comes preloaded with the [Plugin Creation AI Skill](https://redhat.atlassian.net/browse/RHDHPLAN-1295) to provide AI-assisted guidance throughout the development process.

## User Story

So that I can focus on building plugin functionality instead of fighting toolchain configuration,
As a Backstage plugin developer,
I need a golden-path template that scaffolds a complete plugin project with a pre-configured cloud development environment connected to my enterprise RHDH instance for testing.

## Goals (Expected User Outcomes)

### Primary Goals

- **Goal 1:** Reduce time-to-first-commit for new plugins from hours of manual setup to under 5 minutes — measured by elapsed time from template execution to first meaningful code change committed.
- **Goal 2:** Ensure 100% of scaffolded plugins are immediately testable as dynamic plugins in rhdh-local — measured by successful execution of the "Test in RHDH Local" command without errors.
- **Goal 3:** Standardize plugin project structure across the enterprise — measured by adoption rate of the template vs. manual plugin creation.

### Secondary Goals

- Eliminate "works on my machine" issues by providing a consistent Dev Spaces environment for all developers
- Reduce onboarding time for new team members contributing plugins
- Establish a repeatable PR workflow that integrates with existing CI/CD pipelines

## Expected User Experience

### End-to-End Journey

**1. Template Discovery (RHDH Catalog)**

The developer navigates to the RHDH Software Catalog and selects "Create" from the sidebar. They find the "Plugin Creator" template tagged with `plugin`, `devspaces`, and `recommended`.

**2. Template Form (3 steps)**

- **Step 1 — Plugin Details:** The developer enters the plugin name (validated: lowercase, hyphens only), selects the plugin type (Frontend, Backend, or Common library), and picks the owning team from the catalog.
- **Step 2 — Dev Spaces Environment:** The developer provides the URL to their enterprise rhdh-local repository fork. This is the RHDH instance that will be available inside the Dev Spaces workspace for integration testing.
- **Step 3 — Repository Location:** The developer selects the GitHub organization and repository name using the standard RepoUrlPicker.

**3. Scaffolding Execution**

The template:

1. Renders the plugin skeleton with the developer's inputs (plugin name, type, owner)
2. Publishes the rendered code to a new GitHub repository
3. Registers the new component in the Backstage catalog (with Dev Spaces link in the catalog entity)

**4. Output Links**

The developer sees two links:

- **"Open in Dev Spaces"** — opens the workspace directly in OpenShift Dev Spaces
- **"View Repository"** — opens the GitHub repository

**5. Dev Spaces Workspace (automatic on click)**

When the developer clicks "Open in Dev Spaces":

- A workspace starts with the Universal Developer Image (Node.js, TypeScript, Yarn pre-installed)
- The plugin repo is cloned as the primary project
- The enterprise rhdh-local repo is cloned alongside at `/projects/rhdh-local`
- The [Plugin Creation AI Skill](https://redhat.atlassian.net/browse/RHDHPLAN-1295) is preloaded into the workspace to provide AI-assisted plugin development guidance (scaffolding patterns, dynamic plugin best practices, troubleshooting). Note: this skill is not yet in production but is included as an early-access capability.
- Pre-built IDE tasks are available in the command palette

**6. Development Loop**

The developer uses IDE tasks (Terminal → Run Task):
| Task | What it does |
|------|-------------|
| **Install dependencies** | `yarn install` in the plugin directory |
| **Start dev server** | Hot-reloading dev server on port 3000 for isolated plugin development |
| **Run tests** | Executes the plugin test suite |
| **Test in RHDH Local** | Exports the plugin as a dynamic plugin, then boots rhdh-local with it loaded |
| **Push Branch and Create Pull Request** | Commits, pushes, and opens a PR via `gh` CLI |

**7. Ship It**

Once the plugin is tested in rhdh-local and the developer is satisfied, they run "Push Branch and Create Pull Request" to commit all changes, push to origin, and create a PR — all without leaving the Dev Spaces IDE.

### UX/UI Considerations

- Design Needed: No (uses standard Backstage Scaffolder UI)
- Design Documents: N/A
- UX Review Required: No
- Accessibility: Inherits Backstage Scaffolder accessibility; Dev Spaces IDE accessibility is governed by the VS Code editor
- UX quality is assessed by: Template completes without errors, Dev Spaces workspace starts successfully, all IDE tasks execute without manual intervention

## Scope

### In Scope

- Backstage Software Template (`template.yaml`) with 3-step parameter form
- Plugin skeleton for frontend, backend, and common library plugin types
- Devfile 2.2.0 with:
  - Universal Developer Image container (4Gi memory, 2 CPU)
  - Enterprise rhdh-local cloned as a secondary project
  - [Plugin Creation AI Skill](https://redhat.atlassian.net/browse/RHDHPLAN-1295) preloaded into the workspace (pre-production; included for early developer feedback)
  - 5 pre-built IDE commands (install, start, test, test-in-rhdh-local, push-and-pr)
  - Dev server endpoint exposed on port 3000
- `catalog-info.yaml` with Dev Spaces link in entity annotations
- GitHub repository creation and Backstage catalog registration
- Dynamic plugin export using `@janus-idp/cli`

### Out of Scope

- GitLab or Bitbucket as source control targets (GitHub only in v1; separate initiative for multi-SCM support)
- Custom container images beyond the Universal Developer Image (teams can fork the template to customize)
- CI/CD pipeline generation (the PR workflow uses `gh` CLI; pipeline templates are a separate feature)
- Plugin marketplace publishing (out of scope for the creation template; separate publish workflow)
- Authentication/SSO configuration for Dev Spaces (assumed pre-configured at the platform level)
- Backend plugin database provisioning (backend plugins get the skeleton but DB setup is manual)

### Dependencies

- **OpenShift Dev Spaces** — must be deployed and accessible at `workspaces.openshift.com` (or enterprise equivalent). Required for the "Open in Dev Spaces" link to function.
- **Enterprise rhdh-local repository** — the developer must have an existing rhdh-local fork that contains a working RHDH instance. The template does not create or validate this repo.
- **GitHub** — repository creation requires GitHub integration configured in the Backstage instance (GitHub App or PAT).
- **@janus-idp/cli** — used at runtime in Dev Spaces to export the dynamic plugin. Fetched via npx (requires network access from Dev Spaces).
- **Backstage Scaffolder** — the template uses `scaffolder.backstage.io/v1beta3` API and standard actions (`fetch:template`, `publish:github`, `catalog:register`).
- **[Plugin Creation AI Skill (RHDHPLAN-1295)](https://redhat.atlassian.net/browse/RHDHPLAN-1295)** — pre-production AI skill preloaded into the Dev Spaces workspace. Not a hard dependency; the template functions fully without it, but it is included for early-access AI-assisted development.

## Customer Considerations

### Target Personas

**Platform Engineer (Template Author):**

- Context: Responsible for defining golden-path templates that standardize how development teams create and ship software within the enterprise.
- Pain Point: Every team creates plugins differently — inconsistent project structures, missing catalog registrations, no standardized testing workflow. Onboarding new developers takes days.
- Benefit: Ships a single template that enforces enterprise standards for every new plugin from day one. Reduces support burden for "how do I set up my dev environment" questions.

**Backstage Plugin Developer (Template Consumer):**

- Context: A software engineer tasked with building a new plugin for the enterprise developer portal. May be new to Backstage/RHDH or experienced but working on a new plugin.
- Pain Point: Significant time spent configuring the project structure, devfile, dependencies, and figuring out how to test as a dynamic plugin against rhdh-local. Often gets stuck on toolchain issues before writing any business logic.
- Benefit: Goes from template form to writing plugin code in under 5 minutes. Has AI-assisted guidance via the preloaded Plugin Creation AI Skill. Can immediately test against a real RHDH instance. Ships a PR without leaving the IDE.

**Engineering Manager:**

- Context: Manages a team that contributes plugins to the enterprise developer portal. Tracks velocity and time-to-delivery.
- Pain Point: Plugin development velocity is hampered by inconsistent environments and setup time. New team members take 1-2 weeks before they're productive.
- Benefit: Faster plugin delivery, reduced onboarding time, consistent quality across team output.

### Customer Evidence

No named customer accounts have specifically requested this feature as of 2026-07-31. The feature is driven by:

- Internal platform engineering team observation that plugin setup is the primary friction point for RHDH adoption
- Community feedback on Backstage plugin development complexity (Backstage GitHub Discussions, RHDH Slack)
- Strategic alignment with Red Hat's "golden path" developer experience initiative for RHDH

### Deployment Scenarios

- **Platform:** OpenShift with Dev Spaces operator deployed; RHDH instance running with Scaffolder enabled
- **Connectivity:** Requires network access from Dev Spaces to GitHub (for `gh` CLI and `npx` package fetches) and to the enterprise rhdh-local repo
- **Scale:** One template execution per plugin creation event; workspace resource consumption is 4Gi memory + 2 CPU per active workspace
- **Air-gapped:** Not supported in v1 (requires `npx` fetch of `@janus-idp/cli` at runtime; air-gapped support would require pre-baking the CLI into the container image)
- **Security:** GitHub credentials are managed by Backstage's existing GitHub integration; Dev Spaces workspace inherits the developer's OpenShift RBAC; no additional secrets are introduced by this template

## Feature Risks & Mitigations

### Technical Risks

**Risk: Enterprise rhdh-local repo may not exist or may be in a broken state**

- Impact: High — "Test in RHDH Local" command fails, breaking the primary testing workflow
- Mitigation: Add a validation step in the template that checks the URL is reachable (optional future enhancement). Document rhdh-local prerequisites clearly. Ensure the plugin still works in isolation (dev server) even if rhdh-local is unavailable.

**Risk: `@janus-idp/cli` version incompatibility with the scaffolded plugin**

- Impact: Medium — dynamic plugin export may fail if CLI version doesn't match the Backstage version used in the skeleton
- Mitigation: Use `@latest` tag for now (current approach). In future iterations, pin to a version range that matches the skeleton's `@backstage/*` dependency versions.

**Risk: Dev Spaces resource limits may be insufficient for running rhdh-local alongside the plugin dev server**

- Impact: Medium — OOM kills or slow performance when running both simultaneously
- Mitigation: 4Gi memory limit with `--max-old-space-size=3072` NODE_OPTIONS. Document that "Test in RHDH Local" is a sequential workflow (stop dev server before running rhdh-local if memory is constrained).

**Risk: GitHub rate limits on `gh pr create` for high-volume organizations**

- Impact: Low — PR creation fails; developer must create PR manually
- Mitigation: The push-and-pr command is a convenience, not a critical path. Developer can always create PR via GitHub UI.

**Risk: Plugin Creation AI Skill is pre-production and may have breaking changes**

- Impact: Medium — AI skill behavior may change or become temporarily unavailable as it iterates toward GA
- Mitigation: The AI skill is additive — no core workflow depends on it. If the skill is unavailable or broken, all other IDE tasks (install, start, test, export, PR) continue to function normally. Include a version pin or commit reference for the skill to allow controlled updates.

### Business Risks

- **Adoption risk:** Developers may prefer their existing (manual) workflow. Mitigation: Tag template as "recommended," demonstrate time savings in onboarding materials.
- **Maintenance burden:** Template and skeleton must be kept in sync with Backstage/RHDH version upgrades. Mitigation: Align template updates with RHDH release cadence.
- **Overlap with upstream Backstage `yarn new`:** The upstream Backstage CLI can scaffold plugins, but without Dev Spaces integration, rhdh-local testing, or dynamic plugin export. This template adds enterprise-specific value on top.

### Dependencies & External Factors

- OpenShift Dev Spaces operator must be healthy and have capacity for new workspaces
- GitHub App or PAT integration must be configured in the RHDH instance
- Enterprise rhdh-local repository must be maintained and accessible to developers

## Strategic Outcome

Developer experience is a core differentiator for RHDH adoption within enterprises. By reducing the time and expertise required to create and test dynamic plugins, this feature supports the linked outcome in 3 specific ways:

**Accelerated plugin ecosystem growth:** Lowering the barrier to plugin creation removes the primary friction point preventing teams from contributing plugins to their enterprise developer portal. The preloaded AI skill further accelerates development by providing contextual guidance specific to RHDH dynamic plugins.

**Standardization at scale:** Every plugin created through this template inherits enterprise standards (project structure, catalog registration, testing workflow, PR conventions) — eliminating drift and reducing review burden.

**Dev Spaces as the default development environment:** By making Dev Spaces the entry point for plugin development, this template reinforces the platform's value proposition and drives workspace adoption metrics.

## Acceptance Criteria

### Functional Requirements

**Criteria 1: Template Execution**
Given a developer has filled in valid plugin name, plugin type, owner, rhdh-local URL, and GitHub repo URL
When the template executes
Then a new GitHub repository is created containing a compilable plugin skeleton, a valid `devfile.yaml`, and a `catalog-info.yaml` — verified by successful `git clone` and `yarn install && yarn build` on the resulting repo.

**Criteria 2: Dev Spaces Workspace Starts Successfully**
Given the template has executed and produced a repository with a devfile
When the developer clicks the "Open in Dev Spaces" link
Then a Dev Spaces workspace starts within 2 minutes with both the plugin project and rhdh-local cloned — verified by presence of `/projects/<plugin-name>` and `/projects/rhdh-local` in the workspace filesystem.

**Criteria 3: Plugin Dev Server Runs**
Given the workspace has started and "Install dependencies" has completed
When the developer runs "Start dev server"
Then the plugin dev server starts and is accessible on port 3000 — verified by a successful HTTP response from the exposed endpoint.

**Criteria 4: Dynamic Plugin Export Succeeds**
Given the plugin has been developed and dependencies are installed
When the developer runs "Test in RHDH Local"
Then `@janus-idp/cli` exports the dynamic plugin without errors and rhdh-local starts with the plugin loaded — verified by the plugin appearing in the rhdh-local plugin list.

**Criteria 5: Push and PR Creation**
Given the developer has made changes to the plugin source
When the developer runs "Push Branch and Create Pull Request"
Then changes are committed, pushed to the remote, and a pull request is created on GitHub — verified by the PR URL output in the terminal.

**Criteria 6: Catalog Registration**
Given the template has executed successfully
When the developer navigates to the Backstage catalog
Then the new plugin component appears with correct metadata (name, owner, type, GitHub annotation, Dev Spaces link) — verified by searching for the component in the catalog UI.

### Error Handling

**Criteria 7: Invalid Plugin Name**
Given a developer enters a plugin name that violates the pattern (`^[a-z][a-z0-9-]*$`)
When they attempt to proceed
Then the form displays a validation error and does not allow submission — verified by entering "My Plugin" and observing the error.

**Criteria 8: Unreachable rhdh-local During "Test in RHDH Local"**
Given the rhdh-local URL is invalid or the repo cannot be cloned
When the workspace starts
Then the plugin project is still available for isolated development; only the "Test in RHDH Local" task fails with a clear error message — verified by confirming the plugin dev server still works independently.

### Performance Requirements

- Template execution (scaffold + publish + register): completes within 60 seconds
- Dev Spaces workspace startup: under 2 minutes from click to usable IDE
- "Install dependencies" command: under 90 seconds for the base skeleton

### Security & Compliance Requirements

- No secrets are stored in the scaffolded repository (credentials are handled by Backstage GitHub integration and Dev Spaces OpenShift RBAC)
- The template does not introduce any new credential types beyond what Backstage already manages
- The `gh` CLI in Dev Spaces uses the developer's existing GitHub authentication (configured at workspace level)

### User Experience Requirements

- Template form validates input inline (plugin name pattern, required fields)
- Output links are clearly labeled ("Open in Dev Spaces", "View Repository")
- IDE tasks have descriptive labels visible in the command palette
- Error messages from failed commands include actionable guidance

### Documentation Requirements

- Template README in the scaffolded repo explains the development workflow
- Platform team documentation on how to configure the template for their enterprise (setting up rhdh-local, configuring GitHub integration)
- Troubleshooting guide for common Dev Spaces startup issues

### Testing Requirements

- Unit tests: Template YAML schema validation (valid scaffolder v1beta3)
- Integration test: End-to-end template execution against a test GitHub org
- Devfile validation: Schema compliance with Devfile 2.2.0 spec
- Compatibility: Tested against RHDH 1.3+ and Dev Spaces 3.x

## Background and Context

### Problem Statement

RHDH is gaining a number of new capabilities to make plugin creation easier. [RHDHPLAN-1295](https://redhat.atlassian.net/browse/RHDHPLAN-1295) introduces a new CLI-based skills package for AI-assisted dynamic plugin authoring. [Ford's contribution to rhdh-local (PR #272)](https://github.com/redhat-developer/rhdh-local/pull/272) adds full OpenShift Dev Spaces support with a multi-container devfile (`tools`, `rhdh`, `sonataflow`), startup scripts (`start-rhdh.sh`, `start-orchestrator.sh`), and a comprehensive developer guide — born from four months of internal use to solve Podman/WSL setup friction for their development teams.

The problem is that these tools are scattered and only serve users who already know about them. The AI skill lives in a separate CLI package. The Dev Spaces devfile and scripts live in rhdh-local. The dynamic plugin export tooling requires knowledge of `@janus-idp/cli`. A developer must independently discover each piece, understand how they connect, and manually wire them together before they can be productive.

An in-portal Software Template makes AI-assisted plugin authoring a discoverable, end-to-end feature of the platform — surfacing all of these capabilities through a single "Create" action in the RHDH catalog. Instead of knowing that rhdh-local has Dev Spaces support, that a CLI skill exists for plugin guidance, and that a specific export command is needed for dynamic plugins, a developer simply fills out a form and gets a complete, working environment with everything pre-integrated. This makes plugin development seamless rather than a scavenger hunt across repositories and documentation.

### Related Work

- **[rhdh-local PR #272: Dev Spaces support](https://github.com/redhat-developer/rhdh-local/pull/272)** — Ford's contribution adding a multi-container devfile (`tools`, `rhdh`, `sonataflow`), startup scripts, and a developer guide to rhdh-local. Provides the foundational Dev Spaces workspace definition that this template's devfile connects to. Has been in internal use at Ford for 4+ months.
- **[RHDHPLAN-1295: Plugin Creation AI Skill](https://redhat.atlassian.net/browse/RHDHPLAN-1295)** — an AI skill package for RHDH dynamic plugin development. Pre-production; preloaded into the Dev Spaces workspace to provide AI-assisted guidance (scaffolding patterns, best practices, troubleshooting). This template serves as the primary distribution channel for early access to the skill.
- **@janus-idp/cli `package export-dynamic-plugin`** — the underlying tool used to export plugins; this template wraps it into the workflow
- **Backstage `yarn new` CLI** — scaffolds basic plugin packages but without Dev Spaces, dynamic plugin export, or rhdh-local integration
- **RHDH sample templates** — other templates in this repo (e.g., service creators) follow a similar pattern; this is the first plugin-specific template with Dev Spaces integration

### Strategic Context

RHDH's dynamic plugin architecture is one of its most powerful differentiators — but also one of the hardest features to adopt. The ecosystem is maturing rapidly: Ford has proven Dev Spaces-based development works at scale (4 months internal use, [PR #272](https://github.com/redhat-developer/rhdh-local/pull/272)), and [RHDHPLAN-1295](https://redhat.atlassian.net/browse/RHDHPLAN-1295) is adding AI-assisted authoring. But these capabilities remain fragmented across repositories, CLIs, and documentation — invisible to the average developer.

This template unifies these investments into a single, discoverable entry point within the RHDH portal itself. It transforms "find the right devfile, learn the CLI, clone the right repos, read the guide" into "click Create, fill a form, start coding." By making plugin development a first-class, in-portal experience, this feature directly addresses the adoption gap between "RHDH is deployed" and "teams are actively extending it with custom plugins."

## Blocked Reason

None
