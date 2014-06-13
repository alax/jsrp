## Synopsis

JSRP is a pure JavaScript implementation of SRP-6A, the Secure Remote Password protocol, as defined in [RFC 2945](http://tools.ietf.org/html/rfc2945). It can be used in Node.js or the browser via Browserify.

## Installation

To use JSRP in the browser, first add the script:

	<script type="text/javascript" src="jsrp-browser.js"></script>
	
To use JSRP in Node, simply run:

	npm install jsrp
	
## Usage

#### Browser
	
JSRP will be available from the `jsrp` global.
	
#### Node

Just require the module:

	var jsrp = require('jsrp');
	
## Example

The example will run in Node or the browser, JSRP is completely compatible with both.

	var client = new jsrp.client(4096);
	var server = new jsrp.server(4096);
	
	client.init({ username: 'username', password: 'password123' }, function() {
		// Client instance is ready to be used here.
	});
	
	server.init({ salt: LONG_HEX_VALUE, verifier: EVEN_LONGER_HEX_VALUE }, function () {
		// Server instance is ready to be used here.
	});

	cPubKey = client.getPublicKey();
	server.setClientPublicKey(cPubKey);

	salt = server.getSalt();
	client.setSalt(salt);

	sPubKey = server.getPublicKey();
	client.setServerPublicKey(sPubKey);

	client.getSharedKey() === server.getSharedKey() // will be true

## Testing

First, install the dependencies:

	npm install
	
Also, you will need Mocha and CoffeeScript if you don't have them already:

	npm install -g mocha coffee-script
	
Then simply run:
	
	npm test

## Browser Builds

To build JSRP for the browser, you will need Browserify and CoffeeScript:

	npm install -g browserify coffee-script
	
Then run the following commands inside the JSRP directory:

	coffee --compile --output lib src
	browserify jsrp.js --standalone jsrp > jsrp-browser.js
	