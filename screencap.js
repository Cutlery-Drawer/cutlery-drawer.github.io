#!/usr/bin/env node
"use strict";

const {join} = require("path");
const {existsSync, mkdirSync} = require("fs");
const {execFileSync} = require("child_process");
const {performance} = require("perf_hooks");

let saveTo = join(__dirname, ".atom-mocha");
existsSync(saveTo) || mkdirSync(saveTo, {recursive: true});
saveTo = join(saveTo, "screen.png");

const input = deindent `
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

const started = performance.now();
const result = execFileSync("powershell.exe", [
	"-NoLogo",
	"-NoProfile",
	"-NonInteractive",
	"-WindowStyle", "Hidden",
	"-Command", "-",
], {input, encoding: "utf8", windowsHide: true});
const finished = performance.now();

console.log(result);
console.log(`Total time: ${finished - started} ms`);


function deindent(input, ...args){
	
	// Avoid breaking on String.raw if called as an ordinary function
	if("object" !== typeof input || "object" !== typeof input.raw)
		return deindent `${input}`;
	
	const depthTable = [];
	let maxDepth = Number.NEGATIVE_INFINITY;
	let minDepth = Number.POSITIVE_INFINITY;
	
	// Normalise newlines and strip leading or trailing blank lines
	const chunk = String.raw.call(null, input, ...args)
		.replace(/\r(\n?)/g, "$1")
		.replace(/^(?:[ \t]*\n)+|(?:\n[ \t]*)+$/g, "");

	for(const line of chunk.split(/\n/)){
		// Ignore whitespace-only lines
		if(!/\S/.test(line)) continue;
		
		const indentString = line.match(/^[ \t]*(?=\S|$)/)[0];
		const indentLength = indentString.replace(/\t/g, " ".repeat(8)).length;
		if(indentLength < 1) continue;

		const depthStrings = depthTable[indentLength] || [];
		depthStrings.push(indentString);
		maxDepth = Math.max(maxDepth, indentLength);
		minDepth = Math.min(minDepth, indentLength);
		if(!depthTable[indentLength])
			depthTable[indentLength] = depthStrings;
	}

	if(maxDepth < 1)
		return chunk;
	
	const depthStrings = new Set();
	for(const column of depthTable.slice(0, minDepth + 1)){
		if(!column) continue;
		depthStrings.add(...column);
	}
	depthStrings.delete(undefined);
	const stripPattern = [...depthStrings].reverse().join("|");
	return chunk.replace(new RegExp(`^(?:${stripPattern})`, "gm"), "");
}
