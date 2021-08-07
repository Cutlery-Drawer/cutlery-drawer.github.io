"use strict";

const Electron = require("electron");
const {existsSync, mkdirSync, statSync, writeFileSync} = require("fs");
const {dirname, join, isAbsolute, resolve} = require("path");

/**
 * Raise an exception if the Atom workspace isn't attached to the DOM.
 * @return {void}
 * @private
 */
function assertAttached(){
	if(document.body.contains(atom.workspace.getElement())) return;
	const error = new Error(`Workspace element not attached to DOM`);
	error.details = "Use `attachToDOM(atom.workspace.getElement());` to fix";
	console.error(`${error.message}. ${error.details}`);
	throw error;
}

/**
 * Prepare a destination for writing snapshot files to.
 *
 * @example resolveSnapshotPath("/tmp") == "/tmp/atom-712-1628352650081";
 * @example resolveSnapshotPath("/tmp/existing-file") == "/tmp/existing-file.1";
 * @param {String} input
 * @return {String}
 * @private
 */
function resolveSnapshotPath(input){
	if(!isAbsolute(input))
		input = resolve(__dirname, input);
	if(existsSync(input)){
		if(statSync(input).isDirectory())
			input = join(input, `atom-${process.pid}-${Date.now()}`);
		let count = 1;
		const originalPath = input;
		while(existsSync(input + ".html") || existsSync(input + ".png"))
			input = `${originalPath}.${count++}`;
		return input;
	}
	const dir = dirname(input);
	existsSync(dir) || mkdirSync(dir, {recursive: true});
	return input;
}

/**
 * Record a screenshot of the current workspace and save the current DOM state.
 *
 * @example snapshot(".atom-mocha/snapshot") == {
 *    img: ".atom-mocha/snapshot.png",
 *    dom: ".atom-mocha/snapshot.html",
 * };
 * @param {String} to - Location to save the screenshot and HTML files to, sans extension
 * @param {"png"|"jpg"|"pdf"} [format="png"] - Screenshot format
 * @param {Number} [jpgQuality=75] - JPEG quality (0–100)
 * @return {Promise<{{dom: String, img: String}}>}
 * @private
 */
async function snapshot(to, format = "png", jpgQuality = 75){
	assertAttached();
	to = resolveSnapshotPath(to);
	format = String(format).toLowerCase().replace(/^\.|(?<=^\.?jp)e(?=g$)/g, "");
	jpgQuality = Math.max(0, Math.min(100, ~~jpgQuality || 0));
	const paths = {img: to + "." + format, dom: to + ".html"};
	
	// Save current DOM state
	writeFileSync(paths.dom, document.documentElement.outerHTML);
	
	// Hide our reporter, if visible
	const mocha = document.getElementById("mocha");
	if(mocha)
		mocha.style.display = "none";
	
	// Save screenshot
	let image;
	const page = Electron.remote.getCurrentWebContents();
	if("pdf" === format){
		const width  = Math.ceil(CSS.px(window.innerWidth  * 1000).to("mm").value);
		const height = Math.ceil(CSS.px(window.innerHeight * 1000).to("mm").value);
		image = await page.printToPDF({
			marginsType: 1,
			printBackground: true,
			pageSize: {width, height},
		});
	}
	else{
		const capture = await page.capturePage();
		image = "jpg" === format
			? capture.toJPEG(jpgQuality)
			: capture.toPNG();
	}
	
	// Show our reporter again
	if(mocha){
		mocha.style.display = null;
		mocha.getAttribute("style") || mocha.removeAttribute("style");
	}
	writeFileSync(paths.img, image, {encoding: null});
	return paths;
}


module.exports = {
	slow: 15000,
	require: ["chai/register-should"],
	snapshotDir: ".atom-mocha",
	
	beforeStart(){
		// if(!AtomMocha.headless) return;
		
		if(this.snapshotDir){
			const now = new Date().toISOString().replace(/:/g, "-");
			const dir = join(resolve(__dirname, this.snapshotDir), now);
			const fmt = this.snapshotFormat || "png";
			
			let errors = 0;
			const {run} = Mocha.Runnable.prototype;
			Mocha.Runnable.prototype.run = function(fn){
				return run.call(this, (...args) => {
					const [error] = args;
					if(error instanceof Error)
						snapshot(join(dir, String(++errors)), fmt).then(paths => {
							const jsonPath = paths.dom.replace(/\.html?$/i, "") + ".json";
							const jsonData = {
								test: this.titlePath(),
								file: this.file,
								error: error.stack || error.toString(),
								snapshot: paths,
							};
							writeFileSync(jsonPath, JSON.stringify(jsonData, null, "\t"));
							return fn.apply(this, args);
						});
					else return fn.apply(this, args);
				});
			};
		}
	},
	
	afterStart(){
		if(this.snapshotDir)
			attachToDOM(atom.workspace.getElement());
	},
};
