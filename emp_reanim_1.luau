-- Made by @emperrrr (Discord)
-- Discord server: https://discord.gg/UJ7YtqadPJ

do
	local Accessories = {}

	local Aligns = {}

	local Attachments = {}

	local BindableEvent = nil

	local Blacklist = {}

	local CFrameidentity = CFrame.identity

	local Character = nil

	local CurrentCamera = nil

	local Enum = Enum
	local Custom = Enum.CameraType.Custom
	local Dead = Enum.HumanoidStateType.Dead

	local game = game
	local Clone = game.Clone
	local Close = game.Close
	local Connect = Close.Connect
	local Disconnect = Connect(Close, function() end).Disconnect
	local Wait = Close.Wait
	local Destroy = game.Destroy
	local FindFirstAncestorOfClass = game.FindFirstAncestorOfClass
	local FindFirstChildOfClass = game.FindFirstChildOfClass
	local Players = FindFirstChildOfClass(game, "Players")
	local LocalPlayer = Players.LocalPlayer
	local CharacterAdded = LocalPlayer.CharacterAdded
	local RunService = FindFirstChildOfClass(game, "RunService")
	local PostSimulation = RunService.PostSimulation
	local PreRender = RunService.PreRender
	local PreSimulation = RunService.PreSimulation
	local StarterGui = FindFirstChildOfClass(game, "StarterGui")
	local SetCore = StarterGui.SetCore
	local Workspace = FindFirstChildOfClass(game, "Workspace")
	local FallenPartsDestroyHeight = Workspace.FallenPartsDestroyHeight
	local CurrentCameraChanged = Workspace:GetPropertyChangedSignal("CurrentCamera")
	local GetChildren = game.GetChildren
	local GetDescendants = game.GetDescendants
	local GetPropertyChangedSignal = game.GetPropertyChangedSignal
	local IsA = game.IsA

	local Instancenew = Instance.new
	local SetAccessories = Instancenew("HumanoidDescription").SetAccessories
	local HumanoidModel = Players:CreateHumanoidModelFromDescription(Instancenew("HumanoidDescription"), Enum.HumanoidRigType.R6)
	local ModelBreakJoints = HumanoidModel.BreakJoints
	local Head = HumanoidModel.Head
	local BasePartBreakJoints = Head.BreakJoints
	local GetJoints = Head.GetJoints
	local Humanoid = HumanoidModel.Humanoid
	local ApplyDescription = Humanoid.ApplyDescription
	local ChangeState = Humanoid.ChangeState
	local GetAppliedDescription = Humanoid.GetAppliedDescription
	local Move = Humanoid.Move
	local ScaleTo = HumanoidModel.ScaleTo

	local IsFirst = false
	local IsRegistered = false
	local IsRunning = false

	local LastTime = nil

	local math = math
	local mathrandom = math.random
	local mathsin = math.sin

	local next = next

	local OptionsAccessories = nil
	local OptionsApplyDescription = nil
	local OptionsBreakJointsDelay = nil
	local OptionsChangePrimaryPart = nil
	local OptionsParentCharacter = nil
	local OptionsRigTransparency = nil
	local OptionsSetCameraSubject = nil
	local OptionsSetCameraType = nil
	local OptionsSetCharacter = nil
	local OptionsSetCollisionGroup = nil
	local OptionsSimulationRadius = nil
	local OptionsTeleportRadius = nil

	local osclock = os.clock

	local RBXScriptConnections = {}

	local Rig = nil
	local RigHumanoid = nil
	local RigHumanoidRootPart = nil

	local stringfind = string.find

	local table = table
	local tableclear = table.clear
	local tableinsert = table.insert

	local task = task
	local taskdefer = task.defer
	local taskspawn = task.spawn
	local taskwait = task.wait

	local Time = nil

	local Vector3 = Vector3
	local Vector3new = Vector3.new
	local Vector3zero = Vector3.zero

	Humanoid = nil

	local FindFirstChildOfClassAndName = function(Parent, ClassName, Name)
		for Index, Child in next, GetChildren(Parent) do
			if IsA(Child, ClassName) and Child.Name == Name then
				return Child
			end
		end
	end

	local DescendantAdded = function(Descendant)
		if IsA(Descendant, "Attachment") then
			local Attachment = Attachments[Descendant.Name]

			if Attachment then
				local Parent = Descendant.Parent

				if IsA(Parent, "BasePart") then
					local MeshId = nil
					local TextureId = nil

					if IsA(Parent, "MeshPart") then
						MeshId = Parent.MeshId
						TextureId = Parent.TextureID
					else
						local SpecialMesh = FindFirstChildOfClass(Parent, "SpecialMesh")

						if SpecialMesh then
							MeshId = SpecialMesh.MeshId
							TextureId = SpecialMesh.TextureId
						end
					end

					if MeshId then
						for Index, Table in next, OptionsAccessories do
							if stringfind(MeshId, Table.MeshId) and stringfind(TextureId, Table.TextureId) then
								local Instance = FindFirstChildOfClassAndName(Rig, "BasePart", Table.Name)

								if Instance and not Blacklist[Instance] then
									tableinsert(Aligns, {
										LastPosition = Instance.Position,
										Offset = Table.Offset,
										Part0 = Parent,
										Part1 = Instance
									})

									Blacklist[Instance] = true

									return
								end
							end
						end

						for Index, Table in next, Accessories do
							if Table.MeshId == MeshId and Table.TextureId == TextureId then
								local Handle = Table.Handle

								tableinsert(Aligns, {
									LastPosition = Handle.Position,
									Offset = CFrameidentity,
									Part0 = Parent,
									Part1 = Handle
								})

								return
							end
						end

						local Accoutrement = Parent.Parent

						if IsA(Accoutrement, "Accoutrement") then
							local AccoutrementClone = Clone(Accoutrement)

							local HandleClone = FindFirstChildOfClassAndName(AccoutrementClone, "BasePart", "Handle")
							HandleClone.Transparency = OptionsRigTransparency

							for Index, Descendant in next, GetDescendants(HandleClone) do
								if IsA(Descendant, "JointInstance") then
									Destroy(Descendant)
								end
							end

							local AccessoryWeld = Instancenew("Weld")
							AccessoryWeld.C0 = Descendant.CFrame
							AccessoryWeld.C1 = Attachment.CFrame
							AccessoryWeld.Name = "AccessoryWeld"
							AccessoryWeld.Part0 = HandleClone
							AccessoryWeld.Part1 = Attachment.Parent
							AccessoryWeld.Parent = HandleClone

							AccoutrementClone.Parent = Rig

							tableinsert(Accessories, {
								Handle = HandleClone,
								MeshId = MeshId,
								TextureId = TextureId
							})
							tableinsert(Aligns, {
								LastPosition = HandleClone.Position,
								Offset = CFrameidentity,
								Part0 = Parent,
								Part1 = HandleClone
							})
						end
					end
				end
			end
		end
	end

	local SetCameraSubject = function()
		local CameraCFrame = CurrentCamera.CFrame
		CurrentCamera.CameraSubject = RigHumanoid
		Wait(PreRender)
		CurrentCamera.CFrame = CameraCFrame
	end

	local OnCameraSubjectChanged = function()
		if CurrentCamera.CameraSubject ~= RigHumanoid then
			SetCameraSubject()
		end
	end

	local OnCameraTypeChanged = function()
		if CurrentCamera.CameraType ~= Custom then
			CurrentCamera.CameraType = Custom
		end
	end

	local OnCurrentCameraChanged = function()
		CurrentCamera = Workspace.CurrentCamera

		if OptionsSetCameraSubject then
			OnCameraSubjectChanged()
			tableinsert(RBXScriptConnections, Connect(GetPropertyChangedSignal(CurrentCamera, "CameraSubject"), OnCameraSubjectChanged))

			if OptionsSetCameraType then
				OnCameraTypeChanged()
				tableinsert(RBXScriptConnections, Connect(GetPropertyChangedSignal(CurrentCamera, "CameraType"), OnCameraTypeChanged))
			end
		end
	end

	local SetCharacter = function()
		LocalPlayer.Character = Rig
	end

	local SetSimulationRadius = function()
		LocalPlayer.SimulationRadius = OptionsSimulationRadius
	end

	local WaitForChildOfClass = function(Parent, ClassName)
		local Child = FindFirstChildOfClass(Parent, ClassName)

		while not Child do
			Wait(Parent.ChildAdded)
			Child = FindFirstChildOfClass(Parent, ClassName)
		end

		return Child
	end

	local WaitForChildOfClassAndName = function(Parent, ...)
		local Child = FindFirstChildOfClassAndName(Parent, ...)

		while not Child do
			Wait(Parent.ChildAdded)
			Child = FindFirstChildOfClassAndName(Parent, ...)
		end

		return Child
	end

	local OnCharacterAdded = function(NewCharacter)
		if NewCharacter ~= Rig then
			if OptionsSetCameraSubject then
				taskspawn(SetCameraSubject)
			end

			if OptionsSetCharacter then
				taskdefer(SetCharacter)
			end

			tableclear(Aligns)
			tableclear(Blacklist)

			Character = NewCharacter

			if OptionsParentCharacter then
				Character.Parent = Rig
			end

			for Index, Descendant in next, GetDescendants(Character) do
				DescendantAdded(Descendant)
			end

			tableinsert(RBXScriptConnections, Connect(Character.DescendantAdded, DescendantAdded))

			Humanoid = WaitForChildOfClass(Character, "Humanoid")
			local HumanoidRootPart = WaitForChildOfClassAndName(Character, "BasePart", "HumanoidRootPart")

			if IsFirst then
				if OptionsApplyDescription and Humanoid then
					local AppliedDescription = GetAppliedDescription(Humanoid)
					SetAccessories(AppliedDescription, {}, true)
					ApplyDescription(RigHumanoid, AppliedDescription)
				end

				if HumanoidRootPart then
					RigHumanoidRootPart.CFrame = HumanoidRootPart.CFrame

					if OptionsSetCollisionGroup then
						local CollisionGroup = HumanoidRootPart.CollisionGroup

						for Index, Descendant in next, GetDescendants(Rig) do
							if IsA(Descendant, "BasePart") then
								Descendant.CollisionGroup = CollisionGroup
							end
						end
					end
				end

				IsFirst = false
			end

			if HumanoidRootPart then
				if OptionsChangePrimaryPart then
					HumanoidRootPart.CFrame = RigHumanoidRootPart.CFrame + Vector3new(0, FallenPartsDestroyHeight + 4, 0)
				elseif OptionsTeleportRadius then
					HumanoidRootPart.CFrame = RigHumanoidRootPart.CFrame + Vector3new(mathrandom(- OptionsTeleportRadius, OptionsTeleportRadius), 0, mathrandom(- OptionsTeleportRadius, OptionsTeleportRadius))
				end
			end

			taskwait(OptionsBreakJointsDelay)

			ModelBreakJoints(Character)

			if Humanoid then
				ChangeState(Humanoid, Dead)
			end
		end
	end

	local OnPostSimulation = function()
		Time = osclock()
		local DeltaTime = Time - LastTime
		LastTime = Time

		if OptionsSimulationRadius then
			pcall(SetSimulationRadius)
		end

		local AntiSleep = Vector3new(mathsin(osclock()) * 0.0156402587890625, 0, 0)
		local Axis = 26 + mathsin(osclock())

		for Index, Table in next, Aligns do
			local Part0 = Table.Part0

			if Part0.ReceiveAge == 0 and not next(GetJoints(Part0)) then
				local Part1 = Table.Part1

				Part0.AssemblyAngularVelocity = Vector3zero

				local Position = Part1.Position
				local LinearVelocity = ( Position - Table.LastPosition ) / DeltaTime * Axis
				Part0.AssemblyLinearVelocity = Vector3new(LinearVelocity.X, Axis, LinearVelocity.Z)
				Table.LastPosition = Position

				Part0.CFrame = Part1.CFrame * Table.Offset + AntiSleep
			end
		end

		if not OptionsSetCharacter and Humanoid then
			RigHumanoid.Jump = Humanoid.Jump
			Move(RigHumanoid, Humanoid.MoveDirection)
		end

		if IsRegistered then
			SetCore(StarterGui, "ResetButtonCallback", BindableEvent)
		else
			IsRegistered = pcall(SetCore, StarterGui, "ResetButtonCallback", BindableEvent)
		end
	end

	local OnPreSimulation = function()
		if Character then
			for Index, Descendant in next, GetDescendants(Character) do
				if IsA(Descendant, "BasePart") then
					Descendant.CanCollide = false
				end
			end
		end
	end

	Start = function(Options)
		if not IsRunning then
			IsFirst = true
			IsRunning = true

			OptionsAccessories = Options.Accessories or {}
			OptionsApplyDescription = Options.ApplyDescription
			OptionsBreakJointsDelay = Options.BreakJointsDelay or 0
			OptionsChangePrimaryPart = Options.ChangePrimaryPart
			OptionsParentCharacter = Options.ParentCharacter
			local OptionsRigSize = Options.RigSize
			OptionsRigTransparency = Options.RigTransparency or 1
			OptionsSetCameraSubject = Options.SetCameraSubject
			OptionsSetCameraType = Options.SetCameraType
			OptionsSetCharacter = Options.SetCharacter
			OptionsSetCollisionGroup = Options.SetCollisionGroup
			OptionsSimulationRadius = Options.SimulationRadius
			OptionsTeleportRadius = Options.TeleportRadius

			BindableEvent = Instancenew("BindableEvent")
			tableinsert(RBXScriptConnections, Connect(BindableEvent.Event, Stop))

			Rig = Clone(HumanoidModel)
			Rig.Name = LocalPlayer.Name
			RigHumanoid = Rig.Humanoid
			RigHumanoidRootPart = Rig.HumanoidRootPart
			Rig.Parent = Workspace

			for Index, Descendant in next, GetDescendants(Rig) do
				if IsA(Descendant, "Attachment") then
					Attachments[Descendant.Name] = Descendant
				elseif IsA(Descendant, "BasePart") or IsA(Descendant, "Decal") then
					Descendant.Transparency = OptionsRigTransparency
				end
			end

			if OptionsRigSize then
				ScaleTo(Rig, OptionsRigSize)

				RigHumanoid.JumpPower = 50
				RigHumanoid.WalkSpeed = 16
			end

			OnCurrentCameraChanged()
			tableinsert(RBXScriptConnections, Connect(CurrentCameraChanged, OnCurrentCameraChanged))

			local Character = LocalPlayer.Character

			if Character then
				OnCharacterAdded(Character)
			end

			tableinsert(RBXScriptConnections, Connect(CharacterAdded, OnCharacterAdded))

			LastTime = osclock()
			tableinsert(RBXScriptConnections, Connect(PostSimulation, OnPostSimulation))

			if Options.DisableCharacterCollisions then
				OnPreSimulation()
				tableinsert(RBXScriptConnections, Connect(PreSimulation, OnPreSimulation))
			end

			return {
				BindableEvent = BindableEvent,
				Rig = Rig
			}
		end
	end

	Stop = function()
		if IsRunning then
			IsFirst = false
			IsRunning = false

			for Index, RBXScriptConnection in next, RBXScriptConnections do
				Disconnect(RBXScriptConnection)
			end

			tableclear(RBXScriptConnections)

			Destroy(BindableEvent)
			Destroy(Rig)

			if IsRegistered then
				pcall(SetCore, StarterGui, "ResetButtonCallback", true)
			else
				IsRegistered = pcall(SetCore, StarterGui, "ResetButtonCallback", true)
			end
		end
	end
end

Empyrean = Start({
	Accessories = {
		--{ MeshId = "", Name = "", Offset = CFrame.identity, TextureId = "" },
		
		--Left Arms
		
		{ MeshId = "14255522247", Name = "Left Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255543546" },--14255556501
		{ MeshId = "14255522247", Name = "Left Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255544465" },--14255562939
		{ MeshId = "18640914129", Name = "Left Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "18640914168" },--18641142410
		{ MeshId = "17374767929", Name = "Left Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17374768001" },--18641142410
		{ MeshId = "90736849096372", Name = "Left Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "79186624401216" },--90960046381276
		
		--Left Leg

		{ MeshId = "18640901641", Name = "Left Leg", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "18640901676" },--18641187217
		{ MeshId = "17387586286", Name = "Left Leg", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17387586304" },--17387616772
		{ MeshId = "139733645770094", Name = "Left Leg", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "130809869695496" },--82942681251131
		
		--Right Arms
		
		{ MeshId = "14255522247", Name = "Right Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255543546" },--14255554762
		{ MeshId = "14255522247", Name = "Right Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255544465" },--14255560646
		{ MeshId = "18640914129", Name = "Right Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "18640914168" },--18641077392
		{ MeshId = "17374767929", Name = "Right Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17374768001" },--17374846953
		{ MeshId = "105141400603933", Name = "Right Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "71060417496309" },--102599402682100
		
		--Right Legs

		{ MeshId = "18640901641", Name = "Right Leg", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "18640901676" },--18641157833
		{ MeshId = "17387586286", Name = "Right Leg", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17387586304" },--17401151565
		{ MeshId = "99608462237958", Name = "Right Leg", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "130809869695496" },--140395948277978
		
		--Torso
		
		{ MeshId = "14241018198", Name = "Torso", Offset = CFrame.identity, TextureId = "14251599953" },--14255528083
		{ MeshId = "110684113028749", Name = "Torso", Offset = CFrame.identity, TextureId = "70661572547971" },--138364679836274
		{ MeshId = "18640899369", Name = "Torso", Offset = CFrame.identity, TextureId = "18640899481" },--18641046146
	},
	ApplyDescription = true,
	BreakJointsDelay = 0.251,
	ChangePrimaryPart = true,
	DisableCharacterCollisions = true,
	ParentCharacter = true,
	RigSize = 1,
	RigTransparency = 1,
	SetCameraSubject = true,
	SetCameraType = true,
	SetCharacter = false,
	SetCollisionGroup = true,
	SimulationRadius = 2147483647,
	TeleportRadius = 12
})
local Rig = Empyrean.Rig