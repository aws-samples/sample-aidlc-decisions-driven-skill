# Action: tasks-edit

Follow the **Edit Action Pattern** from `aidlc/shared/base.md`. Phase-specific details:

- **Validation**: All design components have tasks, all stories covered, dependencies correct, Kiro checkbox format preserved
- **Cascade rule**: Regenerate `## Execution Waves` section if dependencies changed (re-run wave grouping and file ownership)
- **Downstream to mark outdated**: none (tasks is the last spec phase before implementation)
