module Text: {
  type t = {text: string}
}

type t

type case =
  | Doc(array<t>)
  | Text(Text.t)
  | Paragraph(array<t>)
  | Unknown(t)

let classify: t => case
