local remote = game.Lighting.Remotes:WaitForChild(script.Name)

function ownCheck(Player,  Move)
	local can = false
	for _, area in pairs(Player.Stats:GetChildren()) do
		if string.match(tostring(area.Name), "Move") ~= nil then
			if area.Value == Move then
				can = true
			end
		else
		end
	end
	return can
end

function ownCheck2(Player,  Weapon)
	local can = false
	if Player.Character.PlayerStuff.CharacterMoveset.Value == "None" then

	else
		if Player.Character.PlayerStuff.CharacterMoveset.Value == "any_value" then
			can = true
		else
			if Player.Character.PlayerStuff.CharacterMoveset.Value == Weapon then
				can = true
			end
		end

	end
	return can
end

function isStunned(target, stuns)
	local isStunned = false
	for i, stunname in pairs(stuns) do
		if target.PlayerStuff.Cooldowns:FindFirstChild(stunname) then
			isStunned = true
		end
	end
	return isStunned
end

function giveStunned(target, stuns)
	for stunname, stuntime in pairs(stuns) do
		local stu = Instance.new("IntValue", target.PlayerStuff.Cooldowns)
		stu.Name = stunname
		game.Debris:AddItem(stu, stuntime)
	end
end

function Conjur(plr, color)
	local circle = game.ServerStorage.PFX.ConjuringEffect.ConjuringEffect:clone()
	circle.Parent = plr.HumanoidRootPart
	circle.ConjuringEffect.Color = ColorSequence.new(color)
	circle.ConjuringEffect.Enabled = true
	plr.Humanoid.Animator:LoadAnimation(game.ServerStorage.Animations["Strech Chaos"]):Play()
	wait(1)
	circle.ConjuringEffect.Enabled = false
end

function HEffect(plr)
	local fe = game.ServerStorage.PFX.HitEffect.Attachment:clone()
	fe.Parent = plr.HumanoidRootPart
	for _, effect in pairs(fe:GetChildren()) do
		effect:Emit(21)
	end
end

function ModTarget(target, walkspeed, jumppower, modtime)
	coroutine.wrap(function()
		target.Humanoid.WalkSpeed = walkspeed
		target.Humanoid.JumpPower = jumppower
		wait(modtime)
		target.Humanoid.WalkSpeed = 19
		target.Humanoid.JumpPower = 50
	end)()
end

function Push(plr, target, speed, endtime)
	local BodyVelocity = Instance.new('BodyVelocity',target.HumanoidRootPart)
	BodyVelocity.Velocity = plr.HumanoidRootPart.CFrame.lookVector * speed
	BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	game.Debris:AddItem(BodyVelocity, endtime)
end

function AirPush(plr, airtime, target, speed, endtime)
	local BodyVelocity = Instance.new('BodyVelocity',target.HumanoidRootPart)
	BodyVelocity.Velocity = plr.HumanoidRootPart.CFrame.lookVector * speed + Vector3.new(0,airtime,0)
	BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	game.Debris:AddItem(BodyVelocity, endtime)
end

local function QuadraticBezier(TimePoint,StartPoint,CurvePoint,EndPoint)
	return (1-TimePoint)^2*StartPoint+2*(1-TimePoint)*TimePoint*CurvePoint+TimePoint^2*EndPoint;
end;

function AirTime(plr, target)
	local alignT = Instance.new("AlignPosition", target)
	local alignP = Instance.new("AlignPosition", plr)
	local attachment0P = Instance.new("Attachment", plr.HumanoidRootPart)
	local attachment0T = Instance.new("Attachment", target.HumanoidRootPart)

	local part = Instance.new("Part", workspace)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = CFrame.new(plr.HumanoidRootPart.Position)

	local attachment1 = Instance.new("Attachment", part)

	attachment1.CFrame = CFrame.new(Vector3.new(0,10,-5))

	alignP.Attachment0 = attachment0P
	alignP.Attachment1 = attachment1

	alignT.Attachment0 = attachment0T
	alignT.Attachment1 = attachment1

	alignP.MaxForce = 90010
	alignT.MaxForce = 90010

	attachment0T.CFrame = CFrame.new(Vector3.new(-4,0,0))



	return alignP, alignT
end

function BlockBreak(target, tim)
	target.PlayerStuff.Blocking.Value = false
	local stunned = Instance.new("BoolValue", game.ReplicatedStorage)
	stunned.Name = "Stunned "
	stunned.Value = true

	local stuns = {
		["UniversalCooldown0"] = tim,
	}
	giveStunned(target, stuns)
	for _, child in pairs(target:GetChildren()) do
		if child.Name == "blockinglol" then
			child:Destroy()
		end
	end
	coroutine.wrap(function()
		wait(tim)
		stunned.Value = false
	end)()
	local  anim = target.Humanoid.Animator:LoadAnimation(game.ServerStorage.Animations.Dazed)
	anim:Play()
	local sfx = game.SoundService.SFX.ShieldBreak:clone()
	sfx.Parent = target.HumanoidRootPart
	sfx:Play()
	repeat target.Humanoid.WalkSpeed = 0 target.Humanoid.JumpPower = 0 wait() until stunned.Value == false
	anim:Stop()
	stunned:Destroy()
	target.Humanoid.WalkSpeed = 19 target.Humanoid.JumpPower = 50
end


remote.OnServerEvent:Connect(function(player, aircombo)
	local plr = game.Workspace:WaitForChild(player.Name)
	local stuns = {
		"UniversalCooldown0",
		"Chaos Bind",
	}
	if ownCheck2(player, "Chaos 0") == true and plr.Humanoid.Health > 0 and isStunned(plr, stuns) == false and game.Lighting.Remotes.GetMousePOS:InvokeClient(player, "yes maybe").Parent:FindFirstChild("Humanoid") then
		local target = game.Lighting.Remotes.GetMousePOS:InvokeClient(player, "yes maybe").Parent
		local stuns = {
			["UniversalCooldown0"] = 1,
			["Chaos Bind"] = game.ServerStorage.Fighters["Chaos 0"].Special4.Cooldown.Value,
		}
		ModTarget(plr,0,0,1.5)
		giveStunned(plr, stuns)

		-- create water under legs (hitbox)

		local water = Instance.new("Part", workspace)
		water.CanCollide = false
		water.Material = Enum.Material.Glass
		water.Transparency = 1
		water.Anchored = true
		water.Color = Color3.new(0, 0.666667, 1)
		water.Size = Vector3.new(10,1,10)

		water.CFrame = CFrame.new(target.HumanoidRootPart.Position - Vector3.new(0,3,0))

		local goal = {} goal.Size = Vector3.new(10,10,10) goal.Position = water.Position - Vector3.new(0,-3,0)
		goal.Transparency = 0		
		game.TweenService:Create(water, TweenInfo.new(1), goal):Play()

		wait(1)

		--call hbm to make hitbox out of water
		local hbmodule = require(game.ServerScriptService.Modules.Hitboxs) 

		local targets = hbmodule.CreateHitbox(plr, water, Vector3.new(10,10,10), CFrame.new(0,0,0), 0.01,0.01,true, nil, false)
		-- get targets
		for _, target in pairs(targets) do
			if target == plr then

			else
				if target.PlayerStuff.Blocking.Value == false then
					target.Humanoid:TakeDamage(game.ServerStorage.Fighters["Chaos 0"].Special1.Damage.Value)
					local stuns = {
						["UniversalCooldown0"] = 8,
					}
					-- stun them in the bubble
					giveStunned(target, stuns)
					ModTarget(target, 1,1)

					if (plr.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude > 7 then
						local goal = {} goal.Position = plr.HumanoidRootPart.Position - Vector3.new(7,0,0)
						game.TweenService:Create(target.HumanoidRootPart,TweenInfo.new(1), goal):Play()
						wait(1)
					end


					-- visuals when bubbled
					local bubble = Instance.new("Part", workspace)
					bubble.Name = "Chaos Bubble"
					bubble.CanCollide = false
					bubble.Material = Enum.Material.Glass
					bubble.Transparency = 0.5
					bubble.Anchored = false
					bubble.Shape = Enum.PartType.Ball
					bubble.Color = Color3.new(0, 0.666667, 1)
					bubble.Size = Vector3.new(10,10,10)

					bubble.CFrame = CFrame.new(target.HumanoidRootPart.Position)

					local weld = Instance.new("Motor6D", bubble)
					weld.Part0 = bubble
					weld.Part1 = target.Torso

					game.Debris:AddItem(bubble, 8)


				end
			end
		end
		water:Destroy()
	end
end)
