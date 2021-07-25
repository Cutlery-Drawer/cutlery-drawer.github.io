"use strict";

describe("Aquí", () => {
	it("works", () => {
		console.log({os: process.platform});
		if(/win/i.test(process.platform))
			throw new Error("Puto, que chingados fue eso?");
		console.log("YA ESTA");
	});
});
