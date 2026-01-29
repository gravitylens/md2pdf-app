// Professional Report Template for Typst
// Customize this file to match your organization's style
//
// METADATA FIELDS:
// This template expects the following metadata fields from the markdown frontmatter:
//   - author: Student name (displayed as "Student: ...")
//   - instructor: Instructor name (displayed as "Instructor: ...")
//   - course: Course name and number (displayed as "Course: ...")
//   - duedate: Assignment due date (displayed as "Due Date: ...")
//
// All fields are optional. The header section will only display fields that are provided.
// Field names in markdown should use lowercase with underscores (e.g., "duedate" not "Due Date")
//
// Example markdown frontmatter:
//   author:John Doe
//   instructor:Dr. Smith
//   course:Computer Science 101
//   duedate:January 28, 2026
//   ---

// Define horizontalrule for pandoc compatibility
#let horizontalrule = line(length: 100%, stroke: 1pt + gray)

#let report(
  body,
  ..metadata
) = {
  // Extract metadata as dictionary
  let meta = metadata.named()
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1in),
    footer: context {
      align(right)[
        #text(size: 10pt)[
          #counter(page).display()
        ]
      ]
    },
  )
  
  // Font and text settings
  set text(
    font: "Helvetica",
    size: 11pt,
    lang: "en",
  )
  
  // Paragraph settings
  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 0em,
  )
  
  set block(spacing: 1.2em)
  
  // Counter for first heading
  let first-heading = state("first-heading", true)
  
  // Heading styles
  show heading.where(level: 1): it => context {
    let is-first = first-heading.get()
    first-heading.update(false)
    
    v(0.5em)
    if is-first {
      align(center)[
        #text(
          size: 18pt,
          weight: "bold",
          fill: rgb("#1f4788"),
          it.body
        )
      ]
    } else {
      text(
        size: 18pt,
        weight: "bold",
        fill: rgb("#1f4788"),
        it.body
      )
    }
    v(0.5em)
  }
  
  show heading.where(level: 2): it => {
    v(0.5em)
    text(
      size: 14pt,
      weight: "bold",
      fill: rgb("#1f4788"),
      it.body
    )
    v(0.3em)
  }
  
  show heading.where(level: 3): it => {
    v(0.4em)
    text(
      size: 12pt,
      weight: "bold",
      style: "italic",
      it.body
    )
    v(0.2em)
  }
  
  // Link styling
  show link: it => {
    text(fill: rgb("#1f4788"), underline(it))
  }
  
  // Code block styling
  show raw.where(block: true): it => {
    set text(size: 9pt)
    block(
      fill: rgb("#f5f5f5"),
      inset: 10pt,
      radius: 3pt,
      width: 100%,
      it
    )
  }
  
  show raw.where(block: false): it => {
    box(
      fill: rgb("#f0f0f0"),
      inset: (x: 3pt, y: 0pt),
      outset: (y: 3pt),
      radius: 2pt,
      it
    )
  }
  
  // Table styling
  set table(
    stroke: (x, y) => if y == 0 {
      (bottom: 1pt + black)
    } else {
      (bottom: 0.5pt + gray)
    }
  )
  
  // Quote/blockquote styling
  show quote: it => {
    set text(style: "italic")
    block(
      inset: (left: 1em, top: 0.5em, bottom: 0.5em),
      stroke: (left: 3pt + rgb("#1f4788")),
      fill: rgb("#f9f9f9"),
      width: 100%,
      it.body
    )
  }
  
  // Academic header on first page
  if meta.len() > 0 {
    set align(left)
    text(size: 9pt)[
      #if "author" in meta {
        [Student: #meta.author]
        linebreak()
      }
      #if "instructor" in meta {
        [Instructor: #meta.instructor]
        linebreak()
      }
      #if "course" in meta {
        [Course: #meta.course]
        linebreak()
      }
      #if "duedate" in meta {
        [Due Date: #meta.duedate]
        linebreak()
      }
    ]
    v(1em)
  }
  
  // Document body
  body
}
