import fs from "mz/fs";
import path from "path";
import pify from "pify";
import ghauth from "ghauth";
import GithubAPI from "github";

const github = new GithubAPI({});

import { createPromptModule, Separator } from "inquirer";
const prompt = createPromptModule();

export default Github;

async function Github(options) {
    options = options || {};
    if (options.disabled && options.disabled.includes("github")) return options;

    let answers = await prompt([
        {
            message: "Setup Github repository?",
            type: "confirm",
            name: "confirm",
            default: true
        }
    ]);
    if (!answers.confirm) {
        return options;
    }

    // Login to Github
    let { user, token } = await pify(ghauth)({
        configName: "create-node-module",
        // @see https://www.npmjs.com/package/travis-ci-access-token
        scopes: ["public_repo", "repo", "read:org", "user:email", "repo_deployment", "repo:status", "write:repo_hook"],
        note: "create-node-module"
    });

    // Get (or confirm default) repository details
    answers = await prompt([
        {
            message: "repository owner:",
            type: "input",
            name: "githubOwner",
            default: options.githubOwner || user
        },
        {
            message: "repository name:",
            type: "input",
            name: "githubRepo",
            default: options.githubRepo || path.basename(process.cwd())
        },
        {
            message: "description:",
            type: "input",
            name: "githubDescription",
            default: options.githubDescription || options.description
        }
    ]);
    Object.assign(options, answers);

    // Check that repo doesn't already exist.
    try {
        await pify(github.repos.get)({ owner: options.githubOwner, repo: options.githubRepo });
        options.githubRepoExists = true;
    } catch (e) {
        if (e.code === 404) {
            options.githubRepoExists = false;
        } else {
            console.log(e);
            process.exit(-1);
        }
    }

    github.authenticate({ type: "oauth", token });
    if (options.githubRepoExists) {
        // Update description
        await pify(github.repos.edit)({
            owner: options.githubOwner,
            name: options.githubRepo,
            repo: options.githubRepo,
            description: options.githubDescription
        });
    } else {
        // Create user repo
        if (user === options.githubOwner) {
            await pify(github.repos.create)({
                owner: options.githubOwner,
                name: options.githubRepo,
                description: options.githubDescription
            });
            // or organization repo
        } else {
            await pify(github.repos.createForOrg)({
                org: options.githubOwner,
                name: options.githubRepo,
                description: options.githubDescription
            });
        }
    }
    return options;
}

if (!module.parent) {
    Github();
}
