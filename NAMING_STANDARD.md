# Global Naming Standard

This document defines naming rules for repositories and JS/TS codebases.

## 1) Scope

- Repository names
- JavaScript/TypeScript/TSX file and identifier names

## 2) Repository Name Rules

Required format:

- lowercase letters, numbers, hyphen only
- regex: `^[a-z0-9]+(?:-[a-z0-9]+)*$`

Not allowed:

- spaces
- underscores (`_`)
- URL encoded tokens like `%20`
- mixed/capital letters

Examples:

- `AI Portfolio` -> `ai-portfolio`
- `AutoPMO Pro` -> `auto-pmo-pro`
- `WebUI_Spec_Architect` -> `webui-spec-architect`

## 3) JS/TS Naming Rules

### Files

- General module files: `kebab-case`
- React component files (`.tsx`): `PascalCase` or `kebab-case`

### Exported identifiers

- Functions: `camelCase`
- Variables: `camelCase` or `UPPER_SNAKE_CASE`
- Classes, types, interfaces, enums: `PascalCase`

### Acronyms

Acronyms stay uppercase in identifiers.

- `APIClient`, `URLParser`, `AIModel`, `getAPIResponse`

## 4) Rollout

- Phase A: `NAMING_ENFORCEMENT=warn`
- Phase B: `NAMING_ENFORCEMENT=block`

## 5) Exceptions

Skip generated and vendor outputs:

- `node_modules/`, `dist/`, `build/`, `coverage/`, `.next/`, `vendor/`
- files with `.generated.` / `.gen.` in filename
