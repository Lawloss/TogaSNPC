player_manager.AddValidModel( "Toga", "models/CyanBlue/BNHA/Himiko_Toga/Toga.mdl" )
player_manager.AddValidHands( "Toga", "models/CyanBlue/BNHA/Himiko_Toga/Arms/Toga.mdl", 0, "00000000" )





--Add NPC
local Category = "Boku no Hero Academia"

local NPC = {     Name = "Himiko Toga", 
                Class = "npc_citizen",
                Model = "models/CyanBlue/BNHA/Himiko_Toga/NPC/Toga.mdl",
                Health = "100",
                KeyValues = { citizentype = 4 },
                                Category = Category    }

list.Set( "NPC", "npc_CB_Toga", NPC )



----------------------------------------------------------------------------------------


local PM = FindMetaTable("Player")
customIsPlayingTaunt = customIsPlayingTaunt or PM.IsPlayingTaunt
local CurTime = CurTime
function PM:IsPlayingTaunt()
	if self.CustomGesture then
		if self.CustomGesture < CurTime() then
			self.CustomGesture = nil
			return customIsPlayingTaunt(self)
		end
		return true
	else
		return customIsPlayingTaunt(self)
	end
end
if CLIENT then
	function CustomGesture(id,gesture)
		id = Entity(id)
		if not IsValid(id) then return end
		id.CustomGesture = CurTime() + id:SequenceDuration(gesture)
		id:AddVCDSequenceToGestureSlot( GESTURE_SLOT_VCD, gesture, 0, true ) 
	end
else
	function CustomGesture(ply,gesture,activity,dur)
		if gamemode.Call("PlayerStartTaunt",ply,activity,dur) == false then
			return false
		end
		ply.CustomGesture = CurTime() + dur
		ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_VCD,gesture, 0, true ) 
		local filter = RecipientFilter()
		filter:AddPVS(ply:GetPos())
		for k,v in pairs(filter:GetPlayers()) do
			v:SendLua("CustomGesture("..v:EntIndex()..","..gesture..")")
		end
		return true
	end
	function PlayCustomGesture(ply,gesture)
		local seq,dur,act = ply:LookupSequence(gesture)
		if seq == -1 then return false end
		act = ply:GetSequenceActivity(seq)
		if act == -1 then return false end
		if not gamemode.Call("PlayerShouldTaunt",ply,act) then return false end
		return CustomGesture(ply,seq,act,dur)
	end
	local function PlayAnim(ply,seq)
		if ply:GetModel() == "models/cyanblue/bnha/himiko_toga/toga.mdl" and not ply:IsPlayingTaunt() then
			return PlayCustomGesture(ply,seq)
		end
	end
	hook.Add("PlayerSay","Maho",function(ply,text)
		if string.lower(text) == "kick" then
			PlayAnim(ply,"taunt_kick")
			return ""
		end
	end)
	hook.Add("PlayerSay","Maho2",function(ply,text)
		if string.lower(text) == "fortnite" then
			PlayAnim(ply,"taunt_despacito")
			return ""
		end
	end)
	concommand.Add("tkick",function(ply,cmd)
		if IsValid(ply) then
			PlayAnim(ply,"taunt_kick")
		end
	end)
	concommand.Add("fortnite",function(ply,cmd)
		if IsValid(ply) then
			PlayAnim(ply,"taunt_despacito")
		end
	end)
end