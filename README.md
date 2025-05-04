# Registry Module

A lightweight, type-safe registry system for Roblox (Luau) that allows you to register, retrieve, and manage configuration presets or any objects by a unique key. Perfect for managing items, effects, abilities or any modular settings in your Roblox games.

## Features

* **Generic Type Support**: Define custom types for your registry entries to enable Luau type checking and IntelliSense.
* **Single & Bulk Registration**: Register individual entries with `reg` or multiple entries at once with `regAll`.
* **Immutable Locking**: Once all entries are registered, call `freeze` to prevent further modifications and ensure data integrity.
* **Convenient DSL**: Use metaprogramming to register entries via property assignment (`registry.myPreset = {...}`) or method calls.
* **Automatic Key Assignment**: Customize the property name used for the unique key (defaults to `name`).
* **Built-in Validation**: Ensures keys are strings, entries are tables, and throws clear errors on invalid operations.

## Installation

1. Clone or download this repository.
2. Place the `registry.lua` module in your `ReplicatedStorage` or any shared folder:
3. Require and initialize the registry in your script:

```lua
local registry = require(Path.To.Registry.Module)
local AtmosphereRegistry = registry.new("atmospheres", ...)
```

## Usage

### Defining a Registry

Create a new registry instance by specifying a name, a template instance (class table) for entries, and an optional custom key field:

```lua
-- Define an abstract template for atmosphere presets
type AtmosphereConfig = {
    name: string,
    fadeStyle: Enum.EasingStyle,
    fadeInDuration: number,
    fadeOutDuration: number,
    audioComposition: { [string]: string },
    colorComposition: { [string]: Color3 },
}

local template = {
    fadeStyle = Enum.EasingStyle.Linear,
    fadeInDuration = 1,
    fadeOutDuration = 1,
    audioComposition = {},
    colorComposition = {},
}
local configRegistry: Registry<AtmosphereConfig> = registry.new("Atmosphere", template)
```

### Registering Entries

#### Single Entry

Use `:reg(data)` to register a single entry. The `data` table must include the `customKey` field (default `name`):

```lua
configRegistry:reg {
    name = "default",
    fadeStyle = Enum.EasingStyle.Linear,
    fadeInDuration = 1,
    fadeOutDuration = 1,
}
```

#### Bulk Registration

Use `:regAll(presetsTable)` to register multiple entries at once. The keys of the table become the entry names:

```lua
local presets = {
    default = {},  -- inherits all default values
    chase = {
        fadeStyle = Enum.EasingStyle.Sine,
        fadeInDuration = 0.5,
        fadeOutDuration = 2,
        audioComposition = {
            theme = "Rush1",
        },
        colorComposition = {
            main = Color3.fromHex("A02020"),
        },
    },
}

configRegistry:regAll(presets)
```

#### DSL Syntax

You can also register entries by direct assignment (thanks to `__newindex` metamethod):

```lua
configRegistry.default = {}
configRegistry.stealth = {
    fadeStyle = Enum.EasingStyle.Quad,
    fadeInDuration = 0.8,
}
```

### Retrieving Entries

* `:get(key)` — Returns the entry by its key or `nil` if not found.
* `:listAll()` — Returns the entire internal registry table.

```lua
local chaseConfig = configRegistry:get("chase")
print(chaseConfig.fadeOutDuration)  -- 2
```

### Freezing the Registry

Once all entries are registered, lock the registry to prevent further changes:

```lua
configRegistry:freeze()
assert(configRegistry:isFrozen(), "Registry should be frozen")
```

Any subsequent attempt to register a new entry or modify an existing one will throw an error.

## API Reference

| Method                      | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `new(name, template, key?)` | Create a new registry instance.                     |
| `:reg(data)`                | Register a single entry.                            |
| `:regAll(dataTable)`        | Register multiple entries in bulk.                  |
| `:get(key)`                 | Retrieve an entry by its key.                       |
| `:listAll()`                | Get the full registry table.                        |
| `:freeze()`                 | Lock the registry to prevent further modifications. |
| `:isFrozen()`               | Check if the registry is frozen.                    |

