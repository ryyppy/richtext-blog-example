import React from "react";
import type { RichText } from "../lib/rich-text";
import { render } from "../lib/rich-text";

import { render as reasonRender } from "../lib/RichText.gen";
import type { t as ReasonRichText } from "../lib/RichText.gen";
 
const renderTS = () => {
    const data: RichText = require("../data/storyblok-richtext-data.json");
    return render({doc: data})
}

const renderRE = () => {
    const data: ReasonRichText = require("../data/storyblok-richtext-data.json");
    return reasonRender({context: "Default"}, data);
};

const Home = () => <div>
    <div>
        <h2>Rendered RichText (TS):</h2>
        {renderTS()}
    </div>
    <div>
        <h2> Rendered RichText (Reason):</h2>
        {renderRE()}
    </div>
</div>;

export default Home;