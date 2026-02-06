# Typst Template Specification for md2pdf

This document defines the specification for creating Typst templates that work with the md2pdf converter.

## Overview

Templates are Typst files (`.typ`) that define document layouts and styling. The md2pdf converter automatically extracts metadata from markdown frontmatter and passes it to your template function.

## Template Structure

### Basic Template Anatomy

```typst
// Optional: Define any helper functions or constants
#let horizontalrule = line(length: 100%, stroke: 0.5pt + gray)

// Main template function - REQUIRED
#let template-name(
  // Define your parameters here
  title: none,
  author: none,
  date: none,
  body  // REQUIRED: must be the last parameter
) = {
  // Set document properties
  set document(title: title, author: author)
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (x: 1.5in, y: 1in),
  )
  
  // Typography and styling
  set text(font: "Arial", size: 11pt)
  set par(justify: true)
  
  // Render title, metadata, etc.
  if title != none {
    align(center)[
      #text(size: 24pt, weight: "bold")[#title]
    ]
  }
  
  // REQUIRED: Render the document body
  body
}
```

## Function Naming

### Automatic Detection

The converter automatically detects your template's main function name using this pattern:

```regex
#let\s+([\w-]+)\s*\(
```

**Valid function names:**
- `report`
- `letter`
- `basic-document`
- `my_template`

**Note:** Hyphens and underscores are allowed in function names.

### Best Practices

- Use descriptive, kebab-case names: `technical-report`, `business-letter`
- Keep names lowercase for consistency
- Avoid spaces or special characters (except hyphen and underscore)

## Parameter Handling

### Frontmatter to Parameters

YAML frontmatter in your markdown is automatically converted to Typst function parameters:

**Markdown:**
```yaml
---
title: "My Document"
author: "John Doe"
date: "2026-01-28"
abstract: |
  This is a multiline
  abstract text.
custom_field: "Custom value"
---
```

**Converted to Typst:**
```typst
#show: template-name.with(
  title: "My Document",
  author: "John Doe",
  date: "2026-01-28",
  abstract: [This is a multiline
  abstract text.],
  custom_field: "Custom value",
)
```

### Parameter Type Conversion

| YAML Type | Typst Output | Example |
|-----------|--------------|---------|
| Short string | Quoted string | `"value"` |
| Long/multiline string | Bracket content | `[value]` |
| Number | Number literal | `42` or `3.14` |
| Boolean | Boolean literal | `true` or `false` |

**Rule:** Strings longer than 100 characters or containing newlines are converted to bracket notation `[...]` for proper Typst content handling.

### Key Normalization

Frontmatter keys are normalized for Typst compatibility:

- Spaces → underscores: `Document Title` → `document_title`
- Hyphens → underscores: `sub-title` → `sub_title`
- Converted to lowercase: `AuthorName` → `authorname`

### Reserved Fields

- `template`: Used to specify which template file to use (skipped in parameters)
- `body`: Reserved for document content (never use as frontmatter key)

## Required Elements

### 1. Main Function

Every template MUST have a main function that:
- Accepts parameters for metadata
- Has `body` as the final parameter
- Calls `body` to render the document content

```typst
#let my-template(
  title: none,
  body  // MUST be last
) = {
  // ... your styling ...
  body  // MUST render the body
}
```

### 2. Default Values

All parameters (except `body`) should have default values, typically `none`:

```typst
#let my-template(
  title: none,        // ✓ Good
  author: none,       // ✓ Good
  required-param,     // ✗ Bad - no default
  body
) = { ... }
```

## Handling Missing Metadata

### Strategy 1: Optional Parameters with Defaults

The recommended approach is to make all metadata optional with sensible defaults:

```typst
#let my-template(
  title: none,
  author: none,
  date: none,
  body
) = {
  // Only render if provided
  if title != none {
    align(center)[#text(24pt, weight: "bold")[#title]]
  }
  
  // Provide fallback values
  let display-author = if author != none { author } else { "Anonymous" }
  let display-date = if date != none { date } else { datetime.today().display() }
  
  text[By #display-author on #display-date]
  
  body
}
```

### Strategy 2: Computed Defaults

Generate defaults dynamically when metadata is missing:

```typst
#let my-template(
  title: none,
  author: none,
  date: none,
  body
) = {
  // Use filename or placeholder if no title
  let effective-title = if title != none { title } else { "Untitled Document" }
  
  // Use current date if not provided
  let effective-date = if date != none { 
    date 
  } else { 
    datetime.today().display("[year]-[month]-[day]")
  }
  
  // Conditional sections
  if author != none {
    text[Author: #author]
  } else {
    // Skip author section entirely or show placeholder
    text(fill: gray)[Author: Not specified]
  }
  
  body
}
```

### Strategy 3: Required vs Optional

Distinguish between required and optional fields:

```typst
#let my-template(
  title: none,      // Required - show error if missing
  author: none,     // Optional
  date: none,       // Optional - auto-generate
  body
) = {
  // Validate required fields
  if title == none {
    // Show error in document
    align(center)[
      #text(fill: red, size: 16pt, weight: "bold")[
        ERROR: Document title is required
      ]
    ]
    return  // Stop processing
  }
  
  // Proceed with valid title
  align(center)[#text(24pt, weight: "bold")[#title]]
  
  // Optional fields
  if author != none {
    align(center)[#text(12pt)[#author]]
  }
  
  body
}
```

### Strategy 4: Validation with Warnings

Provide visual indicators for missing recommended fields:

```typst
#let my-template(
  title: none,
  author: none,
  date: none,
  body
) = {
  // Show warnings for missing fields
  let warnings = ()
  
  if title == none {
    warnings.push("Title is missing")
  }
  if author == none {
    warnings.push("Author is missing")
  }
  
  // Display warnings if any
  if warnings.len() > 0 {
    block(
      fill: yellow.lighten(80%),
      inset: 1em,
      radius: 4pt,
      stroke: 1pt + orange
    )[
      #text(weight: "bold")[⚠ Warnings:]
      #for warning in warnings [
        - #warning
      ]
    ]
  }
  
  // Render with fallbacks
  align(center)[
    #text(24pt, weight: "bold")[
      #if title != none { title } else { "Untitled Document" }
    ]
  ]
  
  body
}
```

### Strategy 5: Template-Specific Defaults

Different templates may have different requirements:

```typst
// Academic paper - requires author and title
#let academic-paper(
  title: none,
  authors: none,
  affiliation: none,
  abstract: none,
  body
) = {
  assert(title != none, message: "Academic papers require a title")
  assert(authors != none, message: "Academic papers require at least one author")
  
  // ... rest of template
}

// Casual document - everything optional
#let casual-doc(
  title: none,
  body
) = {
  if title != none {
    heading(level: 1)[#title]
  }
  body
}
```

### Best Practices for Missing Metadata

1. **Use `none` as default**: Always set parameters to `none` by default
2. **Check before rendering**: Use `if param != none` before displaying
3. **Provide sensible fallbacks**: Use placeholder text or computed values
4. **Document requirements**: Clearly state which fields are required in comments
5. **Fail gracefully**: Show helpful error messages in the PDF rather than crashing
6. **Consider use cases**: Academic papers need different fields than casual notes

### Example: Robust Template

```typst
#let robust-template(
  title: none,
  author: none,
  date: none,
  version: none,
  body
) = {
  // Helper function for safe rendering
  let render-if-present(label, value) = {
    if value != none [
      #text(weight: "bold")[#label:] #value \
    ]
  }
  
  // Title with fallback
  align(center)[
    #text(24pt, weight: "bold")[
      #if title != none { title } else { text(fill: gray)["Untitled"] }
    ]
  ]
  v(1em)
  
  // Metadata table - only show provided fields
  let metadata = (
    ("Author", author),
    ("Date", if date != none { date } else { datetime.today().display() }),
    ("Version", version),
  ).filter(((label, val)) => val != none)
  
  if metadata.len() > 0 {
    align(center)[
      #for (label, value) in metadata [
        #text[#label: #value] \
      ]
    ]
  }
  v(2em)
  
  body
}
```

### Converter Support

The md2pdf converter handles missing metadata gracefully:

- Fields not in frontmatter are simply not passed to the template
- Template receives `none` for all unprovided parameters
- No errors are raised for missing optional fields
- Templates can implement their own validation logic

### 3. Body Rendering

The template MUST render the `body` parameter:

```typst
#let my-template(
  title: none,
  body
) = {
  // ... setup and styling ...
  
  body  // ✓ REQUIRED
}
```

## Content Handling

### Multiline Parameters (like Abstract)

For parameters that contain formatted content, use content blocks:

```typst
#let my-template(
  abstract: none,
  body
) = {
  if abstract != none {
    block(
      inset: 1em,
      fill: gray.lighten(80%)
    )[
      #text(weight: "bold")[Abstract]
      #v(0.5em)
      #abstract  // Renders as Typst content
    ]
  }
  
  body
}
```

**Important:** Use `#` prefix when calling functions inside content blocks `[...]`.

## Styling Patterns

### Page Headers/Footers

```typst
set page(
  header: context {
    if counter(page).get().first() > 1 {
      text(size: 9pt)[#title]
      h(1fr)
      counter(page).display("1")
    }
  },
  footer: context {
    align(center)[
      counter(page).display("1 / 1", both: true)
    ]
  }
)
```

### Conditional Rendering

Always check if optional parameters are provided:

```typst
if title != none {
  // Render title
}

if author != none or date != none {
  // Render author info
}
```

### Headings

```typst
show heading.where(level: 1): it => block(above: 1.8em, below: 1em)[
  #set text(20pt, weight: "bold", fill: navy)
  #it.body
]

show heading.where(level: 2): it => block(above: 1.5em, below: 0.8em)[
  #set text(16pt, weight: "semibold")
  #it.body
]
```

### Code Blocks

```typst
show raw.where(block: true): it => block(
  fill: luma(250),
  inset: 1em,
  radius: 4pt,
  width: 100%
)[
  #set text(font: "Courier New", size: 9pt)
  #it
]

show raw.where(block: false): it => box(
  fill: luma(250),
  inset: (x: 3pt, y: 0pt),
  radius: 2pt
)[
  #set text(font: "Courier New")
  #it
]
```

### Lists

```typst
set list(indent: 1em, marker: [•])
set enum(indent: 1em, numbering: "1.")
```

### Quotes

```typst
show quote: it => block(
  fill: luma(250),
  inset: 1em,
  radius: 4pt,
  stroke: (left: 3pt + blue)
)[
  #set text(style: "italic")
  #it.body
]
```

### Tables

```typst
show table: it => {
  set table(
    stroke: (x, y) => if y == 0 {
      (bottom: 1pt + black)
    } else {
      (bottom: 0.5pt + gray)
    },
  )
  it
}
```

## Font Handling

Use font fallbacks for compatibility:

```typst
set text(
  font: ("SF Pro", "Helvetica Neue", "Arial"),
  size: 11pt
)

// For code
set text(
  font: ("JetBrains Mono", "Menlo", "Courier New"),
  size: 9pt
)
```

## Helper Functions

Define reusable elements at the top of your template:

```typst
#let horizontalrule = line(length: 100%, stroke: 0.5pt + gray)

#let section-divider = v(0.5em) + line(length: 100%) + v(0.5em)

#let info-box(title, content) = block(
  fill: blue.lighten(90%),
  inset: 1em,
  radius: 4pt,
)[
  #text(weight: "bold")[#title]
  #v(0.3em)
  #content
]
```

## Color Schemes

Define colors as variables for consistency:

```typst
#let my-template(...) = {
  let primary = rgb("#2563eb")
  let secondary = rgb("#0f172a")
  let accent = rgb("#06b6d4")
  let text-color = rgb("#1e293b")
  let light-bg = rgb("#f8fafc")
  
  // Use throughout template
  set text(fill: text-color)
  // ...
}
```

## Testing Your Template

### Test with Example Markdown

Create a test markdown file:

```markdown
---
template: your-template
title: "Test Document"
author: "Test Author"
date: "2026-01-28"
abstract: |
  Test abstract with multiple
  lines of text.
---

# Heading 1

Regular paragraph text.

## Heading 2

- List item 1
- List item 2

### Heading 3

> This is a quote

\`\`\`python
def hello():
    print("Hello, World!")
\`\`\`
```

### Convert with md2pdf

```bash
python -m md2pdf test.md -t templates/your-template.typ
```

## Common Patterns

### Academic Paper

```typst
#let academic-paper(
  title: none,
  authors: none,  // Could be array
  affiliation: none,
  abstract: none,
  keywords: none,
  body
) = {
  // Two-column layout
  set page(columns: 2, margin: 1in)
  
  // Single column for title/abstract
  show heading.where(level: 1): it => {
    set page(columns: 1)
    // ... title styling
  }
  
  body
}
```

### Business Letter

```typst
#let business-letter(
  sender: none,
  recipient: none,
  date: none,
  subject: none,
  body
) = {
  set page(margin: 1in)
  
  // Sender address (top right)
  align(right)[#sender]
  v(1em)
  
  // Recipient address (left)
  align(left)[#recipient]
  v(2em)
  
  // Date
  text(weight: "bold")[#date]
  v(1em)
  
  // Subject
  if subject != none {
    text(weight: "bold")[Re: #subject]
    v(1em)
  }
  
  body
}
```

## Debugging Tips

### Keep Temp Files

Modify the converter temporarily to keep `.typ` files:

```python
# Don't delete temp_typst to inspect generated Typst
```

### Check Function Detection

Ensure your function name pattern is detected:

```typst
// ✓ Good - will be detected
#let my-template(

// ✗ Bad - extra characters
#let my-template (  // space before (
```

### Verify Parameter Types

Check generated `.typ` file to see how parameters are passed.

## Example Templates

See existing templates in the `templates/` directory:

- `basic-template.typ` - General-purpose document
- `report-template.typ` - Technical reports
- `letter-template.typ` - Formal letters

## Summary Checklist

- [ ] Function name uses `#let function-name(`
- [ ] All parameters have defaults (except `body`)
- [ ] `body` is the last parameter
- [ ] Template calls `body` to render content
- [ ] Optional parameters checked with `if param != none`
- [ ] Functions in content blocks prefixed with `#`
- [ ] Font fallbacks provided
- [ ] Colors defined as variables
- [ ] Tested with sample markdown

## Resources

- [Typst Documentation](https://typst.app/docs)
- [Typst Tutorial](https://typst.app/docs/tutorial)
- [Typst Function Reference](https://typst.app/docs/reference)
