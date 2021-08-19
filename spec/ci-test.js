"use strict";

const {dirname, join, resolve} = require("path");
const {existsSync, unlinkSync} = require("fs");
const pkgRoot = resolve(__dirname, "..");

describe("Aquí", () => {
	it("works", () => {
		console.log("YA ESTA");
	});
});

describe("Screenshots", function(){
	this.timeout(15000);
	
	before(async () => {
		await atom.workspace.open(join(pkgRoot, "package.json"));
		await atom.workspace.open(join(pkgRoot, "README.md"));
	});
	
	it("mystifies unreproducible CI failures", () => {
		const saveTo = join(AtomMocha.options.snapshotDir, "screen.png");
		existsSync(saveTo) && unlinkSync(saveTo);
		console.log(`Saving to: ${saveTo}`);
		captureScreen(saveTo);
		expect(saveTo).to.existOnDisk;
	});
	
	it("says hello", async () => {
		const editor = await atom.workspace.open();
		editor.shouldPromptToSave = () => false;
		editor.setText("Hola Mundo");
	});
});

function captureScreen(saveTo){
	if(!(saveTo = String(saveTo)).endsWith(".png"))
		saveTo += ".png";
	const {execFileSync} = require("child_process");
	const {existsSync, mkdirSync} = require("fs");
	const dir = dirname(saveTo);
	existsSync(dir) || mkdirSync(dir, {recursive: true});
	let result;
	switch(process.platform){
		case "darwin":
			result = execFileSync("screencapture", ["-xmt", "png", saveTo], {encoding: "utf8"});
			break;
		case "win32":
			const input = AtomMocha.utils.deindent `
				Set-StrictMode -Version Latest
				$ErrorActionPreference = "Stop"
				Add-Type -AssemblyName System.Windows.Forms
				[void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")
				[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
				[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
				
				[System.Windows.Forms.Screen]::AllScreens
				$rect    = ([System.Windows.Forms.Screen]::PrimaryScreen).bounds
				$bitmap  = New-Object Drawing.Bitmap -argumentList $rect.width, $rect.height
				$context = [Drawing.Graphics]::FromImage($bitmap)
				$context.copyFromScreen($rect.location, [Drawing.Point]::Empty, $rect.size)
				$bitmap.save("${saveTo}")
				$context.dispose()
				$bitmap.dispose()
			`.replace(/\r?\n|\r|\u2028|\u2029/g, "\r\n");
			result = execFileSync("powershell.exe", [
				"-NoLogo",
				"-NoProfile",
				"-NonInteractive",
				"-WindowStyle", "Hidden",
				"-Command", "-",
			], {input, encoding: "utf8", windowsHide: true});
			break;
	}
	console.log(result);
}
