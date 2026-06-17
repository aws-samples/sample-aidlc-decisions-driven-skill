# Foundation Specification Template — Team Sections

> Load ONLY when team size > 1. Skip entirely for solo developers.

Add these sections to `foundation.md` when generating for teams.

````markdown
## Team Assignments

| Unit | Owner/Team | Priority | Sequence |
|------|-----------|----------|----------|
| [Unit 1] | [Team/Person] | [High/Med/Low] | [1st - rationale] |
| [Unit 2] | [Team/Person] | [Priority] | [2nd - rationale] |

**Parallel Work**: [Which units can be developed in parallel and why]

---

## Repository Ownership Rules

Add to the Repository Structure section:

- [Shared packages] — [Who reviews, approval process]
- [Unit-specific code] — [Owned by assigned team]
- [Infrastructure] — [Who owns]

---

## API Architecture Ownership

Add to the API Architecture section:

**Ownership**: [Team/person responsible for gateway/BFF]

---

## Sync Schedule

**Small team**: Lighter schedule — weekly integration check, PR-based shared code changes.

**Multiple teams**: Full schedule:
- Weekly integration check
- Per-unit design review
- PR-based shared code changes
- Cross-team sync for shared packages

---

## Risks

- Contract drift → spec as source of truth
- Shared code conflicts → versioning + review process
- Integration delays → define integration milestones upfront
````

## Content Adaptation

**Small team (2-3)**: Include all sections, lighter Sync Schedule.

**Multiple teams (4+)**: Full version with all sections, detailed Sync Schedule and Risks.
