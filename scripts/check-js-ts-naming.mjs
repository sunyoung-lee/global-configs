#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const root = process.argv[2] ? path.resolve(process.argv[2]) : process.cwd();
const mode = (process.env.NAMING_ENFORCEMENT || "block").toLowerCase();

const skipDirs = new Set([
  ".git",
  "node_modules",
  "dist",
  "build",
  "coverage",
  ".next",
  ".cache",
  "vendor",
  "out",
  "target",
  ".turbo"
]);

const codeExt = new Set([".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs"]);

const isKebabCase = (value) => /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value);
const isCamelCase = (value) => /^[a-z][A-Za-z0-9]*$/.test(value);
const isUpperSnakeCase = (value) => /^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$/.test(value);
const isPascalCaseWithAcronyms = (value) => /^(?:[A-Z]+[a-z0-9]*)+$/.test(value);

function listFiles(dir, acc = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (skipDirs.has(entry.name)) {
        continue;
      }
      listFiles(full, acc);
      continue;
    }

    if (!entry.isFile()) {
      continue;
    }

    const ext = path.extname(entry.name);
    if (!codeExt.has(ext)) {
      continue;
    }

    if (entry.name.includes(".generated.") || entry.name.includes(".gen.")) {
      continue;
    }

    acc.push(full);
  }

  return acc;
}

function lineForIndex(source, index) {
  return source.slice(0, index).split("\n").length;
}

function validateFileName(filePath, violations) {
  const ext = path.extname(filePath);
  const base = path.basename(filePath, ext);
  const mainName = base.split(".")[0];

  if (mainName === "index") {
    return;
  }

  const tsxPascalAllowed = ext === ".tsx";
  const valid = isKebabCase(mainName) || (tsxPascalAllowed && isPascalCaseWithAcronyms(mainName));

  if (!valid) {
    violations.push({
      file: filePath,
      line: 1,
      rule: "file-name",
      message: `expected kebab-case${tsxPascalAllowed ? " or PascalCase" : ""}, got '${mainName}'`
    });
  }
}

function validateExports(filePath, source, violations) {
  const checks = [
    {
      rule: "export-function",
      regex: /\bexport\s+(?:default\s+)?(?:async\s+)?function\s+([A-Za-z_][A-Za-z0-9_]*)/g,
      valid: isCamelCase,
      expected: "camelCase"
    },
    {
      rule: "export-variable",
      regex: /\bexport\s+(?:const|let|var)\s+([A-Za-z_][A-Za-z0-9_]*)/g,
      valid: (name) => isCamelCase(name) || isUpperSnakeCase(name),
      expected: "camelCase or UPPER_SNAKE_CASE"
    },
    {
      rule: "export-class",
      regex: /\bexport\s+(?:default\s+)?class\s+([A-Za-z_][A-Za-z0-9_]*)/g,
      valid: isPascalCaseWithAcronyms,
      expected: "PascalCase"
    },
    {
      rule: "export-interface",
      regex: /\bexport\s+interface\s+([A-Za-z_][A-Za-z0-9_]*)/g,
      valid: isPascalCaseWithAcronyms,
      expected: "PascalCase"
    },
    {
      rule: "export-type",
      regex: /\bexport\s+type\s+([A-Za-z_][A-Za-z0-9_]*)/g,
      valid: isPascalCaseWithAcronyms,
      expected: "PascalCase"
    },
    {
      rule: "export-enum",
      regex: /\bexport\s+enum\s+([A-Za-z_][A-Za-z0-9_]*)/g,
      valid: isPascalCaseWithAcronyms,
      expected: "PascalCase"
    }
  ];

  for (const check of checks) {
    for (const match of source.matchAll(check.regex)) {
      const name = match[1];
      if (check.valid(name)) {
        continue;
      }

      violations.push({
        file: filePath,
        line: lineForIndex(source, match.index ?? 0),
        rule: check.rule,
        message: `expected ${check.expected}, got '${name}'`
      });
    }
  }
}

const violations = [];
const files = listFiles(root);

for (const filePath of files) {
  validateFileName(filePath, violations);

  const source = fs.readFileSync(filePath, "utf8");
  validateExports(filePath, source, violations);
}

if (violations.length === 0) {
  console.log(`PASS: naming validation passed (${files.length} files scanned)`);
  process.exit(0);
}

for (const v of violations) {
  const rel = path.relative(root, v.file) || v.file;
  console.log(`${rel}:${v.line} [${v.rule}] ${v.message}`);
}

const summary = `Found ${violations.length} naming violation(s) in ${files.length} files`;
if (mode === "warn") {
  console.log(`WARN: ${summary}`);
  process.exit(0);
}

console.error(`FAIL: ${summary}`);
process.exit(1);
