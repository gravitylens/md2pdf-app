# md2pdf

Convert markdown files to professionally styled PDF reports using Typst.

## Features

- Simple command-line interface
- Dynamic metadata parsing from markdown frontmatter
- Professional academic formatting with multiple templates
- BibTeX bibliography and citation support
- CSL (Citation Style Language) support for multiple citation formats
- CSV mail merge for batch document generation
- Variable substitution with `{{field_name}}` syntax
- Support for tables, images, code blocks, and more
- Cross-platform (macOS, Linux, Windows)

## Installation

### Prerequisites

md2pdf requires two external tools:

```bash
# macOS
brew install typst pandoc

# Linux (Debian/Ubuntu)
sudo apt-get install pandoc
cargo install typst-cli

# Windows
winget install Typst.Typst
choco install pandoc
```

### Install md2pdf

#### Option 1: Install from source (recommended for now)

```bash
cd md2pdf-app
pip install -e .
```

#### Option 2: System-wide installation

```bash
cd md2pdf-app
pip install .
```

#### Option 3: Build a distributable package

```bash
cd md2pdf-app
python -m build
# Installs from the wheel
pip install dist/md2pdf-1.0.0-py3-none-any.whl
```

## Usage

### Basic Usage

```bash
# Convert a markdown file to PDF
md2pdf report.md -t templates/report-template.typ

# Generate a letter
md2pdf cover-letter.md -t templates/letter-template.typ

# With bibliography (BibTeX)
md2pdf report.md -t templates/report-template.typ --bibliography references.bib

# With specific citation style (APA, IEEE, Chicago, etc.)
md2pdf report.md -t templates/report-template.typ --bibliography references.bib --csl apa.csl

# CSV mail merge (batch generation)
md2pdf letter-template.md -t templates/letter-template.typ --csv recipients.csv

# CSV mail merge with merged output
md2pdf letter-template.md -t templates/letter-template.typ --csv recipients.csv --merge-output merged.pdf
```

Creates `report.pdf` in the same directory.

### Markdown Format

Start your markdown file with metadata fields (frontmatter) followed by `---`:

```markdown
author: Sarah Martinez
instructor: Dr. Robert Chen
course: Data Science Fundamentals (CS-450)
date: January 28, 2026
---

# Report Title

Your content here...
```

All fields before the `---` delimiter are dynamically parsed and made available to the template. You can use any field names your template supports.

### Variable Substitution

Use `{{field_name}}` syntax in your markdown body to reference metadata fields:

```markdown
recipient: Jane Smith
recipient_company: Tech Corporation
---

Dear {{recipient}},

I am writing to express my interest in working at {{recipient_company}}...
```

### Citations and Bibliography

#### Using BibTeX Citations

Create a `.bib` file with your references:

```bibtex
@article{smith2024,
  author = {Smith, John},
  title = {Advanced Data Analysis},
  journal = {Journal of Data Science},
  year = {2024}
}
```

Reference in markdown using `[@citation_key]`:

```markdown
Recent studies have shown significant improvements [@smith2024].
```

Use with the `--bibliography` flag:

```bash
md2pdf report.md -t templates/report-template.typ --bibliography references.bib
```

#### Citation Styles (CSL)

Use different citation formats with CSL files:

```bash
# IEEE style
md2pdf report.md -t templates/report-template.typ --bibliography refs.bib --csl ieee.csl

# APA style
md2pdf report.md -t templates/report-template.typ --bibliography refs.bib --csl apa.csl

# Chicago style
md2pdf report.md -t templates/report-template.typ --bibliography refs.bib --csl chicago.csl
```

CSL files can be downloaded from the [Citation Style Language repository](https://github.com/citation-style-language/styles).

### Command Options

```bash
# Custom output location
md2pdf report.md -t templates/report-template.typ -o output/final.pdf

# With bibliography and citations
md2pdf report.md -t templates/report-template.typ --bibliography references.bib --csl ieee.csl

# CSV mail merge - generates separate PDFs
md2pdf letter-template.md -t templates/letter-template.typ --csv recipients.csv

# CSV mail merge - generates merged single PDF
md2pdf letter-template.md -t templates/letter-template.typ --csv recipients.csv --merge-output all-letters.pdf
```

### Command Line Options

- `markdown_file` - Path to the markdown file to convert (required)
- `-t, --template` - Path to Typst template file (required)
- `-o, --output` - Output PDF file path (defaults to same name with .pdf)
- `--bibliography` - Path to BibTeX (.bib) file for citations
- `--csl` - Path to CSL file for citation formatting (requires --bibliography)
- `--csv` - Path to CSV file for mail merge batch generation
- `--merge-output` - Output path for merged PDF (requires --csv, uses PyPDF2/pdfunite/pdftk)

## Creating Custom Templates

Templates are located in the `templates/` directory:
- `report-template.typ` - Academic report formatting
- `letter-template.typ` - Business letter formatting

To create custom templates:

1. Copy an existing template:
   ```bash
   cp templates/report-template.typ my-template.typ
   ```

2. Edit `my-template.typ` to customize:
   - Fonts and colors
   - Heading styles
   - Page layout and margins
   - Header and footer formatting
   - Metadata field handling

3. Templates receive metadata as a dictionary:
   ```typst
   #let report(body, ..metadata) = {
     let meta = metadata.named()
     
     // Access any metadata field
     if "author" in meta {
       text[Author: #meta.author]
     }
     
     // Process body content
     body
   }
   ```

4. Use your custom template:
   ```bash
   md2pdf report.md -t my-template.typ
   ```

See the [Typst documentation](https://typst.app/docs) for template syntax.

## Supported Markdown Features

- Headings (# through ######)
- Bold (**text**) and italic (*text*)
- Lists (ordered and unordered)
- Code blocks with syntax highlighting
- Tables
- Links
- Images (local files only)
- Blockquotes
- Horizontal rules

## Examples

See the `examples/` directory for complete working examples.

### Academic Report with Citations

```markdown
author: Sarah Martinez
instructor: Dr. Robert Chen
course: Data Science Fundamentals (CS-450)
date: January 28, 2026
---

# Data Analysis Project Report

## Introduction

Recent advances in machine learning have revolutionized data analysis [@chen2025fundamentals]. 
Customer segmentation techniques have proven particularly effective [@smith2024segmentation].

## Methodology

We applied clustering algorithms to identify distinct customer groups...
```

Generate with:
```bash
md2pdf examples/sample-report.md -t templates/report-template.typ \
  --bibliography examples/references.bib --csl examples/ieee.csl
```

### Business Letter

```markdown
recipient: Jane Smith
recipient_title: Director of Engineering
recipient_company: Tech Corporation
date: January 28, 2026
subject: RE: Application for Software Engineer Position
---

I am writing to express my strong interest in the Software Engineer position at Tech Corporation...
```

Generate with:
```bash
md2pdf examples/cover-letter.md -t templates/letter-template.typ
```

### Mail Merge (Batch Letters)

Create a CSV file (`recipients.csv`):
```csv
recipient,recipient_title,recipient_company,date
John Doe,Chief Technology Officer,Tech Innovations Inc,January 28 2026
Jane Smith,Director of Engineering,Software Solutions LLC,January 28 2026
Robert Johnson,Hiring Manager,Digital Systems Corp,January 28 2026
```

Create a letter template with variables:
```markdown
recipient: {{recipient}}
recipient_title: {{recipient_title}}
recipient_company: {{recipient_company}}
date: {{date}}
subject: RE: Application for Software Engineer Position
---

Dear {{recipient}},

I am writing to express my interest in joining {{recipient_company}}...
```

Generate separate PDFs:
```bash
md2pdf examples/letter-template.md -t templates/letter-template.typ --csv examples/recipients.csv
```

Or generate one merged PDF:
```bash
md2pdf examples/letter-template.md -t templates/letter-template.typ \
  --csv examples/recipients.csv --merge-output all-letters.pdf
```

## Troubleshooting

### "typst is not installed"
Install Typst: `brew install typst` (macOS) or see [Typst installation](https://github.com/typst/typst#installation)

### "pandoc is not installed"
Install pandoc: `brew install pandoc` (macOS) or see [Pandoc installation](https://pandoc.org/installing.html)

### Citations not working
- Ensure your `.bib` file is valid BibTeX format
- Use `[@citation_key]` syntax in markdown
- Provide both `--bibliography` and optionally `--csl` flags
- Check that citation keys in markdown match those in the .bib file

### Mail merge not generating files
- Ensure CSV has a header row with field names
- Field names in CSV must match `{{field_name}}` placeholders in markdown
- For merged output, ensure PyPDF2, pdfunite, or pdftk is available

### Images not appearing
- Ensure image paths are relative to the markdown file
- Use local files only (URLs are not supported)
- Supported formats: PNG, JPEG, GIF, SVG

### Template not found
- Always provide the `-t` flag with template path
- Use absolute paths or paths relative to current directory
- Built-in templates are in the `templates/` directory

## Development

### Building from Source

```bash
git clone https://github.com/jasonniles/md2pdf.git
cd md2pdf
pip install -e .
```

### Creating a Distribution

```bash
python -m build
twine upload dist/*
```

## License

MIT License - See LICENSE file for details

## Changelog

### Version 1.0.0 (2026-01-28)
- Initial release
- Academic report and business letter templates
- Dynamic metadata parsing from frontmatter
- Variable substitution with `{{field_name}}` syntax
- BibTeX bibliography support
- CSL citation style support (IEEE, APA, Chicago, etc.)
- CSV mail merge for batch document generation
- PDF merging support for mail merge output
- Automatic template function detection
- Cross-platform support
