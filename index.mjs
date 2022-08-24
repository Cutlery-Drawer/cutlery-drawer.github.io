#!/usr/bin/env node

function printMacOS(casing){
	console.log("I am running " + casing);
}

function printWindows(){
	console.log("I am running Windows, SEND HELP");
}

function printLinux(guess){
	console.log("I am running some flavour of Linux.");
	if(null !== guess)
		console.log(guess);
}

function printPlatform(){
	if("darwin" === process.platform)
		printMacOS("macOS");
	else if("win32" === process.platform)
		printWindows();
	else if("linux" )
		printLinix("Probably Ubuntu");
}

printPlatform();
