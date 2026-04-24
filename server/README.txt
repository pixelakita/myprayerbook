Bible CLI

Commands
1) Generate references and immediately download passages month-by-month:
   node getreferences.js --year 2026 --apiKey YOUR_OPENROUTER_KEY --overwrite-passages

2) Generate references only:
   node getreferences.js --year 2026 --apiKey YOUR_OPENROUTER_KEY --references-only

3) Download passages from existing reference files:
   node getpassages.js --year 2026 --overwrite

Saved files
- References: <project root>/data/<year>/references.json
- Passages:   <project root>/data/<year>/gospels.json

Important
- The connected pipeline now downloads passages after each month finishes.
  Example: once January references are written, January entries are merged into gospels.json before February starts.
- This means if you stop the run mid-year, earlier months can already be present inside gospels.json.
- Use --overwrite-passages if you want matching dates inside gospels.json replaced.
- Reference generation now merges all dates for the year into one array file: references.json.
- getpassages.js remains backward-compatible with older per-day reference files if they already exist.

Default passage translation
- Passage downloads now default to bible-api translation 'web' for better coverage/completeness.
- You can still override it with --translation dra (or another supported bible-api translation).


Reference conversion
- Passage lookup now converts Jerusalem-Bible-style numbering to WEB/WEBC numbering at query time.
- Default mode: --reference-versification jb-to-webc
- Default Psalm handling: --psalm-mode jb_counts_superscription_as_v1
- Disable conversion with: --reference-versification none
