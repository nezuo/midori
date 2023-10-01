local assertEqual = require(script.assertEqual)
local shouldThrow = require(script.shouldThrow)

--[=[
	Creates a new test inside of the current scope.

	@function test
	@within x

	```lua
	test("1 == 1", function()
		assert(1 == 1)
	end)
	```

	@param name string
	@param callback (context: {}) -> ()
]=]

--[=[
	Creates a new test inside of the current scope. If any test is focused, only focused tests will run.

	@function testFOCUS
	@within x

	```lua
	testFOCUS("1 == 1", function()
		assert(1 == 1)
	end)
	```

	@param name string
	@param callback (context: {}) -> ()
]=]

--[=[
	Creates a new test inside of the current scope that will be skipped.

	@function testSKIP
	@within x

	```lua
	testSKIP("skip", function()
		print("this will not print")
	end)
	```

	@param name string
	@param callback (context: {}) -> ()
]=]

--[=[
	Runs `callback` before each test inside its scope runs. It's passed a `context` table unique to that test.
	`context` can be used to share setup code across tests.

	@function beforeEach
	@within x

	```lua
	beforeEach(function(context)
		context.maid = Maid.new()
	end)

	test(function(context)
		assert(context.maid:isEmpty())
	end)
	```

	@param callback (context: {}) -> ()
]=]

--[=[
	Runs `callback` after each test inside its scope runs. It's passed a `context` table which can be used to cleanup
	state unique to the test.

	@function afterEach
	@within x

	```lua
	afterEach(function(context)
		context.object:destroy()
	end)
	```

	@param callback (context: {}) -> ()
]=]

--[=[
	Creates a nested scope for tests. It can be used to group tests that are testing similar things.

	@function nested
	@within x

	```lua
	nested("nested", function()
		-- This `beforeEach` will only affect tests inside of this nested scope.
		beforeEach(function() end)

		test("nested test", function() end)
	end)
	```

	@param name string
	@param callback () -> ()
]=]

--[=[
	This class is passed into test modules.

	@class x
]=]
return {
	assertEqual = assertEqual,
	shouldThrow = shouldThrow,
}
