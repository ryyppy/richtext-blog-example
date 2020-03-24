# Storyblok RichText Rendering Demo

This is a demonstration on how to represent RichText data from a Storyblok CMS instance in TypeScript & ReasonML.

Goal is to discuss major differences in pattern-matching behavior of [Discriminated Union Types](https://www.typescriptlang.org/docs/handbook/advanced-types.html#discriminated-unions), which in TS are represented as objects & interface type definitions, and as [variant types](https://reasonml.org/docs/manual/latest/variant) in ReasonML.

## Running the Code

```
npm install

# build reason code
npm run re:build

npm run dev

# open localhost:3000
```

## Details

The data used for the example is actual data from a Storyblok instance and can be found in [data/storyblok-richtext-data.json](./data/storyblok-richtext-data.json).

It's a tree of nested objects, starting with a root element of `type: "doc"`.

**This example covers following RichText and Mark elements:**
- RichText: `paragraph`, `bullet_list`, `ordered_list`, `list_item`
- Marks: `italic`, `bold`, `link`

**Here's a rough semantic ruleset to describe the data relations:**
- A `doc` element may contain 0 or more `paragraph`, `bullet_list`, `ordered_list`, `text` elements
- A `bullet_list` may contain 0 or more `list_item` elements
- A `list_item` may contain 0 or more `paragraph`, `bullet_list`, `ordered_list` elements
- A `paragraph` may contain 0 or more `text` elements
- A `text` element contains a `text` and may contain null or more `marks`
    - `marks` may contain 0 to 1 each of the following marks: `bold`, `italic`, `link`

The goal is not to encode all relations, since it turned out to be simpler with a more general approach.
It's still useful to have an idea on how the data is structured in Storyblok.
