include("shared.lua")

hook.Add("InitPostEntity", "local player custom collisions", function()
	LocalPlayer():SetCustomCollisionCheck(true)
end)

if IsValid(LocalPlayer()) then
	LocalPlayer():SetCustomCollisionCheck(true)
end

function GM:OnEntityCreated(ent)
	if ent:GetClass() == "grenade_helicopter" then
		ent.NotSolidTime = CurTime() + g_BombNotSolidTime
		ent:SetCustomCollisionCheck(true)
	end
end

net.Receive("helibomb kill", function()
	local victim = net.ReadEntity()
	local attacker = net.ReadEntity()
	
	GAMEMODE:AddDeathNotice(victim:Nick(), victim:Team(), "default", attacker:Nick(), attacker:Team())
end)

hook.Add("EntityEmitSound", "quieten explosions", function(data)
	if not data.Entity:IsValid() and data.SoundName:find("weapons/explode") then
		data.Volume = 0.12
		return true
	end
end)


--GM.TestMode = false
net.Receive("helibomb test mode", function()
	GAMEMODE.TestMode = net.ReadBool()
end)

local LastVector = Vector(0, 0, 0)
function GM:CreateMove(cmd)
	if cmd:GetForwardMove() == 0 and cmd:GetSideMove() == 0 and not GAMEMODE.TestMode then
		cmd:SetForwardMove(LocalPlayer():GetForward():Dot(LastVector))
		cmd:SetSideMove(LocalPlayer():GetRight():Dot(LastVector))
	else
		LastVector = cmd:GetForwardMove()*LocalPlayer():GetForward() + cmd:GetSideMove()*LocalPlayer():GetRight()
	end
end