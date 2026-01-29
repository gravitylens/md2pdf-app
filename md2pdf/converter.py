#!/usr/bin/env python3
"""
Markdown to PDF Report Converter using Typst
Converts markdown files to professionally styled PDF reports.
"""

import argparse
import subprocess
import sys
import csv
from pathlib import Path


def check_command_exists(command):
    """Check if a command exists on the system."""
    try:
        subprocess.run(
            ['which', command],
            capture_output=True,
            check=True
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def parse_header_fields(markdown_file: Path):
    """Parse all key-value pairs from markdown file until --- delimiter."""
    import yaml
    
    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract YAML frontmatter between --- delimiters
    if content.startswith('---\n'):
        parts = content.split('---', 2)
        if len(parts) >= 2:
            yaml_content = parts[1].strip()
            try:
                fields = yaml.safe_load(yaml_content)
                if fields is None:
                    fields = {}
                return fields
            except yaml.YAMLError:
                pass
    
    return {}


def convert_markdown_to_pdf(
    markdown_file: Path,
    output_pdf: Path,
    template_file: Path,
    override_fields: dict = None,
    bibliography: Path = None,
    csl: Path = None
):
    """
    Convert markdown to PDF using Typst.
    
    Args:
        markdown_file: Path to the input markdown file
        output_pdf: Path to the output PDF file
        template_file: Path to the Typst template file
        override_fields: Optional dict to override parsed metadata fields
        csl: Optional path to CSL citation style file (e.g., IEEE, APA, Chicago)
        bibliography: Optional path to BibTeX bibliography file
    """
    
    # Create temporary Typst file
    temp_typst = output_pdf.with_suffix('.typ')
    
    try:
        # Parse header fields from markdown
        fields = parse_header_fields(markdown_file)
        
        # Apply any overrides
        if override_fields:
            fields.update(override_fields)
        
        # Create temporary markdown file without metadata section
        temp_md = output_pdf.with_suffix('.temp.md')
        with open(markdown_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Remove YAML frontmatter (between --- delimiters)
        if content.startswith('---\n'):
            parts = content.split('---', 2)
            if len(parts) >= 3:
                content = parts[2].lstrip()
        
        # Replace {{variable}} placeholders with metadata values
        for key, value in fields.items():
            if isinstance(value, str):
                placeholder = f'{{{{{key}}}}}'
                content = content.replace(placeholder, value)
        
        with open(temp_md, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Convert markdown to Typst using pandoc (using temp file without metadata)
        print(f"Converting {markdown_file.name} to Typst format...")
        pandoc_cmd = ['pandoc', str(temp_md), '-t', 'typst', '-o', str(temp_typst)]
        
        # Add bibliography support if provided
        if bibliography:
            
            # Add CSL style if provided
            if csl:
                pandoc_cmd.extend(['--csl', str(csl)])
            pandoc_cmd.extend(['--citeproc', '--bibliography', str(bibliography)])
        
        result = subprocess.run(
            pandoc_cmd,
            capture_output=True,
            text=True,
            check=True
        )
        
        # Read the converted Typst content
        with open(temp_typst, 'r', encoding='utf-8') as f:
            typst_body = f.read()
        
        # Clean up temp markdown file
        temp_md.unlink()
        
        # Copy template to same directory as temp file for Typst import
        import shutil
        import re
        temp_template = temp_typst.parent / template_file.name
        shutil.copy(template_file, temp_template)
        
        # Detect the function name from the template (e.g., "report", "letter", etc.)
        with open(temp_template, 'r', encoding='utf-8') as f:
            template_content = f.read()
        
        # Look for #let function_name( pattern (including hyphens)
        func_match = re.search(r'#let\s+([\w-]+)\s*\(', template_content)
        if func_match:
            template_func = func_match.group(1)
        else:
            template_func = "report"  # Default fallback
        
        # Build typst parameters from fields
        params = []
        for key, value in fields.items():
            # Skip the template field as it's not a parameter
            if key == 'template':
                continue
                
            # Normalize key to valid Typst identifier (replace spaces/dashes with underscores, lowercase)
            normalized_key = key.replace(' ', '_').replace('-', '_').lower()
            
            # Format value based on type
            if isinstance(value, str):
                # For multiline strings (like abstracts), use bracket notation
                if '\n' in value or len(value) > 100:
                    # Clean up the value but don't escape newlines
                    clean_value = value.strip()
                    params.append(f'  {normalized_key}: [{clean_value}],')
                else:
                    # For short strings, use quoted notation
                    escaped_value = value.replace('\\', '\\\\').replace('"', '\\"')
                    params.append(f'  {normalized_key}: "{escaped_value}",')
            elif isinstance(value, bool):
                params.append(f'  {normalized_key}: {"true" if value else "false"},')
            elif isinstance(value, (int, float)):
                params.append(f'  {normalized_key}: {value},')
            else:
                # Convert other types to string
                escaped_value = str(value).replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
                params.append(f'  {normalized_key}: "{escaped_value}",')
        
        params_str = '\n'.join(params)
        
        # Wrap with template using relative import
        typst_content = f"""#import "{temp_template.name}": *

#show: {template_func}.with(
{params_str}
)

{typst_body}
"""
        
        with open(temp_typst, 'w', encoding='utf-8') as f:
            f.write(typst_content)
        
        # Convert to PDF using Typst
        print(f"Converting to PDF...")
        result = subprocess.run(
            ['typst', 'compile', str(temp_typst), str(output_pdf)],
            capture_output=True,
            text=True,
            check=True
        )
        
        # Clean up temp files
        temp_typst.unlink()
        if temp_template.exists():
            temp_template.unlink()
        
        print(f"✓ Successfully created: {output_pdf}")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"✗ Error during conversion:", file=sys.stderr)
        print(e.stderr, file=sys.stderr)
        if temp_typst.exists():
            print(f"ℹ Temporary file saved for debugging: {temp_typst}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"✗ Error: {e}", file=sys.stderr)
        if temp_typst.exists():
            temp_typst.unlink()
        if 'temp_template' in locals() and temp_template.exists():
            temp_template.unlink()
        if 'temp_md' in locals() and temp_md.exists():
            temp_md.unlink()
        return False


def main():
    parser = argparse.ArgumentParser(
        description='Convert markdown reports to PDF with custom styling'
    )
    parser.add_argument(
        'markdown_file',
        type=str,
        help='Path to the markdown file to convert'
    )
    parser.add_argument(
        '-o', '--output',
        type=str,
        help='Output PDF file path (default: same name as input with .pdf extension)'
    )
    parser.add_argument(
        '-t', '--template',
        type=str,
        required=True,
        help='Path to Typst template file'
    )
    parser.add_argument(
        '-b', '--bibliography',
        type=str,
        help='Path to BibTeX bibliography file (optional, for citations)'
    )
    parser.add_argument(
        '--csl',
        type=str,
        help='Path to CSL citation style file (e.g., ieee.csl, apa.csl). If not specified, pandoc default is used.'
    )
    parser.add_argument(
        '--csv',
        type=str,
        help='Path to CSV file for mail merge. Each row generates a document with CSV columns as metadata.'
    )
    parser.add_argument(
        '--merge-output',
        action='store_true',
        help='When using --csv, merge all output into a single PDF file instead of separate files per row.'
    )
    
    args = parser.parse_args()
    
    # Check if typst is installed
    if not check_command_exists('typst'):
        print("✗ Error: typst is not installed", file=sys.stderr)
        print("\nTo install typst:", file=sys.stderr)
        print("  macOS: brew install typst", file=sys.stderr)
        print("  Linux: cargo install typst-cli", file=sys.stderr)
        print("  Windows: winget install --id Typst.Typst", file=sys.stderr)
        sys.exit(1)
    
    # Check if pandoc is installed
    if not check_command_exists('pandoc'):
        print("✗ Error: pandoc is not installed", file=sys.stderr)
        print("\nTo install pandoc:", file=sys.stderr)
        print("  macOS: brew install pandoc", file=sys.stderr)
        print("  Linux: sudo apt-get install pandoc", file=sys.stderr)
        print("  Windows: choco install pandoc", file=sys.stderr)
        sys.exit(1)
    
    # Resolve paths
    markdown_file = Path(args.markdown_file)
    if not markdown_file.exists():
        print(f"✗ Error: Markdown file not found: {markdown_file}", file=sys.stderr)
        sys.exit(1)
    
    # Determine output path
    if args.output:
        output_pdf = Path(args.output)
    else:
        output_pdf = markdown_file.with_suffix('.pdf')
    
    # Resolve template path
    template_path = Path(args.template).expanduser().resolve()
    
    if not template_path.exists():
        print(f"✗ Error: Template file not found: {template_path}", file=sys.stderr)
        sys.exit(1)
    
    # Resolve bibliography path if provided
    # Resolve bibliography path if provided
    bibliography_path = None
    if args.bibliography:
        bibliography_path = Path(args.bibliography).expanduser().resolve()
        if not bibliography_path.exists():
            print(f"✗ Error: Bibliography file not found: {bibliography_path}", file=sys.stderr)
            sys.exit(1)
    
    # Resolve CSL path if provided
    csl_path = None
    if args.csl:
        csl_path = Path(args.csl).expanduser().resolve()
        if not csl_path.exists():
            print(f"✗ Error: CSL file not found: {csl_path}", file=sys.stderr)
            sys.exit(1)
    
    # Handle CSV mail merge
    if args.csv:
        csv_path = Path(args.csv).expanduser().resolve()
        if not csv_path.exists():
            print(f"✗ Error: CSV file not found: {csv_path}", file=sys.stderr)
            sys.exit(1)
        
        # Read CSV data
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            rows = list(reader)
        
        if not rows:
            print(f"✗ Error: CSV file is empty", file=sys.stderr)
            sys.exit(1)
        
        print(f"Processing {len(rows)} rows from CSV...")
        
        if args.merge_output:
            # Generate all PDFs and merge them
            temp_pdfs = []
            for i, row in enumerate(rows):
                temp_pdf = output_pdf.parent / f"{output_pdf.stem}_temp_{i}.pdf"
                success = convert_markdown_to_pdf(
                    markdown_file,
                    temp_pdf,
                    template_path,
                    override_fields=row,
                    bibliography=bibliography_path,
                    csl=csl_path
                )
                if not success:
                    print(f"✗ Failed to generate document for row {i+1}", file=sys.stderr)
                    sys.exit(1)
                temp_pdfs.append(temp_pdf)
            
            # Merge PDFs using system tools
            print(f"Merging {len(temp_pdfs)} PDFs into {output_pdf}...")
            try:
                # Try using pdfunite (common on Linux)
                result = subprocess.run(
                    ['pdfunite'] + [str(p) for p in temp_pdfs] + [str(output_pdf)],
                    capture_output=True,
                    text=True
                )
                if result.returncode != 0:
                    # Try using pdftk as fallback
                    subprocess.run(
                        ['pdftk'] + [str(p) for p in temp_pdfs] + ['cat', 'output', str(output_pdf)],
                        capture_output=True,
                        text=True,
                        check=True
                    )
            except (subprocess.CalledProcessError, FileNotFoundError):
                # If neither tool works, try Python's PyPDF2
                try:
                    from PyPDF2 import PdfMerger
                    merger = PdfMerger()
                    for pdf in temp_pdfs:
                        merger.append(str(pdf))
                    merger.write(str(output_pdf))
                    merger.close()
                except ImportError:
                    print(f"✗ Error: No PDF merge tool found. Install pdfunite, pdftk, or PyPDF2", file=sys.stderr)
                    print(f"  Temporary PDFs saved as: {output_pdf.stem}_temp_*.pdf", file=sys.stderr)
                    sys.exit(1)
            
            # Clean up temp PDFs
            for pdf in temp_pdfs:
                pdf.unlink()
            
            print(f"✓ Successfully created merged PDF: {output_pdf}")
        else:
            # Generate separate PDF for each row
            output_dir = output_pdf.parent
            base_name = output_pdf.stem
            
            for i, row in enumerate(rows):
                # Create filename based on row data or index
                if 'recipient' in row:
                    safe_name = row['recipient'].replace(' ', '_').replace('/', '_')
                    row_output = output_dir / f"{base_name}_{safe_name}.pdf"
                else:
                    row_output = output_dir / f"{base_name}_{i+1}.pdf"
                
                success = convert_markdown_to_pdf(
                    markdown_file,
                    row_output,
                    template_path,
                    override_fields=row,
                    bibliography=bibliography_path,
                    csl=csl_path
                )
                if not success:
                    print(f"✗ Failed to generate {row_output}", file=sys.stderr)
                else:
                    print(f"✓ Generated: {row_output}")
        
        sys.exit(0)
    
    #       sys.exit(1)
    
    # Resolve CSL path if provided
    csl_path = None
    if args.csl:
        csl_path = Path(args.csl).expanduser().resolve()
        if not csl_path.exists():
            print(f"✗ Error: CSL file not found: {csl_path}", file=sys.stderr)
            sys.exit(1)
    
    # Convert
    success = convert_markdown_to_pdf(
        markdown_file,
        output_pdf,
        template_path,
        bibliography=bibliography_path,
        csl=csl_path
    )
    
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
