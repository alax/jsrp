transform = require './transform'
SRP = require './srp'

# This is a high-level client interface for the SRP protocol.
class Server

	init: (options, callback) ->
		@vBuf = new Buffer options.verifier, 'hex'
		@saltBuf = new Buffer options.salt, 'hex'

		length = options.length || 4096;
		@srp = new SRP length

		@srp.b (err, b) =>
			@bInt = b
			@BBuf = @srp.B b: @bInt, v: transform.buffer.toBigInteger @vBuf

			callback()

	debugInit: (options, callback) ->
		@vBuf = new Buffer options.verifier, 'hex'
		@saltBuf = new Buffer options.salt, 'hex'

		length = options.length || 4096;
		@srp = new SRP length

		@bInt = transform.buffer.toBigInteger options.b
		@BBuf = @srp.B b: @bInt, v: transform.buffer.toBigInteger @vBuf

		callback()


	getPublicKey: () ->
		return @BBuf.toString 'hex'

	getSalt: () ->
		return @saltBuf.toString 'hex'

	setClientPublicKey: (hexA) ->
		@ABuf = new Buffer hexA, 'hex'

		ABigInt = transform.buffer.toBigInteger @ABuf

		if @srp.isZeroWhenModN ABigInt
			throw Error 'Invalid A value, abort'

		# We have been given B, which means we can calculate u.
		@uInt = @srp.u A: @ABuf, B: @BBuf

		# We can also calculate our secret.
		@SBuf = @srp.serverS
					A: transform.buffer.toBigInteger @ABuf
					v: transform.buffer.toBigInteger @vBuf
					u: @uInt
					b: @bInt

		# Once we have the secret, we can calculate K.
		@KBuf = @srp.K S: @SBuf

	getSharedKey: () ->
		return @KBuf.toString 'hex'

	checkClientProof: (M1hex) ->
		clientM1Buf = new Buffer M1hex, 'hex'
		@M1Buf = @srp.M1 A: @ABuf, B: @BBuf, K: @KBuf

		result = @M1Buf.toString('hex') is clientM1Buf.toString('hex')
		return result

	getProof: () ->
		@M2Buf = @srp.M2 A: @ABuf, M: @M1Buf, K: @KBuf

		result = @M2Buf.toString('hex')
		return result

module.exports = Server