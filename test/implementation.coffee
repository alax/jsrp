assert = require 'assert'
should = require 'should'
SRPClient = require '../src/client'
SRPServer = require '../src/server'
SRPparams = require '../src/parameters'

verifier = null

describe 'High-level Implementation', ->

	Object.keys(SRPparams.params).forEach (length) ->
		client = new SRPClient()
		server = new SRPServer()
		verifier = null

		describe "#{ length }-bit parameters", ->
			it 'should initialize client', (done) ->
				client.init username: 'alice', password: 'password123', length: length, done

			it 'should create verifier', (done) ->
				client.createVerifier (err, result) ->
					verifier = result
					done()

			it 'should initialize server', (done) ->
				server.init length: length, salt: verifier.salt, verifier: verifier.verifier, done

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