local Packages = script.Parent

local Object = require(Packages.object)
local Promise = require(Packages.promise)
local Bin = require(Packages.bin)

local Signal = Object:Extend()

function Signal:Constructor()
	self._Bin = Bin:New()
	self._CallbackList = {}

	self._Bin:AddItem(function()
		self._CallbackList = nil
	end)
end

function Signal:Connect(Callback: (...any) -> ())
	self._CallbackList[#self._CallbackList + 1] = Callback

	return {
		Disconnect = function()
			if self._CallbackList == nil then
				return
			end

			for i,v in ipairs(self._CallbackList) do
				if v == Callback then
					table.remove(self._CallbackList, i)
					break
				end
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
	self._Bin:Empty()
end

export type Connection = { Disconnect: () -> () }

export type Signal = Object.Object<{
	_CallbackList: { (...any) -> () },
	_Bin: Bin.Bin,

	Connect: (self: Signal, Callback: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Once: (self: Signal, Predicate: (...any) -> (boolean)?) -> (Promise.Promise),
	Wait: (self: Signal) -> (Promise.Promise),
	Destroy: (self: Signal) -> (),
}>

return Signal :: Signal