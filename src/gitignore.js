"use strict";
import fs from "fs";
import { createPromptModule, Separator } from "inquirer";
import gitignore from "gitignore";
import pify from "pify";
const prompt = createPromptModule();

export default GitIgnore;

async function GitIgnore() {
    let choices = await pify(gitignore.getTypes)();

    let questions = [
        { type: "confirm", name: "confirm", message: "Add .gitignore?", default: true },
        {
            when: ans => ans.confirm,
            type: "list",
            name: "type",
            message: ".gitignore template",
            choices,
            default: choices.indexOf("Node"),
            paginated: true
        }
    ];

    let answers = await prompt(questions);
    if (answers.confirm) {
        let out = fs.createWriteStream(".gitignore");
        await pify(gitignore.writeFile)({ type: answers.type, writable: out });
        console.log("answers =", answers);
    }
    return;
}

if (!module.parent) {
    GitIgnore();
}
