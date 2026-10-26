# Check-to-Test Mapping Examples

Use these patterns when translating a Check from a strict acceptance criterion into a concrete test entry.

## Form / UI

**AC Check**: error text is present in the response or DOM; accounts store has no new row for this email

**Suggested test**:
- Name: `rejects_invalid_email_and_creates_no_account`
- Type: integration (or e2e if the project uses browser tests)
- Assertion: DOM contains "Enter a valid email" AND store has no row for the submitted email

## API

**AC Check**: response JSON field total_after_discount == 90

**Suggested test**:
- Name: `applies_welcome10_promo_and_returns_discounted_total`
- Type: integration
- Assertion: status === 200 && body.total_after_discount === 90

## CLI / Command

**AC Check**: exit code is 0 and stdout contains "ok"

**Suggested test**:
- Name: `command_succeeds_and_prints_ok`
- Type: integration
- Assertion: process.exitCode === 0 && stdout.includes("ok")

## Rules

- Prefer one test per Check.
- Encode the AC or Check reference in the test name or a comment.
- Only add extra tests when the original Check is ambiguous; mark them `*(supplemented)*`.
- Do not invent assertions that are not supported by the Check.
