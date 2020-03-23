import React from "react";
import type { RichText } from "../lib/rich-text";
import { render } from "../lib/rich-text";

const data: RichText = require("../data/storyblok-richtext-data.json");


const Home = () => <div>
    <h1>Rendered Richtext:</h1>
    {render({doc: data})}
</div>;

export default Home;