# Failure Log

created_at: 2026-06-23
weapon: 翡翠黑铁翼刃长剑

## SIDE_VIEW_NOT_90_DEGREE

### Symptom

The first side-view candidate was narrow, but the guard/charm area still looked like a partial 3/4 or non-perpendicular view instead of a strict vertical engineering side projection.

### Cause

The earlier prompt allowed too much side-visible guard/charm structure. The visual gate accepted "narrow side profile" as sufficient, but for Tripo modeling this must be stricter: the side view must be an exact 90-degree orthographic projection where front-facing guard, gem, rune, and blade surfaces collapse into edge thickness only.

### Fix

- Rejected `left_candidate_01`.
- Rejected `right_from_left_candidate_01`.
- Generated `left_candidate_02_strict_90` with explicit CAD/model-sheet camera wording.
- Mirrored `left_candidate_02_strict_90` to produce the new right view.
- Regenerated `emerald_blackiron_wing_sword_contact_sheet.png`.

### Workflow Rule Updated

The local workflow and Codex skill now treat non-perpendicular side views as hard failures:

```text
SIDE_VIEW_NOT_90_DEGREE
SIDE_VIEW_NOT_VERTICAL
```

Side views must be true orthographic 90-degree projections, not merely narrow-looking 3/4 views.
