// Modern Document Template
// A contemporary, clean template with modern typography and design

#let horizontalrule = line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0"))

#let basic-document(
  title: none,
  author: none,
  date: none,
  abstract: none,
  body
) = {
  // Set document properties
  set document(title: title, author: author)
  
  // Modern color palette
  let primary = rgb("#2563eb")      // Modern blue
  let secondary = rgb("#0f172a")    // Dark slate
  let accent = rgb("#06b6d4")       // Cyan accent
  let text-color = rgb("#1e293b")   // Slate gray
  let light-bg = rgb("#f8fafc")     // Light background
  let border = rgb("#e2e8f0")       // Border gray
  
  // Page setup with modern margins
  set page(
    paper: "us-letter",
    margin: (x: 1.25in, y: 1in),
    header: context {
      if counter(page).get().first() > 1 {
        set text(9pt, fill: rgb("#94a3b8"))
        text(weight: "regular")[#title]
        h(1fr)
        text(weight: "medium")[#counter(page).display("1")]
      }
    },
  )
  
  // Modern typography with system fonts
  set text(
    font: ("SF Pro", "Helvetica Neue", "Arial"),
    size: 10.5pt,
    lang: "en",
    fill: text-color,
  )
  
  set par(
    justify: true,
    leading: 0.7em,
    spacing: 0.65em,
  )
  
  // Modern heading styles
  show heading.where(level: 1): it => block(above: 1.8em, below: 1em)[
    #set text(26pt, weight: "bold", fill: secondary, font: ("SF Pro", "Helvetica Neue", "Arial"))
    #it.body
  ]
  
  show heading.where(level: 2): it => block(above: 1.5em, below: 0.8em)[
    #set text(16pt, weight: "semibold", fill: secondary, font: ("SF Pro", "Helvetica Neue", "Arial"))
    #it.body
  ]
  
  show heading.where(level: 3): it => block(above: 1.2em, below: 0.7em)[
    #set text(13pt, weight: "semibold", fill: primary, font: ("SF Pro", "Helvetica Neue", "Arial"))
    #it.body
  ]
  
  // Modern links
  show link: it => {
    set text(fill: primary, weight: "medium")
    it
  }
  
  // Lists with modern styling
  set list(
    indent: 1em,
    marker: text(fill: primary, size: 1.2em)[•]
  )
  
  set enum(
    indent: 1em,
    numbering: (n) => text(fill: primary, weight: "semibold")[#n.]
  )
  
  // Modern quote blocks
  show quote: it => {
    block(
      fill: light-bg,
      inset: (left: 1.2em, right: 1em, top: 1em, bottom: 1em),
      radius: 6pt,
      stroke: (left: 3pt + primary),
      width: 100%,
    )[
      #set text(style: "italic", size: 10pt, fill: rgb("#475569"))
      #it.body
    ]
  }
  
  // Modern code blocks
  show raw.where(block: true): it => block(
    fill: rgb("#0f172a"),
    inset: (x: 1.2em, y: 1em),
    radius: 6pt,
    width: 100%,
  )[
    #set text(font: ("Menlo", "Monaco", "Courier New"), size: 9pt, fill: rgb("#e2e8f0"))
    #it
  ]
  
  show raw.where(block: false): it => box(
    fill: light-bg,
    inset: (x: 4pt, y: 2pt),
    outset: (y: 3pt),
    radius: 3pt,
  )[
    #set text(font: ("Menlo", "Monaco", "Courier New"), size: 9pt, fill: primary, weight: "medium")
    #it
  ]
  
  // Modern table styling
  show table: it => {
    set table(
      stroke: (x, y) => if y == 0 {
        (bottom: 1.5pt + primary)
      } else {
        (bottom: 0.5pt + border)
      },
      fill: (x, y) => if y == 0 {
        light-bg
      },
    )
    it
  }
  
  // Modern title block
  if title != none {
    v(1em)
    align(center)[
      #block(
        width: 100%,
        inset: (bottom: 1em),
      )[
        #text(
          32pt,
          weight: "bold",
          fill: secondary,
          font: ("SF Pro", "Helvetica Neue", "Arial"),
          tracking: -0.02em,
        )[#title]
      ]
    ]
  }
  
  // Modern author and date
  if author != none or date != none {
    align(center)[
      #block(below: 2em)[
        #if author != none {
          text(
            11pt,
            weight: "medium",
            fill: text-color,
            font: ("SF Pro", "Helvetica Neue", "Arial"),
          )[#author]
        }
        #if author != none and date != none {
          linebreak()
          v(0.3em)
        }
        #if date != none {
          text(
            10pt,
            fill: rgb("#64748b"),
            font: ("SF Pro", "Helvetica Neue", "Arial"),
          )[#date]
        }
      ]
    ]
  }
  
  // Modern abstract
  if abstract != none {
    v(0.5em)
    align(center)[
      #block(
        width: 85%,
        inset: (x: 1.8em, top: 1.3em, bottom: 1.5em),
        fill: light-bg,
        radius: 8pt,
        stroke: 1pt + border,
      )[
        #align(left)[
          #text(
            12pt,
            weight: "bold",
            fill: secondary,
            font: ("SF Pro", "Helvetica Neue", "Arial"),
          )[Abstract]
          #v(0.8em)
          #set text(10pt, fill: rgb("#475569"))
          #set par(leading: 0.75em, justify: true)
          #abstract
        ]
      ]
    ]
    v(2em)
  }
  
  // Main content
  body
}
