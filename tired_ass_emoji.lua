-- id never think id make a fucking fish a brainrot script in the big 26 but 
local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")
local rh = rs:WaitForChild("RemoteHandler")
local f_ev = rh:WaitForChild("Fishing")
local r_ev = rh:WaitForChild("Rebirth")
local c_ev = rh:WaitForChild("Collect")
local s_ev = rh:WaitForChild("SellMultiple")
local p_ev = rh:WaitForChild("Plot")

local lt = os.clock()
local uid = tostring(lp.UserId)
local used = {}
local big_number_i_think = math.huge
while true do
	f_ev:FireServer("Caught", big_number_i_think)

	for _, p in ws.Plots:GetChildren() do
		if p:GetAttribute("Username") == lp.Name or p:GetAttribute("Owner") == lp.Name or p:GetAttribute(lp.Name) then
			local plt = p:FindFirstChild("Platforms") and p.Platforms:FindFirstChild("Platforms")
			if plt then
				for _, m in plt:GetChildren() do
					if m:IsA("Model") then
						local id = m.Name:match("%d+$")
						if id and not used[id] then
							local ent = m:FindFirstChild("Entity")
							if ent and #ent:GetChildren() > 0 then
								c_ev:FireServer("Plot" .. id)
							end
							
							local bp = lp:FindFirstChild("Backpack")
							if bp then
								for _, item in bp:GetChildren() do
									if item.Name:find(uid) then
										local item_uid = item:GetAttribute("UID")
										if item_uid then
											p_ev:FireServer("Add", "Plot" .. id, tostring(item_uid))
											used[id] = true
											break
										end
									end
								end
							end
						end
					end
				end
			end
			break
		end
	end

	  --r_ev:FireServer()
    -- use ts to rebirth but i want za money

    s_ev:FireServer({Rare = true, Legendary = true, Epic = true, Godly = true, Mythic = true, Divine = true, Uncommon = true, Secret = true})

    --[[
    this is for the dumbbell thing
    local Event = game:GetService("ReplicatedStorage").RemoteHandler.Dumbbell
	  Event:FireServer("Bubble")
    ]]
    
    task.wait(0.35)
    -- TURN THIS DOWN AND U WILL LAG AND UR EAR DRUMS WILL EXPLODE. (i dont recommend it!)
end
