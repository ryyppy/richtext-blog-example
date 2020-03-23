import React from "react";

interface Bold {
  type: "bold";
}

interface Italic {
  type: "italic";
}

interface Link {
  type: "link";
  attrs: {
    href: string;
    target: string;
  };
}

interface Text {
  type: "text";
  text: string;
  marks: Mark[] | null;
}

interface Paragraph {
  type: "paragraph";
  content: RichText[];
}

interface Doc {
  type: "doc";
  content: RichText[];
}

interface BulletList {
  type: "bullet_list";
  content: RichText[];
}

interface OrderedList {
  type: "ordered_list";
  content: RichText[];
}

interface ListItem {
  type: "list_item";
  content: RichText[];
}

export type RichText =
  | Doc
  | Text
  | Paragraph
  | BulletList
  | OrderedList
  | ListItem;

export type Mark = Italic | Bold | Link;

interface Default {
  type: "default";
}

interface Ol {
  type: "ol";
  num: number;
}

interface Ul {
  type: "ul";
}

type Context = Default | Ol | Ul;

export const render = (input: {
  ctx?: Context;
  doc: RichText;
}): React.ReactElement => {
  const ctx = input.ctx || { type: "default" };
  const doc = input.doc;

  switch (doc.type) {
    case "paragraph":
    case "doc":
    case "bullet_list":
    case "ordered_list":
    case "list_item":
      let elements = doc.content.map(rt => {
        return render({ ctx, doc: rt });
      });

      switch (doc.type) {
        case "doc":
          return <div className="richtext">{elements}</div>;
        case "paragraph":
          let before;
          switch (ctx.type) {
            case "ol":
              before = <span> {ctx.num}. </span>;
              break;
            case "ul":
              before = <span>• </span>;
              break;
          }
          return (
            <p>
              {before} {elements}{" "}
            </p>
          );
        case "ordered_list":
          elements = doc.content.map((rt, i) => {
            let ctx: Context = { type: "ol", num: i + 1 };
            return render({ ctx, doc: rt });
          });
          return <ol> {elements} </ol>;
        case "bullet_list":
          elements = doc.content.map(rt => {
            return render({ ctx: { type: "ul" }, doc: rt });
          });
          return <ul> {elements} </ul>;
        case "list_item":
          return <li> {elements} </li>;
      }
    case "text":
      let link;
      const className = doc.marks?.reduce((acc, mark) => {
        switch (mark.type) {
          case "bold":
            return acc + " bold";
          case "italic":
            return acc + " italic";
          default:
            return acc;
        }
      }, "");

      const linkMark = doc.marks?.find(m => m.type === "link");

      if (linkMark && linkMark.type === "link") {
        link = linkMark;
      }

      if (link != null) {
        return (
          <a href={link.attrs.href} className={className}>
            {doc.text}
          </a>
        );
      }

      return <span className={className}> {doc.text} </span>;
  }
};
