"use strict";

const {join, resolve} = require("path");
const pkgRoot = resolve(__dirname, "..");

describe("Aquí", () => {
	it("works", () => {
		console.log("YA ESTA");
	});
});

describe("Screenshots", () => {
	before(async () => {
		await atom.workspace.open(join(pkgRoot, "package.json"));
		await atom.workspace.open(join(pkgRoot, "README.md"));
	});
	
	it("takes a selfie", async () => {
		throw new Error("I hate selfies");
	});
	
	it("says hello", async () => {
		const editor = await atom.workspace.open();
		editor.shouldPromptToSave = () => false;
		editor.setText("Hola Mundo");
	});
});
