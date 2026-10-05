@AGENTS.md

# Models and delegation
Default setup for cost and quality: Opus plans, decides, reviews and coordinates; Sonnet implements; the advisor (Fable) helps with hard calls.

## When delegating (main session or an agent coordinating a large task)
- Plan yourself and consult the advisor on hard-to-reverse choices. For large work with truly different possible approaches, you may spawn fresh planning agents (`model: opus`), in parallel if useful. Built-in Plan agents don't see this file, so put requirements and constraints in the brief.
- Pick the model by task type: well-specified implementation → `model: sonnet` (much cheaper and strong at clear tasks); large tasks that need judgment, investigation or coordination → `model: opus`. Do work that takes only a handful of tool calls yourself.
- Forks inherit the whole conversation and your model. Fork only when the task needs that context and the conversation is still short. Otherwise spawn fresh with a self-contained brief: goal, files, constraints, relevant ADRs, done criteria.
- Review worker diffs yourself rather than spawning agents to re-verify routine work.
- At milestones (a plan for large or hard-to-reverse work, cleanup after a batch of features or before a release), consider an adversarial review: a fresh subagent that sees only the plan or diff plus the requirements, Opus for plans and Sonnet for diffs. Ask it for bugs, requirement gaps and structural problems. Reviewers always find something, so fix what's real and drop nitpicks.

## When working for another agent
- Use the advisor when stuck.
- If your task splits into substantial, independent parts, delegate them; the rules above apply. Nest as deep as the task's structure warrants, as long as each level owns a coherent part rather than just passing work along.
- Settle minor ambiguities yourself and list them. Return early only when a choice would change the design.
- Your parent sees only your final message: report what you did, what you decided and what's open, concisely.
