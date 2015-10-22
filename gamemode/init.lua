AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local WALK_SPEED = 250
local RUN_SPEED = 350

local function bomb(ply)
	--if ply.TestMode then return end
	local e = ents.Create("grenade_helicopter")
	e:SetPos(ply:LocalToWorld(Vector(0, 0, 30)))
	e:SetAngles(ply:GetAngles())
	e.Owner = ply
	e:Spawn()
	e:GetPhysicsObject():EnableMotion(true)
	e.NotSolidTime = CurTime() + g_BombNotSolidTime
end

local function removeBombs(ply)
	timer.Destroy("spawn bombs #"..ply:EntIndex())
	for _,e in pairs(ents.FindByClass("grenade_helicopter")) do
		if e.Owner == ply or not IsValid(e.Owner) then
			e:Remove()
		end
	end
end

function GM:EntityTakeDamage(ent, damage_info)
	if ent:IsPlayer() and ent.TestMode then return true end
end

util.AddNetworkString("helibomb test mode")
function GM:ToggleTestMode(ply)
	ply.TestMode = not ply.TestMode
	if ply.TestMode then
		ply:SetWalkSpeed(500)
		ply:SetRunSpeed(2500)
	else
		ply:SetWalkSpeed(WALK_SPEED)
		ply:SetRunSpeed(RUN_SPEED)
	end
	
	net.Start("helibomb test mode")
	net.WriteBool(ply.TestMode)
	net.Send(ply)
end

function GM:PlayerSpawn(ply)
	removeBombs(ply)
	timer.Create("spawn bombs #"..ply:EntIndex(), 0.5, 0, function() ProtectedCall(function() bomb(ply) end) end)
	ply:SetCustomCollisionCheck(true)
	ply:SetHealth(1)
	
	ply:Give("weapon_physgun")
	ply:Give("weapon_physcannon")
	
	ply:SetWalkSpeed(WALK_SPEED)
	ply:SetRunSpeed(RUN_SPEED)
	
	if ply:Nick() == "immibis" then ply:SetRunSpeed(1500) end
end

function GM:PlayerDisconnected(ply)
	removeBombs(ply)
end

function GM:PlayerDeath(ply)
	removeBombs(ply)
end
GM.PlayerSilentDeath = GM.PlayerDeath

function GM:GetFallDamage(ply, speed)
	return 0
end

util.AddNetworkString("helibomb kill")

function GM:PlayerHurt(victim, attacker, healthRemaining, damageTaken)

	if victim.TestMode then return false end

	attacker = attacker.Owner or attacker
	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	
	local message
	if victim == attacker then
		victim:AddFrags(-1)
		message = victim:Nick().." suicided!"
	else
		attacker:AddFrags(1)
		message = attacker:Nick().." killed "..victim:Nick().."!"
	end
	
	for _,o in pairs(player.GetAll()) do
		o:PrintMessage(HUD_PRINTCENTER, message)
	end
	
	print(victim,"killed",attacker)
	
	net.Start("helibomb kill")
	net.WriteEntity(victim)
	net.WriteEntity(attacker)
	net.Broadcast()
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	return true
end

function GM:EntityEmitSound(data)
	if data.Entity:GetClass() == "grenade_helicopter" then
		return false
	end
end

function GM:PlayerNoClip(ply, state)
	return ply.TestMode
end

hook.Add("PhysgunPickup", "only pickup own bombs", function(ply, ent)	
	if ent.Owner and ent.Owner ~= ply and not ply.TestMode then return false end
end)

include("sv_bots.lua")