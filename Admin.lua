local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")


local Prefix = ":"
local ScriptName = "Moderatio1n's Admin"
local ServerBans = {}
local GlobalStats = {}
local JailedPlayers = {}
local PunishedPlayers = {}
local NoClipPlayers = {}

local Ranks = {
	Owner = 4,
	HeadAdmin = 3,
	Admin = 2,
	Mod = 1,
	NonAdmin = 0
}

local PlayerRanks = {
	[4769427369] = Ranks.Owner, --trashmoderatio1n
	[11039225519] = Ranks.HeadAdmin, --NnamesSkid (testing)
	[653626782] = Ranks.HeadAdmin --o9sews
}

local Commands = {}
local JoinOrder = {}
local JoinCounter = 0
local NotificationGuis = {}

local function GetRank(player)
	return PlayerRanks[player.UserId] or 0
end

local function GetRankName(player)
	local rank = GetRank(player)

	for name, level in pairs(Ranks) do
		if level == rank then
			return name
		end
	end

	return "Player"
end

local function Notify(player, title, message, duration)
	if not player or not player.Parent then
		return
	end

	task.spawn(function()
		local PlayerGui = player:FindFirstChildOfClass("PlayerGui")
			or player:WaitForChild("PlayerGui", 5)

		if not PlayerGui or not player.Parent then
			return
		end

		local ScreenGui = NotificationGuis[player]

		if not ScreenGui or not ScreenGui.Parent then
			ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Name = "Moderatio1n's Admin Notifications"
			ScreenGui.ResetOnSpawn = false
			ScreenGui.DisplayOrder = 100
			ScreenGui.IgnoreGuiInset = true
			ScreenGui.Parent = PlayerGui

			NotificationGuis[player] = ScreenGui

			local Container = Instance.new("Frame")
			Container.Name = "Container"
			Container.AnchorPoint = Vector2.new(1, 1)
			Container.Position = UDim2.new(1, -12, 1, -12)
			Container.Size = UDim2.new(0.85, 0, 0.6, 0)
			Container.BackgroundTransparency = 1
			Container.Parent = ScreenGui

			local SizeConstraint = Instance.new("UISizeConstraint")
			SizeConstraint.MinSize = Vector2.new(0, 0)
			SizeConstraint.MaxSize = Vector2.new(340, 600)
			SizeConstraint.Parent = Container

			local Layout = Instance.new("UIListLayout")
			Layout.Padding = UDim.new(0, 8)
			Layout.SortOrder = Enum.SortOrder.LayoutOrder
			Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
			Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			Layout.Parent = Container
		end

		local Container = ScreenGui:FindFirstChild("Container")

		if not Container then
			return
		end

		local Slot = Instance.new("Frame")
		Slot.Name = "NotificationSlot"
		Slot.Size = UDim2.new(1, 0, 0, 86)
		Slot.BackgroundTransparency = 1
		Slot.ClipsDescendants = true
		Slot.LayoutOrder = math.floor(os.clock() * 1000)
		Slot.Parent = Container

		local Frame = Instance.new("Frame")
		Frame.Name = "Notification"
		Frame.Size = UDim2.new(1, 0, 0, 86)
		Frame.Position = UDim2.new(1, 350, 0, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
		Frame.BackgroundTransparency = 0.05
		Frame.BorderSizePixel = 0
		Frame.Parent = Slot

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 8)
		Corner.Parent = Frame

		local Stroke = Instance.new("UIStroke")
		Stroke.Color = Color3.fromRGB(75, 75, 90)
		Stroke.Transparency = 0.35
		Stroke.Thickness = 1
		Stroke.Parent = Frame

		local Accent = Instance.new("Frame")
		Accent.Name = "Accent"
		Accent.Position = UDim2.new(0, 0, 0, 10)
		Accent.Size = UDim2.new(0, 3, 1, -20)
		Accent.BackgroundColor3 = Color3.fromRGB(180, 120, 255)
		Accent.BorderSizePixel = 0
		Accent.Parent = Frame

		local AccentCorner = Instance.new("UICorner")
		AccentCorner.CornerRadius = UDim.new(1, 0)
		AccentCorner.Parent = Accent

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.Position = UDim2.new(0, 14, 0, 10)
		Title.Size = UDim2.new(1, -24, 0, 20)
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.GothamBold
		Title.Text = title or ScriptName
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.TextSize = 13
		Title.TextTruncate = Enum.TextTruncate.AtEnd
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Frame

		local Message = Instance.new("TextLabel")
		Message.Name = "Message"
		Message.Position = UDim2.new(0, 14, 0, 34)
		Message.Size = UDim2.new(1, -24, 0, 42)
		Message.BackgroundTransparency = 1
		Message.Font = Enum.Font.Gotham
		Message.Text = tostring(message or "")
		Message.TextColor3 = Color3.fromRGB(195, 195, 205)
		Message.TextSize = 12
		Message.TextWrapped = true
		Message.TextXAlignment = Enum.TextXAlignment.Left
		Message.TextYAlignment = Enum.TextYAlignment.Top
		Message.Parent = Frame

		local SlideIn = TweenService:Create(
			Frame,
			TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, 0, 0, 0)}
		)

		SlideIn:Play()
		SlideIn.Completed:Wait()

		task.wait(duration or 4)

		if not Slot.Parent or not Frame.Parent then
			return
		end

		local SlideOut = TweenService:Create(
			Frame,
			TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{Position = UDim2.new(1, 350, 0, 0)}
		)

		SlideOut:Play()
		SlideOut.Completed:Wait()

		if Slot.Parent then
			Slot:Destroy()
		end
	end)
end

local function GetPlayers(target, executor)
	target = target and target:lower() or ""

	if target == "" or target == "me" then
		return {executor}
	elseif target == "all" then
		return Players:GetPlayers()
	elseif target == "others" then
		local targets = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= executor then
				table.insert(targets, player)
			end
		end

		return targets
	elseif target == "random" then
		local players = Players:GetPlayers()

		if #players > 0 then
			return {players[math.random(1, #players)]}
		end

		return {}
	end

	local players = Players:GetPlayers()

	table.sort(players, function(a, b)
		return (JoinOrder[a] or math.huge) < (JoinOrder[b] or math.huge)
	end)

	for _, player in ipairs(players) do
		if player.DisplayName:lower() == target then
			return {player}
		end
	end

	for _, player in ipairs(players) do
		if player.Name:lower() == target then
			return {player}
		end
	end

	for _, player in ipairs(players) do
		if player.DisplayName:lower():sub(1, #target) == target then
			return {player}
		end
	end

	for _, player in ipairs(players) do
		if player.Name:lower():sub(1, #target) == target then
			return {player}
		end
	end

	return {}
end


local LoadstringModule

local function GetLoadstringModule()
	if LoadstringModule then
		return LoadstringModule
	end

	local success, module = pcall(function()
		return require(14132891321)
	end)

	if not success then
		return nil, module
	end

	if not module or typeof(module.SpawnS) ~= "function" or typeof(module.SpawnL) ~= "function" then
		return nil, "The Loadstring module is missing SpawnS or SpawnL."
	end

	LoadstringModule = module
	return LoadstringModule
end

GetLoadstringModule()

Commands.kill = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."kill <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				character:BreakJoints()
			end
		end
	end
}


Commands.speed = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."speed <player> <number>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local speed = tonumber(args[3])

		if not speed then
			Notify(executor, ScriptName, "Invalid syntax. \nSyntax: " .. Prefix .. Commands.speed.Syntax)
			return
		end

		for _, target in ipairs(targets) do
			local character = target.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.WalkSpeed = speed
			end
		end
	end
}


Commands.damage = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."damage <player> <number>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local damage = tonumber(args[3])

		if not damage then
			Notify(executor, ScriptName, "Invalid syntax. \nSyntax: " .. Prefix .. Commands.speed.Syntax)
			return
		end

		for _, target in ipairs(targets) do
			local character = target.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid:TakeDamage(damage)
			end
		end
	end
}


Commands.health = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."health <player> <number>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local health = tonumber(args[3])

		if not health then
			Notify(executor, ScriptName, "Invalid syntax. \nSyntax: " .. Prefix .. Commands.speed.Syntax)
			return
		end

		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.MaxHealth = health
					humanoid.Health = health
				end
			end
		end
	end
}


Commands.gear = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix .. "gear <player> <gearid>",

	Execute = function(executor, args)
		if not args[2] or not args[3] then
			Notify(executor, ScriptName, "Syntax error. \nSyntax: ".. Commands.gear.Syntax)
			return
		end

		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		local gearId = tonumber(args[3])

		if not gearId or gearId <= 0 or gearId % 1 ~= 0 then
			Notify(executor, ScriptName, "Invalid gear ID.", 4)
			return
		end

		local success, gear = pcall(function()
			return InsertService:LoadAsset(gearId)
		end)

		if not success or not gear then
			Notify(executor, ScriptName, "Invalid gear ID.", 4)
			return
		end

		local tool = gear:FindFirstChildWhichIsA("Tool", true)

		if not tool then
			gear:Destroy()
			Notify(executor, ScriptName, "Invalid gear ID.", 4)
			return
		end

		for _, target in ipairs(targets) do
			local backpack = target:FindFirstChildOfClass("Backpack")

			if backpack then
				local clonedTool = tool:Clone()
				clonedTool.Parent = backpack
			end
		end

		gear:Destroy()
	end
}


Commands.findgear = {
	Rank = Ranks.Mod,
	Aliases = {"fgear"},
	Syntax = Prefix .. "findgear <player> <gearname>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		local gearName = table.concat(args, " ", 3)

		if gearName == "" then
			Notify(executor, ScriptName, "Syntax error. Usage: " .. Commands.findgear.Syntax, 4)
			return
		end

		local url = "https://catalog.roproxy.com/v1/search/items?category=Accessories&includeNotForSale=true&limit=10&salesTypeFilter=1&subcategory=Gear&Keyword="
			.. HttpService:UrlEncode(gearName)

		local requestSuccess, response = pcall(function()
			return HttpService:GetAsync(url)
		end)

		if not requestSuccess then
			if not HttpService.HttpEnabled then
				Notify(executor, ScriptName, "HTTP requests are disabled. Enable Allow HTTP Requests in Game Settings > Security.", 5)
			else
				Notify(executor, ScriptName, "Unable to search for gear: " .. gearName, 4)
			end
			return
		end

		local decodeSuccess, data = pcall(function()
			return HttpService:JSONDecode(response)
		end)

		if not decodeSuccess or not data or not data.data or #data.data == 0 then
			Notify(executor, ScriptName, "Unable to find gear: " .. gearName, 4)
			return
		end

		local gearId = data.data[1].id

		if not gearId then
			Notify(executor, ScriptName, "Unable to find gear: " .. gearName, 4)
			return
		end

		local loadSuccess, loaded = pcall(function()
			return InsertService:LoadAsset(gearId)
		end)

		if not loadSuccess or not loaded then
			Notify(executor, ScriptName, "Unable to load gear: " .. gearName, 4)
			return
		end

		local tool = loaded:FindFirstChildWhichIsA("Tool", true)

		if not tool then
			loaded:Destroy()
			Notify(executor, ScriptName, "Unable to find gear: " .. gearName, 4)
			return
		end

		for _, target in ipairs(targets) do
			local backpack = target:FindFirstChildOfClass("Backpack")

			if backpack then
				local clonedTool = tool:Clone()
				clonedTool.Parent = backpack
			end
		end

		loaded:Destroy()
	end
}


Commands.heal = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."heal <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.Health = humanoid.MaxHealth
				end
			end
		end
	end
}


Commands.fling = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."fling <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")

				if root then
					local x = math.random(500, 1000)
					local y = math.random(500, 1000)
					local z = math.random(500, 1000)
					root.CFrame = root.CFrame * CFrame.Angles(math.pi, 0, 0)
					character:FindFirstChildOfClass("Humanoid").Sit = true
					root.AssemblyLinearVelocity = Vector3.new(x,y,z)
				end
			end
		end
	end
}


Commands.sword = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."sword <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local gearId = 125013769

		local success, gear = pcall(function()
			return InsertService:LoadAsset(gearId)
		end)

		if not success or not gear then
			Notify(executor, ScriptName, "Failed to get sword.")
			return
		end

		local tool = gear:FindFirstChildWhichIsA("Tool", true)

		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local backpack = target:FindFirstChildOfClass("Backpack")

				if backpack then
					local clonedTool = tool:Clone()
					clonedTool.Parent = backpack
				end
			end
		end

		gear:Destroy()
	end
}


Commands.r6 = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."r6 <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		for _, player in ipairs(targets) do
			local char = player.Character
			if not char then continue end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
				local success, desc = pcall(function()
					return game.Players:GetHumanoidDescriptionFromUserId(player.CharacterAppearanceId)
				end)

				if success and desc then
					local newAvatar = game.Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
					if newAvatar and char.PrimaryPart then
						newAvatar:SetPrimaryPartCFrame(char:GetPrimaryPartCFrame())

						for _, item in pairs(char:GetChildren()) do
							if item:IsA("Tool") or (item:IsA("LuaSourceContainer") and item.Name ~= "Animate") then
								item.Parent = newAvatar
							end
						end

						newAvatar.Name = player.Name
						player.Character = newAvatar
						newAvatar.Parent = Workspace
					end
				end
			end
		end
	end
}

Commands.r15 = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."r15 <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		for _, player in ipairs(targets) do
			local char = player.Character
			if not char then continue end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
				local success, desc = pcall(function()
					return game.Players:GetHumanoidDescriptionFromUserId(player.CharacterAppearanceId)
				end)

				if success and desc then
					local newAvatar = game.Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
					if newAvatar and char.PrimaryPart then
						newAvatar:SetPrimaryPartCFrame(char:GetPrimaryPartCFrame())

						for _, item in pairs(char:GetChildren()) do
							if item:IsA("Tool") or (item:IsA("LuaSourceContainer") and item.Name ~= "Animate") then
								item.Parent = newAvatar
							end
						end

						newAvatar.Name = player.Name
						player.Character = newAvatar
						newAvatar.Parent = Workspace
					end
				end
			end
		end
	end
}

Commands.reset = {
	Rank = Ranks.Mod,
	Aliases = {"re"},
	Syntax = Prefix.."reset <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		for _, player in ipairs(targets) do
			local character = player.Character
			if character and character.PrimaryPart then
				local position = character:GetPrimaryPartCFrame()
				local success, desc = pcall(function()
					return game.Players:GetHumanoidDescriptionFromUserId(player.UserId)
				end)

				if success and desc then
					local newChar = game.Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
					newChar.Name = player.Name
					newChar:SetPrimaryPartCFrame(position)

					for _, item in pairs(character:GetChildren()) do
						if item:IsA("Tool") or (item:IsA("LuaSourceContainer") and item.Name ~= "Animate") then
							item.Parent = newChar
						end
					end

					player.Character = newChar
					newChar.Parent = Workspace
				end
			end
		end
	end
}


Commands.god = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."god <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.MaxHealth = math.huge
					humanoid.Health = math.huge
				end
			end
		end
	end
}


Commands.stun = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."stun <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local hum = character:FindFirstChildOfClass("Humanoid")
				hum.PlatformStand = true
			end
		end
	end
}


Commands.unstun = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."unstun <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local hum = character:FindFirstChildOfClass("Humanoid")
				hum.PlatformStand = false
			end
		end
	end
}


Commands.sit = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."sit <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local hum = character:FindFirstChildOfClass("Humanoid")
				hum.Sit = true
			end
		end
	end
}


Commands.jump = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."jump <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local hum = character:FindFirstChildOfClass("Humanoid")
				hum.Jump = true
			end
		end
	end
}


Commands.trip = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."trip <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				local HRP = character:FindFirstChild("HumanoidRootPart")
				if HRP then
					HRP.CFrame = HRP.CFrame * CFrame.Angles(math.pi, 0, 0)
					HRP.AssemblyAngularVelocity = Vector3.new(25, 0, 0)
				end
			end
		end
	end
}


Commands.invisible = {
	Rank = Ranks.Mod,
	Aliases = {"invis"},
	Syntax = Prefix.."invisible <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				for i,v in character:GetDescendants() do
					if v:IsA("BasePart") then
						v.Transparency = 1
					end
				end
			end
		end
	end
}


Commands.visible = {
	Rank = Ranks.Mod,
	Aliases = {"vis", "uninvisible", "uninvis"},
	Syntax = Prefix.."visible <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				for i,v in character:GetDescendants() do
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
						v.Transparency = 0
					end
				end
			end
		end
	end
}


Commands.forcefield = {
	Rank = Ranks.Mod,
	Aliases = {"ff"},
	Syntax = Prefix.."forcefield <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				Instance.new("ForceField", character)
			end
		end
	end
}


Commands.unforcefield = {
	Rank = Ranks.Mod,
	Aliases = {"unff"},
	Syntax = Prefix.."unforcefield <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				for i,v in character:GetChildren() do
					if v:IsA("ForceField") then
						v:Destroy()
					end
				end
			end
		end
	end
}


Commands.rejoin = {
	Rank = Ranks.Mod,
	Aliases = {"rj"},
	Syntax = Prefix.."rejoin <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		for _, target in ipairs(targets) do
			if target ~= executor and GetRank(target) >= GetRank(executor) then
				Notify(
					executor,
					ScriptName,
					"You cannot force rejoin " .. target.Name .. " because they have the same or a higher rank.",
					4
				)
				continue
			end

			Notify(executor, ScriptName, "Rejoining " .. target.Name .. "...", 4)

			task.spawn(function()
				local success, err = pcall(function()
					TeleportService:TeleportToPlaceInstance(
						game.PlaceId,
						game.JobId,
						target
					)
				end)

				if not success then
					Notify(
						executor,
						ScriptName,
						"Failed to rejoin " .. target.Name .. ": " .. tostring(err),
						4
					)
				end
			end)
		end
	end
}


Commands.punish = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."punish <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		for _, target in ipairs(targets) do
			if PunishedPlayers[target.UserId] then
				continue
			end

			local PunishInfo = {}
			PunishedPlayers[target.UserId] = PunishInfo

			local function HideCharacter(character)
				task.spawn(function()
					while PunishedPlayers[target.UserId] == PunishInfo
						and target.Parent do

						if character.Parent ~= nil then
							character.Parent = nil
						end

						task.wait()
					end
				end)
			end

			PunishInfo.CharacterConnection = target.CharacterAdded:Connect(HideCharacter)

			local character = target.Character

			if character then
				HideCharacter(character)
			end
		end
	end
}

Commands.unpunish = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."unpunish <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		for _, target in ipairs(targets) do
			local PunishInfo = PunishedPlayers[target.UserId]

			if not PunishInfo then
				continue
			end

			PunishedPlayers[target.UserId] = nil

			if PunishInfo.CharacterConnection then
				PunishInfo.CharacterConnection:Disconnect()
			end

			local character = target.Character

			if character then
				character.Parent = Workspace
			end
		end
	end
}


Commands.noclip = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."noclip <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local groupName = "NoCollideTorso"

		if not PhysicsService:IsCollisionGroupRegistered(groupName) then
			PhysicsService:RegisterCollisionGroup(groupName)
		end

		PhysicsService:CollisionGroupSetCollidable(groupName, "Default", false)

		for _, target in ipairs(targets) do
			if NoClipPlayers[target.UserId] then
				continue
			end

			local character = target.Character

			if not character then
				continue
			end

			local NoClipInfo = {}
			NoClipPlayers[target.UserId] = NoClipInfo

			local function ProcessPart(part)
				if NoClipPlayers[target.UserId] ~= NoClipInfo then
					return
				end

				if part:IsA("BasePart")
					and part.Name ~= "HumanoidRootPart"
					and not part.Name:find("Leg")
					and not part.Name:find("Foot") then

					part.CollisionGroup = groupName
				end
			end

			for _, part in ipairs(character:GetDescendants()) do
				ProcessPart(part)
			end

			NoClipInfo.DescendantConnection = character.DescendantAdded:Connect(ProcessPart)
		end
	end
}


Commands.clip = {
	Rank = Ranks.Mod,
	Aliases = {"unnoclip"},
	Syntax = Prefix.."clip <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		for _, target in ipairs(targets) do
			local NoClipInfo = NoClipPlayers[target.UserId]

			if not NoClipInfo then
				continue
			end

			NoClipPlayers[target.UserId] = nil

			if NoClipInfo.CharacterConnection then
				NoClipInfo.CharacterConnection:Disconnect()
			end

			if NoClipInfo.DescendantConnection then
				NoClipInfo.DescendantConnection:Disconnect()
			end

			local character = target.Character

			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CollisionGroup = "Default"
					end
				end
			end
		end
	end
}


Commands.kick = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."kick <player> <reason> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		local reason = table.concat(args, " ", 3)

		if reason == "" then
			reason = "You have been kicked from the game"
		end

		for _, target in ipairs(targets) do
			if target == executor then
				Notify(executor, ScriptName, "You cannot kick yourself.", 4)
				continue
			end

			if GetRank(target) < GetRank(executor) then
				Notify(executor, ScriptName, "Kicked " .. target.Name .. ".", 4)
				target:Kick("[Moderatio1n's Admin]: " .. reason)
			else
				Notify(
					executor,
					ScriptName,
					"You cannot kick " .. target.Name .. " because they have the same or a higher rank.",
					4
				)
			end
		end
	end
}

Commands.explode = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."explode <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local blastPressure = tonumber(args[3]) or 500000
		local blastRadius = tonumber(args[4]) or 10

		for _, target in ipairs(targets) do
			local character = target.Character
			local root = character and (
				character:FindFirstChild("HumanoidRootPart")
					or character:FindFirstChild("UpperTorso")
					or character:FindFirstChild("Torso")
			)

			if root then
				local explosion = Instance.new("Explosion")
				explosion.Position = root.Position
				explosion.BlastPressure = blastPressure
				explosion.BlastRadius = blastRadius
				explosion.Parent = Workspace
			end
		end
	end
}

Commands.freeze = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."freeze <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				for i,v in character:GetChildren() do
					if v:IsA("BasePart") then
						v.Anchored = true
					end
				end
			end
		end
	end
}

Commands.unfreeze = {
	Rank = Ranks.Mod,
	Aliases = {"thaw"},
	Syntax = Prefix.."unfreeze <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end


		for _, target in ipairs(targets) do
			local character = target.Character

			if character then
				for i,v in character:GetChildren() do
					if v:IsA("BasePart") then
						v.Anchored = false
					end
				end
			end
		end
	end
}



Commands.btools = {
	Rank = Ranks.Admin,
	Aliases = {"f3x"},
	Syntax = Prefix.."btools <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local ok, result = pcall(function()
			local loader = require(580330877)

			if typeof(loader) == "function" then
				return loader()
			end

			return loader
		end)

		if not ok or typeof(result) ~= "Instance" or not result:IsA("Tool") then
			Notify(executor, ScriptName, "Failed to load F3X.", 4)
			return
		end

		result.Name = "Building Tools"
		result.CanBeDropped = false

		for _, target in ipairs(targets) do
			local Backpack = target:FindFirstChildOfClass("Backpack")

			if Backpack then
				local Tool = result:Clone()
				Tool.Parent = Backpack
			end
		end

		result:Destroy()
	end
}


Commands.jail = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix .. "jail <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		for _, target in ipairs(targets) do
			if JailedPlayers[target.UserId] then
				Notify(executor, ScriptName, target.Name .. " is already jailed.", 4)
				continue
			end

			local character = target.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")

			if not root then
				Notify(executor, ScriptName, target.Name .. " has no character to jail.", 4)
				continue
			end

			local Center = CFrame.new(root.Position + Vector3.new(0, 1, 0))

			local Jail = Instance.new("Model")
			Jail.Name = target.Name .. "'s Jail"

			local function CreatePart(name, size, offset, color, material, transparency, locked, rotation)
				local part = Instance.new("Part")
				part.Name = name
				part.Size = size
				part.CFrame = Center
					* CFrame.new(offset)
					* (rotation or CFrame.new())
				part.Color = color
				part.Material = material
				part.Transparency = transparency
				part.Anchored = true
				part.TopSurface = Enum.SurfaceType.Smooth
				part.BottomSurface = Enum.SurfaceType.Smooth
				part.Shape = Enum.PartType.Block
				part.Locked = locked
				part.Parent = Jail

				return part
			end

			CreatePart(
				"Base",
				Vector3.new(5, 1, 5),
				Vector3.new(0, -3.5, 0),
				Color3.fromRGB(2, 2, 2),
				Enum.Material.Plastic,
				0,
				true
			)

			CreatePart(
				"Wall",
				Vector3.new(5, 6, 0.1),
				Vector3.new(0, 0, -2.45),
				Color3.fromRGB(255, 255, 255),
				Enum.Material.Glass,
				0.5,
				true
			)

			CreatePart(
				"Wall",
				Vector3.new(5, 6, 0.1),
				Vector3.new(0, 0, 2.45),
				Color3.fromRGB(255, 255, 255),
				Enum.Material.Glass,
				0.5,
				true
			)

			CreatePart(
				"Wall",
				Vector3.new(5, 6, 0.1),
				Vector3.new(-2.45, 0, 0),
				Color3.fromRGB(255, 255, 255),
				Enum.Material.Glass,
				0.5,
				true,
				CFrame.Angles(0, math.rad(90), 0)
			)

			CreatePart(
				"Wall",
				Vector3.new(5, 6, 0.1),
				Vector3.new(2.45, 0, 0),
				Color3.fromRGB(255, 255, 255),
				Enum.Material.Glass,
				0.5,
				true,
				CFrame.Angles(0, math.rad(90), 0)
			)

			CreatePart(
				"Head",
				Vector3.new(5, 1, 5),
				Vector3.new(0, 3.5, 0),
				Color3.fromRGB(2, 2, 2),
				Enum.Material.Plastic,
				0,
				true
			)

			local JailHumanoid = Instance.new("Humanoid")
			JailHumanoid.Parent = Jail

			Jail.Parent = Workspace
			CollectionService:AddTag(Jail, "Moderatio1n's Jail")

			local JailInfo = {
				Model = Jail,
				Center = Center,
				Destroying = false,
				Connections = {},
				TrackedObjects = {}
			}

			JailedPlayers[target.UserId] = JailInfo

			local function TrackObject(object)
				if JailInfo.TrackedObjects[object] then
					return
				end

				local objectInfo = {
					Restoring = false,
					Destroying = false
				}

				JailInfo.TrackedObjects[object] = objectInfo

				table.insert(JailInfo.Connections, object.Destroying:Connect(function()
					objectInfo.Destroying = true
				end))

				table.insert(JailInfo.Connections, object.AncestryChanged:Connect(function()
					if objectInfo.Restoring
						or objectInfo.Destroying
						or JailInfo.Destroying
						or JailInfo.TrackedObjects[object] ~= objectInfo then
						return
					end

					if object.Parent == nil then
						objectInfo.Restoring = true

						task.defer(function()
							if not objectInfo.Destroying
								and not JailInfo.Destroying
								and JailInfo.TrackedObjects[object] == objectInfo
								and object.Parent == nil then

								if object == Jail then
									object.Parent = Workspace
								else
									object.Parent = Jail
								end
							end

							objectInfo.Restoring = false
						end)
					end
				end))
			end

			TrackObject(Jail)

			for _, object in ipairs(Jail:GetDescendants()) do
				TrackObject(object)
			end

			table.insert(JailInfo.Connections, Jail.DescendantAdded:Connect(function(object)
				TrackObject(object)

				for _, descendant in ipairs(object:GetDescendants()) do
					TrackObject(descendant)
				end
			end))

			JailInfo.DestroyingConnection = Jail.Destroying:Connect(function()
				JailInfo.Destroying = true

				if JailedPlayers[target.UserId] == JailInfo then
					JailedPlayers[target.UserId] = nil
				end

				for _, connection in ipairs(JailInfo.Connections) do
					connection:Disconnect()
				end

				table.clear(JailInfo.Connections)
				table.clear(JailInfo.TrackedObjects)

				if JailInfo.CharacterConnection then
					JailInfo.CharacterConnection:Disconnect()
				end
			end)

			local function ReturnToJail(characterToReturn)
				task.spawn(function()
					local characterRoot = characterToReturn:WaitForChild("HumanoidRootPart", 10)

					if not characterRoot then
						return
					end

					task.wait(0.1)

					if JailedPlayers[target.UserId] ~= JailInfo then
						return
					end

					characterRoot.CFrame = Center
					characterRoot.AssemblyLinearVelocity = Vector3.zero
					characterRoot.AssemblyAngularVelocity = Vector3.zero
				end)
			end

			JailInfo.CharacterConnection = target.CharacterAdded:Connect(ReturnToJail)

			root.CFrame = Center
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero

			task.spawn(function()
				while target.Parent and JailedPlayers[target.UserId] == JailInfo do
					task.wait(0.1)

					local currentCharacter = target.Character
					local currentRoot = currentCharacter
						and currentCharacter:FindFirstChild("HumanoidRootPart")

					if currentRoot then
						local localPosition = Center:PointToObjectSpace(currentRoot.Position)

						if math.abs(localPosition.X) > 2.5
							or math.abs(localPosition.Z) > 2.5
							or localPosition.Y < -2.5
							or localPosition.Y > 2.5 then

							currentRoot.CFrame = Center
							currentRoot.AssemblyLinearVelocity = Vector3.zero
							currentRoot.AssemblyAngularVelocity = Vector3.zero
						end
					end
				end
			end)
		end
	end
}


Commands.unjail = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix .. "unjail <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		for _, target in ipairs(targets) do
			local JailInfo = JailedPlayers[target.UserId]

			if not JailInfo then
				Notify(executor, ScriptName, target.Name .. " is not jailed.", 4)
				continue
			end

			if JailInfo.Model then
				JailInfo.Model:Destroy()
			else
				JailedPlayers[target.UserId] = nil

				if JailInfo.CharacterConnection then
					JailInfo.CharacterConnection:Disconnect()
				end
			end
		end
	end
}


Commands.teleport = {
	Rank = Ranks.Mod,
	Aliases = {"tp"},
	Syntax = Prefix.."teleport <player1> <player2>",

	Execute = function(executor, args)
		if not args[2] or not args[3] then
			Notify(executor, ScriptName, "Syntax: :teleport player1 player2")
			return
		end

		local targets1 = GetPlayers(args[2], executor)
		local targets2 = GetPlayers(args[3], executor)

		if #targets1 == 0 or #targets2 == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local character2 = targets2[1].Character
		local root2 = character2 and (
			character2:FindFirstChild("HumanoidRootPart")
				or character2:FindFirstChild("UpperTorso")
				or character2:FindFirstChild("Torso")
		)

		if not root2 then
			Notify(executor, ScriptName, "Second player's character not found.")
			return
		end

		local count = 0

		for _, target in ipairs(targets1) do
			local character1 = target.Character
			local root1 = character1 and (
				character1:FindFirstChild("HumanoidRootPart")
					or character1:FindFirstChild("UpperTorso")
					or character1:FindFirstChild("Torso")
			)

			if root1 then
				character1:PivotTo(root2.CFrame * CFrame.new(0, 0, -4))
				count += 1
			end
		end

		Notify(
			executor,
			ScriptName,
			"Teleported " .. count .. (count == 1 and " player." or " players.")
		)
	end
}

Commands.bring = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."bring <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local character = executor.Character
		local root = character and (
			character:FindFirstChild("HumanoidRootPart")
				or character:FindFirstChild("UpperTorso")
				or character:FindFirstChild("Torso")
		)

		if not root then
			return
		end


		for _, target in ipairs(targets) do
			local targetCharacter = target.Character
			local targetRoot = targetCharacter and (
				targetCharacter:FindFirstChild("HumanoidRootPart")
					or targetCharacter:FindFirstChild("UpperTorso")
					or targetCharacter:FindFirstChild("Torso")
			)

			if targetRoot then
				targetCharacter:PivotTo(root.CFrame * CFrame.new(0, 0, -4))
			end
		end
	end
}

Commands.goto = {
	Rank = Ranks.Mod,
	Aliases = {"to"},
	Syntax = Prefix.."goto <player> [optional]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local targetCharacter = targets[1].Character
		local targetRoot = targetCharacter and (
			targetCharacter:FindFirstChild("HumanoidRootPart")
				or targetCharacter:FindFirstChild("UpperTorso")
				or targetCharacter:FindFirstChild("Torso")
		)

		if not targetRoot then
			Notify(executor, ScriptName, "Target's character was not found.")
			return
		end

		local character = executor.Character

		if not character then
			Notify(executor, ScriptName, "Your character was not found.")
			return
		end

		character:PivotTo(targetRoot.CFrame * CFrame.new(0, 0, -4))
	end
}


Commands.s = {
	Rank = Ranks.HeadAdmin,
	Aliases = {"ss"},
	Syntax = Prefix.."s <code>",

	Execute = function(executor, args)
		local code = table.concat(args, " ", 2)

		if code == "" then
			Notify(executor, ScriptName, "Syntax error. \nSyntax: "..Commands.s.Syntax)
			return
		end

		local module, err = GetLoadstringModule()

		if not module then
			Notify(executor, ScriptName, "Unable to load the Loadstring module: "..tostring(err))
			return
		end

		local success, executionError = pcall(function()
			module:SpawnS(code, ServerScriptService)
		end)

		if not success then
			Notify(executor, ScriptName, "Execution error: "..tostring(executionError))
		end
	end
}


Commands.cs = {
	Rank = Ranks.HeadAdmin,
	Aliases = {"ls"},
	Syntax = Prefix.."cs <player> <code>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local code = table.concat(args, " ", 3)

		if code == "" then
			Notify(executor, ScriptName, "Syntax error. Usage: "..Commands.cs.Syntax)
			return
		end

		local module, err = GetLoadstringModule()

		if not module then
			Notify(executor, ScriptName, "Unable to load the Loadstring module: "..tostring(err))
			return
		end

		for _, target in ipairs(targets) do
			if target ~= executor and GetRank(target) >= GetRank(executor) then
				Notify(executor, ScriptName, "You can't execute code on players with the same or a higher rank.")
				continue
			end

			local playerGui = target:FindFirstChildOfClass("PlayerGui")

			if not playerGui then
				Notify(executor, ScriptName, "Unable to find PlayerGui for "..target.Name..".")
				continue
			end

			local LocalScriptStorage = Instance.new("ScreenGui")
			LocalScriptStorage.Name = "LocalScriptStorage"
			LocalScriptStorage.ResetOnSpawn = false
			LocalScriptStorage.Parent = playerGui

			local executed, executionError = pcall(function()
				task.spawn(function()
					module:SpawnL(code, LocalScriptStorage)
				end)
			end)

			if not executed then
				LocalScriptStorage:Destroy()
				Notify(executor, ScriptName, "Execution error for "..target.Name..": "..tostring(executionError))
			end
		end
	end
}


Commands.crash = {
	Rank = Ranks.Admin,
	Aliases = {},
	Syntax = Prefix.."crash <player>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local code = [[while true do
		game.Players.LocalPlayer.PlayerGui.LocalScriptStorageCrash:Clone().Parent = game.Players.LocalPlayer.PlayerGui
	end]]

		local module, err = GetLoadstringModule()

		if not module then
			Notify(executor, ScriptName, "Unable to load the Loadstring module: "..tostring(err))
			return
		end

		for _, target in ipairs(targets) do

			if target == executor then
				Notify(executor, ScriptName, "You cannot crash yourself.", 4)
				continue
			end

			if GetRank(target) >= GetRank(executor) then
				Notify(executor, ScriptName, "You can't crash players with the same or a higher rank.")
				continue
			end

			local playerGui = target:FindFirstChildOfClass("PlayerGui")

			if not playerGui then
				Notify(executor, ScriptName, "Unable to find PlayerGui for "..target.Name..".")
				continue
			end

			local LocalScriptStorage = Instance.new("ScreenGui")
			LocalScriptStorage.Name = "LocalScriptStorageCrash"
			LocalScriptStorage.ResetOnSpawn = false
			LocalScriptStorage.Parent = playerGui

			local executed, executionError = pcall(function()
				task.spawn(function()
					module:SpawnL(code, LocalScriptStorage)
				end)
			end)

			if not executed then
				LocalScriptStorage:Destroy()
				Notify(executor, ScriptName, "Execution error for "..target.Name..": "..tostring(executionError))
			end
		end
	end
}


Commands.chat = {
	Rank = Ranks.Admin,
	Aliases = {"speak", "talk"},
	Syntax = Prefix.."chat <player> <message>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local message = table.concat(args, " ", 3)


		if message == "" then
			Notify(executor, ScriptName, "Syntax error. \nSyntax: "..Commands.chat.Syntax)
			return
		end

		local code = [[
		local TextChatService = game:GetService("TextChatService")
		local generalChannel = TextChatService.TextChannels.RBXGeneral 
		generalChannel:SendAsync("]] .. message .. [[")]]

		local module, err = GetLoadstringModule()

		if not module or typeof(module.SpawnL) ~= "function" then
			Notify(executor, ScriptName, "Unable to load the Loadstring module or find SpawnL.")
			return
		end

		for _, target in ipairs(targets) do
			if target ~= executor and GetRank(target) >= GetRank(executor) then
				Notify(executor, ScriptName, "You can't force chat players with the same or a higher rank.")
				continue
			end

			local playerGui = target:FindFirstChildOfClass("PlayerGui")

			local LocalScriptStorage = Instance.new("ScreenGui")
			LocalScriptStorage.Name = "LocalScriptStorage"
			LocalScriptStorage.ResetOnSpawn = false
			LocalScriptStorage.Parent = playerGui

			local executed, err = pcall(function()
				module:SpawnL(code, target:WaitForChild("PlayerGui"))
			end)

			if not executed then
				Notify(executor, ScriptName, "Execution error for "..target.Name..": "..tostring(err))
			end
		end
	end
}


Commands.shutdown = {
	Rank = Ranks.HeadAdmin,
	Aliases = {},
	Syntax = Prefix.."shutdown <reason> [optional]",

	Execute = function(executor, args)
		local reason = table.concat(args, " ", 2)
		if reason == "" then
			reason = "The server has been shut down."
		end

		task.spawn(function()
			while true do
				task.wait(0)

				for _, player in ipairs(Players:GetPlayers()) do
					player:Kick("[Moderatio1n's Admin]: " .. reason)
				end
			end
		end)
	end
}

Commands.respawn = {
	Rank = Ranks.Mod,
	Aliases = {"res"},
	Syntax = Prefix.."respawn <player> [optional]",
	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		for _, target in ipairs(targets) do
			task.spawn(function()
				pcall(function()
					target:LoadCharacterAsync()
				end)
			end)
		end
	end
}

Commands.ban = {
	Rank = Ranks.Admin,
	Aliases = {"serverban", "sban"},
	Syntax = Prefix .. "ban <player> <reason> [optional]",

	Execute = function(executor, args)
		local reason = table.concat(args, " ", 3)

		if reason == "" then
			reason = "The banhammer has spoken."
		end

		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		for _, target in ipairs(targets) do
			if target == executor then
				Notify(executor, ScriptName, "You cannot ban yourself.", 4)
				continue
			end

			if GetRank(target) >= GetRank(executor) then
				Notify(
					executor,
					ScriptName,
					"You cannot ban " .. target.Name .. " because they have the same or a higher rank.",
					4
				)
				continue
			end

			ServerBans[target.UserId] = {
				Name = target.Name,
				DisplayName = target.DisplayName,
				Reason = reason,
				Rank = GetRank(executor)
			}

			target:Kick("[Moderatio1n's Admin]: " .. reason)
			Notify(executor, ScriptName, "Banned " .. target.Name .. ".", 4)
		end
	end
}

Commands.unban = {
	Rank = Ranks.Admin,
	Aliases = {"unsban", "unserverban"},
	Syntax = Prefix .."unban <player>",

	Execute = function(executor, args)
		local targetName = table.concat(args, " ", 2):lower()

		if targetName == "" then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		local closestUserId
		local closestName
		local closestRank
		local bestMatch = math.huge

		for userId, banInfo in pairs(ServerBans) do
			local username = type(banInfo) == "table" and banInfo.Name or nil
			local displayName = type(banInfo) == "table" and banInfo.DisplayName or nil

			if not username then
				local onlinePlayer = Players:GetPlayerByUserId(userId)
				if onlinePlayer then
					username = onlinePlayer.Name
					displayName = onlinePlayer.DisplayName
				end
			end

			if username then
				local names = {
					username,
					displayName or username
				}

				for _, name in ipairs(names) do
					name = name:lower()

					local position = name:find(targetName, 1, true)
					if position then
						local score = position + math.abs(#name - #targetName)

						if score < bestMatch then
							bestMatch = score
							closestUserId = userId
							closestName = username
							closestRank = type(banInfo) == "table" and banInfo.Rank or 0
						end
					end
				end
			end
		end

		if not closestUserId then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		if closestRank > GetRank(executor) then
			Notify(
				executor,
				ScriptName,
				"You cannot unban " .. closestName .. " because they were banned by someone with a higher rank.",
				4
			)
			return
		end

		ServerBans[closestUserId] = nil
		Notify(executor, ScriptName, "Unbanned " .. closestName .. ".", 4)
	end
}

Commands.rank = {
	Rank = Ranks.HeadAdmin,
	Aliases = {"setrank"},
	Syntax = Prefix .. "rank <player> <rankname>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		local rankName = args[3] and args[3]:lower()

		local RankNames = {
			owner = Ranks.Owner,
			headadmin = Ranks.HeadAdmin,
			admin = Ranks.Admin,
			mod = Ranks.Mod,
			nonadmin = Ranks.NonAdmin
		}

		local newRank = rankName and RankNames[rankName]

		if newRank == nil then
			Notify(
				executor,
				ScriptName,
				"Rank: " .. (args[3] or "") .. " not found.\nAvailable ranks: Owner, HeadAdmin, Admin, Mod, NonAdmin",
				5
			)
			return
		end

		if newRank >= GetRank(executor) then
			Notify(
				executor,
				ScriptName,
				"You cannot assign a rank equal to or higher than your own.",
				4
			)
			return
		end

		for _, target in ipairs(targets) do
			if target == executor then
				Notify(executor, ScriptName, "You cannot change your own rank.", 4)
				continue
			end

			if GetRank(target) >= GetRank(executor) then
				Notify(
					executor,
					ScriptName,
					"You cannot change the rank of " .. target.Name .. " as they have the same or a higher rank.",
					4
				)
				continue
			end

			PlayerRanks[target.UserId] = newRank

			local formattedRank = rankName:sub(1, 1):upper() .. rankName:sub(2)

			Notify(
				executor,
				ScriptName,
				"Changed " .. target.Name .. "'s rank to " .. formattedRank .. ".",
				4
			)

			Notify(
				target,
				ScriptName,
				"Your rank has been changed to " .. formattedRank .. ".",
				4
			)
		end
	end
}

Commands.createteam = {
	Rank = Ranks.Mod,
	Aliases = {"addteam"},
	Syntax = Prefix .. "createteam <teamname> <teamcolor> [optional]",

	Execute = function(executor, args)
		local teamName = args[2]
		local colorName = table.concat(args, " ", 3)

		if not teamName then
			Notify(
				executor,
				ScriptName,
				"Invalid syntax.\nSyntax: " .. Prefix .. Commands.createteam.Syntax,
				4
			)
			return
		end

		local brickColor = colorName ~= "" and BrickColor.new(colorName) or BrickColor.new()

		local Teams = game:GetService("Teams")

		local team = Instance.new("Team")
		team.Name = teamName
		team.TeamColor = brickColor
		team.Parent = Teams
	end
}

Commands.deleteteam = {
	Rank = Ranks.Mod,
	Aliases = {"removeteam"},
	Syntax = Prefix .. "deleteteam <teamname>",
	Execute = function(executor, args)
		local teamName = table.concat(args, " ", 2)

		local Teams = game:GetService("Teams")
		local team = Teams:FindFirstChild(teamName)

		if not team or not team:IsA("Team") then
			Notify(executor, ScriptName, "Team '" .. teamName .. "' does not exist.", 4)
			return
		end

		team:Destroy()
	end
}

Commands.team = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix .. "team <player> <teamname>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		local teamName = table.concat(args, " ", 3)
		local Teams = game:GetService("Teams")
		local team = Teams:FindFirstChild(teamName)

		if not team or not team:IsA("Team") then
			Notify(executor, ScriptName, "Team '" .. teamName .. "' does not exist.", 4)
			return
		end

		for _, target in ipairs(targets) do
			target.Team = team
			target.Neutral = false
		end
	end
}

Commands.createstat = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix .. "createstat <statname> <stattype>",

	Execute = function(executor, args)
		local statName = args[2]
		local statType = args[3] and args[3]:lower()

		if not statName or not statType then
			Notify(executor, ScriptName, "Invalid syntax.\nSyntax: " .. Prefix .. Commands.createstat.Syntax, 4)
			return
		end

		local StatTypes = {
			int = "IntValue",
			number = "NumberValue",
			string = "StringValue",
			bool = "BoolValue"
		}

		local className = StatTypes[statType]

		if not className then
			Notify(executor, ScriptName, "Invalid stat type.\nAvailable types: Int, Number, String, Bool", 4)
			return
		end

		local key = statName:lower()

		if GlobalStats[key] then
			Notify(executor, ScriptName, "A global stat named " .. statName .. " already exists.", 4)
			return
		end

		local initialValue = 0

		if className == "StringValue" then
			initialValue = ""
		elseif className == "BoolValue" then
			initialValue = false
		end

		GlobalStats[key] = {
			Name = statName,
			ClassName = className,
			Value = initialValue
		}

		for _, player in ipairs(Players:GetPlayers()) do
			local leaderstats = player:FindFirstChild("leaderstats")

			if not leaderstats then
				leaderstats = Instance.new("Folder")
				leaderstats.Name = "leaderstats"
				leaderstats.Parent = player
			end

			if not leaderstats:FindFirstChild(statName) then
				local stat = Instance.new(className)
				stat.Name = statName
				stat.Value = initialValue
				stat.Parent = leaderstats
			end
		end

		Notify(executor, ScriptName, "Created global stat " .. statName .. ".", 4)
	end
}

Commands.removestat = {
	Rank = Ranks.Mod,
	Aliases = {"deletestat"},
	Syntax = Prefix .. "removestat <statname>",

	Execute = function(executor, args)
		local statName = table.concat(args, " ", 2)

		if statName == "" then
			Notify(executor, ScriptName, "Invalid syntax.\nSyntax: " .. Prefix .. Commands.removestat.Syntax, 4)
			return
		end

		local key = statName:lower()
		local globalStat = GlobalStats[key]

		if not globalStat then
			Notify(executor, ScriptName, "No global stat named " .. statName .. " exists.", 4)
			return
		end

		GlobalStats[key] = nil

		for _, player in ipairs(Players:GetPlayers()) do
			local leaderstats = player:FindFirstChild("leaderstats")
			local stat = leaderstats and leaderstats:FindFirstChild(globalStat.Name)

			if stat then
				stat:Destroy()
			end
		end

		Notify(executor, ScriptName, "Removed global stat " .. globalStat.Name .. ".", 4)
	end
}

Commands.setstat = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix .. "setstat <player> <statname> <value>",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.", 4)
			return
		end

		local statName = args[3]
		local value = table.concat(args, " ", 4)

		if not statName or value == "" then
			Notify(executor, ScriptName, "Invalid syntax.\nSyntax: " .. Prefix .. Commands.setstat.Syntax, 4)
			return
		end

		local globalStat = GlobalStats[statName:lower()]

		if not globalStat then
			Notify(executor, ScriptName, "No global stat named " .. statName .. " exists.", 4)
			return
		end

		local newValue

		if globalStat.ClassName == "IntValue" then
			newValue = tonumber(value)

			if not newValue then
				Notify(executor, ScriptName, "Value must be a number.", 4)
				return
			end

			newValue = math.floor(newValue)
		elseif globalStat.ClassName == "NumberValue" then
			newValue = tonumber(value)

			if not newValue then
				Notify(executor, ScriptName, "Value must be a number.", 4)
				return
			end
		elseif globalStat.ClassName == "StringValue" then
			newValue = value
		elseif globalStat.ClassName == "BoolValue" then
			value = value:lower()

			if value ~= "true" and value ~= "false" then
				Notify(executor, ScriptName, "Value must be true or false.", 4)
				return
			end

			newValue = value == "true"
		end

		for _, target in ipairs(targets) do
			local leaderstats = target:FindFirstChild("leaderstats")
			local stat = leaderstats and leaderstats:FindFirstChild(globalStat.Name)

			if not stat then
				Notify(executor, ScriptName, target.Name .. " does not have the stat " .. globalStat.Name .. ".", 4)
				continue
			end

			stat.Value = newValue
			Notify(executor, ScriptName, "Set " .. target.Name .. "'s " .. globalStat.Name .. " to " .. tostring(newValue) .. ".", 4)
		end
	end
}


Commands.commands = {
	Rank = Ranks.Mod,
	Aliases = {"cmds"},
	Syntax = Prefix.."commands [player]",

	Execute = function(executor, args)
		local targets = GetPlayers(args[2], executor)

		if #targets == 0 then
			Notify(executor, ScriptName, "No matching player found.")
			return
		end

		local RankNames = {
			[4] = "Owner",
			[3] = "HeadAdmin",
			[2] = "Admin",
			[1] = "Mod",
			[0] = "NonAdmin"
		}

		local CommandNames = {}

		for commandName in pairs(Commands) do
			table.insert(CommandNames, commandName)
		end

		table.sort(CommandNames)

		for _, target in ipairs(targets) do
			local playerGui = target:FindFirstChildOfClass("PlayerGui")

			if not playerGui then
				continue
			end

			local existingGui = playerGui:FindFirstChild("Moderatio1n's Admin Commands")

			if existingGui then
				existingGui:Destroy()
			end

			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Name = "Moderatio1n's Admin Commands"
			ScreenGui.ResetOnSpawn = false
			ScreenGui.DisplayOrder = 50
			ScreenGui.Parent = playerGui

			local MainFrame = Instance.new("Frame")
			MainFrame.Name = "MainFrame"
			MainFrame.AnchorPoint = Vector2.new(0.5, 0)
			MainFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
			MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
			MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			MainFrame.BorderSizePixel = 0
			MainFrame.Parent = ScreenGui

			local SizeConstraint = Instance.new("UISizeConstraint")
			SizeConstraint.MinSize = Vector2.new(280, 42)
			SizeConstraint.MaxSize = Vector2.new(520, 400)
			SizeConstraint.Parent = MainFrame

			local MainCorner = Instance.new("UICorner")
			MainCorner.CornerRadius = UDim.new(0, 8)
			MainCorner.Parent = MainFrame

			local TitleBar = Instance.new("Frame")
			TitleBar.Name = "TitleBar"
			TitleBar.Size = UDim2.new(1, 0, 0, 42)
			TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			TitleBar.BorderSizePixel = 0
			TitleBar.Parent = MainFrame

			local TitleCorner = Instance.new("UICorner")
			TitleCorner.CornerRadius = UDim.new(0, 8)
			TitleCorner.Parent = TitleBar

			local TitleBarCover = Instance.new("Frame")
			TitleBarCover.Size = UDim2.new(1, 0, 0, 8)
			TitleBarCover.Position = UDim2.new(0, 0, 1, -8)
			TitleBarCover.BackgroundColor3 = TitleBar.BackgroundColor3
			TitleBarCover.BorderSizePixel = 0
			TitleBarCover.Parent = TitleBar

			local Title = Instance.new("TextLabel")
			Title.Name = "Title"
			Title.Position = UDim2.new(0, 12, 0, 0)
			Title.Size = UDim2.new(1, -100, 1, 0)
			Title.BackgroundTransparency = 1
			Title.Text = "Moderatio1n's Admin"
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextSize = 16
			Title.Font = Enum.Font.GothamBold
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = TitleBar

			local MinimizeButton = Instance.new("TextButton")
			MinimizeButton.Name = "MinimizeButton"
			MinimizeButton.Position = UDim2.new(1, -64, 0, 7)
			MinimizeButton.Size = UDim2.new(0, 24, 0, 28)
			MinimizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
			MinimizeButton.BorderSizePixel = 0
			MinimizeButton.Text = "−"
			MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			MinimizeButton.TextSize = 20
			MinimizeButton.Font = Enum.Font.GothamBold
			MinimizeButton.Parent = TitleBar

			local MinimizeCorner = Instance.new("UICorner")
			MinimizeCorner.CornerRadius = UDim.new(0, 5)
			MinimizeCorner.Parent = MinimizeButton

			local CloseButton = Instance.new("TextButton")
			CloseButton.Name = "CloseButton"
			CloseButton.Position = UDim2.new(1, -34, 0, 7)
			CloseButton.Size = UDim2.new(0, 24, 0, 28)
			CloseButton.BackgroundColor3 = Color3.fromRGB(170, 45, 50)
			CloseButton.BorderSizePixel = 0
			CloseButton.Text = "X"
			CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			CloseButton.TextSize = 14
			CloseButton.Font = Enum.Font.GothamBold
			CloseButton.Parent = TitleBar

			local CloseCorner = Instance.new("UICorner")
			CloseCorner.CornerRadius = UDim.new(0, 5)
			CloseCorner.Parent = CloseButton

			local Content = Instance.new("Frame")
			Content.Name = "Content"
			Content.Position = UDim2.new(0, 0, 0, 42)
			Content.Size = UDim2.new(1, 0, 1, -42)
			Content.BackgroundTransparency = 1
			Content.Visible = true
			Content.Parent = MainFrame

			local Sidebar = Instance.new("Frame")
			Sidebar.Name = "Sidebar"
			Sidebar.Size = UDim2.new(0, 112, 1, 0)
			Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
			Sidebar.BorderSizePixel = 0
			Sidebar.Parent = Content

			local CommandsTab = Instance.new("TextButton")
			CommandsTab.Name = "CommandsTab"
			CommandsTab.Position = UDim2.new(0, 6, 0, 8)
			CommandsTab.Size = UDim2.new(1, -12, 0, 34)
			CommandsTab.BackgroundColor3 = Color3.fromRGB(70, 100, 180)
			CommandsTab.BorderSizePixel = 0
			CommandsTab.Text = "Commands"
			CommandsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
			CommandsTab.TextSize = 12
			CommandsTab.Font = Enum.Font.GothamBold
			CommandsTab.Parent = Sidebar

			local CommandsTabCorner = Instance.new("UICorner")
			CommandsTabCorner.CornerRadius = UDim.new(0, 5)
			CommandsTabCorner.Parent = CommandsTab

			local BansTab = Instance.new("TextButton")
			BansTab.Name = "BansTab"
			BansTab.Position = UDim2.new(0, 6, 0, 48)
			BansTab.Size = UDim2.new(1, -12, 0, 34)
			BansTab.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
			BansTab.BorderSizePixel = 0
			BansTab.Text = "Bans"
			BansTab.TextColor3 = Color3.fromRGB(255, 255, 255)
			BansTab.TextSize = 12
			BansTab.Font = Enum.Font.GothamBold
			BansTab.Parent = Sidebar

			local BansTabCorner = Instance.new("UICorner")
			BansTabCorner.CornerRadius = UDim.new(0, 5)
			BansTabCorner.Parent = BansTab

			local Pages = Instance.new("Frame")
			Pages.Name = "Pages"
			Pages.Position = UDim2.new(0, 112, 0, 0)
			Pages.Size = UDim2.new(1, -112, 1, 0)
			Pages.BackgroundTransparency = 1
			Pages.Parent = Content

			local CommandsPage = Instance.new("Frame")
			CommandsPage.Name = "CommandsPage"
			CommandsPage.Size = UDim2.new(1, 0, 1, 0)
			CommandsPage.BackgroundTransparency = 1
			CommandsPage.Parent = Pages

			local CommandsScroll = Instance.new("ScrollingFrame")
			CommandsScroll.Name = "CommandsScroll"
			CommandsScroll.Position = UDim2.new(0, 6, 0, 6)
			CommandsScroll.Size = UDim2.new(1, -12, 1, -12)
			CommandsScroll.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
			CommandsScroll.BorderSizePixel = 0
			CommandsScroll.ScrollBarThickness = 5
			CommandsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			CommandsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			CommandsScroll.Parent = CommandsPage

			local CommandsScrollCorner = Instance.new("UICorner")
			CommandsScrollCorner.CornerRadius = UDim.new(0, 5)
			CommandsScrollCorner.Parent = CommandsScroll

			local CommandsPadding = Instance.new("UIPadding")
			CommandsPadding.PaddingTop = UDim.new(0, 6)
			CommandsPadding.PaddingBottom = UDim.new(0, 6)
			CommandsPadding.PaddingLeft = UDim.new(0, 6)
			CommandsPadding.PaddingRight = UDim.new(0, 6)
			CommandsPadding.Parent = CommandsScroll

			local CommandsLayout = Instance.new("UIListLayout")
			CommandsLayout.Padding = UDim.new(0, 6)
			CommandsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			CommandsLayout.Parent = CommandsScroll

			for index, commandName in ipairs(CommandNames) do
				local command = Commands[commandName]

				local Entry = Instance.new("Frame")
				Entry.Name = commandName
				Entry.Size = UDim2.new(1, 0, 0, 76)
				Entry.BackgroundColor3 = Color3.fromRGB(43, 43, 51)
				Entry.BorderSizePixel = 0
				Entry.LayoutOrder = index
				Entry.Parent = CommandsScroll

				local EntryCorner = Instance.new("UICorner")
				EntryCorner.CornerRadius = UDim.new(0, 5)
				EntryCorner.Parent = Entry

				local CommandLabel = Instance.new("TextLabel")
				CommandLabel.Position = UDim2.new(0, 8, 0, 5)
				CommandLabel.Size = UDim2.new(1, -16, 0, 20)
				CommandLabel.BackgroundTransparency = 1
				CommandLabel.Text = commandName
				CommandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				CommandLabel.TextSize = 14
				CommandLabel.Font = Enum.Font.GothamBold
				CommandLabel.TextXAlignment = Enum.TextXAlignment.Left
				CommandLabel.Parent = Entry

				local RankLabel = Instance.new("TextLabel")
				RankLabel.Position = UDim2.new(0, 8, 0, 26)
				RankLabel.Size = UDim2.new(1, -16, 0, 16)
				RankLabel.BackgroundTransparency = 1
				RankLabel.Text = "Rank: "..(RankNames[command.Rank] or "Unknown")
				RankLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
				RankLabel.TextSize = 11
				RankLabel.Font = Enum.Font.Gotham
				RankLabel.TextXAlignment = Enum.TextXAlignment.Left
				RankLabel.Parent = Entry

				local SyntaxLabel = Instance.new("TextLabel")
				SyntaxLabel.Position = UDim2.new(0, 8, 0, 43)
				SyntaxLabel.Size = UDim2.new(1, -16, 0, 16)
				SyntaxLabel.BackgroundTransparency = 1
				SyntaxLabel.Text = "Syntax: "..tostring(command.Syntax or "Not specified")
				SyntaxLabel.TextColor3 = Color3.fromRGB(170, 200, 255)
				SyntaxLabel.TextSize = 10
				SyntaxLabel.Font = Enum.Font.Gotham
				SyntaxLabel.TextXAlignment = Enum.TextXAlignment.Left
				SyntaxLabel.TextTruncate = Enum.TextTruncate.AtEnd
				SyntaxLabel.Parent = Entry

				local AliasesLabel = Instance.new("TextLabel")
				AliasesLabel.Position = UDim2.new(0, 8, 0, 59)
				AliasesLabel.Size = UDim2.new(1, -16, 0, 13)
				AliasesLabel.BackgroundTransparency = 1
				AliasesLabel.Text = "Aliases: "..(#(command.Aliases or {}) > 0 and table.concat(command.Aliases, ", ") or "None")
				AliasesLabel.TextColor3 = Color3.fromRGB(175, 175, 185)
				AliasesLabel.TextSize = 10
				AliasesLabel.Font = Enum.Font.Gotham
				AliasesLabel.TextXAlignment = Enum.TextXAlignment.Left
				AliasesLabel.TextTruncate = Enum.TextTruncate.AtEnd
				AliasesLabel.Parent = Entry
			end

			local BansPage = Instance.new("Frame")
			BansPage.Name = "BansPage"
			BansPage.Size = UDim2.new(1, 0, 1, 0)
			BansPage.BackgroundTransparency = 1
			BansPage.Visible = false
			BansPage.Parent = Pages

			local RefreshBansButton = Instance.new("TextButton")
			RefreshBansButton.Name = "RefreshBansButton"
			RefreshBansButton.Position = UDim2.new(0, 6, 0, 6)
			RefreshBansButton.Size = UDim2.new(1, -12, 0, 30)
			RefreshBansButton.BackgroundColor3 = Color3.fromRGB(55, 75, 125)
			RefreshBansButton.BorderSizePixel = 0
			RefreshBansButton.Text = "Refresh Bans"
			RefreshBansButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			RefreshBansButton.TextSize = 12
			RefreshBansButton.Font = Enum.Font.GothamBold
			RefreshBansButton.Parent = BansPage

			local RefreshCorner = Instance.new("UICorner")
			RefreshCorner.CornerRadius = UDim.new(0, 5)
			RefreshCorner.Parent = RefreshBansButton

			local BansScroll = Instance.new("ScrollingFrame")
			BansScroll.Name = "BansScroll"
			BansScroll.Position = UDim2.new(0, 6, 0, 42)
			BansScroll.Size = UDim2.new(1, -12, 1, -48)
			BansScroll.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
			BansScroll.BorderSizePixel = 0
			BansScroll.ScrollBarThickness = 5
			BansScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			BansScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			BansScroll.Parent = BansPage

			local BansScrollCorner = Instance.new("UICorner")
			BansScrollCorner.CornerRadius = UDim.new(0, 5)
			BansScrollCorner.Parent = BansScroll

			local BansPadding = Instance.new("UIPadding")
			BansPadding.PaddingTop = UDim.new(0, 6)
			BansPadding.PaddingBottom = UDim.new(0, 6)
			BansPadding.PaddingLeft = UDim.new(0, 6)
			BansPadding.PaddingRight = UDim.new(0, 6)
			BansPadding.Parent = BansScroll

			local BansLayout = Instance.new("UIListLayout")
			BansLayout.Padding = UDim.new(0, 6)
			BansLayout.SortOrder = Enum.SortOrder.LayoutOrder
			BansLayout.Parent = BansScroll

			local function RefreshBans()
				for _, child in ipairs(BansScroll:GetChildren()) do
					if child:IsA("Frame") or child:IsA("TextLabel") then
						child:Destroy()
					end
				end

				local BanEntries = {}

				for userId, banData in pairs(ServerBans) do
					table.insert(BanEntries, {
						UserId = userId,
						Data = banData
					})
				end

				table.sort(BanEntries, function(a, b)
					return tostring(a.Data.DisplayName or a.Data.Name or a.UserId):lower()
						< tostring(b.Data.DisplayName or b.Data.Name or b.UserId):lower()
				end)

				if #BanEntries == 0 then
					local EmptyLabel = Instance.new("TextLabel")
					EmptyLabel.Size = UDim2.new(1, 0, 0, 40)
					EmptyLabel.BackgroundTransparency = 1
					EmptyLabel.Text = "No banned players."
					EmptyLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
					EmptyLabel.TextSize = 13
					EmptyLabel.Font = Enum.Font.Gotham
					EmptyLabel.Parent = BansScroll
					return
				end

				for index, entry in ipairs(BanEntries) do
					local banData = entry.Data

					local BanEntry = Instance.new("Frame")
					BanEntry.Name = tostring(entry.UserId)
					BanEntry.Size = UDim2.new(1, 0, 0, 94)
					BanEntry.BackgroundColor3 = Color3.fromRGB(43, 43, 51)
					BanEntry.BorderSizePixel = 0
					BanEntry.LayoutOrder = index
					BanEntry.Parent = BansScroll

					local BanEntryCorner = Instance.new("UICorner")
					BanEntryCorner.CornerRadius = UDim.new(0, 5)
					BanEntryCorner.Parent = BanEntry

					local BanName = Instance.new("TextLabel")
					BanName.Position = UDim2.new(0, 8, 0, 5)
					BanName.Size = UDim2.new(1, -16, 0, 18)
					BanName.BackgroundTransparency = 1
					BanName.Text = tostring(banData.DisplayName or banData.Name or entry.UserId)
						.." (@"..tostring(banData.Name or "Unknown")..")"
					BanName.TextColor3 = Color3.fromRGB(255, 255, 255)
					BanName.TextSize = 12
					BanName.Font = Enum.Font.GothamBold
					BanName.TextXAlignment = Enum.TextXAlignment.Left
					BanName.TextTruncate = Enum.TextTruncate.AtEnd
					BanName.Parent = BanEntry

					local BanUserId = Instance.new("TextLabel")
					BanUserId.Position = UDim2.new(0, 8, 0, 24)
					BanUserId.Size = UDim2.new(1, -16, 0, 15)
					BanUserId.BackgroundTransparency = 1
					BanUserId.Text = "UserId: "..tostring(entry.UserId)
					BanUserId.TextColor3 = Color3.fromRGB(180, 180, 190)
					BanUserId.TextSize = 10
					BanUserId.Font = Enum.Font.Gotham
					BanUserId.TextXAlignment = Enum.TextXAlignment.Left
					BanUserId.Parent = BanEntry

					local BanReason = Instance.new("TextLabel")
					BanReason.Position = UDim2.new(0, 8, 0, 41)
					BanReason.Size = UDim2.new(1, -16, 0, 26)
					BanReason.BackgroundTransparency = 1
					BanReason.Text = "Reason: "..tostring(banData.Reason or "No reason provided.")
					BanReason.TextColor3 = Color3.fromRGB(220, 180, 180)
					BanReason.TextSize = 10
					BanReason.Font = Enum.Font.Gotham
					BanReason.TextXAlignment = Enum.TextXAlignment.Left
					BanReason.TextYAlignment = Enum.TextYAlignment.Top
					BanReason.TextWrapped = true
					BanReason.Parent = BanEntry

					local BanRank = Instance.new("TextLabel")
					BanRank.Position = UDim2.new(0, 8, 0, 70)
					BanRank.Size = UDim2.new(1, -16, 0, 16)
					BanRank.BackgroundTransparency = 1
					BanRank.Text = "Banned by rank: "..(RankNames[banData.Rank] or "Unknown")
					BanRank.TextColor3 = Color3.fromRGB(175, 175, 185)
					BanRank.TextSize = 10
					BanRank.Font = Enum.Font.Gotham
					BanRank.TextXAlignment = Enum.TextXAlignment.Left
					BanRank.Parent = BanEntry
				end
			end

			local function SetPage(pageName)
				local showCommands = pageName == "Commands"

				CommandsPage.Visible = showCommands
				BansPage.Visible = not showCommands

				CommandsTab.BackgroundColor3 = showCommands
					and Color3.fromRGB(70, 100, 180)
					or Color3.fromRGB(45, 45, 52)

				BansTab.BackgroundColor3 = not showCommands
					and Color3.fromRGB(70, 100, 180)
					or Color3.fromRGB(45, 45, 52)

				if pageName == "Bans" then
					RefreshBans()
				end
			end

			CommandsTab.MouseButton1Click:Connect(function()
				SetPage("Commands")
			end)

			BansTab.MouseButton1Click:Connect(function()
				SetPage("Bans")
			end)

			RefreshBansButton.MouseButton1Click:Connect(RefreshBans)

			local minimized = false
			
			MinimizeButton.MouseButton1Click:Connect(function()
				minimized = not minimized

				if minimized then
					MinimizeButton.Text = "+"
					Content.Visible = false

					MainFrame:TweenSize(
						UDim2.new(0.9, 0, 0, 42),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.2,
						true
					)
				else
					MinimizeButton.Text = "−"

					MainFrame:TweenSize(
						UDim2.new(0.9, 0, 0.8, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.2,
						true
					)

					task.delay(0.2, function()
						if MainFrame.Parent and not minimized then
							Content.Visible = true
						end
					end)
				end
			end)

			CloseButton.MouseButton1Click:Connect(function()
				ScreenGui:Destroy()
			end)

			local DragDetector = Instance.new("UIDragDetector")
			DragDetector.Parent = TitleBar

			SetPage(args[3] == "bans" and "Bans" or "Commands")
		end
	end
}

Commands.bans = {
	Rank = Ranks.Mod,
	Aliases = {},
	Syntax = Prefix.."bans [player]",

	Execute = function(executor, args)
		local newArgs = table.clone(args)
		newArgs[3] = "bans"

		Commands.commands.Execute(executor, newArgs)
	end
}


local function GetCommand(commandName)
	commandName = commandName:lower()

	if Commands[commandName] then
		return Commands[commandName]
	end

	for _, command in pairs(Commands) do
		for _, alias in ipairs(command.Aliases or {}) do
			if alias:lower() == commandName then
				return command
			end
		end
	end

	return nil
end

local function ExecuteCommand(player, message)
	if message:sub(1, #Prefix) ~= Prefix then
		return
	end

	local args = {}

	for argument in message:sub(#Prefix + 1):gmatch("%S+") do
		table.insert(args, argument)
	end

	local commandName = args[1] and args[1]:lower()
	local command = commandName and GetCommand(commandName)

	if not command then
		return
	end


	if GetRank(player) < command.Rank then
		local RankNames = {
			[Ranks.Owner] = "Owner",
			[Ranks.HeadAdmin] = "HeadAdmin",
			[Ranks.Admin] = "Admin",
			[Ranks.Mod] = "Mod",
			[Ranks.NonAdmin] = "NonAdmin"
		}

		Notify(player, ScriptName, "You do not have permission to use this command.\nRank Required: " .. (RankNames[command.Rank] or "Unknown"), 4)
		return
	end

	command.Execute(player, args)
end

local function SetupPlayer(player)
	JoinCounter += 1
	JoinOrder[player] = JoinCounter

	if ServerBans[player.UserId] then
		player:Kick(ServerBans[player.UserId].Reason)
		return
	end

	local PunishInfo = PunishedPlayers[player.UserId]

	if PunishInfo then
		PunishInfo.CharacterConnection = player.CharacterAdded:Connect(function(character)
			task.spawn(function()
				while PunishedPlayers[player.UserId] == PunishInfo
					and player.Parent do

					if character.Parent ~= nil then
						character.Parent = nil
					end

					task.wait()
				end
			end)
		end)

		local character = player.Character

		if character then
			task.spawn(function()
				while PunishedPlayers[player.UserId] == PunishInfo
					and player.Parent do

					if character.Parent ~= nil then
						character.Parent = nil
					end

					task.wait()
				end
			end)
		end
	end

	local JailInfo = JailedPlayers[player.UserId]

	if JailInfo and JailInfo.Model and JailInfo.Model.Parent then
		JailInfo.CharacterConnection = player.CharacterAdded:Connect(function(character)
			local root = character:WaitForChild("HumanoidRootPart", 10)

			if root and JailedPlayers[player.UserId] == JailInfo then
				root.CFrame = JailInfo.Center
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end)

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if root then
			root.CFrame = JailInfo.Center
		end
	end

	player.Chatted:Connect(function(message)
		ExecuteCommand(player, message)
	end)

	if GetRank(player) > 0 then
		Notify(
			player,
			ScriptName,
			"Welcome to Moderatio1n's Admin! Your rank is " .. GetRankName(player) .. ".",
			6
		)
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	for _, globalStat in pairs(GlobalStats) do
		if not leaderstats:FindFirstChild(globalStat.Name) then
			local stat = Instance.new(globalStat.ClassName)
			stat.Name = globalStat.Name
			stat.Value = globalStat.Value
			stat.Parent = leaderstats
		end
	end
end

Players.PlayerAdded:Connect(SetupPlayer)

Players.PlayerRemoving:Connect(function(player)
	JoinOrder[player] = nil

	if NotificationGuis[player] then
		NotificationGuis[player]:Destroy()
		NotificationGuis[player] = nil
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	SetupPlayer(player)
end
