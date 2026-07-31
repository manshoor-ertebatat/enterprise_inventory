const fs = require("fs");
const path = require("path");
const postcss = require("postcss");
const safeParser = require("postcss-safe-parser");

const cssDir = path.join(__dirname, "../app/static/css");

const cssFiles = fs.readdirSync(cssDir)
    .filter(f => f.endsWith(".css"))
    .sort();

const selectors = {};

for (const file of cssFiles) {

    const css = fs.readFileSync(path.join(cssDir, file), "utf8");

    const root = postcss.parse(css, {
        parser: safeParser
    });

    root.walkRules(rule => {

        if (!rule.selector)
            return;

        const parent = rule.parent;

        if (parent && parent.type === "atrule") {

            if (
                parent.name === "keyframes" ||
                parent.name === "font-face"
            )
                return;
        }

        rule.selectors.forEach(sel => {

            sel = sel.trim();

            if (
                sel.startsWith(":root") ||
                sel.startsWith("@")
            )
                return;

            if (!selectors[sel])
                selectors[sel] = {};

            if (!selectors[sel][file])
                selectors[sel][file] = 0;

            selectors[sel][file]++;
        });

    });

}

const duplicated = [];

Object.entries(selectors).forEach(([selector, files]) => {

    const names = Object.keys(files);

    if (names.length > 1) {

        duplicated.push({
            selector,
            files
        });

    }

});

duplicated.sort((a, b) =>
    a.selector.localeCompare(b.selector)
);

console.log("\n===== DUPLICATED SELECTORS =====\n");

duplicated.forEach(item => {

    console.log(item.selector);

    Object.entries(item.files).forEach(([file, count]) => {

        console.log(`   ${file} (${count})`);

    });

    console.log("");

});

console.log("--------------------------------");
console.log("CSS files :", cssFiles.length);
console.log("Duplicates:", duplicated.length);
