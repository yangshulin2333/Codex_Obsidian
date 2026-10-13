"""Packaged render_docx PNG pipeline with a native Word-compatible PDF adapter.

Windows workspace dependencies do not include LibreOffice. This adapter exports
read-only documents through the installed Word-compatible WPS COM server, then
uses the packaged renderer and bundled Poppler. No source document is saved.
"""
import importlib.util
import os
from pathlib import Path
import subprocess
import sys

SKILL = Path('C:/Users/long001/.codex/plugins/cache/openai-primary-runtime/documents/26.1011.11113/skills/documents')
POPPLER = Path('C:/Users/long001/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/poppler/Library/bin')
EXPORT = Path(__file__).with_name('export_docx_pdf.ps1')
spec = importlib.util.spec_from_file_location('packaged_render_docx', SKILL / 'render_docx.py')
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)
os.environ['PATH'] = str(POPPLER) + os.pathsep + os.environ.get('PATH','')

def convert_to_pdf(doc_path, user_profile, convert_tmp_dir, stem, verbose):
    pdf_path = str(Path(convert_tmp_dir) / (stem + '.pdf'))
    args = ['C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(EXPORT), '-InputPath', str(Path(doc_path).resolve()), '-OutputPath', pdf_path]
    result = subprocess.run(args, capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
    log = f'Native Word-compatible WPS PDF export exit={result.returncode}\n{result.stdout}\n{result.stderr}'
    if result.returncode != 0 or not Path(pdf_path).is_file():
        return '', log
    if verbose:
        print(log)
    return pdf_path, log

renderer.convert_to_pdf = convert_to_pdf
renderer.main()
