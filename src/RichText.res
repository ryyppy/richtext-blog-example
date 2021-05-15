module Text = {
  type t = {text: string}
}

type t

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

type case =
  | Doc(array<t>)
  | Text(Text.t)
  | Paragraph(array<t>)
  | Unknown(t)

let classify = (v: t): case =>
  switch v->getType {
  | "doc" => Doc(v->getContent)
  | "text" => Text(v->Obj.magic)
  | "paragraph" => Paragraph(v->getContent)
  | "unknown"
  | _ =>
    Unknown(v)
  }
