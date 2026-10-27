# Codebase map: {{UNIT_ID}}

**Updated**: {{DATE}}  
**Next module**: {{MODULE or "not started"}}

Reload this file before scanning. Do not rescan a module whose Mapped cell is `yes`.

## Entry points

| Kind | Location | Notes |
|------|----------|-------|
{{ENTRY_ROWS}}

## Modules

| Module | Role | Mapped | On planned path | Hotspot | Notes |
|--------|------|--------|-----------------|---------|-------|
{{MODULE_ROWS}}

## Hotspots

{{how judged: command and window, or "Not started."}}

| Path | Churn signal | Size signal | Why it matters |
|------|--------------|-------------|----------------|
{{HOTSPOT_ROWS}}

## Dead-code candidates

A row without production evidence stays a candidate. Do not delete it.

| Path | Static signal | Production evidence | Decision |
|------|---------------|---------------------|----------|
{{DEAD_ROWS}}

## Dependencies

{{internal edges and external services worth not rediscovering, or "None recorded yet."}}

## Unknowns

List question ids only. The question text lives in [open-questions.md](open-questions.md).

| Question | Pattern |
|----------|---------|
{{UNKNOWN_ROWS}}

## Encodings

{{ISO-8859-1, UTF-8, or "None recorded yet."}}
