let s = React.string
let ate = React.array

module Mark = {
  type t

  module Link = {
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

  let getType: t => string = %raw(`
    function(value) {
      if(typeof value === "object" && value.type != null) {
        return value.type;
      }
      return "unknown";
    }
  `)

  let classify = (v: t): case =>
    switch v->getType {
    | "italic" => Italic
    | "bold" => Bold
    | "link" => Link(v->Obj.magic)
    | "unknown"
    | _ =>
      Unknown(v)
    }
}

module Text = {
  type t = {
    text: string,
    marks: option<array<Mark.t>>,
  }
}

type t

type case =
  | Doc(array<t>)
  | Text(Text.t)
  | Paragraph(array<t>)
  | BulletList(array<t>)
  | OrderedList(array<t>)
  | ListItem(array<t>)
  | Unknown(t)

let getType: t => string = %raw(`
    function(value) {
      if(typeof value === "object" && value.type != null) {
        return value.type;
      }
      return "unknown";
    }
  `)

let getContent: t => array<t> = %raw(`
    function(value) {
      if(typeof value === "object" && value.content != null) {
        return value.content;
      }
      return [];
    }
  `)

let classify = (v: t): case =>
  switch v->getType {
  | "doc" => Doc(v->getContent)
  | "bullet_list" => BulletList(v->getContent)
  | "ordered_list" => OrderedList(v->getContent)
  | "list_item" => ListItem(v->getContent)
  | "text" => Text(v->Obj.magic)
  | "paragraph" => Paragraph(v->getContent)
  | "unknown"
  | _ =>
    Unknown(v)
  }

type listType =
  | Ol
  | Ul

type context =
  | Default
  | Ol({num: int})
  | Ul

let rec render = (~context=Default, ~key: option<string>=?, doc: t): React.element => {
  let case = doc->classify
  switch case {
  | Doc(content)
  | Paragraph(content)
  | OrderedList(content)
  | BulletList(content)
  | ListItem(content) =>
    let elements =
      Belt.Array.mapWithIndex(content, (i, rt) =>
        render(~key=Belt.Int.toString(i), ~context, rt)
      )->ate

    switch case {
    | Doc(_) => <div className="richtext"> elements </div>
    | Paragraph(_) =>
      let before = switch context {
      | Ul => <span> {j`• `->s} </span>
      | Ol({num}) => <span> {(num->Belt.Int.toString ++ ". ")->s} </span>
      | _ => React.null
      }
      <p ?key> before elements </p>
    | BulletList(_) =>
      let elements =
        Belt.Array.mapWithIndex(content, (i, rt) =>
          render(~key=Belt.Int.toString(i), ~context=Ul, rt)
        )->ate
      <ul ?key> elements </ul>
    | OrderedList(content) =>
      let elements = Belt.Array.mapWithIndex(content, (i, rt) => {
        let context = Ol({num: i + 1})
        render(~key=Belt.Int.toString(i), ~context, rt)
      })->ate
      <ol ?key> elements </ol>
    | ListItem(_) => <li ?key> elements </li>
    | _ => elements
    }
  | Text(text) =>
    let setting = switch text.marks {
    | None => (None, None)
    | Some(marks) =>
      open! Mark

      let className = Belt.Array.reduce(marks, "", (acc, mark) =>
        switch mark->classify {
        | Italic => acc ++ " italic"
        | Bold => acc ++ " bold"
        | _ => acc
        }
      )->Some

      let linkOpt = Js.Array2.find(marks, m =>
        switch m->classify {
        | Link(_) => true
        | _ => false
        }
      )->Belt.Option.flatMap(m =>
        switch m->classify {
        | Link(link) => Some(link)
        | _ => None
        }
      )
      (className, linkOpt)
    }

    switch setting {
    | (className, Some(link)) =>
      <a ?key href=link.attrs.href target=link.attrs.target ?className> {text.text->s} </a>
    | (className, None) => <span ?key ?className> {text.text->s} </span>
    }
  | _ => React.null
  }
}
