---
type: workflow
domain: roblox
status: active
owner: mixed
source: codex
created: 2026-07-11
updated: 2026-08-12
---

# 单把魔法杖运行模板

## STRUCTURE_AND_DEPTH_LOCK.md

```markdown
# [Asset Name] - Structure and Depth Lock

## Identity
- Category: medium Roblox RPG magic wand, not staff or weapon.
- Approved design baseline: `front.png`.
- Total displayed height: 100%.
- Maximum front width: about [x%] of total height.

## Vertical Proportions
- Top main element and holder: [x%].
- Upper metal collar: [x%].
- Shaft: [x%].
- Lower collar and tail: [x%].

## Fixed Components
- 1 [main top element].
- Exactly [count] [holder parts].
- [count] [metal collars / bands and positions].
- 1 [shaft].
- 1 [tail].

## Material and Color Lock
- Main element: [color + material].
- Holder: [color + material].
- Metal: [color + material].
- Shaft: [color + material].
- Tail: [color + material].

## Depth Contract
- Shaft front width: [W]; expected side depth: [Dmin-Dmax]; geometry: [round / oval / flat].
- Gem front width: [W]; expected side depth: [Dmin-Dmax]; geometry: [thick crystal / sphere / convex body].
- Holder front width: [W]; expected side envelope: [Dmin-Dmax].
- Tail front width: [W]; expected side depth: [Dmin-Dmax].

## Side Visibility Contracts

### left.png
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:

### right.png
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:

### left45.png
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:

### right45.png
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:

## Contract Confirmation
- Codex restatement:
- User confirmation:
- Confirmation date:

## Mirror Authorization
- Default: not authorized.
- Source file:
- Target file:
- Exact user authorization:
- Authorization date:
```

## RUN_NOTES.md

```markdown
# [Asset Name] - Run Notes

## Baseline
- Approved source: `front.png`.
- User approval date:

## Accepted Views
- `front.png`:
- `left45.png`:
- `left.png`:
- `right.png`:
- `right45.png`:
- `back.png`:

## Quality Gates
- Full object visible in every view: pass / fail.
- Same total height and uniform scale: pass / fail.
- Component count and vertical anchors: pass / fail.
- Four side visibility contracts confirmed before generation: pass / fail.
- Must-visible / hidden structures, counts, positions, and occlusion: pass / fail.
- Side camera at 90 degrees: pass / fail.
- Shaft, gem, holder, collars, and tail retain volume: pass / fail.
- Final folder contains exactly six images: pass / fail.

## Rejected Candidates
- [file]: [failure tag and reason].

## Deliberate Exclusion
- No `top.png` or `bottom.png` unless reliable 3D evidence exists.

## Generation Mode
- Built-in image generation / approved fallback.
- Mirrored files and explicit authorization:
- Contract failure tags (`SIDE_VISIBILITY_CONTRACT_MISSING` / `SIDE_VISIBILITY_CONTRACT_BROKEN` / `UNCONFIRMED_SIDE_MIRROR`):
```
