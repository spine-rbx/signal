local Packages = script.Parent

local Object = require(Packages.object)
local Promise = require(Packages.promise)

local Signal = Object:Extend()

function Signal:Constructor()
	self._CallbackList = {}
end

function Signal:Connect(Callback: (...any) -> ())
	self._CallbackList[#self._CallbackList + 1] = Callback

	return {
		Disconnect = function()
			local index = 0
			for i,v in ipairs(self._CallbackList) do
				if v == Callback then
					index = i
					break
				end
			end

			if index > 0 then
				table.remove(self._CallbackList, index)
			end
		end,
	}
end

function Signal:Fire(...)
	for _,v in ipairs(self._CallbackList) do
		task.spawn(v, ...)
	end
end

function Signal:Once(Predicate: (...any) -> (boolean?)?)
	return Promise:New(function(Resolve)
		local Disconnect

		Disconnect = self:Connect(function(...)
			if Predicate == nil or Predicate(...) then
				Disconnect()
				Resolve(...)
			end
		end).Disconnect
	end)
end

function Signal:Wait()
	return self:Once()
end

function Signal:Destroy()
	self._CallbackList = nil
end

export type Connection = { Disconnect: () -> () }

export type Signal = Object.Object<{
	Connect: (self: Signal, Callback: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Once: (self: Signal, Predicate: (...any) -> (boolean)?) -> (Promise.Promise),
	Wait: (self: Signal) -> (Promise.Promise),
	Destroy: (self: Signal) -> (),

	_CallbackList: { (...any) -> () },
}>

return Signal :: Signal