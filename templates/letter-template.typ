// Professional Business Letter Template for Typst
//
// METADATA FIELDS:
// This template expects the following metadata fields from the markdown frontmatter:
//   - recipient: Recipient's name (e.g., "Jane Smith" or "Hiring Manager")
//   - recipient_title: Recipient's job title (optional, e.g., "Director of Engineering")
//   - recipient_company: Company/organization name (e.g., "Tech Corporation")
//   - recipient_address: Mailing address (optional, e.g., "123 Main St, City, ST 12345")
//   - date: Letter date (e.g., "January 28, 2026")
//   - subject: Subject line (optional, e.g., "RE: Application for Software Engineer Position")
//
// Example markdown frontmatter:
//   recipient:Jane Smith
//   recipient_title:Director of Engineering
//   recipient_company:Tech Corporation
//   date:January 28, 2026
//   subject:RE: Application for Software Engineer Position
//   ---

// Define horizontalrule for pandoc compatibility
#let horizontalrule = line(length: 100%, stroke: 1pt + gray)

#let letter(
  body,
  ..metadata
) = {
  // Extract metadata as dictionary
  let meta = metadata.named()
  
  // Page setup
  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1in),
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
  
  // ==========================================
  // SENDER INFORMATION (EDIT THIS SECTION)
  // ==========================================
  text(size: 11pt)[
    *Your Name*\
    123 Your Street\
    Your City, ST 12345\
    (555) 123-4567\
    jason\@example.com
  ]
  
  v(2em)
  
  // Date
  if "date" in meta {
    text(size: 11pt)[#meta.date]
    v(2em)
  }
  
  // Recipient information
  if meta.len() > 0 {
    text(size: 11pt)[
      #if "recipient" in meta {
        if "recipient_title" in meta {
          [#meta.recipient, #meta.recipient_title]
          linebreak()
        } else {
          [#meta.recipient]
          linebreak()
        }
      }
      #if "recipient_company" in meta {
        [#meta.recipient_company]
        linebreak()
      }
      #if "recipient_address" in meta {
        [#meta.recipient_address]
        linebreak()
      }
    ]
    v(2em)
  }
  
  // Subject line (optional)
  if "subject" in meta {
    text(weight: "bold", size: 11pt)[#meta.subject]
    v(1em)
  }
  
  // Salutation
  if "recipient" in meta {
    if meta.recipient.contains("Manager") or meta.recipient.contains("Committee") or meta.recipient.contains("Team") {
      [Dear #meta.recipient:]
    } else {
      // Extract last name for formal salutation
      let name_parts = meta.recipient.split(" ")
      if name_parts.len() > 1 {
        [Dear #name_parts.last():]
      } else {
        [Dear #meta.recipient:]
      }
    }
  } else {
    [Dear Hiring Manager:]
  }
  
  v(1em)
  
  // Letter body
  body
  
  v(2em)
  
  // Closing
  [Sincerely,]
  
  v(3em)
  
  // Signature line (sender name from hardcoded section)
  [Jason Niles]
}
