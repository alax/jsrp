assert = require 'assert'
should = require 'should'
SRPClient = require '../src/client'
SRPServer = require '../src/server'
transform = require '../src/transform'
client = new SRPClient()
server = new SRPServer()

I = Buffer.from "alice"
P = Buffer.from "password123"
s = Buffer.from 'beb25379d1a8581eb5a727673a2441ee', 'hex'
a = Buffer.from '60975527035cf2ad1989806f0407210bc81edc04e2762a56afd529ddda2d4393', 'hex'
b = Buffer.from 'e487cb59d31ac550471e81f00f6928e01dda08e974a004f49e61f5d105284d20', 'hex'

v_static = '7e273de8 696ffc4f 4e337d05 b4b375be b0dde156 9e8fa00a 9886d812
            9bada1f1 822223ca 1a605b53 0e379ba4 729fdc59 f105b478 7e5186f5
            c671085a 1447b52a 48cf1970 b4fb6f84 00bbf4ce bfbb1681 52e08ab5
            ea53d15c 1aff87b2 b9da6e04 e058ad51 cc72bfc9 033b564e 26480d78
            e955a5e2 9e7ab245 db2be315 e2099afb'

v_static = transform.cleanHex v_static

init = () ->
  await new Promise (resolve) ->
    client.debugInit
      username: I.toString('utf8'),
      password: P.toString('utf8'),
      length: 1024,
      a: a,
      compatibility: true,
      resolve

  await new Promise (resolve) ->
    server.init
      salt: s.toString('hex'),
      verifier: v_static,
      length: 1024,
      b: b.toString('hex'),
      compatibility: true,
      resolve

  client.setSalt s.toString('hex')
  client.setServerPublicKey server.getPublicKey()
  server.setClientPublicKey client.getPublicKey()

init()

describe 'Compatibility mode', ->
  describe 'Client proof', ->
    it 'was calculated with S', ->
      clientProof = client.getProof()
      clientProof.should.equal 'b46a783846b7e569ff8f9b44ab8d88edeb085a65'
      server.checkClientProof(clientProof).should.be.true()

  describe 'Server proof', ->
    it 'was calculated with S', ->
      serverProof = server.getProof()
      serverProof.should.equal('0b0a6ad3024e79b5cad04042abb3a3f592d20c17')
      client.checkServerProof(serverProof).should.be.true()
