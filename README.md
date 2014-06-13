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
	
## API Reference

`Client` methods:

- **`init(options, callback)`**
	- `options` should be an object containing a username and a password. { username: 'username', password: 'password' }
	- `callback` will be called when the client instance is ready to use.
- **`getPublicKey() -> Hex A value`**
	- Return the hex representation of the client's A value, suitable for sending over the network.
- **`setSalt(salt)`**
	- `salt` should be the hex string obtained from `Server.getSalt()`, this sets the client's internal salt value for later computations.
- **`setServerPublicKey(serverPublicKey)`**
	- `serverPublicKey` should be the hex representation of the server's B value, as returned from `Server.getPublicKey()`
- **`getSharedKey() -> Hex K value`**
	- The hex representation of the computed secret shared key, suitable for external crypto usage.
- **`getProof() -> Hex M1 value`**
	- Client's M1 value as a hex string, suitable for transmission to the server.
- **`checkServerProof(serverM2Value) -> boolean`**
	- Returns true if `serverM2Value` matches the client's own M2 value computation, false if it doesn't. `serverM2Value` can be obtained from `Server.getProof()`
- **`getSalt() -> Hex salt`**
	- The hex value of the salt generated from `createVerifier()` (see next item), or the salt that was passed via setSalt()
- **`createVerifier(options, callback) -> Hex V value`**
	- `options` should be an object containing a username and password. Ex: { username: 'username', password: 'password' }
	- `callback` will be called once the verifier has been created, with two values, `err`, and `object`, where `object` looks like { verifier: HEX_STRING, salt: HEX_STRING) and is suitable for transmission to the server.
	
`Server` methods:

- (coming soon, just check src/server.coffee for the time being)

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
	