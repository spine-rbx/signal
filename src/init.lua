local Packages = script.Parent

local Object = require(Packages.object)

local Signal = Object:Extend()

function Signal:Constructor()
	self._CallbackList = {}
end

function Signal:Connect(Callback: (...any) -> ())
	local n = #self._CallbackList + 1
	self._CallbackList[n] = Callback

	return {
		Disconnect = function()
			table.remove(self._CallbackList, n)
		end
	}
end

function Signal:Fire(...)
	for _,v in ipairs(self._CallbackList) do
		task.spawn(v, ...)
	end
end

function Signal:Wait()
	local Running = coroutine.running()
	local Disconnect

	Disconnect = self:Connect(function(...)
		Disconnect()
		coroutine.resume(Running, ...)
	end).Disconnect

	return coroutine.yield()
end

function Signal:Once(Predicate: (...any) -> (boolean?))
	local Running = coroutine.running()
	local Disconnect

	Disconnect = self:Connect(function(...)
		if Predicate(...) == true then
			Disconnect()
			coroutine.resume(Running, ...)
		end
	end).Disconnect

	return coroutine.yield()
end

function Signal:Destroy()
	self._CallbackList = nil
end

export type Signal = Object.Object<{
	Connect: (Callback: (...any) -> ()) -> { Disconnect: () -> () },
	Fire: (...any) -> (),
	Wait: () -> (...any),
	Once: (Predicate: (...any) -> (boolean)) -> (...any),
	Destroy: () -> (),

	_CallbackList: { (...any) -> () },
}>

return Signal :: Signal