--# selene: allow(undefined_variable)

return function()
	local Signal = require(script.Parent)

	describe("signal", function()
		it("should fire events", function()
			local s = Signal:New()

			local value = false

			s:Connect(function()
				value = true
			end)

			s:Fire()

			expect(value).to.equal(true)
		end)

		it("should disconnect events", function()
			local s = Signal:New()

			local value = false

			local c = s:Connect(function()
				value = true
			end)

			s:Fire()

			expect(value).to.equal(true)

			c:Disconnect()
			value = false

			s:Fire()

			expect(value).to.equal(false)
		end)

		it("should wait", function()
			local s = Signal:New()

			task.defer(function()
				s:Fire("hello", "world")
			end)

			local hello, world = s:Wait()

			expect(hello).to.equal("hello")
			expect(world).to.equal("world")
		end)
	end)
end