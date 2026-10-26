# Complexity Examples

Use these as calibration when assigning complexity. Prefer splitting when in doubt.

## XS
- Add a single validation rule to an existing function
- Rename a constant or update a config value
- Fix a typo in an error message

## S
- Add a new API endpoint that reuses existing service methods
- Write unit tests for one function
- Add a simple UI field that binds to an existing model

## M
- Implement a vertical slice: schema + service + endpoint + basic test for one operation
- Add rate limiting to one route including config and tests
- Convert one form component to use a new validation library

## L
- Multi-step workflow that touches several modules and requires design decisions
- Migration of an authentication method that affects middleware and tests
- Feature that needs new data model + business rules + several endpoints

## XL (must be split)
- Entire feature from scratch across frontend and backend
- Large refactor of multiple unrelated areas
- Anything that would require the agent to hold the whole codebase in context
