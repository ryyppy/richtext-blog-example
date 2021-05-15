// We simulate some JS object coming into our system
// ready to be parsed
let input: RichText.t = %raw(`
  {
    type: "doc",
    content: [
      {
        type: "paragraph",
        content: [{type: "text", "text": "text 1"}]
      },
      {
        type: "paragraph",
        content: [{type: "text", "text": "text 2"}]
      }
    ]
  }
`)

let rec printTexts = (input: RichText.t) =>
  switch RichText.classify(input) {
  | Doc(content)
  | Paragraph(content) =>
    Belt.Array.forEach(content, printTexts)
  | Text({text}) => Js.log(text)
  | Unknown(value) => Js.log2("Unknown value found: ", value)
  }

printTexts(input)

switch RichText.classify(input) {
| Doc([]) => Js.log("This document is empty")
| Doc(content) => Belt.Array.forEach(content, printTexts)
| Text({text: "text 1"}) => Js.log("We blantly ignore 'text 1'")
| Text({text}) => Js.log("Text we accept: " ++ text)
| _ => () /* "Do nothing" */
}
