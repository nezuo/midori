# Getting Started

### Creating Tests
First, create a module with a `.test` suffix. This module will return a function that when called will create your tests.

A simple test module might look like this:

`Module.test.lua`
```lua
return function(x)
    x.test("1 == 1", function()
        assert(1 == 1)
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
To isolate certain tests, Midori provides a `testFOCUS` and a `testSKIP` function.

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
