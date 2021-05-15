module Mark: {
  type t

  module Link: {
    type attrs = {
      href: string,
      target: string,
    }
    type t = {attrs: attrs}
  }

  type case =
    | Link(Link.t)
    | Italic
    | Bold
    | Unknown(t)

  let getType: t => string

  let classify: t => case
}

module Text: {
  type t = {
    text: string,
    marks: option<array<Mark.t>>,
  }
}

@genType
type t

type case =
  | Doc(array<t>)
  | Text(Text.t)
  | Paragraph(array<t>)
  | BulletList(array<t>)
  | OrderedList(array<t>)
  | ListItem(array<t>)
  | Unknown(t)

type listType =
  | Ol
  | Ul

@genType
type context =
  | Default
  | Ol({num: int})
  | Ul

let classify: t => case

@genType
let render: (~context: context=?, ~key: string=?, t) => React.element
