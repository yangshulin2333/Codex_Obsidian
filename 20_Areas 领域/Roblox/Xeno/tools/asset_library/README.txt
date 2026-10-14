Asset-library workflow entry

python organize_assets.py --archive ARCHIVE_ROOT --output LIBRARY_ROOT --lune-executable LUNE_PATH
Use --resume only with verified prior results and the original evidence directory.
Use --no-zip to stop at a directory library. Evidence stays outside raw and library.

Additional stages: extract_scene_models.py, verify_scene_models.py, finalize_asset_library.py,
verify_asset_library.py and package_asset_library.py. Inspect each --help.
All paths are explicit CLI inputs; configuration templates document local roles.
Python standard library and a compatible Lune decoder are used. Archived game scripts
are never executed or converted to Luau. Raw bytes remain unchanged.

Classified download library tools

Requirements: Python 3.11+; optional Lune supporting @lune/roblox. Standard Python
library only. No network, account credentials, unrelated cache scanning, archived
script require, decompilation or game-code execution is performed.

Portable extraction command:
  python classify_downloaded_assets.py --archive ARCHIVE_ROOT --output LIBRARY_ROOT --lune-executable LUNE_PATH --evidence-dir EVIDENCE_DIRECTORY

--archive and --output are required. --lune-executable is optional. Without Lune,
raw Roblox containers are preserved in other/downloaded-containers as unclassified;
the tool does not infer their contents from their asset IDs or filenames. Default
--evidence-dir is a sibling LIBRARY_ROOT-download-evidence directory. Use a new
library output/index and evidence directory for each run. Existing identical raw
copies are hash checked; conflicting destination bytes are never overwritten.

Read-only actual-package preflight (no --output is required):
  python classify_downloaded_assets.py --archive EXTRACTED_PACKAGE_ROOT --check-inputs-only --evidence-dir EVIDENCE_DIRECTORY
Verifies every bound manifest/inventory and every successful source file. It creates
only the evidence report: no library output directory, content copies or Lune call.
Controlled hash-anchored manifest/inventory references first resolve at their exact
archive-relative path, then, if absent, at validation/<same relative path>. Basename
searching and unrelated roots are never used. Each chosen file must match its hash.

To preserve the exact real command, PID, stdout, stderr and exit:
  python run_observed.py --archive ARCHIVE_ROOT --output LIBRARY_ROOT --lune-executable LUNE_PATH --evidence-dir EVIDENCE_DIRECTORY

Required input: archive download-validation.json (or validation/download-validation.json
for a relocated extracted raw package) with integrity_and_scope_passed
true, its manifest_reports (relative path + SHA256), source inventories identified
by each manifest's summary, canonical files and effective_requests. Recorded input
paths relocate relative to the original canonical root, so the archive can move.
Every bound manifest/inventory and every physical successful source file is checked
against its recorded SHA256/size. Exactly one copied file per unique content SHA256
is retained; all successful content is copied, including fonts/JSON/unknown data.

Output categories (paths relative to the library root):
  textures/                 recognized PNG/JPEG/DDS bytes
  models/meshes/             raw Roblox mesh bytes, observed version header only
  audio/                    recognized OGG/MP3 bytes
  animations/downloaded/    offline deserialized keyframe/curve animation payloads
  other/fonts/              font bytes, including historical suffix/header mismatch
  other/json/               JSON metadata, retained as data
  other/downloaded-containers/ unknown/model/rig/mixed Roblox containers
  other/unclassified/       remaining raw content
This tool does not own assembled scene models, extracted rigs or scene animations.

download-index.json schemaVersion 1:
  source: captureIdentity {placeId,universeId,canonicalSha256}, canonicalPath/hash,
          verifiedSourceMetadata manifest/inventory relative paths and hashes
  summary: uniqueDownloadedContents, copiedBytes, categoryCounts, subtypeCounts,
           extensionCounts, containerClassCounts, finalRequestCount/statuses,
           finalHttpFailures, source/copy hash and immutable metadata check flags
  files[]: relativePath, filename, category, subtype, tags[], referencePaths[],
           assetIDs[], requestKeys[], sha256, bytes, extension, copiedFileSha256,
           sourceProofs[], references[], usageEvidence[], formatEvidence,
           containerClassification, copyVerification
  sourceProofs[]: manifestPath/hash, inventoryPath/hash, key/status, inventoryIndices,
                  parentKeys, sourceFile (archive relative), sourceSha256/sourceBytes
  requests[]: key, assetID, final status, httpStatus, URI/error, content sha256,
              references, parentKeys and all recorded history (including old failures)
  rejectedReferences[]: original unsupported references and bound manifest hash
  classifierExecution[]: timestamps/exit/tool/input/report hashes, no local raw root

Usage tags are based on explicit class/property references. SurfaceAppearance maps
record their PBR channel; UI images, ParticleEmitter/Beam/Trail textures and sound/
animation references retain their literal observed property and inventory evidence.
Music-by-path is explicitly a candidate, not an audio analysis result. One content
used by multiple IDs/properties retains all tags and evidence without extra copies.

classify_containers.luau imports only Lune builtin fs/process/serde/roblox modules.
It deserializes model data into an offline DOM, counts root/descendant classes and
reads keyframe timing/loop/priority/pose names. It never imports or executes archived
Script, LocalScript or ModuleScript instances. All failures stay unclassified.
Mesh skeleton/bone streams are not decoded; no rig availability promise is made.

Evidence directory includes command-execution.json, exact stdout/stderr logs,
VERIFICATION.txt, container input/report and download-library-verification.json.
After writing download-index.json, the tool independently reopens the index and
rechecks every destination size/hash before returning successful completion.

Portable verification after moving the library:
  python verify_downloaded_library.py --library LIBRARY_ROOT --report REPORT_JSON
Optionally add --archive ARCHIVE_ROOT to recheck every source manifest/inventory
and successful physical source file. Destination paths and source proofs stay
relative, and only this tool's owned categories are scanned for unindexed content.

