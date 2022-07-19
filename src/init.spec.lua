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
	end)

	describe("Signal:Once", function()
		it("should yield", function()
			local s = Signal:New()

			task.defer(function()
				s:Fire(true)
			end)

			local p = s:Once()
			
			p:Then(function(value)
				expect(value).to.equal(true)
			end)

			expect(p:Wait()).to.equal(true)
		end)
	end)
end