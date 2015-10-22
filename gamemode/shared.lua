GM.Name = "Helicopter Bomb Chase"
GM.Author = "immibis"
GM.Email = "immibis@gmail.com"
GM.Website = "N/A"

g_BombNotSolidTime = 1 -- seconds

function GM:ShouldCollide(a, b)
	--return not a:IsPlayer() or not b:IsPlayer()
	if a:IsPlayer() and b:IsPlayer() then return false end -- two players
	if not (a:IsPlayer() or b:IsPlayer()) then return true end -- two objects
	
	if a:IsPlayer() then b,a = a,b end
	
	-- collision of object with player
	if a.NotSolidTime and a.NotSolidTime > CurTime() then return false end
	
	return true
	--return false
	
end
