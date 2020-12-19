StartDebug()

--require("X.lua")

local ABppmod = RegisterMod( "AfterBirth++", 1);

-- Fake 4-head Clover --

local F4HC = Isaac.GetItemIdByName("Fake 4-head Clover");
 
function ABppmod:Fake4Head(player, cacheFlag)
	if player:HasCollectible(F4HC) then
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
			player.Damage = player.Damage - 0.35;
		end
		if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
			player.MaxFireDelay = player.MaxFireDelay + 2;
		end
		if (cacheFlag == CacheFlag.CACHE_SPEED) then
			player.MoveSpeed = player.MoveSpeed - 0.2;
		end
		if (cacheFlag == CacheFlag.CACHE_SHOTSPEED) then
			player.ShotSpeed = player.ShotSpeed - 0.3;
		end
		if (cacheFlag == CacheFlag.CACHE_LUCK) then
			player.Luck = (player.Luck + 2) * 1.75;
		end
	end
 
end

ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.Fake4Head)

------------------------------------------------------------

-- Super Sizer --

local SSizer = Isaac.GetItemIdByName("Super Sizer");

function ABppmod:SuperSizer()
	local player = Isaac.GetPlayer(0);
	local currlevel = Game():GetLevel();
	local currstage = currlevel:GetStage();
	
	if(player:HasCollectible(SSizer)) then
		currlevel:RemoveCurses();
		if (currlevel:CanStageHaveCurseOfLabyrinth(currstage)) then
			currlevel:AddCurse(LevelCurse.CURSE_OF_LABYRINTH,false);
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ABppmod.SuperSizer);

------------------------------------------------------------

-- Guppy's Soul --

local GSoul = Isaac.GetItemIdByName("Guppy's Soul");

local function GSoul_LegitRoom(roomID,roomDT)
	if roomDT.Type == RoomType.ROOM_SUPERSECRET then
		if (roomID == 0) or (roomID == 1) or (roomID == 6) then
			return false;
		end
	end
	return true;
end

function ABppmod:GuppysSoul()
	local player = Isaac.GetPlayer(0);
	
	if (player:HasCollectible(GSoul)) then
		local currRoom = Game():GetLevel():GetCurrentRoomDesc().Data.Variant
		local room = Game():GetLevel():GetCurrentRoomDesc().Data;
		for _, pickup in ipairs(Isaac.GetRoomEntities()) do
			if ((pickup.Type == EntityType.ENTITY_PICKUP) 
			and (pickup.Variant == PickupVariant.PICKUP_HEART) 
			and (pickup.SubType ~= HeartSubType.HEART_HALF_SOUL)
			and GSoul_LegitRoom(currRoom,room)) then
				pos = pickup.Position;
				vel = pickup.Velocity;
				pickup:Remove();
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL,pos,vel,pickup);
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.GuppysSoul, EntityType.ENTITY_PLAYER);

------------------------------------------------------------

-- Holy Heart --

local HHeart = Isaac.GetItemIdByName("Holy Heart");

local function HH_check_int(n)
	-- checking not float
	if(n - math.floor(n) > 0) then
		error("trying to use bitwise operation on non-integer!")
	end
end

local function HH_to_bits(n)
	--n = math.floor(n)
	HH_check_int(n)
	if(n < 0) then -- negative
		return HH_to_bits(bit.bnot(math.abs(n)) + 1)
	end
	-- to bits table
	local tbl = {}
	local cnt = 1
	while (n > 0) do
		local last = n%2
		if(last == 1) then
			tbl[cnt] = 1
		else
			tbl[cnt] = 0
		end
		n = (n-last)/2
		cnt = cnt + 1
	end
	return tbl
end

local function HH_countBits(bitmask)
	local count = 0
	local tbl = HH_to_bits(bitmask)
	for i=1, #tbl do
		if tbl[i] == 1 then
			count = count + 1
		end
	end
	return count
end

local previous_sumHH = 0

function ABppmod:HH_cache()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(HHeart) then
		local Sum = (math.ceil(player:GetSoulHearts()/2) + math.ceil(player:GetHearts()/2));
	
		if (Sum ~= previous_sumHH) then
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
			player:EvaluateItems();
		end
		previous_sumHH = sum
	end
end

function ABppmod:HolyHeart(player, cacheFlag)   
    if player:HasCollectible(HHeart) then         
        local FilledCont = player:GetHearts();
        local SoulHearts = player:GetSoulHearts();
        local BlackHearts = HH_countBits(player:GetBlackHearts());
        local Character = player:GetPlayerType();
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
            if (Character == PlayerType.PLAYER_XXX) then
                player.Damage = player.Damage + (math.ceil(SoulHearts/2) - BlackHearts) * 0.25;
                player.Damage = player.Damage - BlackHearts * 0.4;
            elseif (Character == PlayerType.PLAYER_THELOST) then
				if (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then
					player.Damage = player.Damage + 1.5
				else
					player.Damage = player.Damage - 1
				end
			else --Si somos cualquier otro personaje.
				player.Damage = player.Damage + math.ceil(FilledCont/2) * 0.5;
                player.Damage = player.Damage - (math.ceil(SoulHearts/2) - BlackHearts) * 0.15;
                player.Damage = player.Damage - BlackHearts * 0.4;
            end
        end
    end
end

ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.HolyHeart);
ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.HH_cache, EntityType.ENTITY_PLAYER);

------------------------------------------------------------

-- BFF 2 --

local BFF2 = Isaac.GetItemIdByName("BFF2");

local function BFF2_Bumbo(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if ((sprite:IsPlaying("Level4Spawn")) or (sprite:IsPlaying("Level1Spawn"))
	or (sprite:IsPlaying("Level2Spawn"))) then
		if sprite:GetFrame() == 10 then
			local ent = Isaac.GetRoomEntities()
			for _,drop in ipairs(ent) do
				if (drop.FrameCount == 0) then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, drop.Variant, drop.SubType,(pos+Vector(5,5)),Vector(0,0),familiar)
					break
				end
			end
		end
	end
end

local function BFF2_RottenBaby(familiar)
    local pos = familiar.Position
    local sprite = familiar:GetSprite()
    local player = Isaac.GetPlayer(0)
	
	if ((sprite:IsPlaying("ShootDown")) or (sprite:IsPlaying("ShootSide"))
    or (sprite:IsPlaying("ShootUp")) or (sprite:IsPlaying("FloatShootDown"))
    or (sprite:IsPlaying("FloatShootSide")) or (sprite:IsPlaying("FloatShootUp"))) then
        for _,fly in ipairs(ent) do
            if (fly.FrameCount == 0) and (fly.Variant == FamiliarVariant.BLUE_FLY) and (fly.SpawnerType == player.Type) and (fly:GetData().IsNewFly == nil) then
				spawnedFly = player:AddBlueFlies(1, player.Position, nil);
				spawnedFly:GetData().IsNewFly = true;
            end
        end
    end
end

local function BFF2_DarkBum(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if (sprite:IsPlaying("Spawn")) and (sprite:GetFrame() == 1) then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector(0,0), familiar);
	end
end

local function BFF2_Sissy(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") and sprite:GetFrame() == 10 then
		player:AddBlueSpider(familiar.Position)
	end
end

local function BFF2_Sworn(familiar)
	local pos = familiar.Position
	local ent = Isaac.GetRoomEntities()
	for _,drop in ipairs(ent) do
		if (drop.Variant == PickupVariant.PICKUP_HEART) then
			if (drop.SubType == HeartSubType.HEART_ETERNAL) then
				if ((drop:GetSprite():GetFrame() == 0) and (drop.SpawnerType == familiar.Type)) then
					--if (drop.Position:Distance(familiar.Position) < 50) then
						drop.SpawnerType = player.Type
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, pos+Vector(5,5), Vector(0,0), player);
					--end
				end
			end
		end
	end
end

local function BFF2_ChargedBaby(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") and sprite:GetFrame() == 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 0, pos+Vector(5,5), Vector(0,0), familiar);
	elseif sprite:IsPlaying("Act") and sprite:GetFrame() == 1 then
		local player = Isaac.GetPlayer(0)
		if (player:NeedsCharge()) then
			player:SetActiveCharge(player:GetActiveCharge()+1)
		end
	end
end

function ABppmod:BFF2_Leech(EntDMGed,DMG,DMGF,EntDMGer,DMGCountF)
	 if ((player:HasCollectible(BFF2)) and (player:HasCollectible(Isaac.GetItemIdByName("Leech")))) then
		if ((EntDMGed.HitPoints - DMG <= 0) and (EntDMGer.Type == EntityType.ENTITY_FAMILIAR) and (EntDMGer.Variant == FamiliarVariant.LEECH)) then
			local player = Isaac.GetPlayer(0)
			player:AddHearts(1)
		end
	end
end

local function BFF2_KeyBum(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") then
		for _,drop in ipairs(ent) do
			if drop.FrameCount == 0 then
				if (drop.Variant == 50) or (drop.Variant == 51) or (drop.Variant == 52)
				or (drop.Variant == 53) or (drop.Variant == 60) or (drop.Variant == 360) then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, drop.Variant, drop.SubType,(pos+Vector(5,5)),Vector(0,0),familiar)
					break
				end
			end
		end
	end
end	

local function BFF2_AnimationHeart(familiar,SubType)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") and sprite:GetFrame() == 0 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, SubType, pos+Vector(5,5), Vector(0,0), familiar);
	end
end

local function BFF2_AnimationMultDrops(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") then
		for _,drop in ipairs(ent) do
			if drop.FrameCount == 0 then
				if (drop.SpawnerVariant == familiar.Variant) then
					if (drop.Variant == PickupVariant.PICKUP_TRINKET) then
						Isaac.Spawn(EntityType.ENTITY_PICKUP, drop.Variant, 0,(pos+Vector(5,5)),Vector(0,0),familiar)
						break
					else
						Isaac.Spawn(EntityType.ENTITY_PICKUP, drop.Variant, drop.SubType,(pos+Vector(5,5)),Vector(0,0),familiar)
					end
				end
			end
		end
	end
end
	
local function BFF2_Animation(familiar,Variant)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") and sprite:GetFrame() == 0 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, Variant, 0, pos+Vector(5,5), Vector(0,0), familiar);
	end
end

function ABppmod:BFF2()
	player = Isaac.GetPlayer(0)
	if player:HasCollectible(BFF2) then
		local tFam = {
			--[[SackOfPennies]]	FamiliarVariant.SACK_OF_PENNIES,
			--[[BombBag]]			FamiliarVariant.BOMB_BAG,
			--[[MysterySack]]		FamiliarVariant.MYSTERY_SACK,
			--[[SackOfSacks]]		FamiliarVariant.SACK_OF_SACKS,
			--[[LilChest]]		FamiliarVariant.LIL_CHEST,
			--[[Relic]]			FamiliarVariant.RELIC,
			--[[Chad]]			FamiliarVariant.LITTLE_CHAD,
			--[[Bum]]			FamiliarVariant.BUM_FRIEND,
			--[[DarkBum]]			FamiliarVariant.DARK_BUM,
			--[[KeyBum]]			FamiliarVariant.KEY_BUM,
			--[[Sissy]]			FamiliarVariant.SISSY_LONGLEGS,
			--[[RottenBaby]]		FamiliarVariant.ROTTEN_BABY,
			--[[SwornProtector]]	FamiliarVariant.SWORN_PROTECTOR,
			--[[RuneBag]]			FamiliarVariant.RUNE_BAG,
			--[[BatteryBaby]]		FamiliarVariant.CHARGED_BABY,
			--[[AcidBaby]]		FamiliarVariant.ACID_BABY,
			--[[Bumbo]]			FamiliarVariant.BUMBO
		}
		
		local tBool = {
			--[[SackOfPennies]]	false, --Funciona
			--[[BombBag]]			false, --Funciona
			--[[MysterySack]]		false, --Funciona
			--[[SackOfSacks]]		false, --Funciona
			--[[LilChest]]		false, --Funciona
			--[[Relic]]			false, --Funciona
			--[[Chad]]			false, --Funciona
			--[[Bum]]			false, --Funciona
			--[[DarkBum]]			false, --Funciona
			--[[KeyBum]]			false, --Funciona
			--[[Sissy]]			false, --Funciona
			--[[RottenBaby]]		false, --Funciona
			--[[SwornProtector]]	false, --Funciona
			--[[RuneBag]]			false, --Funciona
			--[[BatteryBaby]]		false, --Funciona
			--[[AcidBaby]]		false, --Funciona
			--[[Bumbo]]			false  --Funciona
		}
		local tEntFam = {
			--[[SackOfPennies]]	0,
			--[[BombBag]]			0,
			--[[MysterySack]]		0,
			--[[SackOfSacks]]		0,
			--[[LilChest]]		0,
			--[[Relic]]			0,
			--[[Chad]]			0,
			--[[Bum]]			0,
			--[[DarkBum]]			0,
			--[[KeyBum]]			0,
			--[[Sissy]]			0,
			--[[RottenBaby]]		0,
			--[[SwornProtector]]	0,
			--[[RuneBag]]			0,
			--[[BatteryBaby]]		0,
			--[[AcidBaby]]		0,
			--[[Bumbo]]			0
		}
		
		local tFunc = {
			--[[SackOfPennies]]	function() BFF2_Animation(tEntFam[1],PickupVariant.PICKUP_COIN) end,
			--[[BombBag]]			function() BFF2_Animation(tEntFam[2],PickupVariant.PICKUP_BOMB) end,
			--[[MysterySack]]		function() BFF2_AnimationMultDrops(tEntFam[3]) end,
			--[[SackOfSacks]]		function() BFF2_Animation(tEntFam[4],PickupVariant.PICKUP_GRAB_BAG) end,
			--[[LilChest]]		function() BFF2_AnimationMultDrops(tEntFam[5]) end,
			--[[Relic]]			function() BFF2_AnimationHeart(tEntFam[6],HeartSubType.HEART_SOUL) end,
			--[[Chad]]			function() BFF2_AnimationHeart(tEntFam[7],HeartSubType.HEART_HALF) end,
			--[[Bum]]			function() BFF2_AnimationMultDrops(tEntFam[8]) end,
			--[[DarkBum]]			function() BFF2_DarkBum(tEntFam[9]) end,
			--[[KeyBum]]			function() BFF2_KeyBum(tEntFam[10]) end,
			--[[Sissy]]			function() BFF2_Sissy(tEntFam[11],FamiliarVariant.BLUE_SPIDER) end,
			--[[RottenBaby]]		function() BFF2_RottenBaby(tEntFam[12]) end,
			--[[SwornProtector]]	function() BFF2_Sworn(tEntFam[13]) end,
			--[[RuneBag]]			function() BFF2_AnimationMultDrops(tEntFam[14]) end,
			--[[BatteryBaby]]		function() BFF2_ChargedBaby(tEntFam[15]) end,
			--[[AcidBaby]]		function() BFF2_Animation(tEntFam[16],PickupVariant.PICKUP_PILL) end,
			--[[Bumbo]]			function() BFF2_Bumbo(tEntFam[17]) end
		}
		ent = Isaac.GetRoomEntities()
		for _,v in ipairs(ent) do
			if (v.Type == EntityType.ENTITY_FAMILIAR) then
				for i,_ in ipairs(tFam) do
					if (v.Variant == tFam[i]) then
						tBool[i] = true
						tEntFam[i] = v:ToFamiliar()
					end
				end
			end
		end
		for i,v in ipairs(tBool) do
			if v then
				tFunc[i]()
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.BFF2);
ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.BFF2_Leech);

------------------------------------------------------------

-- Math Lesson #1 --

local MathLesson1 = Isaac.GetItemIdByName("Math Lesson #1");

local ML1_tTDMG={}
local ML1_tTScale={}
local ML1_tPos={}
local ML1_tTears={}
local ML1_tLazors={}
local ML1_tLDMG={}
local ML1_tLPos={}
local ML1_tLScale={}
local ML1_FramesKnife = 0

function ABppmod:ML1_Stats(player,cacheFlag)
	if player:HasCollectible(MathLesson1) then
		if (cacheFlag == CacheFlag.CACHE_SHOTSPEED) then
			player.ShotSpeed = player.ShotSpeed - 0.4;
		end
		if (cacheFlag == CacheFlag.CACHE_RANGE) then
			player.TearFallingSpeed = player.TearFallingSpeed + 4;
		end
	end
end

function ABppmod:MLesson1()
	player = Isaac.GetPlayer(0)
	if player:HasCollectible(MathLesson1) then
		ent = Isaac.GetRoomEntities()
		for _,shot in ipairs(ent) do
			if (#ML1_tPos>60) then --el Limite de 60 evita lageos
				for i,v in ipairs(ML1_tPos) do
					if not ML1_tTears[v]:Exists() then
						ML1_tTears[v] = nil
						ML1_tTScale[v] = nil
						ML1_tTDMG[v] = nil
						table.remove(ML1_tPos,i)
					end
				end
				for i,v in ipairs(ML1_tLPos) do
					if not ML1_tLazors[v]:Exists() then
						ML1_tLazors[v] = nil
						ML1_tLScale[v] = nil
						ML1_tLDMG[v] = nil
						table.remove(ML1_tLPos,i)
					end
				end
			elseif (shot.Type == EntityType.ENTITY_TEAR) then --Tears
				if (shot.Parent.Type == EntityType.ENTITY_PLAYER) or (shot.Parent.Variant == FamiliarVariant.INCUBUS) then
					shot = shot:ToTear()
					local frame = shot.FrameCount
					if frame == 1 then 
						ML1_tTears[shot.Index] = shot
						ML1_tTDMG[shot.Index] = shot.CollisionDamage
						ML1_tTScale[shot.Index] = shot.BaseScale
						table.insert(ML1_tPos,shot.Index)
					end
					for i,v in ipairs(ML1_tPos) do
						if (ML1_tTears[v] ~= nil) and not (ML1_tTears[v]:Exists()) then
							ML1_tTears[v] = nil
							ML1_tTScale[v] = nil
							ML1_tTDMG[v] = nil
							table.remove(ML1_tPos,i)
						end
					end
					if (frame ~= 0) then
						local modulo = (frame-1) % 15 --Valor entre 0 y 19, se repite cada vez que frames aumenta en 20 valores
						if ((math.modf((frame-1)/15) % 2) == 0) then --Estamos en la parte par, donde crece el daño
							shot.CollisionDamage = ML1_tTDMG[shot.Index] * (0.5 + modulo/(28/3)) --28/3 nos permite tener 0.5+0 en modulo = 0 , y 0.5+1.5 en modulo = 19
							shot.Scale = ML1_tTScale[shot.Index] * (0.5 + modulo/(28/3))
						else --Estamos en la parte impar, donde decrece el daño
							shot.CollisionDamage = ML1_tTDMG[shot.Index] * (2 - modulo/(28/3)) --28/3 nos permite tener 2-0 en modulo = 0 , y 2-1.5 en modulo = 19
							shot.Scale = ML1_tTScale[shot.Index] * (2 - modulo/(28/3))
						end
					end
				end
			elseif (shot.Type == EntityType.ENTITY_LASER) or (shot.Type == EntityType.ENTITY_KNIFE) then --Láseres o Cuchillos
				if (shot.Parent.Type == EntityType.ENTITY_PLAYER) or (shot.Parent.Variant == FamiliarVariant.INCUBUS) or (shot.Parent.Type == EntityType.ENTITY_LASER) then
					local frame = 0
					if (shot.Type == EntityType.ENTITY_KNIFE) and not (shot:ToKnife():IsFlying()) then
						shot.SpriteScale = Vector(1,1)
						ML1_FramesKnife = shot.FrameCount
					end
					if (shot.Type == EntityType.ENTITY_KNIFE) and (shot:ToKnife():IsFlying()) then
						frame = shot.FrameCount - ML1_FramesKnife
					elseif (shot.Type == EntityType.ENTITY_LASER) then
						frame = shot.FrameCount
					end
					if (frame == 1) then
						ML1_tLazors[shot.Index] = shot
						ML1_tLDMG[shot.Index] = shot.CollisionDamage
						ML1_tLScale[shot.Index] = shot.SpriteScale.X
						table.insert(ML1_tLPos,shot.Index)
					end
					for i,v in ipairs(ML1_tLPos) do
						if (ML1_tLazors[v] ~= nil) and not (ML1_tLazors[v]:Exists()) then
							ML1_tLazors[v] = nil
							ML1_tLScale[v] = nil
							ML1_tLDMG[v] = nil
							table.remove(ML1_tLPos,i)
						end
					end
					if (frame ~= 0) and shot:Exists() and ((shot.Variant ~= 1) or (frame <= 30) or player:HasCollectible(Isaac.GetItemIdByName("The Ludovico Technique"))) then --Sigue a partir del 30 a menos que el laser sea brimstone, pero sí sigue con Ludostone
						local modulo = (frame-1) % 15 --Valor entre 0 y 14, se repite cada vez que frames aumenta en 15 valores
						if ((math.modf((frame-1)/15) % 2) == 0) then --Estamos en la parte par, donde decrece el daño
							shot.CollisionDamage = ML1_tLDMG[shot.Index] * (0.5 + modulo/(28/3)) --28/3 nos permite tener 2-0 en modulo = 0 , y 2-1.5 en modulo = 19
							local Vec = Vector(ML1_tLScale[shot.Index] * (0.5 + modulo/(28/3)), ML1_tLScale[shot.Index] * (0.5 + modulo/(28/3))) --28/3 nos permite tener 2-0 en modulo = 0 , y 2-1.5 en modulo = 19
							shot.SpriteScale = Vec
						else --Estamos en la parte impar, donde crece el daño
							shot.CollisionDamage = ML1_tLDMG[shot.Index] * (2 - modulo/(28/3)) --28/3 nos permite tener 2-0 en modulo = 0 , y 2-1.5 en modulo = 19
							local Vec = Vector(ML1_tLScale[shot.Index] * (2 - modulo/(28/3)), ML1_tLScale[shot.Index] * (2 - modulo/(28/3))) --28/3 nos permite tener 2-0 en modulo = 0 , y 2-1.5 en modulo = 19
							shot.SpriteScale = Vec
						end
					end
					if ((shot.Variant == 1) or (shot.Variant == 9)) and (frame >= 30) and not player:HasCollectible(Isaac.GetItemIdByName("The Ludovico Technique")) then --Variant 1 es el láser brimstone, 9 es Brimstone+Tech
						shot.CollisionDamage = ML1_tLDMG[shot.Index] * (0.5 - frame/80) --/80 ya que en el frame 40 querremos 0.5 - 0.5
						local Vec = Vector(ML1_tLScale[shot.Index] * (0.5 - frame/80),ML1_tLScale[shot.Index] * (0.5 - frame/80))
						shot.SpriteScale = Vec 
					elseif (shot.Variant == 1) and (frame >= 41) and not player:HasCollectible(Isaac.GetItemIdByName("The Ludovico Technique")) then
						local Vec = Vector(1,1)
						shot.SpriteScale = Vec
						shot:Remove()
					end
				end
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.MLesson1)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.ML1_Stats)

------------------------------------------------------------

-- Power Bombs --

local PowerBombs = Isaac.GetItemIdByName("Power Bombs!")

function ABppmod:PBombs()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(PowerBombs) then
		ent = Isaac.GetRoomEntities()
		for _,bomb in ipairs(ent) do
			if (bomb.Type == EntityType.ENTITY_BOMBDROP) and (bomb:GetData().NewBomb == nil) then
				bomb = bomb:ToBomb()
				if (bomb.SpawnerType == EntityType.ENTITY_PLAYER) or (bomb.SpawnerVariant == FamiliarVariant.INCUBUS)  then
					bomb.ExplosionDamage = bomb.ExplosionDamage * 3
					if player:HasCollectible(Isaac.GetItemIdByName("Mr. Mega")) then
						bomb.RadiusMultiplier = bomb.RadiusMultiplier / (4/3) -- 0.75
					else
						bomb.RadiusMultiplier = bomb.RadiusMultiplier / 2 -- 0.5
					end
					bomb:GetData().NewBomb = false
				end
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.PBombs)

------------------------------------------------------------

-- Downgrader --

local Downgrader = Isaac.GetItemIdByName("Downgrader")

local DG_t1stEnemy = {
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_RING_OF_FLIES,
			EntityType.ENTITY_DART_FLY,
			EntityType.ENTITY_SWARM,
			EntityType.ENTITY_HUSH_FLY,
			EntityType.ENTITY_MOTER,
			EntityType.ENTITY_FLY_L2,
			EntityType.ENTITY_FULL_FLY,
			EntityType.ENTITY_SUCKER,
			EntityType.ENTITY_POOTER,
			EntityType.ENTITY_BOOMFLY,
			EntityType.ENTITY_BOOMFLY,
			
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_SQUIRT,
			EntityType.ENTITY_SQUIRT,
			EntityType.ENTITY_DINGA,
			
			EntityType.ENTITY_BIGSPIDER,
			EntityType.ENTITY_HOPPER, -- Trite
			EntityType.ENTITY_SPIDER_L2,
			EntityType.ENTITY_RAGLING,
			EntityType.ENTITY_RAGLING, --De Ragman
			EntityType.ENTITY_BLISTER,
			EntityType.ENTITY_TICKING_SPIDER,
			EntityType.ENTITY_BABY_LONG_LEGS,
			EntityType.ENTITY_CRAZY_LONG_LEGS,
			EntityType.ENTITY_BLIND_CREEP,
			EntityType.ENTITY_THE_THING,
			EntityType.ENTITY_RAGE_CREEP,
			
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_HUSH_BOIL,
			EntityType.ENTITY_WALKINGBOIL,
			EntityType.ENTITY_WALKINGBOIL,
			
			EntityType.ENTITY_NIGHT_CRAWLER,
			EntityType.ENTITY_ROUNDY,
			EntityType.ENTITY_PARA_BITE,
			
			EntityType.ENTITY_MULLIGAN,
			EntityType.ENTITY_HIVE,
			EntityType.ENTITY_HIVE,
			EntityType.ENTITY_SWARMER,
			EntityType.ENTITY_NEST,
			
			EntityType.ENTITY_FLAMINGHOPPER,
			EntityType.ENTITY_LEAPER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_BLACK_GLOBIN_BODY,
			EntityType.ENTITY_SPLASHER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_CYCLOPIA,
			EntityType.ENTITY_HUSH_GAPER,
			EntityType.ENTITY_GREED_GAPER,
			EntityType.ENTITY_GURGLE,
			EntityType.ENTITY_NULLS,
			EntityType.ENTITY_SKINNY,
			
			EntityType.ENTITY_MRMAW, 
			EntityType.ENTITY_MAW, -- Psy Maw
			EntityType.ENTITY_PSY_HORF,
			EntityType.ENTITY_MAW, -- Maw
			EntityType.ENTITY_MAW, -- Red Maw
			
			EntityType.ENTITY_BLACK_BONY,
			EntityType.ENTITY_FLESH_DEATHS_HEAD,
			
			EntityType.ENTITY_FAT_BAT,
			
			EntityType.ENTITY_WIZOOB,
			EntityType.ENTITY_RED_GHOST,
			
			EntityType.ENTITY_CONJOINED_FATTY,
			EntityType.ENTITY_FATTY,
			EntityType.ENTITY_BLUBBER,
			EntityType.ENTITY_CONJOINED_FATTY,
			EntityType.ENTITY_FAT_SACK,
			
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_BLACK_GLOBIN,
			
			EntityType.ENTITY_KNIGHT,
			EntityType.ENTITY_FLOATING_KNIGHT,
			EntityType.ENTITY_BONE_KNIGHT,
			
			EntityType.ENTITY_CLOTTY,
			EntityType.ENTITY_MEGA_CLOTTY,
			
			EntityType.ENTITY_MOMS_DEAD_HAND,
			
			EntityType.ENTITY_SPITY,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_CONJOINED_SPITTY,
			EntityType.ENTITY_GRUB,
			
			EntityType.ENTITY_CAMILLO_JR,
			EntityType.ENTITY_PSY_TUMOR,
			EntityType.ENTITY_MEMBRAIN,
			EntityType.ENTITY_MEMBRAIN,
			EntityType.ENTITY_GUTS,
			
			EntityType.ENTITY_PARA_BITE,
			EntityType.ENTITY_COD_WORM,
			EntityType.ENTITY_LEECH,
			EntityType.ENTITY_LEECH,
			
			EntityType.ENTITY_HOST,
			EntityType.ENTITY_MOBILE_HOST,
			EntityType.ENTITY_FLESH_MOBILE_HOST,
			EntityType.ENTITY_MEATBALL,
			
			EntityType.ENTITY_NERVE_ENDING,
			
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			
			EntityType.ENTITY_EYE,
			
			EntityType.ENTITY_DOPLE,
			
			EntityType.ENTITY_BABY,
			
			EntityType.ENTITY_BEGOTTEN,
			
			EntityType.ENTITY_HANGER,
			
			EntityType.ENTITY_STONEHEAD,
			EntityType.ENTITY_BRIMSTONE_HEAD,
			EntityType.ENTITY_STONE_EYE,
			EntityType.ENTITY_GAPING_MAW,
			
			EntityType.ENTITY_BLACK_MAW,
			
			EntityType.ENTITY_BLASTOCYST_MEDIUM,
			EntityType.ENTITY_BLASTOCYST_SMALL,
			EntityType.ENTITY_FISTULA_MEDIUM,
			EntityType.ENTITY_FISTULA_SMALL,
			EntityType.ENTITY_FISTULA_MEDIUM,
			EntityType.ENTITY_FISTULA_SMALL,
			
			EntityType.ENTITY_FIREPLACE,
			EntityType.ENTITY_FIREPLACE
			
			}

local DG_t2ndEnemy = {
			EntityType.ENTITY_FLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_ATTACKFLY,
			EntityType.ENTITY_FLY_L2,
			EntityType.ENTITY_SUCKER,
			EntityType.ENTITY_POOTER,
			EntityType.ENTITY_BOOMFLY,
			EntityType.ENTITY_BOOMFLY,
			
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_DIP,
			EntityType.ENTITY_SQUIRT,
			EntityType.ENTITY_SQUIRT,
			
			EntityType.ENTITY_SPIDER,
			EntityType.ENTITY_SPIDER,
			EntityType.ENTITY_SPIDER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_SPIDER_L2,
			EntityType.ENTITY_BABY_LONG_LEGS,
			EntityType.ENTITY_CRAZY_LONG_LEGS,
			EntityType.ENTITY_WALL_CREEP,
			EntityType.ENTITY_WALL_CREEP,
			EntityType.ENTITY_BLIND_CREEP,
			
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_BOIL,
			EntityType.ENTITY_WALKINGBOIL,
			EntityType.ENTITY_WALKINGBOIL,
			
			EntityType.ENTITY_ROUND_WORM,
			EntityType.ENTITY_ROUND_WORM,
			EntityType.ENTITY_ROUND_WORM,
			
			EntityType.ENTITY_MULLIGAN,
			EntityType.ENTITY_MULLIGAN,
			EntityType.ENTITY_HIVE,
			EntityType.ENTITY_HIVE,
			EntityType.ENTITY_MULLIGAN,
			
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_HOPPER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_GUSHER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_GAPER,
			EntityType.ENTITY_SKINNY,
			
			EntityType.ENTITY_MAW,
			EntityType.ENTITY_MAW,
			EntityType.ENTITY_HORF,
			EntityType.ENTITY_HORF,
			EntityType.ENTITY_HORF,
			
			EntityType.ENTITY_BONY,
			EntityType.ENTITY_DEATHS_HEAD,
			
			EntityType.ENTITY_ONE_TOOTH,
			
			EntityType.ENTITY_THE_HAUNT,
			EntityType.ENTITY_WIZOOB,
			
			EntityType.ENTITY_FATTY,
			EntityType.ENTITY_FATTY,
			EntityType.ENTITY_HALF_SACK,
			EntityType.ENTITY_CONJOINED_FATTY,
			EntityType.ENTITY_FATTY,
			
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_GLOBIN,
			EntityType.ENTITY_GLOBIN,
			
			EntityType.ENTITY_KNIGHT,
			EntityType.ENTITY_KNIGHT,
			EntityType.ENTITY_KNIGHT,
			
			EntityType.ENTITY_CLOTTY,
			EntityType.ENTITY_CLOTTY,
			
			EntityType.ENTITY_MOMS_HAND,
			
			EntityType.ENTITY_MAGGOT,
			EntityType.ENTITY_MAGGOT,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_SPITY,
			EntityType.ENTITY_CHARGER,
			
			EntityType.ENTITY_PSY_TUMOR,
			EntityType.ENTITY_TUMOR,
			EntityType.ENTITY_BRAIN,
			EntityType.ENTITY_GUTS,
			EntityType.ENTITY_GUTS,
			
			EntityType.ENTITY_PARA_BITE,
			EntityType.ENTITY_PARA_BITE,
			EntityType.ENTITY_LEECH,
			EntityType.ENTITY_LEECH,
			
			EntityType.ENTITY_HOST,
			EntityType.ENTITY_FLESH_MOBILE_HOST,
			EntityType.ENTITY_HOST,
			EntityType.ENTITY_HOST,
			
			EntityType.ENTITY_NERVE_ENDING,
			
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			EntityType.ENTITY_VIS,
			
			EntityType.ENTITY_EYE,
			
			EntityType.ENTITY_DOPLE,
			
			EntityType.ENTITY_BABY,
			
			EntityType.ENTITY_HOMUNCULUS,
			
			EntityType.ENTITY_KEEPER,
			
			EntityType.ENTITY_STONEHEAD,
			EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
			EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
			EntityType.ENTITY_BROKEN_GAPING_MAW,
			
			EntityType.ENTITY_OOB,
			
			EntityType.ENTITY_BLASTOCYST_SMALL,
			EntityType.ENTITY_EMBRYO,
			EntityType.ENTITY_FISTULA_SMALL,
			EntityType.ENTITY_CHARGER,
			EntityType.ENTITY_FISTULA_SMALL,
			EntityType.ENTITY_SPIDER,
			
			EntityType.ENTITY_FIREPLACE,
			EntityType.ENTITY_FIREPLACE
			}

local DG_t1stVar = {
			0, -- Attack Fly
			0, -- Ring Fly
			0, -- Dart Fly
			0, -- Swarm Fly
			0, -- Hush Fly
			0, -- Moter
			0, -- Lvl2 Fly
			0, -- Full Fly
			1, -- Spit
			1, -- Super Pooter
			1, -- Red Boom Fly
			2, -- Drowned Boom Fly
			
			1, -- Corn Dip
			2, -- Brownie Dip
			0, -- Squirt
			1, -- Dank Squirt
			0, -- Dinga
			
			0, -- Big Spider
			1, -- Trite
			0, -- Lvl 2 Spider
			0, -- Ragling
			1, -- Ragman's Ragling
			0, -- Blister
			0, -- Ticking Spider
			0, -- Baby Long Legs
			0, -- Crazy Long Legs
			0, -- Blind Creep
			0, -- The Thing
			0, -- Rage Creep
			
			1, -- Gut
			2, -- Sack
			0, -- Hush Boil
			1, -- Walking Gut
			2, -- Walking Sack
			
			0, -- Night Crawler
			0, -- Roundy
			0, -- Para-Bite
			
			2, -- Mulliboom
			0, -- Hive
			1, -- Drowned Hive
			0, -- Swarmer
			0, -- Nest
			
			0, -- Flaming Hopper
			0, -- Leaper
			0, -- Gusher
			0, -- Black Globin's Body
			0, -- Splasher
			0, -- Frowning Gaper
			0, -- Cyclopia
			0, -- Hush Gaper
			0, -- Greed Gaper
			0, -- Gurgle
			0, -- Nulls
			1, -- Rotty
			
			0, -- Mr Maw's Body
			2, -- Psychic Maw
			0, -- Psychic Horf
			0, -- Maw
			1, -- Red Maw
			
			0, -- Black Bony
			0, -- Flesh Death's Head
			
			0, -- Fat Bat
			
			0, -- Wizoob
			0, -- Red Ghost
			
			0, -- Conjoined Fatty
			1, -- Pale Fatty
			0, -- Blubber
			1, -- Blue Conjoined Fatty
			0, -- Fat Sack
			
			1, -- Gazing Globin
			2, -- Dank Globin
			0, -- Black Globin
			
			1, -- Selfless Knight
			0, -- Floating Knight
			0, -- Bone Knight
			
			2, -- I. Blob
			0, -- Mega Clotty
			
			0, -- Mom's Dead Hand
			
			0, -- Spitty
			0, -- Charger
			1, -- Drowned Charger
			0, -- Conjoined Spitty
			0, -- Grub
			
			0, -- Camillo Jr
			0, -- Psy Tumor
			0, -- MemBrain
			1, -- Mama Guts
			1, -- Scarred Guts
			
			1, -- Scarred Para-Bite
			0, -- Cod Worm
			1, -- Kamikaze Leech
			2, -- Holy Leech
			
			0, -- Host
			0, -- Mobile Host
			0, -- Red Mobile Host
			0, -- Meatball
			
			1, -- Nerve Ending 2
			
			0, -- Vis
			1, -- Double Vis
			3, -- Scarred Double Vis
			
			1, -- BloodShot Eye
			
			1, -- Evil Twin
			
			1, -- Angelic Baby
			
			0, -- Begotten
			
			0, -- Hanger
			
			1, -- Vomit Grimace
			0, -- Brimstone Head
			0, -- Stone Eye
			0, -- Gaping Maw
			
			0, -- Black Maw
			
			0, -- Blastocyst Medium
			0, -- Blastocyst Small
			0, -- Fistula Medium
			0, -- Fistula Small
			1, -- Teratoma Medium
			1, -- Teratoma Small
			
			1, -- Red Fire Place
			3 -- Purple Fire Place
			}

local DG_t2ndVar = {
			0, -- Black Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Attack Fly
			0, -- Lvl2 Fly
			0, -- Sucker
			0, -- Pooter
			0, -- Boom Fly
			0, -- Boom Fly
			
			0, -- Dip
			0, -- Dip
			0, -- Dip
			0, -- Squirt
			0, -- Squirt
			
			0, -- Spider
			0, -- Spider
			0, -- Spider
			1, -- Trite
			1, -- Trite
			1, -- Trite
			0, -- Lvl2 Spider
			1, -- Small Baby Long Legs
			1, -- Small Crazy Long Legs
			0, -- Wall Creep
			0, -- Wall Creep
			0, -- Blind Creep
			
			0, -- Boil
			0, -- Boil
			0, -- Boil
			0, -- Walking Boil
			0, -- Walking Boil
			
			0, -- Round Worm
			0, -- Round Worm
			0, -- Round Worm
			
			1, -- Mulligoon
			0, -- Mulligan
			0, -- Hive
			0, -- Hive
			0, -- Mulligan
			
			0, -- Hopper
			0, -- Hopper
			1, -- Pacer
			0, -- Gusher
			0, -- Gusher
			1, -- Gaper
			1, -- Gaper
			1, -- Gaper
			1, -- Gaper
			0, -- Gaper
			0, -- Gaper
			0, -- Skinny
			
			0, -- Maw
			0, -- Maw
			0, -- Horf
			0, -- Horf
			0, -- Horf
			
			0, -- Bony
			0, -- Death's Head
			
			0, -- One Tooth
			
			10, -- Lil' Haunt
			0, -- Wizoob
			
			0, -- Fatty
			0, -- Fatty
			0, -- Half Sack 
			0, -- Conjoined Fatty
			1, -- Fale Fatty
			
			0, -- Globin
			0, -- Globin
			0, -- Globin
			
			0, -- Knight
			0, -- Knight
			0, -- Knight
			
			0, -- Clotty
			0, -- Clotty
			
			0, -- Mom's Hand
			
			0, -- Maggot
			0, -- Maggot
			0, -- Charger
			0, -- Spitty
			0, -- Charger
			
			0, -- Psy Tumor
			0, -- Tumor
			0, -- Brain
			0, -- Guts
			0, -- Guts
			
			0, -- Para-Bite
			0, -- Para-Bite
			0, -- Leech
			0, -- Leech
			
			1, -- Red Host
			0, -- Flesh Mobile Host
			1, -- Red Host
			1, -- Red Host
			
			0, -- Nerve Ending
			
			2, -- Chubber
			0, -- Vis
			1, -- Double Vis
			
			0, -- Eye
			
			0, -- Dople
			
			0, -- Baby
			
			0, -- Homunculus
			
			0, -- Keeper
			
			0, -- Stone Grimace
			0, -- Turret Grimace
			0, -- Turret Grimace
			1, -- Broken Gaping Maw
			
			0, -- Oob
			
			0, -- Blastocyst Small
			0, -- Embryo
			0, -- Fistula Small
			0, -- Charger
			1, -- Teratoma Small
			0, -- Spider
			
			0, -- Fire Place
			2 -- Blue Fire Place
			}
			
			
function ABppmod:DGrader()
	ent = Isaac.GetRoomEntities()
	for _,v in ipairs(ent) do
		if v:IsEnemy() and v:ToNPC():IsChampion() then
			new=Isaac.Spawn(v.Type,v.Variant,0,v.Position,v.Velocity,v)
			new:GetData().Done = true
			v:GetData().Done = true
			v:Remove()
		else
			for i,v2 in ipairs(DG_t1stEnemy) do
				if v.Type == v2 then
					if v.Variant == DG_t1stVar[i] then
						new=Isaac.Spawn(DG_t2ndEnemy[i],DG_t2ndVar[i],0,v.Position,v.Velocity,v)
						new:GetData().Done = true
						v:GetData().Done = true
						v:Remove()
					end
				end
			end
		end
	end
	return true
end

ABppmod:AddCallback(ModCallbacks.MC_USE_ITEM, ABppmod.DGrader, Downgrader)

------------------------------------------------------------

-- Golden Potato Peeler --

local GoldenPPeeler = Isaac.GetItemIdByName("Golden Potato Peeler")

local GPP_luckUps = 0

function ABppmod:GPP_resetLuckUps()
	GPP_luckUps=0
	local player = Isaac.GetPlayer(0)
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
end

function ABppmod:GPP_cache(player,cacheFlag)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(GoldenPPeeler) then
		if (cacheFlag == CacheFlag.CACHE_LUCK) then
			player.Luck = player.Luck + GPP_luckUps*0.5
		end
	end
end

function ABppmod:GPPeeler()
	local player = Isaac.GetPlayer(0)
	if player:GetMaxHearts() >= 2 then
		player:AddMaxHearts(-2,true)
		pos = player.Position
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BOMB,BombSubType.BOMB_GOLDEN,pos+Vector(30,0),Vector(0,0),player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY,KeySubType.KEY_GOLDEN,pos+Vector(-30,0),Vector(0,0),player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,HeartSubType.HEART_GOLDEN,pos+Vector(0,30),Vector(0,0),player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,CoinSubType.COIN_DIME,pos+Vector(0,-30),Vector(0,0),player)
		GPP_luckUps = GPP_luckUps + 1
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
		if player:GetMaxHearts() == 0 and player:GetSoulHearts() == 0 then
			player:Kill()
		end
	return true
	end
end

ABppmod:AddCallback(ModCallbacks.MC_USE_ITEM, ABppmod.GPPeeler, GoldenPPeeler)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.GPP_cache)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED , ABppmod.GPP_resetLuckUps)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_END , ABppmod.GPP_resetLuckUps)

------------------------------------------------------------

-- Bless from above --

local BlessFromAbove = Isaac.GetItemIdByName("Bless from above")

local BFA_frames = 0
local BFA_doInv = false

function ABppmod:BFA_blinking()
    local player = Isaac.GetPlayer(0);
	if player:HasCollectible(BlessFromAbove) and BFA_doInv and ((player.FrameCount - BFA_frames) <= 90) then
		local isOpaque = false;
		
		if(player.FrameCount % 4 == 0) then
			isOpaque = not(isOpaque);
		end
		
		if(isOpaque) then
			player.Color = Color(1, 1, 1, 1, 0, 0, 0);
		else
			player.Color = Color(1, 1, 1, 0, 0, 0, 0);
		end
	elseif player:HasCollectible(BlessFromAbove) and BFA_doInv then
		BFA_doInv = not(BFA_doInv)
		if not isOpaque then
			player.Color = Color(1, 1, 1, 1, 0, 0, 0);
		end
	end
end

function ABppmod:BFA_frames()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(BlessFromAbove) and BFA_doInv then
		if ((player.FrameCount - BFA_frames) <= 90) then
			return false
		else
			BFA_doInv = false
			return true
		end
	end
end

function ABppmod:BFAbove()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(BlessFromAbove) then
		room = Game():GetRoom()
		if room:IsFirstVisit() and not room:IsClear() then
			BFA_frames = player.FrameCount
			BFA_doInv = true
			blinking()
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.BFA_frames,EntityType.ENTITY_PLAYER)
ABppmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ABppmod.BFAbove)
ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.BFA_blinking)


------------------------------------------------------------

					-- Skin Illnesses --

--------------
-- Blisters --

local Blisters = Isaac.GetItemIdByName("Blisters");
 
function ABppmod:Skin_Blisters(player, cacheFlag)
	if player:HasCollectible(Blisters) then
		if not player:IsFlying() and not player:HasTrinket(Isaac.GetTrinketIdByName("Callus")) then
			if (cacheFlag == CacheFlag.CACHE_SPEED) then
				player.MoveSpeed = (player.MoveSpeed + 0.2) * 0.6;
			end
		end
	end
end

local BL_wasFlying = false
local BL_hadCallus = false

function ABppmod:Blisters_UpdateSpeed()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Blisters) then
		local isFlying = player:IsFlying()
		local hasCallus = player:HasTrinket(Isaac.GetTrinketIdByName("Callus"))
		if (isFlying ~= BL_wasFlying) or (hasCallus ~= BL_hadCallus) then
			player:AddCacheFlags(CacheFlag.CACHE_SPEED);
			player:EvaluateItems();
		end
		BL_wasFlying = isFlying
		BL_hadCallus = hasCallus
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.Blisters_UpdateSpeed, EntityType.ENTITY_PLAYER);

ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.Skin_Blisters)

----------------
-- Stafilocus --

local Stafi = Isaac.GetItemIdByName("Stafilocus");

function ABppmod:Skin_Stafilocus()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Stafi) then
		local pos = player.Position
		creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_WHITE,0,pos,Vector(0,0),player):ToEffect()
		creep.Scale = creep.Scale * 4
		creep.Timeout = creep.Timeout * 3
		Isaac.Spawn(EntityType.ENTITY_BOIL,2,0,pos,Vector(5,5),player)
		player.AddSlowing(creep, 30, 1, Color(0.1, 0.1, 0.1, 1, 0, 0, 0))--TODO
	end
end

ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.Skin_Stafilocus,EntityType.ENTITY_PLAYER)

---------------
--- Ezcemas ---

local Ezcemas = Isaac.GetItemIdByName("Ezcemas")

function ABppmod:Skin_Ezcemas(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Ezcemas) then
		if (dmgFlag & 1114768 ~= 0) then -- Este número corresponde al bitmask de los tipos de daño de DamageFlag 100010000001010010000
			if (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)) or player:HasCollectible(Isaac.GetItemIdByName("The Wafer")) then
				player:TakeDamage(0, 2097152, source, dmgCountdownFrames) --Fake dmg
			else
				player:TakeDamage(dmgAmount, 1, source, dmgCountdownFrames)
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.Skin_Ezcemas,EntityType.ENTITY_PLAYER)

------------
-- Herpes --

local Herpes = Isaac.GetItemIdByName("Herpes")

local H_rooms = 0

function ABppmod:Skin_HerpesCache(player,cacheFlag)
	if player:HasCollectible(Herpes) then
		room = Game():GetRoom()
		level = Game():GetLevel()
		if room:IsFirstVisit() and (level:GetStartingRoomIndex() == level:GetCurrentRoomIndex()) then -- Si estamos en la sala inicial del nivel por primera vez
			if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
				player.Damage = player.Damage - (H_rooms * 2/30)
			end
			if (cacheFlag == CacheFlag.CACHE_SPEED) then
				player.MoveSpeed = player.MoveSpeed + (H_rooms * 1/30)
			end
			H_rooms = 0
		elseif room:IsFirstVisit() then
			if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
				player.Damage = player.Damage + (2/30 * H_rooms)
			end
			if (cacheFlag == CacheFlag.CACHE_SPEED) then
				player.MoveSpeed = player.MoveSpeed - (1/30 * H_rooms)
			end
		end
	end
end

function ABppmod:Skin_Herpes()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(Herpes) then
		room = Game():GetRoom()
		if room:IsFirstVisit() then
			H_rooms = H_rooms + 1
			player:AddCacheFlags(CacheFlag.CACHE_SPEED);
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
			player:EvaluateItems();
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ABppmod.Skin_Herpes)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.Skin_HerpesCache)

-------------
-- Sunburn --

local SunBurn = Isaac.GetItemIdByName("SunBurn")

local SB_count = 0

function ABppmod:SunBurn_Count()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(SunBurn) then
		while SB_count > 0 do
			Isaac.ExecuteCommand("remove c1");Isaac.ExecuteCommand("remove c308")
			SB_count = SB_count - 1
		end
	end
end

function ABppmod:Skin_SunBurn(entity, dmgAmount, dmgFlag, source, dmgSB_countdownFrames)
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(SunBurn) then
		if ((dmgFlag == 0) or (dmgFlag & 2097152 ~= 0)) and (source.Type ~= 9) then -- Los proyectiles no cuentan, Dull razor sí.
			SB_count = SB_count + 1
			Isaac.ExecuteCommand("giveitem c1");Isaac.ExecuteCommand("giveitem c308")
			player:TakeDamage(dmgAmount, 1, source, dmgSB_countdownFrames)
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.Skin_SunBurn,EntityType.ENTITY_PLAYER)
ABppmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ABppmod.SunBurn_Count)

--------------------------------
-- Skin Cancer Transformation -- TODO

local SC_fakepill = Isaac.GetPillEffectByName("Skin Cancer!")

local SC_HasTransform = false
local SC_DidAnimation = false

local SC_tBools = {
		false, --Blisters
		false, --SunBurn
		false, --Herpes
		false, --Ezcemas
		false  --Stafilocus
		}

local SC_tItems = {
		Blisters,
		SunBurn,
		Herpes,
		Ezcemas,
		Stafilocus
		}

function ABppmod:SkinCancer_Checks(player,cacheFlag)
	if not SC_HasTransform then
		for i,v in ipairs(SC_tItems) do
			if player:HasCollectible(v) then
				SC_tBools[i] = true
			end
		end
		local count = 0
		for _,v2 in ipairs(SC_tBools) do
			if v2 then 
				count = count + 1
			end
			if count >= 3 then 
				SC_HasTransform = true
			end
		end
	elseif not SC_DidAnimation then
		Isaac.ExecuteCommand("playsfx 132")
		--TODO -> Display text (Skin Cancer!)
		SC_DidAnimation = true
	end
end

function ABppmod:SkinCancer_Restart()
	SC_HasTransform = false
	SC_DidAnimation = false
	SC_tBools = {
		false, --Blisters
		false, --SunBurn
		false, --Herpes
		false, --Ezcemas
		false  --Stafilocus
	}
end

function ABppmod:SkinCancer(entity, dmgAmount, dmgFlag, source, dmgSB_countdownFrames)
	if SC_DidAnimation then
		return(not(((dmgFlag == 0) or (dmgFlag & 1114768 ~= 0)) and (source.Type ~= 9)))
	end
end

ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.SkinCancer_Checks)
ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.SkinCancer, EntityType.ENTITY_PLAYER)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ABppmod.SkinCancer_Restart)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_END , ABppmod.SkinCancer_Restart)

------------------------------------------------------------

-- Samson's Other Headband --

local SOHeadBand = Isaac.GetItemIdByName("Samson's other Headband")

local SOHB_rooms = 0

local SOHB_lastRoom = nil
local SOHB_currRoom = nil

local SOHB_hadFight = false

function ABppmod:SOHB_Restart()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(SOHeadBand) then
		SOHB_rooms = 0
		SOHB_lastRoom = nil
		SOHB_currRoom = nil
		SOHB_hadFight = false
	end
end

function ABppmod:SOHB_Stats(player,cacheFlag)
	if player:HasCollectible(SOHeadBand) then
		local room = Game():GetRoom()
		if room:IsFirstVisit() and room:IsClear() and SOHB_lastRoom ~= room then
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage + (1/4 * SOHB_rooms)
			end
		end
	end
end

function ABppmod:SOHB_TakeDMG()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(SOHeadBand) then
		SOHB_rooms = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
		player:EvaluateItems();
	end
end

function ABppmod:SOHB_NewRoom()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(SOHeadBand) then
		SOHB_currRoom = Game():GetRoom()
		SOHB_hadFight = not(SOHB_currRoom:IsClear())
	end
end

function ABppmod:SOHB()
	local player = Isaac.GetPlayer(0)
	local room = Game():GetRoom()
	local Character = player:GetPlayerType()
	if player:HasCollectible(SOHeadBand) then
		if room:IsFirstVisit() and room:IsClear() and SOHB_lastRoom ~= SOHB_currRoom and SOHB_hadFight then
			if SOHB_rooms < 24 then
				SOHB_rooms = SOHB_rooms + 1
			end
			SOHB_lastRoom = SOHB_currRoom
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
			player:EvaluateItems();
		end
		if (Character == PlayerType.PLAYER_THELOST) then
			if not (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) and player:HasCollectible(Isaac.GetItemIdByName("Holy Mantle")) then
				SOHB_rooms = 0
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
				player:EvaluateItems();
			end
		end
	end
end
	
ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.SOHB)
ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.SOHB_TakeDMG,EntityType.ENTITY_PLAYER)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.SOHB_Stats)
ABppmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ABppmod.SOHB_NewRoom)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ABppmod.SOHB_Restart)

------------------------------------------------------------

-- First Impression --

local FirstImpression = Isaac.GetItemIdByName("First Impression")

local FI_doBigTear = false
local FI_hasHit = false
local FI_NBigTears = 0
local FI_tBigTears = {}
local FI_NCreepSplashes = 0
local FI_tCreepSplashes = {}
local FI_boosts = 0

local function FI_Modify(shot)
	shot:SetColor(Color(0.5,0,0,1,0,0,0),0,1,false,false)
	FI_doBigTear = false
	if shot.Type == EntityType.ENTITY_TEAR then
		shot.Scale = shot.Scale * 2.5
		FI_NBigTears = FI_NBigTears + 1
		table.insert(FI_tBigTears,shot)
		shot.CollisionDamage = shot.CollisionDamage * 4
	elseif shot.Type == EntityType.ENTITY_LASER then
		local vec = Vector(shot.SpriteScale.X * 2, shot.SpriteScale.Y * 2)
		shot.SpriteScale = vec
		if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
			shot.CollisionDamage = shot.CollisionDamage * 2.5
		else
			shot.CollisionDamage = shot.CollisionDamage * 4
		end
	elseif shot.Type == EntityType.ENTITY_BOMBDROP
	or shot.Variant == EffectVariant.ROCKET then --Fetus
		local vec = Vector(shot.SpriteScale.X * 2, shot.SpriteScale.Y * 2)
		shot.SpriteScale = vec
		FI_NBigTears = FI_NBigTears + 1
		table.insert(FI_tBigTears,shot)
		if shot.Type == EntityType.ENTITY_BOMBDROP then
			shot:ToBomb().ExplosionDamage = shot:ToBomb().ExplosionDamage * 2.5
		else
			
		end
	end
end

local function FI_TearToCreep()
	if FI_NBigTears > 0 then
		for i,tear in ipairs(FI_tBigTears) do
			if not tear:Exists() then
				pos = tear.Position
				creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_PUDDLE_MILK,0,pos,Vector(0,0),player):ToEffect()
				creep:SetColor(Color(0.5,0,0,1,0,0,0),0,1,false,false)
				if player:HasTrinket(Isaac.GetTrinketIdByName("Lost Cork")) then
					creep.Size = creep.Size * 4.7
				else
					creep.Size = creep.Size * 2.35
				end
				creep.Scale = creep.Scale * 2.65
				table.remove(FI_tBigTears,i)
				FI_NBigTears = FI_NBigTears - 1
				FI_NCreepSplashes = FI_NCreepSplashes + 1
				table.insert(FI_tCreepSplashes,creep)
			end
		end
	end
end

local function FI_doCreep()
	if FI_NCreepSplashes > 0 then
		for i,creep in ipairs(FI_tCreepSplashes) do
			if creep:Exists() then
				if (player.Position:Distance(creep.Position) <= (player.Size + creep.Size)) 
				and (creep:GetData().isTouching == nil 
				or not creep:GetData().isTouching) then
					creep:GetData().isTouching = true
					FI_boosts = FI_boosts + 1
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
					player:EvaluateItems();
				elseif creep:GetData().isTouching ~= nil
				and creep:GetData().isTouching
				and (player.Position:Distance(creep.Position) > (player.Size + creep.Size)) then
					creep:GetData().isTouching = false
					FI_boosts = FI_boosts - 1
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
					player:EvaluateItems();
				end
			else
				table.remove(FI_tCreepSplashes,i)
				FI_NCreepSplashes = FI_NCreepSplashes - 1
			end
			if FI_NCreepSplashes == 0 then
				FI_boosts = 0
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
				player:EvaluateItems();
			end
		end
	end
end

function ABppmod:FImpression()
	local player = Isaac.GetPlayer(0)
	if player:HasCollectible(FirstImpression) and not player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
		if FI_doBigTear then
			ent = Isaac.GetRoomEntities()
			for _,shot in ipairs(ent) do
				if (shot.Parent ~= nil)
				and ((shot.Parent.Type == EntityType.ENTITY_PLAYER) 
				or (shot.Parent.Variant == FamiliarVariant.INCUBUS)
				or (shot.Parent.Type == EntityType.ENTITY_LASER)
				or (shot.Parent.Type == EntityType.ENTITY_EFFECT)) then
					if (shot.Type == EntityType.ENTITY_TEAR) then
						shot = shot:ToTear()
						FI_Modify(shot)
						if player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then
							player:SetShootingCooldown(150)
						else
							player:SetShootingCooldown(45)
						end
					elseif (shot.Type == EntityType.ENTITY_LASER) then
						shot = shot:ToLaser()
						FI_Modify(shot)
						if (shot.Variant == 1) or (shot.Variant == 9) then -- Brim o TechBrim
							player:SetShootingCooldown(150)
						elseif player:HasWeaponType(WeaponType.WEAPON_TECH_X) then
							player:SetShootingCooldown(90)
						else
							player:SetShootingCooldown(30)
						end
					elseif (shot.Type == EntityType.ENTITY_BOMBDROP)
					or (shot.Variant == EffectVariant.ROCKET) then
						FI_Modify(shot)
						if (shot.Variant == EffectVariant.ROCKET) then
							player:SetShootingCooldown(90)
						else
							player:SetShootingCooldown(45)
						end
					end
				end
			end
		elseif FI_NBigTears > 0 then
			FI_TearToCreep()
		end
		if FI_NCreepSplashes > 0 then
			FI_doCreep()
		end
	elseif player:HasCollectible(FirstImpression) and player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
		local ent = Isaac.GetRoomEntities()
		local CDmg = player.Damage * 4
		if FI_doBigTear then
			for _,shot in ipairs(ent) do
				if (shot.Type == EntityType.ENTITY_TEAR)
				and (shot.Parent ~= nil)
				and (shot.Parent.Type == EntityType.ENTITY_PLAYER) then
					if not FI_hasHit then
						shot = shot:ToTear()
						if shot:GetData().isBig == nil then
							shot.Scale = shot.Scale * 2.5
							FI_NBigTears = FI_NBigTears + 1
							table.insert(FI_tBigTears,shot)
						end
						shot.CollisionDamage = CDmg
						shot:SetColor(Color(0.5,0,0,1,0,0,0),0,1,false,false)
						shot:GetData().isBig = true
					else
						FI_doBigTear = false
						player:SetShootingCooldown(45)
						shot:Remove()
						FI_hasHit = false
					end
				end
			end
		end
		if FI_NBigTears > 0 then
			FI_TearToCreep()
		end
		if FI_NCreepSplashes > 0 then
			FI_doCreep()
		end
	end
end

function ABppmod:FI_hasHitEnemy(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	if player:HasCollectible(FirstImpression) 
	and player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
		FI_hasHit = (source.Type == EntityType.ENTITY_TEAR)
		return true
	elseif player:HasCollectible(FirstImpression)
	and (source.Type == EntityType.ENTITY_EFFECT)
	and (source.Variant == EffectVariant.ROCKET)
	and entity:GetData().tookDmg == nil then
		entity:GetData().tookDmg = true
		entity:TakeDamage(dmgAmount * 3, dmgFlag, source, dmgcountdownFrames)
		return true
	end
	return true
end

function ABppmod:FI_Cache(player,cacheFlag)
	if player:HasCollectible(FirstImpression) and not player:IsFlying() then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			if FI_boosts > 0 then
				if FI_boosts > 9 then
					if (player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS)) then
						player.Damage = player.Damage * (1.5 ^ 3) --Si hay más de 9, capearlo a 5
					else
						player.Damage = player.Damage * (1.5 ^ 9) --Si hay más de 9, capearlo a 5
					end
				elseif (player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS)) then
						player.Damage = player.Damage * (1.5 ^ (FI_boosts/3)) 
				else
					player.Damage = player.Damage * (1.5 ^ FI_boosts) 
				end
			end
		end
	end
end

function ABppmod:FI_NewRoom()
	if player:HasCollectible(FirstImpression) then
		room = Game():GetRoom()
		FI_doBigTear = not(room:IsClear())
		FI_NBigTears = 0
		FI_tBigTears = {}
		FI_NCreepSplashes = 0
		FI_tCreepSplashes = {}
		FI_boosts = 0
		FI_hasHit = false
		player = Isaac.GetPlayer(0)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
		player:EvaluateItems();
	end
end

function ABppmod:FI_Reset()
	if player:HasCollectible(FirstImpression) then
		FI_doBigTear = false
		FI_NBigTears = 0
		FI_tBigTears = {}
		FI_NCreepSplashes = 0
		FI_tCreepSplashes = {}
		FI_boosts = 0
		FI_hasHit = false
		player = Isaac.GetPlayer(0)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
		player:EvaluateItems();
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ABppmod.FI_NewRoom)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.FI_Cache)
ABppmod:AddCallback(ModCallbacks.MC_POST_UPDATE, ABppmod.FImpression)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ABppmod.FI_Reset)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_END, ABppmod.FI_Reset)
ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.FI_hasHitEnemy)
