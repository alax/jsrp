## Synopsis

JSRP is a pure JavaScript implementation of SRP-6A, the Secure Remote Password protocol, as defined in [RFC 2945](http://tools.ietf.org/html/rfc2945). It can be used in Node.js or the browser via Browserify. It uses SHA-256 by default for hashing, although it will support any of Node's hashing functions. It currently supports 2048 and 4096 bit parameters.

## Motivation

JSRP was written to make SRP simple to implement and work with from the browser and on the server. All high-level functions return hex strings that are easy to pass between server and client, as well as save. No need to waste time serializing and unserializing objects just to transmit them over the network.

## Installation

To use JSRP in the browser, first add the script:

```html
<script type="text/javascript" src="jsrp-browser.js"></script>
```
	
To use JSRP in Node, simply run:

	npm install jsrp
	
## Usage

#### Browser
	
JSRP will be available from the `jsrp` global.
	
#### Node

Just require the module:

```javascript
var jsrp = require('jsrp');
```
	
## Example

The example will run in Node or the browser, JSRP is completely compatible with both.

**Example Registration Process:**

```javascript
var client = new jsrp.client();
	
client.init({ username: 'testUser', password: 'password123' }, function () {
	client.createVerifier(function(err, result) {
		// result will contain the necessary values the server needs to
		// authenticate this user in the future.
		sendSaltToServer(result.salt);
		sendVerifierToServer(result.verifier);
	});
});
```

**Example Login Process:** (normally client and server wouldn't be in the same code, but the example is this way for the sake of brevity)

```javascript
var client = new jsrp.client();
var server = new jsrp.server();
	
client.init({ username: 'username', password: 'password123' }, function() {
	// Client instance is ready to be used here.
});
	
server.init({ salt: 'LONG_HEX_VALUE', verifier: 'EVEN_LONGER_HEX_VALUE' }, function () {
	// Server instance is ready to be used here.
});
	
// Remember, both client and server must have called their
// init() callback before you can continue using them. The
// following functions would normally be called inside that
// callback.

cPubKey = client.getPublicKey();
server.setClientPublicKey(cPubKey);

salt = server.getSalt();
client.setSalt(salt);

sPubKey = server.getPublicKey();
client.setServerPublicKey(sPubKey);

client.getSharedKey() === server.getSharedKey() // will be true
```
	
## API Reference

`Client` methods:

- **`init(options, callback)`**
	- `options` should be an object containing a username and a password. `{ username: 'username', password: 'password' }`. You may also pass a length property, which will allow you to select  the size of your parameters. It defaults to 4096.
	- `callback` will be called when the client instance is ready to use.
- **`getPublicKey() -> Hex A value`**
	- Return the hex representation of the client's ***A*** value, suitable for sending over the network.
- **`setSalt(salt)`**
	- `salt` should be the hex string obtained from `Server.getSalt()`, this sets the client's internal salt value for later computations.
- **`setServerPublicKey(serverPublicKey)`**
	- `serverPublicKey` should be the hex representation of the server's ***B*** value, as returned from `Server.getPublicKey()`. When this function is called, provided the publicKey is valid, the client instance will compute the rest of the values needed internally to complete authentication. *This will throw an error if the server provides an incorrect value, authentication MUST be aborted here.*
- **`getSharedKey() -> Hex K value`**
	- The hex representation of the computed secret shared key, suitable for external crypto usage.
- **`getProof() -> Hex M1 value`**
	- Client's ***M1*** value as a hex string, suitable for transmission to the server.
- **`checkServerProof(serverProof) -> Boolean`**
	- Returns true if `serverProof` matches the client's own proof computation, false if it doesn't. `serverProof` can be obtained from `Server.getProof()`. *This can only be called after `getProof()`*.
- **`getSalt() -> Hex salt`**
	- The hex value of the salt generated from `createVerifier()` (see next item), or the salt that was passed via setSalt()
- **`createVerifier(callback) -> Hex V value`**
	- Generate ***v*** and ***salt*** from the values passed to `init()`
	- `callback` will be called once the verifier has been created, with two values, `err`, and `object`, where `object` looks like `{ verifier: HEX_STRING, salt: HEX_STRING }` and is suitable for transmission to the server.
	
`Server` methods:

- **`init(options, callback)`**
	- `options` should be an object containing the hex representations of `verifier` and `salt`. These should be the values received from the initial client registration using `Client.createVerifier()`. You may also pass length, which allows you to select the size of your parameters.
	- `callback` will be invoked once the server instance is ready to use.
- **`getPublicKey() -> Hex B value`**
	- Return the server's ***B*** value in hex format, suitable for transmission to the client.
- **`getSalt() -> Hex salt value`**
	- Return the salt value (this will be the same value passed to `init()`)
- **`setClientPublicKey(clientPublicKey)`**
	- `clientPublicKey` should be the hex value returned from `Client.getPublicKey()`. Assuming it's valid, the server will then compute the values necessary to complete authentication internally. *This will throw an error if the client provides an incorrect value, authentication MUST be aborted here.*
- **`getSharedKey() -> Hex K value`**
	- The secret shared key suitable for further crypto operations.
- **`checkClientProof(clientProof) -> Boolean`**
	- Returns true if `clientProof` matches the server's own proof computation, false if it doesn't. If this value is true, then the client has provided the correct password, and can be considered authenticated. If it's false, the client used the wrong password. `clientProof` is the hex string obtained from `Client.getProof()`
- **`getProof() -> Hex M2 value`**
	- The server's ***M2*** value as a hex string, suitable for transmission to the client. *This can only be called after `checkClientProof()`*.
	
In either scenario, if you'd like to interact with the SRP protocol implementation directly, the SRP object will be available on the client/server object after running `init()`. You can access it using `clientObj.srp` or `serverObj.srp`. The intermediate values calculated by the client and server are also available on the objects themselves as well.

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
	
## Credits

JSRP would not exist if it wasn't for Node-SRP: [https://github.com/mozilla/node-srp](https://github.com/mozilla/node-srp). They provided a solid reference implementation, but JSRP was born out of wanting a reliable browser implementation as well as server implementation.
	
