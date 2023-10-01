# Getting Started

### Creating Tests

First, to create a test module, create a new `ModuleScript` with a `.test` suffix. Test modules are required to return function and a table called `x` will be passed in. [`x`](/api/x) contains utility asserts like [`shouldThrow`](/api/x#shouldThrow), functions to register tests, and more.

A simple test module might look like this:

`Module.test.lua`
```lua
return function(x)
    local assertEqual = x.assertEqual

    x.test("1 == 1", function()
        assertEqual(1, 1)
    end)
end
```

### Running Tests
To run your tests, call `Midori.runTests` with an instance. Midori will find all `.test` modules inside that instance.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Midori = require(ReplicatedStorge.Packages.Midori)

Midori.runTests(ReplicatedStorage.YourLibrary)
```

### Debugging Tests
To isolate certain tests, [`x`](/api/x) provides a `testFOCUS` and a `testSKIP` function.

```lua
return function(x)
    -- Only tests that have been called with `testFOCUS` will run.
    x.testFOCUS("focus" function() end)
end
```

```lua
return function(x)
    -- This test will not run.
    x.testSKIP("skip" function() end)
end
```
