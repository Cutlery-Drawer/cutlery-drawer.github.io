"use strict";

const Electron = require("electron");
const {existsSync, mkdirSync, statSync, writeFileSync} = require("fs");
const {dirname, join, isAbsolute, resolve} = require("path");

module.exports = {
	slow: 15000,
	require: ["chai/register-should"],
	snapshotDir: ".atom-mocha",
};
