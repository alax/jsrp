BigInteger = require 'jsbn'

class Transform

	cleanHex: (hexStr) ->
		return hexStr.split(/\s/).join ''

	class TransBigInt
		# Specify the toHex method in case we decide to change BigInteger 
		# libraries.
		toHex: (bigIntegerObj) ->
			thisHexString = bigIntegerObj.toString 16

			# If the length of the hex string is odd, JSBN left off a leading
			# zero.
			if thisHexString.length % 2 is 1
				thisHexString = "0" + thisHexString

			return thisHexString

		fromHex: (hexStr) ->
			return new BigInteger hexStr, 16

		# Convert a BigInteger to a buffer. This works by converting the
		# BigInteger to a hex string, then loading the hex string into a buffer.
		# Definitely not the best way to do it, but it works well.
		toBuffer: (bigIntegerObj) ->
			thisHexString = @toHex bigIntegerObj

			return new Buffer thisHexString, 'hex'

	class TransBuffer

		toHex: (bufferObj) ->
			return bufferObj.toString 'hex'

		# Convert a buffer to a BigInteger. This works the same way TransBigInt.
		# toBuffer works, by first converting to hex and then loading back.
		toBigInteger: (bufferObj) ->
			thisHexString = @toHex bufferObj
			return new BigInteger thisHexString, 16

	class TransPad extends TransBigInt
		to: (n, length) ->
			padding = length - n.length

			# Check for negative padding here.
			result = new Buffer length
			result.fill 0, 0, padding

			n.copy result, padding

			return result

		toN: (number, params) ->
			return @to @toBuffer(number), (params.length / 8)

		toH: (number, params) ->
			hashBits = null

			switch params.hash
				when 'sha1' then hashBits = 160
				when 'sha256' then hashBits = 256
				when 'sha512' then hashBits = 512
				else throw Error 'Unable to determine hash length!'

			return @to @toBuffer(number), (hashBits / 8)

	constructor: () ->
		@bigInt = new TransBigInt
		@buffer = new TransBuffer
		@pad = new TransPad

module.exports = new Transform