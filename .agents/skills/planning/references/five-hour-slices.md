# Five-hour slices

## Budget

Treat five hours as active agent time:

- 30 minutes: verify baseline, prerequisites, ownership, and acceptance evidence;
- 3 hours: implement one outcome;
- 1 hour: run focused validation and repair defects within scope;
- 30 minutes: reconcile evidence, prune completed work, and write the handoff.

At four hours, start no new behavior. Use the reserve to reach a safe, reviewable checkpoint and report any unfinished work accurately.

## Phase test

A phase is small enough only when it has:

- one independently useful outcome;
- no unresolved product or architecture decision;
- an exact file write set or specifically named external systems;
- at most one primary integration lock;
- focused validation that can normally complete within the window;
- a result that can merge or be externally verified without a later phase making it coherent.

Split by provider, command, platform, data transformation, public interface, or validation matrix row when a proposed phase crosses these boundaries. Put broad workspace validation in its own final integration phase when focused validation already makes each implementation phase safe.

## Blocking and repair

External approvals, host availability, CI queues, downloads, and human review are prerequisites and do not consume the phase budget while waiting. A blocked phase names the missing evidence and performs no speculative implementation.

If validation reveals an unexpected defect, finish the current phase only when its stated outcome still passes. Otherwise keep it open and create a new repair phase with a fresh budget, write set, and validation. Never hide overrun by broadening the original outcome.
