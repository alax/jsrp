transform = require './transform'
SRP = require './srp'

# This is a high-level client interface for the SRP protocol.
class Client

	# Init generates the "a" value and stores it.
	init: (options, callback) ->
		@IBuf = new Buffer options.username
		@PBuf = new Buffer options.password

		length = options.length || 4096;
		@srp = new SRP length

		@srp.a (err, a) =>
			@aInt = a
			@ABuf = @srp.A a: @aInt

			callback()

	# Over-ride random "a" selection
	debugInit: (options, callback) ->
		@IBuf = new Buffer options.username
		@PBuf = new Buffer options.password

		length = options.length || 4096;
		@srp = new SRP length

		@aInt = transform.buffer.toBigInteger options.a
		@ABuf = @srp.A a: @aInt

		callback()

	getPublicKey: () ->
		return @ABuf.toString 'hex'

	# Set the salt value. Salt should be provided in HEX format.
	setSalt: (hexSalt) ->
		@saltBuf = new Buffer hexSalt, 'hex'

		# Now that we have the salt, we can also calulate x.
		@xInt = @srp.x I: @IBuf, P: @PBuf, salt: @saltBuf

	# Set the server B value, B should be provided in hex as well.
	# RFC 2945 states that we must abort authentication if B % N is zero.
	setServerPublicKey: (hexB) ->
		@BBuf = new Buffer hexB, 'hex'

		BBigInt = transform.buffer.toBigInteger @BBuf

		if @srp.isZeroWhenModN BBigInt
			throw Error 'Invalid B value, abort'

		# We have been given B, which means we can calculate u.
		@uInt = @srp.u A: @ABuf, B: @BBuf

		# We can also calculate our secret.
		@SBuf = @srp.clientS
					B: transform.buffer.toBigInteger @BBuf
					a: @aInt
					u: @uInt
					x: @xInt

		# Once we have the secret, we can calculate K.
		@KBuf = @srp.K S: @SBuf

	# Get our M1 in Hex value to send to the server for verification.
	getProof: () ->
		@M1Buf = @srp.M1 A: @ABuf, B: @BBuf, K: @KBuf
		return @M1Buf.toString 'hex'

	# Allow us to verify the server's M2 response.
	checkServerProof: (hexM2) ->
		ServerM2Buf = new Buffer hexM2, 'hex'
		@M2Buf = @srp.M2 A: @ABuf, M: @M1Buf, K: @KBuf

		result = @M2Buf.toString('hex') is ServerM2Buf.toString('hex')
		return result

	# Return the shared key K in hex format so that it can be used with other
	# libraries.
	getSharedKey: () ->
		return @KBuf.toString 'hex'

	createVerifier: (callback) ->
		@srp.generateSalt (err, salt) =>
			@saltBuf = salt

			result = @srp.v I: @IBuf, P: @PBuf, salt: @saltBuf
			result = result.toString 'hex'

			callback null, verifier: result, salt: @getSalt()

	getSalt: ->
		return @saltBuf.toString 'hex'

module.exports = Client;
