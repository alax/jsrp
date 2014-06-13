assert = require 'assert'
should = require 'should'
SRPClient = require '../src/client'
SRPServer = require '../src/server'
client = new SRPClient()
server = new SRPServer()

verifier = null

describe 'High-level Implementation', ->
	it 'should initialize client', (done) ->
		client.init username: 'alice', password: 'password123', done

	it 'should initialize server', (done) ->
		server.init salt: 'a15b19ed48c0a0f9d695cfa17faeaadb0a536f49c0e106bd5c507b11e194665a', verifier: '1db3c79fb4fe1ea5eb92c58c10cc2c32b7dc6996cd1b72b3335279adcc2fe35b762b3ca0909480716d9dab57c168bce557add3b2329c716b8cdade4a26395cb48f93f26882c2bd8788b35dd1be99ba4d56b09ace0d1657e4380c70dfcf0a8955a41ccdaa9373ec415e360e66e1febd34b823f5e77f3d931700d089e31c93c11e4fa6e92bac3fc476a7dd8c0a97502b83b8a560be925939bccf7604ca1c9ca8c6b34c400aa874ccd1f41faf48e6420b9fc063c8a61acf648af5144fb98e1e91a46b9128c7477e28f97d6435428decd2ca44ad0603c831e1604f98738cae9e5df330d5e3b239eb6b0443c079c82da58fcc6c0fea484386e88a87a35d36e93bc52fa3f22b96d52d3a447fa2c3fec2601718e3d729575b21c751dda85b2663a72fca5ce0fecc6cf3ab0ff7c2838134b33ed8733e675022f327cdf62ad3885ba26bc2f4abf21ef94c061990420d2c3363a048ea91f5c549027fe4286e67b48c600ea9e4925e4e08a3a3e10e680758a5a4eb85ca5897f612da7b1d8af10dcde968624024b1502abcaf66bd2e695d50d89d111e4ee42867a44e6e405f7c812756297118df9a26305ebe63ad501255b4a090b31021679f0b3e10603ed2fc529d7ea26085be1f924e8048d9b15651e77ff5784749d4156bb8b49a28b882b1019bb0bb4f429c3f98f6f33621d122a4e89b9b0f3cc48babf6534abd5563eb998475c212d049', done

	it 'should create a verifier', (done) ->
		client.createVerifier username: 'alice', password: 'password123', (err, result) ->
			done()

	it 'client and server should have matching K values', ->
		cPubKey = client.getPublicKey()
		server.setClientPublicKey(cPubKey)

		salt = server.getSalt()
		client.setSalt(salt)

		sPubKey = server.getPublicKey()
		client.setServerPublicKey(sPubKey)

		client.getSharedKey().should.equal(server.getSharedKey())

	it 'server should accept client proof', ->
		cProof = client.getProof()
		server.checkClientProof(cProof).should.equal(true)

	it 'client should accept server proof', ->
		sProof = server.getProof()
		client.checkServerProof(sProof).should.equal(true)