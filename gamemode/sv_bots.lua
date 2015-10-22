print("sv_bots load")

local function ControlBot(ply, cmd)

	if not ply:Alive() then
		--cmd:SetButtons(math.mod(CurTime(), 1) < 0.5 and IN_ATTACK or 0)
		--ply:Spawn()
		return
	else
		cmd:SetButtons(IN_RUN)
	end

	local sumpos = Vector(0,0,0)
	for _,ent in pairs(ents.FindInSphere(ply:GetPos(), 500)) do
		if ent:GetClass() ~= "grenade_helicopter" then continue end
		local relpos = ent:GetPos() - ply:GetPos()
		if relpos:Length() < 50 then continue end
		relpos.z = 0
		
		sumpos = sumpos + relpos/relpos:LengthSqr()
	end
	
	local origin = ply:GetPos()+Vector(0,0,50)
	for ang=0,359,22.5 do
		local rads = math.rad(ang)
		local dir = Vector(math.sin(rads), math.cos(rads), 0)
		
		local traceres = util.TraceLine({start=origin, endpos=origin+dir*100, filter=function(e) return e:IsValid() end})
		if traceres.Hit and traceres.HitWorld then
			--print(ang,dir)
			--sumpos = sumpos + dir
		else
			--print(trace.HitPos)
		end
	end
	
	
	local movevec
	--print(movevec)
	movevec = -sumpos:GetNormalized()
	if movevec:Length() == 0 or movevec.x ~= movevec.x then movevec = ply:GetForward() end
	
	movevec:Normalize()
	
	--ply:SetAngles(movevec:Angle())
	movevec = movevec * ply:GetRunSpeed()
	cmd:SetForwardMove(ply:GetForward():Dot(movevec))
	cmd:SetSideMove(ply:GetRight():Dot(movevec))
end

function GM:StartCommand(ply, cmd)
	if ply:IsBot() then
		ControlBot(ply, cmd)
	end
end

timer.Create("respawn bots", 1, 0, function()
	for _,v in pairs(player.GetAll()) do
		if v:IsBot() and not v:Alive() then
			v:Spawn()
		end
	end
end)