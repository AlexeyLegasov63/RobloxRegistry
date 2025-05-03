
--[=[
	@within Registry
	@class Registry
	@tag registry
	@description A registry is a table that allows you to register and retrieve objects by a unique key.
]=]
export type Registry<T = any> = {
	reg : (self: Registry<T>, data: {[string]: any?}) -> (),
	regAll : (self: Registry<T>, data: {[string]: {[string]: any?}}) -> (),
	get : (self: Registry<T>, key: string) -> T?,
	listAll : (self: Registry<T>) -> {[string]: T?},
	freeze : (self: Registry<T>) -> (),
	isFrozen : (self: Registry<T>) -> boolean,
}

local registry = {}
registry.__index = registry

--[=[
	@within Registry
	@function new
	@param registerName string -- The name of the registry.
	@param registerInstance {[string]: any?} -- The instance to be registered.
	@param customKey string? -- The key to be used for the registry. Defaults to "name".
	@throws Error if the registry name or instance is nil.
	@returns Registry<T>
]=]
function registry.new<T>(registerName: string, registerInstance: {[string]: any?}, customKey: string?): Registry<T>
	assert(registerName, `The registry name cannot be nil.`)
	assert(registerInstance, `The registry instance cannot be nil.`)

	local self = {}
	self._name = registerName
	self._isFrozen = false
	self._registry = {}
	self._customKey = customKey or "name"
	self._instance = registerInstance
	self._instance.__index = self._instance

	return setmetatable(self, registry)
end

--[=[
	Registers a new T in the registry.
	@param data {[string]: any?} -- The instance to be registered.
	@throws Error if the registry is frozen or if the key already exists.
	@throws Error if the value is nil or not a table.
	@throws Error if the key is not a string.
]=]
function registry:reg(data: {[string]: any?})
	if self._isFrozen then
		error(`Cannot modify a frozen registry. ({self._name})`)
	end

	assert(data, `A nil value cannot be registered. ({self._name})`)
	assert((typeof(data) == "table"), `The value must be a table. ({self._name})`)

	local key = data[self._customKey] -- the key to be used for the registry

	assert(key, `The value cannot be registered due to no key. ({self._name})`)
	assert((typeof(key) == "string"), `The key must be a string. ({self._name})`)
	assert(not self._registry[key], `The key already exists. ({self._name})`)

	self._registry[key] = setmetatable(data, self._instance)
end

--[=[
	Registers multiple T in the registry.
	@param data {[string]: {[string]: any?}} -- The instances to be registered.
	@throws Error if the registry is frozen or if the key already exists.
	@throws Error if the value is nil or not a table.
	@throws Error if the key is not a string.
]=]
function registry:regAll(data: {[string]: {[string]: any?}})
	if self._isFrozen then
		error(`Cannot modify a frozen registry. ({self._name})`)
	end

	assert(data, `A nil value cannot be registered. ({self._name})`)
	assert((typeof(data) == "table"), `The value must be a table. ({self._name})`)

	for key, value in pairs(data) do
		assert(value, `A nil value cannot be registered. ({self._name})`)
		assert((typeof(value) == "table"), `The value must be a table. ({self._name})`)
		self:_reg(key, value) -- register the value
	end
end

--[=[
	Returns the registered T in the registry.
	@throws Error if the key is not a string.
	@returns T?
]=]
function registry:get(key: string)
	assert((typeof(key) == "string"), `The key must be a string. ({self._name})`)
	return self._registry[key]
end

--[=[
	Returns all registered T in the registry.
	@returns {[string]: T?}
]=]
function registry:listAll()
	return self._registry
end

--[=[
	Freezes the registry, preventing any further modifications.
	@throws Error if the registry is already frozen.
]=]
function registry:freeze()
	assert(not self._isFrozen, `The registry is already frozen. ({self._name})`)
	self._isFrozen = true
	table.freeze(self._registry)
end

--[=[ 
	Returns true if the registry is frozen, false otherwise.
	@returns boolean
]=]
function registry:isFrozen()
	return self._isFrozen
end

--[=[
	@within Registry
	@function registry
	@param key string -- The key to be used for the registry.
	@param value {[string]: any?} -- The instance to be registered.
	@throws Error if the registry is frozen or if the key already exists.
	@throws Error if the value is nil or not a table.
	@throws Error if the key is not a string.
]=]
function registry:_reg(key, value)
	value[self._customKey] = key -- the key to be used for the registry
	self:reg(value) -- register the value
end

function registry:__tostring()
	return `Registry({self._name})`
end

function registry:__index(key: string)
	assert((typeof(key) == "string"), `The key must be a string. ({self._name})`)
	--[[
		We need to check if the key is in the registry first to detect functions
	]]--
    if registry[key] then 
		return registry[key] 
	end

	return self:get(key)
end

function registry:__newindex(key: string, value: any)
	assert((typeof(key) == "string"), `The key must be a string. ({self._name})`)
	assert((typeof(value) == "table"), `The value must be a table. ({self._name})`)

	self:_reg(key, value) -- register the value
end

return registry
