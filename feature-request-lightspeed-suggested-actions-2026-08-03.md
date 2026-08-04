# RHDH Lightspeed Suggested Actions — AI-Powered Discoverability

## Engineering Brief

What to build: An AI-powered suggested actions feature within RHDH Lightspeed that surfaces the top 3 most relevant platform workflows to users based on organizational usage patterns, user role, and available plugins/templates.

Who it's for: All RHDH users — particularly new users who don't yet know the platform's navigation structure, and platform engineers who need to demonstrate value quickly to stakeholders and onboarding partners.

Why it's needed: RHDH users do not discover the platform's most valuable capabilities quickly enough. The current navigation model requires users to know where to look. Adding AI-ranked suggested actions inverts the model: instead of requiring users to find capabilities, the platform surfaces the most relevant capabilities to the user.

Done looks like:

- Lightspeed displays 3 outcome-focused suggestions ranked by organizational usage patterns
- Clicking a suggestion navigates directly to the corresponding RHDH workflow in 1–2 clicks
- Admins can customize, override, hide, and configure default suggestions
- New users discover and execute their first meaningful platform action within their first session

## Feature Overview

An AI-powered discoverability layer within RHDH Lightspeed that generates 3 outcome-focused use case suggestions based on organizational usage patterns. Rather than presenting a static menu of platform features, Lightspeed leverages organizational usage patterns — template executions, access requests, deployment workflows, catalog interactions — to rank and recommend the top 3 actions that deliver the most value to users in this specific RHDH instance. Clicking on a suggested action takes the user directly to the page where they can take that action.

## User Story

So that I can immediately discover and act on RHDH's most valuable capabilities without learning the platform's navigation structure,
As an RHDH user,
I need Lightspeed to suggest the most relevant workflows for me and my organization, ranked by what my peers actually use, accessible from any page, and executable in 1–2 clicks.

## Goals (Expected User Outcomes)

### Primary Goals

- **Goal 1:** Reduce time-to-first-meaningful-action for new RHDH users — measured by elapsed time from first login to first template execution, access request, or catalog interaction.
- **Goal 2:** Improve perceived platform value within the first session — measured by user engagement rate with suggested actions and reduction in "what does this do?" support queries.

### Secondary Goals

- Increase adoption of underutilized but high-value workflows by surfacing them to the right users
- Reduce onboarding support burden for platform engineering teams

## Scope

### In Scope

- Lightspeed generates and displays the top 3 outcome-focused use case suggestions based on organizational usage patterns
- Lightspeed integration for ranking suggestions based on organizational usage frequency, user role, and available plugins/templates
- Suggestions are framed as outcomes (e.g., "Create a new service," "Request environment access"), not navigation labels
- Suggestions are scoped broadly enough to apply across teams and roles, but specific enough to map to a single actionable workflow (e.g., "Deploy a new service" not "Use the scaffolder," but also not "Deploy a Node.js 18 Express API with PostgreSQL to cluster-west-2")
- Click-through navigation from each suggestion to the corresponding RHDH workflow (templates, access requests, deployment, catalog registration)
- Admin configuration: ability to customize the suggestions, override AI rankings, hide suggestions, and set defaults for cold-start instances

### Out of Scope

- Custom action creation by end users (users cannot define new action types; they can only interact with system-generated suggestions)
- Cross-instance action recommendations (each RHDH instance is self-contained; no telemetry sharing between instances)
- Replacing existing sidebar navigation (suggestions are additive; all existing navigation remains intact)

## Customer Considerations

### Customer Evidence

"The most common question we get is 'why should we use it?'"
— Platform Engineer, IT Dev Hub

"I just don't think people see the value behind it as much. It's like, 'Oh, we need to onboard here, but what do we get from that? Why are we doing it?'"
— Platform Engineer, IT Dev Hub

"We have a new partner being onboarded right now, but they're fighting it and saying, 'What's the value in this thing? Why do we have to do this?'"
— Account Executive for Australia, Red Hat

"For new users it's not obvious what the next best action is for a specific goal like 'create a service,' 'register a component,' 'request access,' or 'check my deployment health.' The homepage feels like it may be optimized for discovery rather than task completion."
— Engineering Manager, Red Hat

## Acceptance Criteria

### Functional Requirements

**Criteria 1: Suggestion Generation**
Given a user is logged into RHDH and has access to at least one template, catalog, or workflow
When they open Lightspeed or navigate to a page where suggestions are displayed
Then Lightspeed displays exactly 3 outcome-focused suggestions ranked by organizational usage patterns — verified by confirming the suggestions reflect the top workflows by execution frequency within the instance.

**Criteria 2: Outcome-Oriented Framing**
Given Lightspeed has generated suggestions
When the suggestions are rendered to the user
Then each suggestion is phrased as a user outcome (e.g., "Create a new service," "Request environment access," "Register a component") and does not use internal navigation labels, plugin names, or technical identifiers — verified by reviewing suggestion text against a style guide that prohibits labels like "Go to Scaffolder" or "Open catalog-import."

**Criteria 3: Suggestion Scope Calibration**
Given Lightspeed is generating suggestion text
When formulating the action label
Then the suggestion is specific enough to map to a single workflow entry point but broad enough to apply across teams (e.g., "Deploy a new service" is valid; "Use the scaffolder" is too vague; "Deploy a Node.js 18 Express API with PostgreSQL to cluster-west-2" is too narrow) — verified by confirming each suggestion resolves to exactly one target page/workflow.

**Criteria 4: Click-Through Navigation**
Given a user sees a suggested action
When they click on the suggestion
Then they are navigated directly to the corresponding RHDH workflow page (e.g., the specific template form, the access request page, the catalog registration page) in no more than 2 clicks from the suggestion — verified by measuring click depth from suggestion to workflow start.

**Criteria 5: Ranking by Organizational Usage**
Given an RHDH instance has accumulated usage data (plugin usage, template executions)
When Lightspeed generates suggestions for a user
Then suggestions are ranked by organizational usage frequency weighted by the user's role and available plugins/templates — verified by confirming that the top-ranked suggestion corresponds to the most frequently executed workflow for users with a similar role in the organization.

**Criteria 6: Admin Override and Customization**
Given an RHDH administrator accesses the Lightspeed configuration
When they modify suggestion settings
Then the admin can: (a) override AI-generated rankings with manually pinned suggestions, (b) hide specific suggestions from appearing, (c) set default suggestions for cold-start instances with no usage data — verified by applying each configuration change and confirming the user-facing suggestions reflect the admin's settings.

**Criteria 7: Cold-Start Behavior**
Given a new RHDH instance with no organizational usage history
When a user opens Lightspeed for the first time
Then Lightspeed displays admin-configured default suggestions (or sensible platform defaults if no admin configuration exists) rather than showing an empty state or error — verified by deploying a fresh instance and confirming suggestions appear on first user login.

### Error Handling

**Criteria 8: Insufficient Usage Data**
Given the RHDH instance has fewer than the minimum required data points to generate statistically meaningful rankings
When Lightspeed attempts to generate suggestions
Then it falls back to admin-configured defaults or platform-level defaults and does not display stale, irrelevant, or empty suggestions — verified by testing with an instance that has minimal usage history.

**Criteria 9: Unavailable Target Workflow**
Given a suggestion references a workflow that has been disabled, removed, or is inaccessible to the current user
When the suggestion would otherwise be displayed
Then Lightspeed excludes that suggestion and substitutes the next-highest-ranked valid action — verified by disabling a top-ranked template and confirming it does not appear in suggestions.

**Criteria 10: Lightspeed Service Unavailable**
Given the Lightspeed AI ranking service is temporarily unavailable or experiencing errors
When a user navigates to a page where suggestions are displayed
Then the system gracefully degrades by showing cached suggestions or admin-configured defaults rather than an error state — verified by simulating a Lightspeed service outage and confirming the UI remains functional.

### Performance Requirements

- Suggestion generation and display: renders within 2 seconds of page load (perceived latency, not blocking page render)
- Ranking computation: completes within 500ms for instances with up to 10,000 tracked workflow executions
- Suggestions update frequency: rankings refresh at minimum once per 24-hour period (not real-time per request)

### Security & Compliance Requirements

- Suggestions respect RBAC: a user is never shown a suggestion for a workflow they do not have permission to execute
- No personally identifiable information is used in ranking (usage patterns are aggregated at the organizational level, not individual user behavior)
- Admin configuration changes are auditable (logged with user identity and timestamp)
- Usage data used for ranking does not leave the RHDH instance (no external telemetry)

### User Experience Requirements

- Suggestions are visually distinct from navigation — users understand these are personalized recommendations, not static menu items
- Each suggestion includes a brief description (1 line) explaining what the action does, in addition to the outcome-focused title
- Suggestions do not obstruct or delay access to the user's intended workflow if they already know where they're going
- The suggestion UI is consistent across pages where it appears (no layout shifts or style inconsistencies)

### Documentation Requirements

- Admin guide: how to configure default suggestions, override rankings, and hide actions
- End-user guide: what suggested actions are, how they're generated, and how to use them
- API reference: configuration schema for admin overrides and cold-start defaults
- Release notes: feature announcement with screenshots and configuration instructions

### Testing Requirements

- Unit tests: ranking algorithm correctness (given known usage data, verify expected suggestion order)
- Integration tests: end-to-end flow from usage event ingestion → ranking computation → suggestion display → click-through navigation
- RBAC tests: confirm suggestions are filtered by user permissions across all supported roles
- Cold-start tests: verify behavior on fresh instances with zero, partial, and admin-configured usage data
- Performance tests: ranking computation under load (1K, 5K, 10K tracked workflow executions)
- Accessibility tests: suggestions meet WCAG 2.1 AA compliance (keyboard navigable, screen reader compatible)

## Background and Context

### Problem Statement

RHDH users do not discover the platform's most valuable capabilities quickly enough. The current navigation model requires users to know where to look: templates are under "Self Service" and provisioning a cluster environment is under "Cluster Platform". This creates a discoverability gap where users underutilize the platform, leading to lower perceived value and slower adoption.

Adding suggested actions in Lightspeed solves this by inverting the navigation model: instead of requiring users to find capabilities, the platform surfaces the most relevant capabilities to the user, ranked by AI and informed by what their peers actually use.

### Strategic Context

Platform adoption is driven by time-to-value. When users cannot quickly find and execute the platform's highest-value workflows, they question the platform's purpose entirely — as evidenced by customer feedback ("What's the value in this thing? Why do we have to do this?"). AI-powered suggested actions directly address this by making RHDH's value proposition tangible and immediate from the first session.

## Blocked Reason

None
