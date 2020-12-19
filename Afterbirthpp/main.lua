--[[TODO:
		Almacenar datos en alphaMod.data.run
		Epic fetus con First Impression
		Añadir más casos al Downgrader
		D26 :
			Greed Mode
			Rerolls
		Chemistry Jar : 
			Sprites (buenos)
		Devil's Checklist :
			Lamb,Mom,Fallen
]]


StartDebug()

local ABppmod = RegisterMod("AfterBirth++", 1)
local alphaMod
local SkinCancerId

local ITEMS = {}
local TRINKETS = {}
local CJ_tConfigs = {}
local CJ_tMainJar = {}
local CJ_tPlayerSpHearts = {}
local SCREEN_SIZE = Game():GetRoom():GetRenderSurfaceTopLeft()*2 + Vector(442,286)

local function start() 
	alphaMod = AlphaAPI.registerMod(ABppmod)
	CJ_tConfigs = {
		PC_HeartPurple = alphaMod:getPickupConfig("Heart (Purple)", 1),
		PC_HeartDarkRed = alphaMod:getPickupConfig("Heart (Dark Red)", 2),
		PC_HeartDarkBlue = alphaMod:getPickupConfig("Heart (Dark Blue)", 3),
		PC_HeartLightSalmon = alphaMod:getPickupConfig("Heart (Light Salmon)", 4),
		PC_HeartLightBlue = alphaMod:getPickupConfig("Heart (Light Blue)", 5),
		PC_HeartGrey = alphaMod:getPickupConfig("Heart (Grey)", 6),
		PC_HeartOrange = alphaMod:getPickupConfig("Heart (Orange)", 7),
		PC_HeartDarkGreen = alphaMod:getPickupConfig("Heart (Dark Green)", 8),
		PC_HeartDarkYellow = alphaMod:getPickupConfig("Heart (Dark Yellow)", 9),
		PC_HeartLightYellow = alphaMod:getPickupConfig("Heart (Light Yellow)", 10)
		}
	for _,v in pairs(CJ_tConfigs) do
		v:setDropSound(SoundEffect.SOUND_MEAT_FEET_SLOW0)
		v:setCollectSound(SoundEffect.SOUND_BAND_AID_PICK_UP)
	end

	ITEMS.F4HC = alphaMod:registerItem("Fake 4-head Clover", nil)
	ITEMS.F4HC:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.Fake4Head)
	
	ITEMS.SSizer = alphaMod:registerItem("Super Sizer", nil)
	ITEMS.SSizer:addCallback(AlphaAPI.Callbacks.FLOOR_CHANGED, ABppmod.SuperSizer)
	
	ITEMS.GSoul = alphaMod:registerItem("Guppy's Soul", nil)
	ITEMS.GSoul:addCallback(AlphaAPI.Callbacks.ENTITY_APPEAR, ABppmod.GuppysSoul, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART)

	ITEMS.HHeart = alphaMod:registerItem("Holy Heart", nil)
	ITEMS.HHeart:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.HH_cache, EntityType.ENTITY_PLAYER)
	ITEMS.HHeart:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.HolyHeart)
	
	ITEMS.BFF2 = alphaMod:registerItem("BFF2", nil)
	ITEMS.BFF2:addCallback(AlphaAPI.Callbacks.FAMILIAR_UPDATE, ABppmod.BFF2)
	ITEMS.BFF2:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.BFF2_Leech)
	
	ITEMS.ML1 = alphaMod:registerItem("Math Lesson #1", nil)
	ITEMS.ML1:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.MLesson1, EntityType.ENTITY_TEAR)
	ITEMS.ML1:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.MLesson1, EntityType.ENTITY_LASER)
	ITEMS.ML1:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.ML1_Stats)
	ITEMS.ML1:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.ML1_Unblock)
	
	ITEMS.PBombs = alphaMod:registerItem("Power Bombs!", nil)
	ITEMS.PBombs:addCallback(AlphaAPI.Callbacks.ENTITY_APPEAR, ABppmod.PBombs, EntityType.ENTITY_BOMBDROP)
	ITEMS.PBombs:addCallback(AlphaAPI.Callbacks.ITEM_PICKUP, ABppmod.PB_GiveBombs)
	
	ITEMS.DGrader = alphaMod:registerItem("Downgrader", nil)
	ITEMS.DGrader:addCallback(AlphaAPI.Callbacks.ITEM_USE, ABppmod.DGrader)

	ITEMS.GPPeeler = alphaMod:registerItem("Golden Potato Peeler", nil)
	ITEMS.GPPeeler:addCallback(AlphaAPI.Callbacks.ITEM_USE, ABppmod.GPPeeler, ITEMS.GPPeeler.id)
	ITEMS.GPPeeler:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.GPP_cache)
	ITEMS.GPPeeler:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.GPP_resetLuckUps)
	
	ITEMS.BFAbove = alphaMod:registerItem("Bless From Above", nil)
	ITEMS.BFAbove:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.BFA_frames,EntityType.ENTITY_PLAYER)
	ITEMS.BFAbove:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.BFAbove)
	ITEMS.BFAbove:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.BFA_blinking, EntityType.ENTITY_PLAYER)
	
	ITEMS.Blisters = alphaMod:registerItem("Blisters", nil)
	ITEMS.Blisters:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.Blisters_UpdateSpeed, EntityType.ENTITY_PLAYER)
	ITEMS.Blisters:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.Skin_Blisters)
	
	ITEMS.Stafi = alphaMod:registerItem("Stafilocus", nil)
	ITEMS.Stafi:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.Skin_Stafilocus,EntityType.ENTITY_PLAYER)
	
	ITEMS.Ezcemas = alphaMod:registerItem("Ezcemas", nil)
	ITEMS.Ezcemas:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.Skin_Ezcemas,EntityType.ENTITY_PLAYER)
	
	ITEMS.Herpes = alphaMod:registerItem("Herpes", nil)
	ITEMS.Herpes:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.Skin_Herpes)
	ITEMS.Herpes:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.Skin_HerpesCache)
	
	ITEMS.SunBurn = alphaMod:registerItem("SunBurn", nil)
	ITEMS.SunBurn:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.SunBurn_Count)
	ITEMS.SunBurn:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.Skin_SunBurn, EntityType.ENTITY_PLAYER)
	
	SkinCancerId = alphaMod:registerTransformation(
		"Skin Cancer!",
		{
			Isaac.GetItemIdByName("Blisters"),
			Isaac.GetItemIdByName("Herpes"),
			Isaac.GetItemIdByName("Stafilocus"),
			Isaac.GetItemIdByName("Ezcemas"),
			Isaac.GetItemIdByName("SunBurn")
		},
		3
	)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.TRANSFORMATION_TRIGGER,ABppmod.SkinCancer_Anim, SkinCancerId)
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE,ABppmod.SkinCancer, EntityType.ENTITY_PLAYER)
	
	ITEMS.SunBurn = alphaMod:registerItem("SunBurn", nil)
	ITEMS.SunBurn:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.SunBurn_Count)
	ITEMS.SunBurn:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.Skin_SunBurn, EntityType.ENTITY_PLAYER)
	
	ITEMS.SOHB = alphaMod:registerItem("Samson's other Headband", nil)
	ITEMS.SOHB:addCallback(AlphaAPI.Callbacks.ROOM_CLEARED, ABppmod.SOHB)
	ITEMS.SOHB:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.SOHB_TakeDMG, EntityType.ENTITY_PLAYER)
	ITEMS.SOHB:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.SOHB_Stats)
	ITEMS.SOHB:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.SOHB_NewRoom)
	ITEMS.SOHB:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.SOHB_Restart)
	ITEMS.SOHB:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.SOHB_Lost, EntityType.ENTITY_PLAYER)
	
	ITEMS.FI = alphaMod:registerItem("First Impression", nil)
	ITEMS.FI:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.FI_NewRoom)
	ITEMS.FI:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.FI_Cache)
	ITEMS.FI:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.FImpression, EntityType.ENTITY_PLAYER)
	ITEMS.FI:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.FI_Reset)
	ITEMS.FI:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.FI_hasHitEnemy)
	
	
	ITEMS.CJ = alphaMod:registerItem("Chemistry Jar", nil)
	ITEMS.CJ:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.CJ_PickNormalHeart, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART)
	ITEMS.CJ:addCallback(AlphaAPI.Callbacks.ITEM_USE, ABppmod.ChemJar)
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.CJ_Restart)
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_CONTINUED, ABppmod.CJ_ContinueRun)
	CJ_tConfigs.PC_HeartPurple:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartDarkRed:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartDarkBlue:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartLightSalmon:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartLightBlue:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartGrey:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartOrange:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartDarkGreen:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartDarkYellow:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	CJ_tConfigs.PC_HeartLightYellow:addCallback(AlphaAPI.Callbacks.PICKUP_PICKUP, ABppmod.CJ_PickSpecialHeart)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.CJ_PurpleHeartEffect_HPChange, EntityType.ENTITY_PLAYER)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.CJ_DarkRedHeartEffect_RoomChange)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.CJ_LightSalmonHeartEffect_HPChange, EntityType.ENTITY_PLAYER)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.CJ_GreyHeartEffects_StopJoker, EntityType.ENTITY_PLAYER)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_DEATH, ABppmod.CJ_OrangeHeartEffect_Create, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_DEATH, ABppmod.CJ_DarkGreenHeartEffect_Create, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_DAMAGE, ABppmod.CJ_DarkYellowHeartEffect_changeTear)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_APPEAR, ABppmod.CJ_LightYellowHeartEffect_changeCoins, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)
	
	ITEMS.D26 = alphaMod:registerItem("D26", nil)
	ITEMS.D26:addCallback(AlphaAPI.Callbacks.ITEM_USE, ABppmod.D26)
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.D26_Restart)
	alphaMod:addCallback(AlphaAPI.Callbacks.ENTITY_APPEAR, ABppmod.D26_ChangeSpawnedItem, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
	
	ITEMS.MV = alphaMod:registerItem("Mini-Void", nil)
	ITEMS.MV:addCallback(AlphaAPI.Callbacks.ITEM_USE, ABppmod.MiniVoid)
	ITEMS.MV:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.MV_cachePassive)
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.MV_Restart)
	
	TRINKETS.TC = alphaMod:registerTrinket("Trump Card", nil)
	TRINKETS.TC:addCallback(AlphaAPI.Callbacks.ENTITY_APPEAR, ABppmod.TCard, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD)
	
	ITEMS.SD = alphaMod:registerItem("Stuffed Die", nil)
	ITEMS.SD:addCallback(AlphaAPI.Callbacks.ITEM_USE, ABppmod.SDie)
	ITEMS.SD:addCallback(AlphaAPI.Callbacks.ITEM_CACHE, ABppmod.SD_cacheLuck)
	ITEMS.SD:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.SD_ChangeRoom)
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.SD_Restart)
	
	ITEMS.ES = alphaMod:registerItem("Eden's Spirit", nil)
	ITEMS.ES:addCallback(AlphaAPI.Callbacks.ITEM_PICKUP, ABppmod.ES_getItem)
	ITEMS.ES:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.ESpirit, EntityType.ENTITY_PLAYER)
	alphaMod:addCallback(AlphaAPI.Callbacks.PLAYER_DIED, ABppmod.ES_playerDied)
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.ES_Restart)
	
	TRINKETS.CL = alphaMod:registerTrinket("Devil's Checklist", nil)
	TRINKETS.CL:addCallback(AlphaAPI.Callbacks.ROOM_CHANGED, ABppmod.CL_enterRoom)
	TRINKETS.CL:addCallback(AlphaAPI.Callbacks.ROOM_CLEARED, ABppmod.CL_clearedRoom)
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.CL_Restart)
	TRINKETS.CL:addCallback(AlphaAPI.Callbacks.ENTITY_UPDATE, ABppmod.CL_updateEnemiesData)
	TRINKETS.CL:addCallback(AlphaAPI.Callbacks.ENTITY_APPEAR, ABppmod.CL_spawnedFallen, EntityType.ENTITY_FALLEN)
	
	alphaMod:addCallback(AlphaAPI.Callbacks.RUN_STARTED, ABppmod.PH_Restart)
end

------------------------------------------------------------

-- Fake 4-head Clover --
 
function ABppmod.Fake4Head(player, cacheFlag)
	if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
		player.Damage = player.Damage - 0.35
	end
	if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
		player.MaxFireDelay = player.MaxFireDelay + 2
	end
	if (cacheFlag == CacheFlag.CACHE_SPEED) then
		player.MoveSpeed = player.MoveSpeed - 0.2
	end
	if (cacheFlag == CacheFlag.CACHE_SHOTSPEED) then
		player.ShotSpeed = player.ShotSpeed - 0.3
	end
	if (cacheFlag == CacheFlag.CACHE_RANGE) then
		player.TearFallingSpeed = player.TearFallingSpeed - 0.5
	end
	if (cacheFlag == CacheFlag.CACHE_LUCK) then
		player.Luck = (math.abs(player.Luck) + 2) * 1.75
	end
end

------------------------------------------------------------

-- Super Sizer -- TODO : Black Candle


function ABppmod.SuperSizer(level)
	local currstage = level:GetStage()
	if (level:CanStageHaveCurseOfLabyrinth(currstage)) then
		while level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == 0 do -- Reseedea hasta que toque curse
			Isaac.ExecuteCommand("reseed")
		end
	end
end	

------------------------------------------------------------

-- Guppy's Soul --

local function GSoul_LegitRoom(roomID,roomDT)
	if roomDT.Type == RoomType.ROOM_SUPERSECRET then
		if (roomID == 0) or (roomID == 1) or (roomID == 6) then
			return false
		end
	end
	return true
end

function ABppmod.GuppysSoul(heart,data)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local currRoom = AlphaAPI.GAME_STATE.LEVEL:GetCurrentRoomDesc().Data.Variant
	local room = AlphaAPI.GAME_STATE.LEVEL:GetCurrentRoomDesc().Data
	if GSoul_LegitRoom(currRoom,room) and data.done == nil then
		local pos = heart.Position
		local vel = heart.Velocity
		heart:Remove()
		local newHeart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL,pos,vel,heart)
		newHeart:GetData().done = true
	end
end

------------------------------------------------------------

-- Holy Heart --

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

function ABppmod.HH_cache()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local Sum = (math.ceil(player:GetSoulHearts()/2) + math.ceil(player:GetHearts()/2))
	if (Sum ~= previous_sumHH) then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	previous_sumHH = sum
end

function ABppmod.HolyHeart(player, cacheFlag)          
	local FilledCont = player:GetHearts()
	local SoulHearts = player:GetSoulHearts()
	local BlackHearts = HH_countBits(player:GetBlackHearts())
	local Character = player:GetPlayerType()
	if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
		if (Character == PlayerType.PLAYER_XXX) then
			player.Damage = player.Damage + (math.ceil(SoulHearts/2) - BlackHearts) * 0.25
			player.Damage = player.Damage - BlackHearts * 0.4
		elseif (Character == PlayerType.PLAYER_THELOST) then
			if (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then
				player.Damage = player.Damage + 2
			else
				player.Damage = player.Damage - 1
			end
		else --Si somos cualquier otro personaje.
			player.Damage = player.Damage + math.ceil(FilledCont/2) * 0.65
			player.Damage = player.Damage - (math.ceil(SoulHearts/2) - BlackHearts) * 0.15
			player.Damage = player.Damage - BlackHearts * 0.4
		end
	end
end

------------------------------------------------------------

-- BFF 2 --

local function BFF2_Bumbo(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if ((sprite:IsPlaying("Level4Spawn")) or (sprite:IsPlaying("Level1Spawn"))
	or (sprite:IsPlaying("Level2Spawn"))) then
		if sprite:GetFrame() == 10 then
			local ent = AlphaAPI.entities.friendly
			for _,drop in ipairs(ent) do
				if (drop.FrameCount <= 1) and drop:GetData().isDup == nil then
					local newDrop = Isaac.Spawn(EntityType.ENTITY_PICKUP, drop.Variant, 0,Isaac.GetFreeNearPosition(pos,10),Vector(0,0),familiar)
					newDrop:GetData().isDup = true
					drop:GetData().isDup = true
					break
				end
			end
		end
	end
end

local function BFF2_RottenBaby(familiar)
    local pos = familiar.Position
    local sprite = familiar:GetSprite()
    local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	
	if ((sprite:IsPlaying("ShootDown")) or (sprite:IsPlaying("ShootSide"))
    or (sprite:IsPlaying("ShootUp")) or (sprite:IsPlaying("FloatShootDown"))
    or (sprite:IsPlaying("FloatShootSide")) or (sprite:IsPlaying("FloatShootUp"))) then
		local ent = AlphaAPI.entities.friendly
        for _,fly in ipairs(ent) do
            if (fly.FrameCount <= 1) and (fly.Variant == FamiliarVariant.BLUE_FLY) and (fly.SpawnerType == player.Type) and (fly:GetData().IsNewFly == nil) then
				local spawnedFly = player:AddBlueFlies(1, player.Position, nil)
				spawnedFly:GetData().IsNewFly = true
				fly:GetData().IsNewFly = true
            end
        end
    end
end

local function BFF2_DarkBum(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if (sprite:IsPlaying("Spawn")) and (sprite:GetFrame() == 1) then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, Isaac.GetFreeNearPosition(pos,10), Vector(0,0), familiar)
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
	local ent = AlphaAPI.entities.friendly
	for _,drop in ipairs(ent) do
		if (drop.Variant == PickupVariant.PICKUP_HEART) then
			if (drop.SubType == HeartSubType.HEART_ETERNAL) then
				if ((drop:GetSprite():GetFrame() == 0) and (drop.SpawnerType == familiar.Type)) then
					drop.SpawnerType = player.Type
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, Isaac.GetFreeNearPosition(pos,10), Vector(0,0), player)
				end
			end
		end
	end
end

local function BFF2_ChargedBaby(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") and sprite:GetFrame() == 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 0, Isaac.GetFreeNearPosition(pos,10), Vector(0,0), familiar)
	elseif sprite:IsPlaying("Act") and sprite:GetFrame() == 1 then
		local player = AlphaAPI.GAME_STATE.PLAYERS[1]
		if (player:NeedsCharge()) then
			player:SetActiveCharge(player:GetActiveCharge()+1)
		end
	end
end

function ABppmod.BFF2_Leech(EntDMGed,DMG,DMGF,EntDMGer,DMGCountF)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	 if player:HasCollectible(Isaac.GetItemIdByName("Leech")) then
		if ((EntDMGed.HitPoints - DMG <= 0) and (EntDMGer.Type == EntityType.ENTITY_FAMILIAR) and (EntDMGer.Variant == FamiliarVariant.LEECH)) then
			AlphaAPI.GAME_STATE.PLAYERS[1]:AddHearts(1)
		end
	end
end

local function BFF2_KeyBum(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") then
		local ent = AlphaAPI.entities.friendly
		for _,drop in ipairs(ent) do
			if drop.FrameCount <= 1 and drop:GetData().isDup == nil then
				if (drop.Variant == 50) or (drop.Variant == 51) or (drop.Variant == 52)
				or (drop.Variant == 53) or (drop.Variant == 60) or (drop.Variant == 360) then
					local newDrop = Isaac.Spawn(EntityType.ENTITY_PICKUP, drop.Variant, 0,Isaac.GetFreeNearPosition(pos,10),Vector(0,0),familiar)
					drop:GetData().isDup = true
					newDrop:GetData().isDup = true
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
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, SubType, Isaac.GetFreeNearPosition(pos,10), Vector(0,0), familiar)
	end
end

local function BFF2_AnimationMultDrops(familiar)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") then
		local ent = AlphaAPI.entities.friendly
		for _,drop in ipairs(ent) do
			if drop.FrameCount <= 1 and drop:GetData().isDup == nil then
				if (drop.SpawnerVariant == familiar.Variant) then
					local newDrop = Isaac.Spawn(EntityType.ENTITY_PICKUP, drop.Variant, 0,Isaac.GetFreeNearPosition(pos,10),Vector(0,0),familiar)
					drop:GetData().isDup = true
					newDrop:GetData().isDup = true
					break
				end
			end
		end
	end
end
	
local function BFF2_Animation(familiar,Variant)
	local pos = familiar.Position
	local sprite = familiar:GetSprite()
	if sprite:IsPlaying("Spawn") and sprite:GetFrame() == 0 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, Variant, 0, Isaac.GetFreeNearPosition(pos,10), Vector(0,0), familiar)
	end
end

function ABppmod.BFF2(familiar)
	local tFam = {
		--[[SackOfPennies]]	FamiliarVariant.SACK_OF_PENNIES,
		--[[BombBag]]			FamiliarVariant.BOMB_BAG,
		--[[MysterySack]]		FamiliarVariant.MYSTERY_SACK,
		--[[SackOfSacks]]		FamiliarVariant.SACK_OF_SACKS,
		--[[LilChest]]			FamiliarVariant.LIL_CHEST,
		--[[Relic]]				FamiliarVariant.RELIC,
		--[[Chad]]				FamiliarVariant.LITTLE_CHAD,
		--[[Bum]]					FamiliarVariant.BUM_FRIEND,
		--[[DarkBum]]			FamiliarVariant.DARK_BUM,
		--[[KeyBum]]				FamiliarVariant.KEY_BUM,
		--[[Sissy]]				FamiliarVariant.SISSY_LONGLEGS,
		--[[RottenBaby]]		FamiliarVariant.ROTTEN_BABY,
		--[[SwornProtector]]	FamiliarVariant.SWORN_PROTECTOR,
		--[[RuneBag]]			FamiliarVariant.RUNE_BAG,
		--[[BatteryBaby]]		FamiliarVariant.CHARGED_BABY,
		--[[AcidBaby]]			FamiliarVariant.ACID_BABY,
		--[[Bumbo]]				FamiliarVariant.BUMBO
	}
	
	local tBool = {
		--[[SackOfPennies]]	false, --Funciona
		--[[BombBag]]			false, --Funciona
		--[[MysterySack]]		false, --Funciona
		--[[SackOfSacks]]		false, --Funciona
		--[[LilChest]]			false, --Funciona
		--[[Relic]]				false, --Funciona
		--[[Chad]]				false, --Funciona
		--[[Bum]]					false, --Funciona
		--[[DarkBum]]			false, --Funciona
		--[[KeyBum]]				false, --Funciona
		--[[Sissy]]				false, --Funciona
		--[[RottenBaby]]		false, --Funciona
		--[[SwornProtector]]	false, --Funciona
		--[[RuneBag]]			false, --Funciona
		--[[BatteryBaby]]		false, --Funciona
		--[[AcidBaby]]			false, --Funciona
		--[[Bumbo]]				false  --Funciona
	}
	local tEntFam = {
		--[[SackOfPennies]]	0,
		--[[BombBag]]			0,
		--[[MysterySack]]		0,
		--[[SackOfSacks]]		0,
		--[[LilChest]]			0,
		--[[Relic]]				0,
		--[[Chad]]				0,
		--[[Bum]]					0,
		--[[DarkBum]]			0,
		--[[KeyBum]]				0,
		--[[Sissy]]				0,
		--[[RottenBaby]]		0,
		--[[SwornProtector]]	0,
		--[[RuneBag]]			0,
		--[[BatteryBaby]]		0,
		--[[AcidBaby]]			0,
		--[[Bumbo]]				0
	}
	
	local tFunc = {
		--[[SackOfPennies]]	function(i) BFF2_Animation(tEntFam[1],PickupVariant.PICKUP_COIN) end,
		--[[BombBag]]			function(i) BFF2_Animation(tEntFam[2],PickupVariant.PICKUP_BOMB) end,
		--[[MysterySack]]		function(i) BFF2_AnimationMultDrops(tEntFam[3]) end,
		--[[SackOfSacks]]		function(i) BFF2_Animation(tEntFam[4],PickupVariant.PICKUP_GRAB_BAG) end,
		--[[LilChest]]			function(i) BFF2_AnimationMultDrops(tEntFam[5]) end,
		--[[Relic]]				function(i) BFF2_AnimationHeart(tEntFam[6],HeartSubType.HEART_SOUL) end,
		--[[Chad]]				function(i) BFF2_AnimationHeart(tEntFam[7],HeartSubType.HEART_HALF) end,
		--[[Bum]]					function(i) BFF2_AnimationMultDrops(tEntFam[8]) end,
		--[[DarkBum]]			function(i) BFF2_DarkBum(tEntFam[9]) end,
		--[[KeyBum]]				function(i) BFF2_KeyBum(tEntFam[10]) end,
		--[[Sissy]]				function(i) BFF2_Sissy(tEntFam[11],FamiliarVariant.BLUE_SPIDER) end,
		--[[RottenBaby]]		function(i) BFF2_RottenBaby(tEntFam[12]) end,
		--[[SwornProtector]]	function(i) BFF2_Sworn(tEntFam[13]) end,
		--[[RuneBag]]			function(i) BFF2_AnimationMultDrops(tEntFam[14]) end,
		--[[BatteryBaby]]		function(i) BFF2_ChargedBaby(tEntFam[15]) end,
		--[[AcidBaby]]			function(i) BFF2_AnimationMultDrops(tEntFam[16]) end,
		--[[Bumbo]]				function(i) BFF2_Bumbo(tEntFam[17]) end
	}
	for i,v in ipairs(tFam) do
		if (familiar.Variant == v) then
			tBool[i] = true
			tEntFam[i] = familiar
			break
		end
	end
	for i,v in ipairs(tBool) do
		if v then
			tFunc[i]()
		end
	end
end

------------------------------------------------------------

-- Math Lesson #1 --

local ML1_block = false

function ABppmod.ML1_Stats(player,cacheFlag)
	if (cacheFlag == CacheFlag.CACHE_SHOTSPEED) then
		player.ShotSpeed = player.ShotSpeed - 0.4
	end
	if (cacheFlag == CacheFlag.CACHE_RANGE) then
		player.TearFallingSpeed = player.TearFallingSpeed + 4
	end
end

function ABppmod.ML1_Unblock() -- Esta función desbloqueará los cambios de los sprites (no del daño)
	local game = AlphaAPI.GAME_STATE.GAME -- Cuando haya muchos láseres al mismo tiempo, esto se hace
	local cantLaseres = 0 -- Para reducir lo más posible los lags.
	if game:GetFrameCount() % 30 == 0 then -- Cada medio segundo se recheckea a ver si se limpió la zona
		local laseres = AlphaAPI.entities.friendly -- Y si se encuentran menos de 6 láseres, se desbloquea
		for _,v in ipairs(laseres) do
			if v.Type == 7 then
				cantLaseres = cantLaseres + 1
				if cantLaseres > 6 then
					break
				end
			end
		end
		if cantLaseres <= 6 then
			ML1_block = false
		end
	end
end

--[[function ABppmod.MLesson1(entity,data)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if (entity.SpawnerType == EntityType.ENTITY_PLAYER) or (entity.SpawnerVariant == FamiliarVariant.INCUBUS) then
		if (entity.Type == EntityType.ENTITY_TEAR) or (entity.Type == EntityType.ENTITY_LASER) then	
			if not ML1_block then
				local cantLaseres = 0
				if player:HasCollectible(Isaac.GetItemIdByName("Brimstone"))
				or player:HasCollectible(Isaac.GetItemIdByName("Technology Zero")) then
					local laseres = AlphaAPI.entities.friendly
					for _,v in ipairs(laseres) do
						if v.Type == 7 then
							cantLaseres = cantLaseres + 1
						end
					end
				end
				if cantLaseres > 10 then -- Si hay más de 10 láseres con este efecto, se para de hacer el efecto para reducir lageos
					ML1_block = true
				end
				if not ML1_block then
					local x = entity.FrameCount
					if x >= 40 
					and player:HasCollectible(Isaac.GetItemIdByName("Brimstone"))
					and not player:HasCollectible(Isaac.GetItemIdByName("The Ludovico Technique")) -- Si tenemos ludo no hacemos esto
					and (player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) -- Solo con Brimstone normal
					or player:HasWeaponType(WeaponType.WEAPON_ROCKETS)) then -- O Epic Fetus + Brimstone
						local res = math.cos(8*math.pi/3 + (x-40)*math.pi/30)+1 -- Esta operación se explica en LogicaSinusoidal
						local Vec = Vector(res,res)
						entity.SpriteScale = Vec
						entity.CollisionDamage = player.Damage * res
						if (res == 0) then
							entity:Remove()
						end	
					elseif x > 0 then
						local res = math.sin(math.pi/(20/x) - math.pi/2)+1.5 -- Esta operación se explica en LogicaSinusoidal
						local Vec = Vector(res,res)
						entity.SpriteScale = Vec
						if (entity.Type == EntityType.ENTITY_LASER) then
							entity.CollisionDamage = player.Damage * res -- Se tiene que hacer aquí por que no funcionan los láseres en el DMG_Callback
						end
					end
				end
			end
		end
	end
end]]

local function ML1_DecreasedChange(entity,x)
	local res = math.cos(8*math.pi/3 + (x-40)*math.pi/30)+1 -- Esta operación se explica en LogicaSinusoidal
	local Vec = Vector(res,res)
	entity.SpriteScale = Vec
	if entity:GetData().ActualSize == nil then entity:GetData().ActualSize = entity.Size end
	entity.Size = entity:GetData().ActualSize * res
	return res
end

local function ML1_ConstChange(entity,x)
	local res = math.sin(math.pi/(20/x) - math.pi/2)+1.5 -- Esta operación se explica en LogicaSinusoidal
	local Vec = Vector(res,res)
	entity.SpriteScale = Vec
	if entity:GetData().ActualSize == nil then entity:GetData().ActualSize = entity.Size end
	entity.Size = entity:GetData().ActualSize * res
	return res
end

function ABppmod.MLesson1(entity,data)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if (entity.SpawnerType == EntityType.ENTITY_PLAYER) or (entity.SpawnerVariant == FamiliarVariant.INCUBUS) then
		if (entity.Type == EntityType.ENTITY_TEAR) then
			local x = entity.FrameCount
			if x > 1 then
				ML1_ConstChange(entity,x)
			else
				entity:GetData().ActualSize = entity.Size
			end
		elseif (entity.Type == EntityType.ENTITY_LASER) then
			local x = entity.FrameCount
			if x <= 1 then
				entity:GetData().ActualSize = entity.Size
			elseif entity.Variant == 1 or entity.Variant == 9 then -- Brim or TechBrim
				if entity.SubType == 0 then -- Brim o TechBrim (ambos tienen 0 de SubTipo)
					if x < 40 then
						local res = ML1_ConstChange(entity,x)
						entity.CollisionDamage = player.Damage * res
					else -- if x >= 40
						local res = ML1_DecreasedChange(entity,x)
						entity.CollisionDamage = player.Damage * res
						if res == 0 then
							entity:Remove()
						end
					end
				elseif entity.SubType == 2 then-- BrimX
					local res = ML1_ConstChange(entity,x)
					entity.CollisionDamage = player.Damage * res
				end
			elseif entity.Variant == 2 then -- Variant == 2
				if entity.SubType == 2 then -- Solo Tech X y Brim se aplican. Tech, LudoTech, Tech2 y Jacobs se ignoran (SubType 0)
					local res = ML1_ConstChange(entity,x)
					entity.CollisionDamage = player.Damage * res
				end
			end
		end
	end
end

function ABppmod:MLesson1Damage(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames) -- Solo para tears y Ludo normal
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if player:HasCollectible(Isaac.GetItemIdByName("Math Lesson #1")) then
		local sourceRef = source
		source = AlphaAPI.getEntityFromRef(source)
		if source == nil then source = sourceRef end
		if entity:IsActiveEnemy(false) then
			if (source.Type == EntityType.ENTITY_TEAR) then
				local x = source.FrameCount
				if x > 0 then
					local res = math.sin(math.pi/(20/x)-math.pi/2)+1.5
					if (dmgFlag & 2^22) == 0 then -- Nos inventamos la flag y evitamos bucle infinito
						entity:TakeDamage(dmgAmount*res, dmgFlag | 2^22, sourceRef, dmgCountdownFrames)
						return false -- Se anula el primer ataque que creó esta llamada
					end
				else
					return false -- Si x=0 no hace daño
				end
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.MLesson1Damage)

------------------------------------------------------------

-- Power Bombs --

function ABppmod.PB_GiveBombs()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	player:AddBombs(5)
end

function ABppmod.PBombs(bomb)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	bomb = bomb:ToBomb()
	if (bomb.SpawnerType == EntityType.ENTITY_PLAYER) or (bomb.SpawnerVariant == FamiliarVariant.INCUBUS)  then
		bomb.ExplosionDamage = bomb.ExplosionDamage * 3
		if player:HasCollectible(Isaac.GetItemIdByName("Mr. Mega")) then
			bomb.RadiusMultiplier = bomb.RadiusMultiplier / (4/3) -- 0.75
		else
			bomb.RadiusMultiplier = bomb.RadiusMultiplier / 2 -- 0.5
		end
	end
end

------------------------------------------------------------

-- Downgrader --

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
			
function ABppmod.DGrader()
	local ent = AlphaAPI.entities.enemies
	for _,v in ipairs(ent) do
		if v:ToNPC():IsChampion() then
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

------------------------------------------------------------

-- Golden Potato Peeler --

local GPP_luckUps = 0

function ABppmod:GPP_resetLuckUps()
	GPP_luckUps=0
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
end

function ABppmod:GPP_cache(player,cacheFlag)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if player:HasCollectible(GoldenPPeeler) then
		if (cacheFlag == CacheFlag.CACHE_LUCK) then
			player.Luck = player.Luck + GPP_luckUps*0.5
		end
	end
end

function ABppmod:GPPeeler()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if player:GetMaxHearts() >= 2 then
		player:AddMaxHearts(-2,true)
		pos = player.Position
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BOMB,BombSubType.BOMB_GOLDEN,Isaac.GetFreeNearPosition(pos,30),Vector(0,0),player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY,KeySubType.KEY_GOLDEN,Isaac.GetFreeNearPosition(pos,30),Vector(0,0),player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,HeartSubType.HEART_GOLDEN,Isaac.GetFreeNearPosition(pos,30),Vector(0,0),player)
		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,CoinSubType.COIN_DIME,Isaac.GetFreeNearPosition(pos,30),Vector(0,0),player)
		GPP_luckUps = GPP_luckUps + 1
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
		if player:GetMaxHearts() == 0 and player:GetSoulHearts() == 0 then
			player:Kill()
		end
	return true
	end
end

------------------------------------------------------------

-- Bless from above --

local BFA_Nframes = 0
local BFA_doInv = false

local function BFA_blinkingFrec(FrameCount)
	return (7 - math.ceil((FrameCount - BFA_Nframes)/15)) -- Rango desde 7 hasta 1
end

function ABppmod.BFA_blinking()
    local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if BFA_doInv and ((player.FrameCount - BFA_Nframes) <= 90) then
		local isOpaque = false
		
		if((player.FrameCount % BFA_blinkingFrec(player.FrameCount)) == 0) then
			isOpaque = not(isOpaque)
		end
		
		if(isOpaque) then
			player.Color = Color(1, 1, 1, 1, 0, 0, 0)
		else
			player.Color = Color(1, 1, 1, 0, 0, 0, 0)
		end
	elseif BFA_doInv then
		BFA_doInv = not(BFA_doInv)
		if not isOpaque then
			player.Color = Color(1, 1, 1, 1, 0, 0, 0)
		end
	end
end

function ABppmod.BFA_frames(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if BFA_doInv then
		if ((player.FrameCount - BFA_Nframes) <= 90) then
			if dmgFlag & DamageFlag.DAMAGE_IV_BAG == 0 then
				return false
			end
		else
			BFA_doInv = false
		end
	end
end

function ABppmod.BFAbove()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local room = AlphaAPI.GAME_STATE.ROOM
	if room:IsFirstVisit() and not room:IsClear() then
		BFA_Nframes = player.FrameCount
		BFA_doInv = true
	end
end

------------------------------------------------------------

					-- Skin Illnesses --

--------------
-- Blisters --
 
function ABppmod.Skin_Blisters(player, cacheFlag)
	if not player:IsFlying() and not player:HasTrinket(Isaac.GetTrinketIdByName("Callus")) then
		if (cacheFlag == CacheFlag.CACHE_SPEED) then
			player.MoveSpeed = (player.MoveSpeed + 0.2) * 0.6
		end
	end
end

local BL_wasFlying = false
local BL_hadCallus = false

function ABppmod.Blisters_UpdateSpeed()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local isFlying = player:IsFlying()
	local hasCallus = player:HasTrinket(Isaac.GetTrinketIdByName("Callus"))
	if (isFlying ~= BL_wasFlying) or (hasCallus ~= BL_hadCallus) then
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
	end
	BL_wasFlying = isFlying
	BL_hadCallus = hasCallus
end

----------------
-- Stafilocus --

function ABppmod.Skin_Stafilocus()
	if not AlphaAPI.hasTransformation(SkinCancerId) then
		local player = AlphaAPI.GAME_STATE.PLAYERS[1]
		local pos = player.Position
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_WHITE,0,pos,Vector(0,0),player):ToEffect()
		creep.Scale = creep.Scale * 4
		creep.Timeout = creep.Timeout * 3
		Isaac.Spawn(EntityType.ENTITY_BOIL,2,0,pos,Vector(5,5),player)
	end
end

---------------
--- Ezcemas ---	

function ABppmod.Skin_Ezcemas(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	if not AlphaAPI.hasTransformation(SkinCancerId) then
		local player = AlphaAPI.GAME_STATE.PLAYERS[1]
		if (dmgFlag & 1114768 ~= 0) then -- Este número corresponde al bitmask de los tipos de daño de DamageFlag 01 0001 0000 0010 1001 0000
			if (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)) or player:HasCollectible(Isaac.GetItemIdByName("The Wafer")) then
				player:TakeDamage(0, 2097152, source, dmgCountdownFrames) --Fake dmg
			else
				player:TakeDamage(dmgAmount, 1, source, dmgCountdownFrames)
			end
		end
	end
end

------------
-- Herpes --

local H_rooms = 0

function ABppmod.Skin_HerpesCache(player,cacheFlag)
	local room = AlphaAPI.GAME_STATE.ROOM
	local level = AlphaAPI.GAME_STATE.LEVEL
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

function ABppmod.Skin_Herpes()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local room = AlphaAPI.GAME_STATE.ROOM
	if room:IsFirstVisit() then
		H_rooms = H_rooms + 1
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

-------------
-- Sunburn --

local SB_count = 0

function ABppmod.SunBurn_Count()
	if not AlphaAPI.hasTransformation(SkinCancerId) and SB_count > 0 then
		local player = AlphaAPI.GAME_STATE.PLAYERS[1]
		while SB_count > 0 do
			player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_SAD_ONION)
			SB_count = SB_count - 1
		end
	end
end

function ABppmod.Skin_SunBurn(entity, dmgAmount, dmgFlag, source, dmgSB_countdownFrames)
	if not AlphaAPI.hasTransformation(SkinCancerId) then
		local player = AlphaAPI.GAME_STATE.PLAYERS[1]
		if ((dmgFlag == 0) or (dmgFlag & 2097152 ~= 0)) and (source.Type ~= 9) then -- Los proyectiles no cuentan, Dull razor sí.
			SB_count = SB_count + 1
			player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_SAD_ONION,true)
			if (dmgFlag & 2^22) == 0 then -- Nos inventamos la flag y evitamos bucle infinito
				player:TakeDamage(dmgAmount*2, dmgFlag | 2^22, source, dmgSB_countdownFrames*2)
				return false -- Se anula el primer ataque que creó esta llamada
			end
		end
	end
end

--------------------------------
-- Skin Cancer Transformation

function ABppmod.SkinCancer_Anim()
	Isaac.ExecuteCommand("playsfx 132")
	AlphaAPI.playOverlay(AlphaAPI.OverlayType.OVERLAY_STREAK, "gfx/SkinCancer.png")
end

function ABppmod.SkinCancer(entity, dmgAmount, dmgFlag, source, dmgSB_countdownFrames)
	if AlphaAPI.hasTransformation(SkinCancerId) then
		if ((dmgFlag == 0) or (dmgFlag & 1114768 ~= 0)) and (source.Type ~= 9) then -- 01 0001 0000 0010 1001 0000
			return false
		end
	end
end

------------------------------------------------------------

-- Samson's Other Headband --

local SOHeadBand = Isaac.GetItemIdByName("Samson's other Headband")

local SOHB_rooms = 0
local SOHB_lastRoom = nil
local SOHB_currRoom = nil
local SOHB_hadFight = false

function ABppmod.SOHB_Restart()
	SOHB_rooms = 0
	SOHB_lastRoom = nil
	SOHB_currRoom = nil
	SOHB_hadFight = false
end

function ABppmod.SOHB_Stats(player,cacheFlag)
	local room = AlphaAPI.GAME_STATE.ROOM
	if room:IsFirstVisit() and room:IsClear() and SOHB_lastRoom ~= room then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + (1/4 * SOHB_rooms)
		end
	end
end

function ABppmod.SOHB_TakeDMG()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	SOHB_rooms = 0
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end

function ABppmod.SOHB_NewRoom(room)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	SOHB_currRoom = room
	SOHB_hadFight = not(SOHB_currRoom:IsClear())
end

function ABppmod.SOHB_Lost()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local Character = player:GetPlayerType()
	if (Character == PlayerType.PLAYER_THELOST) then
		if not (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) and player:HasCollectible(Isaac.GetItemIdByName("Holy Mantle")) then
			SOHB_rooms = 0
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	end
end

function ABppmod.SOHB(room)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local Character = player:GetPlayerType()
	if room:IsFirstVisit() then
		if SOHB_rooms < 24 then
			SOHB_rooms = SOHB_rooms + 1
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

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
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
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
	elseif shot.Type == EntityType.ENTITY_BOMBDROP then --Fetus
		local vec = Vector(shot.SpriteScale.X * 2, shot.SpriteScale.Y * 2)
		shot.SpriteScale = vec
		FI_NBigTears = FI_NBigTears + 1
		table.insert(FI_tBigTears,shot)
		shot:ToBomb().ExplosionDamage = shot:ToBomb().ExplosionDamage * 2.5
	end
end

local function FI_TearToCreep()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if FI_NBigTears > 0 then
		for i,tear in ipairs(FI_tBigTears) do
			if not tear:Exists() then
				local pos = tear.Position
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_PUDDLE_MILK,0,pos,Vector(0,0),player):ToEffect()
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
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if FI_NCreepSplashes > 0 then
		for i,creep in ipairs(FI_tCreepSplashes) do
			if creep:Exists() then
				if (player.Position:Distance(creep.Position) <= (player.Size + creep.Size)) 
				and (creep:GetData().isTouching == nil 
				or not creep:GetData().isTouching) then
					creep:GetData().isTouching = true
					FI_boosts = FI_boosts + 1
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()
				elseif creep:GetData().isTouching ~= nil
				and creep:GetData().isTouching
				and (player.Position:Distance(creep.Position) > (player.Size + creep.Size)) then
					creep:GetData().isTouching = false
					FI_boosts = FI_boosts - 1
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()
				end
			else
				table.remove(FI_tCreepSplashes,i)
				FI_NCreepSplashes = FI_NCreepSplashes - 1
			end
			if FI_NCreepSplashes == 0 then
				FI_boosts = 0
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
		end
	end
end

function ABppmod.FImpression()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if not player:HasCollectible(Isaac.GetItemIdByName("The Ludovico Technique")) then
		if FI_doBigTear then
			local ent = AlphaAPI.entities.friendly
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
					elseif (shot.Type == EntityType.ENTITY_BOMBDROP) then
						FI_Modify(shot)
						player:SetShootingCooldown(45)
					end
				end
			end
		elseif FI_NBigTears > 0 then
			FI_TearToCreep()
		end
		if FI_NCreepSplashes > 0 then
			FI_doCreep()
		end
	else --Ludo
		local ent = AlphaAPI.entities.friendly
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

function ABppmod.FI_hasHitEnemy(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
		FI_hasHit = (source.Type == EntityType.ENTITY_TEAR)
	elseif entity:GetData().tookDmg == nil then
		entity:GetData().tookDmg = true
	end
end

function ABppmod.FI_Cache(player,cacheFlag)
	if not player:IsFlying() then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			if FI_boosts > 0 then
				if FI_boosts > 9 then
					if (player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS)) then
						player.Damage = player.Damage * (1.5 ^ 3) --Si hay más de 9, capearlo a 3
					else
						player.Damage = player.Damage * (1.5 ^ 9) --Si hay más de 9, capearlo a 9
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

function ABppmod.FI_NewRoom()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local room = AlphaAPI.GAME_STATE.ROOM
	FI_doBigTear = not(room:IsClear())
	FI_NBigTears = 0
	FI_tBigTears = {}
	FI_NCreepSplashes = 0
	FI_tCreepSplashes = {}
	FI_boosts = 0
	FI_hasHit = false
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end

function ABppmod.FI_Reset()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	FI_doBigTear = false
	FI_NBigTears = 0
	FI_tBigTears = {}
	FI_NCreepSplashes = 0
	FI_tCreepSplashes = {}
	FI_boosts = 0
	FI_hasHit = false
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end

-----------------------------------------------------------
---------------------- Chemistry Jar ----------------------
-----------------------------------------------------------

local CJ_doVanishAnim = false

local CJ_tHeartType = { -- Tipo de corazón almacenado
		HeartSubType.HEART_FULL,
		HeartSubType.HEART_SOUL,
		HeartSubType.HEART_BLACK,
		HeartSubType.HEART_GOLDEN,
		HeartSubType.HEART_ETERNAL
		--	HeartSubType.HEART_HALF, -- El Doublepack no se puede usar, antisynergy con Humbleing bundle
		--	HeartSubType.HEART_HALF_SOUL,
		--	HeartSubType.HEART_SCARED,
		--	HeartSubType.HEART_BLENDED -- Este contará como lo que le correspondería si se fuera a coger normalmente
}

--[[Morado=1, Rojo Oscuro=2, Azul Oscuro=3, Salmón claro=4, Azul Claro=5,
	 Gris=6, Naranja=7, Verde Oscuro=8, Amarillo Oscuro=9, Amarillo Claro=10]]

local CJ_tCorrespondencias = {
		{nil,1,2,7,4},-- Esta tabla nos devuelve el subtipo del corazón especial
		{1,nil,3,8,5},-- a partir de las dos coordenadas que obtiene CJ_MixHearts
		{2,3,nil,9,6},-- con los dos 'for'. El orden de las columnas/filas es el
		{7,8,9,nil,10},-- mismo que en CJ_tHeartType
		{4,5,6,10,nil}
		}

local CJ_tAnimationNames = {
		"PurpleHeart",
		"DarkRedHeart",
		"DarkBlueHeart",
		"LightSalmonHeart",
		"LightBlueHeart",
		"GreyHeart",
		"OrangeHeart",
		"DarkGreenHeart",
		"DarkYellowHeart",
		"LightYellowHeart"
		}

local CJ_tSprites = {
	Sprite(),
	Sprite(),
	Sprite()
		}

local CJ_tVanishSprites = {
	Sprite(),
	Sprite(),
	Sprite()
		}
	
function ABppmod.CJ_Restart()
	alphaMod.data.run.CJ_tMainJar = { -- Estas dos tablas se almacenan aquí para guardar los datos entre runs
		CoverState = false, -- Estado tapa , false : cerrado
		tHearts = {
			nil, -- Primer corazón
			nil	 -- Segundo corazón
			},
		CantHearts = 0, -- puede valer 0, 1 ó 2, también se usara para los estados de la jarra
		hasHalf = false
	}

	alphaMod.data.run.CJ_tPlayerSpHearts = {
		tHearts = {
			nil, -- Primer corazón
			nil, -- Segundo corazón
			nil	 -- Tercer corazón
			},
		CantHearts = 0 -- puede valer 0, 1, 2 ó 3
	}
	
	alphaMod.data.run.CJ_tSpecialHeartsData = {
		tPurple = {
			cantHearts = 0,
			cantPurpleHearts = 0,
			doCache = false
		},
		tDarkRed = {
			doCache = false,
			roomsLeft = 0
		},
		tDarkBlue = {cantDarkBlueHearts = 0},
		tLightSalmon = {
			cantHearts = 0,
			cantLightSalmonHearts = 0
		},
		tLightBlue = {
			Delete = true,
			hitsTaken = 0
		},
		tGrey = {
			cantGreyHearts = 0,
			Fly = false,
			StopJoker = false
		},
		tOrange = {cantOrangeHearts = 0},
		tDarkGreen = {cantDarkGreenHearts = 0},
		tDarkYellow = {
			cantDarkYellowHearts = 0,
			doPierce = false,
			cachePierce = false
		},
		tLightYellow = {cantLightYellowHearts = 0}
	}
	for i=1, 3 do
		CJ_tSprites[i]:Stop()
		CJ_tVanishSprites[i]:Stop()
	end
	CJ_doVanishAnim = false
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	player:AddCacheFlags(161) -- Damage + Flying + TearFlags
	player:EvaluateItems()
	local FlightCostume = Isaac.GetCostumeIdByPath("gfx/characters/GreyHeartFlight.anm2")
	player:TryRemoveNullCostume(FlightCostume)
end

function ABppmod.CJ_ContinueRun()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	player:AddCacheFlags(161) -- Damage + Flying + TearFlags
	player:EvaluateItems()
end

local function CJ_insertAux(heart)
	heart:GetData().Done = true
	heart:ToPickup():PlayPickupSound()
	heart:GetSprite():Play("Collect", true)
	heart.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	heart.Velocity = Vector(0,0)
	heart.Friction = 0
end

local function CJ_insertHeart(heart,SubType)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if (player.Position:Distance(heart.Position) <= (player.Size + heart.Size)+10) -- +10 para evitar cogerlo 2 veces, en jarra y vida normal
	and heart:Exists()
	and heart:GetData().Done == nil then -- Si lo tocamos
		if alphaMod.data.run.CJ_tMainJar.CantHearts == 0 then
			alphaMod.data.run.CJ_tMainJar.tHearts[1] = SubType 
			alphaMod.data.run.CJ_tMainJar.CantHearts = 1
		else
			alphaMod.data.run.CJ_tMainJar.tHearts[2] = SubType
			alphaMod.data.run.CJ_tMainJar.CantHearts = 2
		end
		CJ_insertAux(heart)
	end
end

local function CJ_insertHalfHeartAux(SubType,pos)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tMainJar.tHearts[pos] == SubType then -- Si tenemos medio corazón al meter otro los unimos en 1 entero
		if SubType == 2 then -- Medio corazón rojo
			alphaMod.data.run.CJ_tMainJar.tHearts[pos] = 1 -- Corazón rojo entero
			alphaMod.data.run.CJ_tMainJar.hasHalf = false
		elseif SubType == 8 then -- Medio corazón azul
			alphaMod.data.run.CJ_tMainJar.tHearts[pos] = 3 -- Corazón azul entero
			alphaMod.data.run.CJ_tMainJar.hasHalf = false
		end
	else -- Si no coinciden (Coger medio azul cuando tenemos medio rojo) creamos uno blended
		if not player:HasFullHearts() then -- Si no tenemos todos los corazones rojos enteros, se transforma en un corazón rojo
			alphaMod.data.run.CJ_tMainJar.tHearts[pos] = 1 -- Corazón rojo entero
			alphaMod.data.run.CJ_tMainJar.hasHalf = false
		else
			alphaMod.data.run.CJ_tMainJar.tHearts[pos] = 3 -- Corazón azul entero
			alphaMod.data.run.CJ_tMainJar.hasHalf = false
		end
	end
end

local function CJ_insertHalfHeart(heart,SubType)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if (player.Position:Distance(heart.Position) <= (player.Size + heart.Size)+10) -- +10 para evitar cogerlo 2 veces, en jarra y vida normal
	and heart:Exists()
	and heart:GetData().Done == nil then -- Si lo tocamos
		if alphaMod.data.run.CJ_tMainJar.CantHearts == 0 then
			alphaMod.data.run.CJ_tMainJar.tHearts[1] = SubType 
			alphaMod.data.run.CJ_tMainJar.CantHearts = 1
			alphaMod.data.run.CJ_tMainJar.hasHalf = true
			CJ_insertAux(heart)
		elseif (alphaMod.data.run.CJ_tMainJar.tHearts[1] == 2 or alphaMod.data.run.CJ_tMainJar.tHearts[1] == 8) then -- Si el primer corazón es una mitad
			CJ_insertHalfHeartAux(SubType,1)
			CJ_insertAux(heart)
		else -- Si el primer corazón es uno entero
			if alphaMod.data.run.CJ_tMainJar.CantHearts == 1 then -- Si el segundo está vacío
				alphaMod.data.run.CJ_tMainJar.tHearts[2] = SubType  -- Lo metemos y ya está
				alphaMod.data.run.CJ_tMainJar.CantHearts = 2
				alphaMod.data.run.CJ_tMainJar.hasHalf = true
				CJ_insertAux(heart)
			elseif (alphaMod.data.run.CJ_tMainJar.tHearts[2] == 2 or alphaMod.data.run.CJ_tMainJar.tHearts[2] == 8) then -- Si el segundo corazón es una mitad
				CJ_insertHalfHeartAux(SubType,2)
				CJ_insertAux(heart)
			end
		end
	end
end

local function CJ_insertDoublePack(heart)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if (player.Position:Distance(heart.Position) <= (player.Size + heart.Size)+10) -- +10 para evitar cogerlo 2 veces, en jarra y vida normal
	and heart:Exists()
	and heart:GetData().Done == nil then -- Si lo tocamos
		if alphaMod.data.run.CJ_tMainJar.CantHearts == 0 then
			alphaMod.data.run.CJ_tMainJar.tHearts[1] = 1
			alphaMod.data.run.CJ_tMainJar.tHearts[2] = 1
			alphaMod.data.run.CJ_tMainJar.CantHearts = 2
			CJ_insertAux(heart)
		end
	end
end

local CJ_tPickHeart = {
	function(heart) CJ_insertHeart(heart,HeartSubType.HEART_FULL) end,
	function(heart) CJ_insertHalfHeart(heart,HeartSubType.HEART_HALF) end,
	function(heart) CJ_insertHeart(heart,HeartSubType.HEART_SOUL) end,
	function(heart) CJ_insertHeart(heart,HeartSubType.HEART_ETERNAL) end,
	function(heart) CJ_insertDoublePack(heart) end,
	function(heart) CJ_insertHeart(heart,HeartSubType.HEART_BLACK) end,
	function(heart) CJ_insertHeart(heart,HeartSubType.HEART_GOLDEN) end,
	function(heart) CJ_insertHalfHeart(heart,HeartSubType.HEART_HALF_SOUL) end,
	function(heart) CJ_insertHeart(heart,HeartSubType.HEART_FULL) end
	}

function ABppmod.CJ_PickNormalHeart(heart, data) -- Esto usará el Callback Entity_update, ya que hay que aplicar la lógica de poder cogerlos o no.
	-- Si tenemos la tapa abierta, meteremos los corazones en la jarra aunque los pudieramos coger normalmente
	-- Si tenemos la tapa cerrada nunca meteremos ningún corazón en la jarra
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tMainJar.CoverState then -- Solo hacer cosas si la tapa está abierta
		if not heart:ToPickup():IsShopItem() then -- No funciona con corazones a la venta
			if not heart:GetSprite():IsPlaying("Collect") -- Evitamos coger el mismo corazón 2 veces
			and not heart:GetSprite():IsPlaying("Appear") then -- Y evitamos coger un corazón que acaba de spawnear
				if alphaMod.data.run.CJ_tMainJar.CantHearts < 2 then -- Solo tratar de meter corazones si solo hay 1 ó 0
					if heart.SubType == HeartSubType.HEART_BLENDED then -- Si cogimos un blended
						if (player:HasFullHearts()) then -- Se convierte en azul si tenemos toda la vida roja al completo
							CJ_tPickHeart[HeartSubType.HEART_SOUL](heart) 
						else -- Si no, se combierte en uno rojo
							CJ_tPickHeart[HeartSubType.HEART_FULL](heart)
						end
					else
						CJ_tPickHeart[heart.SubType](heart) -- Si no es blended, usa el subtipo como índice en la tabla
					end
				else --Si está llena con 2 corazones, puede que aún se puedan meter una mitad más
					if (heart.SubType == HeartSubType.HEART_HALF) then
						CJ_insertHalfHeart(heart,HeartSubType.HEART_HALF)
					elseif (heart.SubType == HeartSubType.HEART_HALF_SOUL) then
						CJ_insertHalfHeart(heart,HeartSubType.HEART_HALF_SOUL)
					end
				end
			end
		end
	end
	if heart:GetSprite():IsFinished("Collect") then -- Aprovechamos la función para esperar a la animación
		heart:Remove()
	end
end	

local function CJ_MixHearts(SubType1,SubType2)
	for i,v in ipairs(CJ_tHeartType) do
		if v == SubType1 then
			for i2,v2 in ipairs(CJ_tHeartType) do
				if v2 == SubType2 then
					return CJ_tCorrespondencias[i][i2]
				end
			end
		end
	end
end

function ABppmod.ChemJar()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tMainJar.CantHearts == 0 then -- Si hay 0 corazones, solo se cambia de estado la tapa
		alphaMod.data.run.CJ_tMainJar.CoverState = not(alphaMod.data.run.CJ_tMainJar.CoverState)
		-- Cambio Sprite
	elseif alphaMod.data.run.CJ_tMainJar.CantHearts == 1 then -- Si hay 1 corazón y está abierto se cierra,
		if alphaMod.data.run.CJ_tMainJar.CoverState then		-- si está cerrado se abre y se suelta el corazón.
			alphaMod.data.run.CJ_tMainJar.CoverState = not(alphaMod.data.run.CJ_tMainJar.CoverState)
		else
			local pos = player.Position
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,alphaMod.data.run.CJ_tMainJar.tHearts[1],Isaac.GetFreeNearPosition(pos,10),Vector(0,0),player)
			alphaMod.data.run.CJ_tMainJar.tHearts[1] = nil
			alphaMod.data.run.CJ_tMainJar.CoverState = true
			alphaMod.data.run.CJ_tMainJar.CantHearts = 0
		end
	else
		if alphaMod.data.run.CJ_tMainJar.CoverState then		-- Si hay 2 corazónes y está abierto se cierra,
			alphaMod.data.run.CJ_tMainJar.CoverState = not(alphaMod.data.run.CJ_tMainJar.CoverState) -- si está cerrado se abre y se suelta el corazón especial.
		else
			local pos = player.Position
			if alphaMod.data.run.CJ_tMainJar.tHearts[1] == alphaMod.data.run.CJ_tMainJar.tHearts[2] 
			or alphaMod.data.run.CJ_tMainJar.hasHalf then	-- a menos que ambos corazones sean iguales o haya una mitad metida
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,alphaMod.data.run.CJ_tMainJar.tHearts[1],Isaac.GetFreeNearPosition(pos,10),Vector(0,0),player)
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,alphaMod.data.run.CJ_tMainJar.tHearts[2],Isaac.GetFreeNearPosition(pos,10),Vector(0,0),player)
			else
				local SpecialHeart = CJ_MixHearts(alphaMod.data.run.CJ_tMainJar.tHearts[1],alphaMod.data.run.CJ_tMainJar.tHearts[2])
				if player:HasCollectible(Isaac.GetItemIdByName("Car Battery")) then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, 11,SpecialHeart,Isaac.GetFreeNearPosition(pos,10),Vector(0,0),player) -- 11 = variante corazones especiales
				end
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 11,SpecialHeart,Isaac.GetFreeNearPosition(pos,10),Vector(0,0),player) -- Si tenemos Car Battery, spawneamos 2
			end
			alphaMod.data.run.CJ_tMainJar.tHearts[1] = nil
			alphaMod.data.run.CJ_tMainJar.tHearts[2] = nil
			alphaMod.data.run.CJ_tMainJar.CoverState = true
			alphaMod.data.run.CJ_tMainJar.CantHearts = 0
			alphaMod.data.run.CJ_tMainJar.hasHalf = false
		end
	end
end

function ABppmod:CJ_RenderHeartVanish()
	-- TODO No hacer nada de esto si somos PH
	if CJ_doVanishAnim then
		for i=1 , 3 do
			if not CJ_tVanishSprites[i]:IsLoaded() then
				CJ_tVanishSprites[i]:Load("gfx/ui/ui_specialhearts.anm2",true)
			end
		end
		if (CJ_tVanishSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:GetFrame() == -1) then
			CJ_tVanishSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:Play("HeartVanish",true)
		end
		local pos = 48 + ((alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts-1)*12)
		if (CJ_tVanishSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:GetFrame() >= 24) then -- Cuando acabe la animación:
			local player = AlphaAPI.GAME_STATE.PLAYERS[1]
			if alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts] == 5 then -- Si fue un corazón azul claro
				alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken = 0 -- Reinicia el contador del corazón 
			end
			alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts] = nil	-- Borra el corazón
			CJ_tVanishSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:Stop() -- Para de renderizar la animación
			if player:HasCollectible(Isaac.GetItemIdByName("Chemistry Jar")) then -- Si el jugador tiene la jarra
				CJ_tSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:Play("EmptySpecialHeart",true) -- Cambia el corazón a vacío
				local room = AlphaAPI.GAME_STATE.ROOM
				if not (room:GetType() == 5 and room:GetFrameCount() <= 1 and IsFirstVisit ()) then -- Esto evita renderizar las cosas en el VS screen
					CJ_tSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:Render(Vector(pos,35),Vector(0,0),Vector(0,0)) -- Y renderízalo
				end
			end  -- Si el jugador no tiene la jarra no renderices los vacíos
			alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts = alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts - 1
			CJ_doVanishAnim = false 
		else
			CJ_tVanishSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:SetFrame("HeartVanish",CJ_tVanishSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:GetFrame()+1)
			local room = AlphaAPI.GAME_STATE.ROOM
			if not (room:GetType() == 5 and room:GetFrameCount() <= 1 and IsFirstVisit ()) then -- Esto evita renderizar las cosas en el VS screen
				CJ_tVanishSprites[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]:Render(Vector(pos,35),Vector(0,0),Vector(0,0))
			end
		end
	else
		for i=1 , 3 do
			CJ_tVanishSprites[i] = Sprite()
		end
	end
end

local function CJ_whereIs1To3(heart)
	for i=1, 3 do
		if alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[i] == heart then
			return i
		end
	end
	return 0
end

local function CJ_whereIs3To1(heart)
	for i=3, 1, -1 do
		if alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[i] ~= nil
		and alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[i] == heart then
			return i
		end
	end
	return 0
end

----------------------------------

------- Purple Heart -------

local function CJ_EarntPurpleHeartEffect(i)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
		alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantPurpleHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantPurpleHearts + 1
		alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.doCache = true
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

local function CJ_LostPurpleHeartEffect(i)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantPurpleHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantPurpleHearts - 1
	alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.doCache = true
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end

function ABppmod.CJ_PurpleHeartEffect_HPChange()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local hearts = player:GetHearts()
	if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
		if (hearts ~= alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantHearts) then
			if alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantPurpleHearts > 0 then
				alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.doCache = true
				alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantHearts = hearts
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
		end
		alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantHearts = hearts
	end
end

------- Dark Red Heart -------

local function CJ_EarntDarkRedHeartEffect(i)
	-- No tiene que hacer nada
end

local function CJ_LostDarkRedHeartEffect(i)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.doCache = true
	alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.roomsLeft = 4
	AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK, "gfx/ui/giantbook/giantbook_rebirth_002_darkredheart.png", false)
	--player:UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE,false,false,false,false)
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end

function ABppmod.CJ_DarkRedHeartEffect_RoomChange()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
		if alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.roomsLeft > 0 then
			alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.roomsLeft = alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.roomsLeft - 1
			alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.doCache = true
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	end
end

function ABppmod:CJ_DarkRedPurpleHeartEffect_DamageCache(player,cacheFlag) -- Se hace función común de caché para evitar sobreescrituras
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		local darkredDMG = 0
		local purpleDMG = 0
		if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
			if alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.doCache then
				darkredDMG = (alphaMod.data.run.CJ_tSpecialHeartsData.tDarkRed.roomsLeft*1.5)
			end
			if alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.doCache then
				purpleDMG = ((alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantHearts * 0.125) * alphaMod.data.run.CJ_tSpecialHeartsData.tPurple.cantPurpleHearts)
			end
			player.Damage = player.Damage + darkredDMG + purpleDMG
		end
	end
end	

------- Dark Blue Heart -------

local function CJ_EarntDarkBlueHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tDarkBlue.cantDarkBlueHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tDarkBlue.cantDarkBlueHearts + 1
end

local function CJ_LostDarkBlueHeartEffect(i)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	alphaMod.data.run.CJ_tSpecialHeartsData.tDarkBlue.cantDarkBlueHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tDarkBlue.cantDarkBlueHearts - 1
	AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK, "gfx/ui/giantbook/giantbook_rebirth_002_darkblueheart.png", false)
	player:AddBlueFlies(10, player.Position+Vector(-20,0), nil)
end

function ABppmod:CJ_DarkBlueHeartEffect_KilledEnemy(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tSpecialHeartsData.tDarkBlue.cantDarkBlueHearts > 0 then
		if entity:IsActiveEnemy(false)
		and (entity.HitPoints - dmgAmount) <= 0
		and (source.Entity.SpawnerType == EntityType.ENTITY_PLAYER or source.Type == EntityType.ENTITY_PLAYER)
		and not (source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == FamiliarVariant.BLUE_FLY)
		and entity:GetData().Done == nil then
			player:AddBlueFlies(alphaMod.data.run.CJ_tSpecialHeartsData.tDarkBlue.cantDarkBlueHearts, player.Position, nil)
			entity:GetData().Done = true
		end
	end
end

------- Light Salmon Heart -------

local function CJ_EarntLightSalmonHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantLightSalmonHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantLightSalmonHearts + 1
end

local function CJ_LostLightSalmonHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantLightSalmonHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantLightSalmonHearts - 1
end

function ABppmod.CJ_LightSalmonHeartEffect_HPChange()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local hearts = player:GetMaxHearts()
	if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
		if (hearts > alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantHearts) then
			if alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantLightSalmonHearts > 0 then
				player:AddMaxHearts(alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantLightSalmonHearts*2,false)
				player:AddHearts(alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantLightSalmonHearts*2,false)
				hearts = player:GetMaxHearts()
			end
		end
		alphaMod.data.run.CJ_tSpecialHeartsData.tLightSalmon.cantHearts = hearts
	end
end

------- Light Blue Heart -------

local function CJ_EarntLightBlueHeartEffect(i)
	if alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken ~= 0 then
		alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken = 0
		if alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.Delete then 
			alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[i] = nil
			alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts = alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts - 1
		end
	end
end

local function CJ_LostLightBlueHeartEffect(i)
	if alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken < 3 then
		CJ_doVanishAnim = false
		alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken = alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken + 1
	else
		--alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[i] = nil
		alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken = 0
	end
end

------- Grey Heart ------- 

local function CJ_EarntGreyHeartEffect(i)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.Fly = true
	alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.cantGreyHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.cantGreyHearts + 1
	player:AddCacheFlags(CacheFlag.CACHE_FLYING)
	player:EvaluateItems()
	if alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.cantGreyHearts == 1 then -- Si es el primer corazón gris
		player:AddCollectible(CollectibleType.COLLECTIBLE_DUALITY,0,false)
		AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK, "gfx/ui/giantbook/giantbook_rebirth_002_greyheart.png", false)
		local FlightCostume = Isaac.GetCostumeIdByPath("gfx/characters/GreyHeartFlight.anm2")
		player:AddNullCostume(FlightCostume)
	end
end

local function CJ_LostGreyHeartEffect(i)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.cantGreyHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.cantGreyHearts - 1
	player:UseCard(Card.CARD_JOKER)
	alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.StopJoker = true
	if alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.cantGreyHearts == 0 then
		alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.Fly = false
		player:AddCacheFlags(CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
		local FlightCostume = Isaac.GetCostumeIdByPath("gfx/characters/GreyHeartFlight.anm2")
		player:TryRemoveNullCostume(FlightCostume)
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_DUALITY)
	end
end

function ABppmod:CJ_GreyHeartEffect_FlightCache(player,cacheFlag) 
	if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
		if alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.Fly then		
			if cacheFlag == CacheFlag.CACHE_FLYING then
				local FlightCostume = Isaac.GetCostumeIdByPath("gfx/characters/GreyHeartFlight.anm2")
				player:AddNullCostume(FlightCostume)
				player.CanFly = true
			end
		end
	end
end

function ABppmod.CJ_GreyHeartEffects_StopJoker()
	if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
		if alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.StopJoker then
			if SFXManager():IsPlaying(SoundEffect.SOUND_JOKER) then
				SFXManager():Stop(SoundEffect.SOUND_JOKER)
				alphaMod.data.run.CJ_tSpecialHeartsData.tGrey.StopJoker = false
			end
		end
	end
end

------- Orange Heart -------

local function CJ_EarntOrangeHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tOrange.cantOrangeHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tOrange.cantOrangeHearts + 1
end

local function CJ_LostOrangeHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tOrange.cantOrangeHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tOrange.cantOrangeHearts - 1
end

local CJ_OrangeHeartEffect_tPossibleHearts = {
	1,1,1,1, 2,2,2, 3,3,3, 4,4, 5,5, 6,6,6, 7, 8,8,8, 9,9, 10,10
	}

--[[Chances:
		4/25 -> Red heart : 16%
		3/25 -> Soul heart, Black heart, Half red heart, Half soul heart : 12%
		2/25 -> Scared heart, Double red heart, Eternal heart, Blended heart : 8%
		1/25 -> Golden heart : 4%
		
		8%+8%+12%+16% -> 44% de las veces será un corazón rojo de algún tipo 	}
		12%+12%  -> 24% de las veces será un corazón azul de algún tipo			} 44% + 24% + 8% -> 76% de las veces será un corazón rojo o azul
																												  ^-Blended
	]]

local function CJ_OrangeHeartEffect_HeartChance()
	local rng = RNG()
	rng:SetSeed(Random(), 1)
	local RandomInt = rng:RandomInt(25)
	return CJ_OrangeHeartEffect_tPossibleHearts[RandomInt+1]
end

function ABppmod.CJ_OrangeHeartEffect_Create(coin)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tSpecialHeartsData.tOrange.cantOrangeHearts > 0 and coin:GetData().Done == nil then
		local pos = player.Position
		local SubType = CJ_OrangeHeartEffect_HeartChance()
		if (player.Position:Distance(coin.Position) <= (player.Size + coin.Size)) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, SubType,Isaac.GetFreeNearPosition(pos,10),Vector(0,0),player)
			coin:GetData().Done = true
		end
	end
end

------- Dark Green Heart -------

local function CJ_EarntDarkGreenHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tDarkGreen.cantDarkGreenHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tDarkGreen.cantDarkGreenHearts + 1
end

local function CJ_LostDarkGreenHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tDarkGreen.cantDarkGreenHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tDarkGreen.cantDarkGreenHearts - 1
end

function ABppmod.CJ_DarkGreenHeartEffect_Create(coin)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.CJ_tSpecialHeartsData.tDarkGreen.cantDarkGreenHearts > 0 and coin:GetData().Done == nil then
		local pos = player.Position
		if (player.Position:Distance(coin.Position) <= (player.Size + coin.Size)) then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_D6,false,false,false,false)
			coin:GetData().Done = true
		end
	end
end

------- Dark Yellow Heart -------

local function CJ_EarntDarkYellowHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts + 1
	if (alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts > 0) then
		local player = AlphaAPI.GAME_STATE.PLAYERS[1]
		alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.doPierce = true
		alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cachePierce = true
		player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
		player:EvaluateItems()
	end
end

local function CJ_LostDarkYellowHeartEffect(i)
	if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
		alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts - 1
		if (alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts == 0) then
			local player = AlphaAPI.GAME_STATE.PLAYERS[1]
			alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.doPierce = false
			alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cachePierce = true
			player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
			player:EvaluateItems()
		end
	end
end

function ABppmod:CJ_DarkYellowHeartEffect_Pierce(player,cacheFlag)
	if cacheFlag == CacheFlag.CACHE_TEARFLAG then 
		if alphaMod.data.run.CJ_tSpecialHeartsData ~= nil then
			if alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cachePierce then
				if alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.doPierce then
					player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
				else
					player.TearFlags = player.TearFlags & ~TearFlags.TEAR_PIERCING
				end
				alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cachePierce = false
			end
		end
	end
end

function ABppmod.CJ_DarkYellowHeartEffect_changeTear(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	source = AlphaAPI.getEntityFromRef(source)
	if source ~= nil 
	and entity:IsActiveEnemy(false)
	and source.SpawnerType == EntityType.ENTITY_PLAYER
	and source.Type == EntityType.ENTITY_TEAR
	and alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts > 0 then entity.CollisionDamage = entity:GetData().ML1_OGDMG * res
		tear = source:ToTear()
		if tear:GetData().numHits == nil then
			AlphaAPI.callDelayed(function(tear)
				tear.TearFlags = tear.TearFlags | TearFlags.TEAR_MIDAS
				tear:ChangeVariant(20) -- Penny tears
				tear:GetData().numHits = 1
			end, 1, false, tear)
		elseif tear:GetData().numHits < alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts then
			tear:GetData().numHits = tear:GetData().numHits + 1
		elseif tear:GetData().numHits >= alphaMod.data.run.CJ_tSpecialHeartsData.tDarkYellow.cantDarkYellowHearts then
			tear:Remove()
		end
	end
end

------- Light Yellow Heart -------

local function CJ_EarntLightYellowHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tLightYellow.cantLightYellowHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tLightYellow.cantLightYellowHearts + 1
end

local function CJ_LostLightYellowHeartEffect(i)
	alphaMod.data.run.CJ_tSpecialHeartsData.tLightYellow.cantLightYellowHearts = alphaMod.data.run.CJ_tSpecialHeartsData.tLightYellow.cantLightYellowHearts - 1
end

function ABppmod.CJ_LightYellowHeartEffect_changeCoins(coin)
	if alphaMod.data.run.CJ_tSpecialHeartsData.tLightYellow.cantLightYellowHearts > 0 then
		coin.SubType = CoinSubType.COIN_LUCKYPENNY
	end
end

----------------------------------

local CJ_tEarntHeartEffects = { -- Efectos de los corazones a aplicar cuando se cogen
	function(i) CJ_EarntPurpleHeartEffect(i) end,
	function(i) CJ_EarntDarkRedHeartEffect(i) end,
	function(i) CJ_EarntDarkBlueHeartEffect(i) end,
	function(i) CJ_EarntLightSalmonHeartEffect(i) end,
	function(i) CJ_EarntLightBlueHeartEffect(i) end,
	function(i) CJ_EarntGreyHeartEffect(i) end,
	function(i) CJ_EarntOrangeHeartEffect(i) end,
	function(i) CJ_EarntDarkGreenHeartEffect(i) end,
	function(i) CJ_EarntDarkYellowHeartEffect(i) end,
	function(i) CJ_EarntLightYellowHeartEffect(i) end
}

function ABppmod.CJ_PickSpecialHeart(player,entity,data)
	for _,v in pairs(CJ_tConfigs) do -- TODO
		if AlphaAPI.matchConfig(entity, v) then
			if alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts < 3 then
				table.insert(alphaMod.data.run.CJ_tPlayerSpHearts.tHearts,entity.SubType)
				alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts = alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts + 1
				CJ_tEarntHeartEffects[alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]](alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts)
				return true
			elseif entity.SubType == 5 and alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken > 0 then -- Si tenemos 3, podemos coger 1 azul claro si ya tenemos otro azul claro roto
				alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.Delete = false
				CJ_tEarntHeartEffects[5](CJ_whereIs3To1(5))
				alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.Delete = true
				return true
			end
		end
	end
end

local CJ_tLostHeartEffects = { -- Efectos de los corazones a aplicar cuando se pierden
	function(i) CJ_LostPurpleHeartEffect(i) end,
	function(i) CJ_LostDarkRedHeartEffect(i) end,
	function(i) CJ_LostDarkBlueHeartEffect(i) end,
	function(i) CJ_LostLightSalmonHeartEffect(i) end,
	function(i) CJ_LostLightBlueHeartEffect(i) end,
	function(i) CJ_LostGreyHeartEffect(i) end,
	function(i) CJ_LostOrangeHeartEffect(i) end,
	function(i) CJ_LostDarkGreenHeartEffect(i) end,
	function(i) CJ_LostDarkYellowHeartEffect(i) end,
	function(i) CJ_LostLightYellowHeartEffect(i) end
}

function ABppmod:CJ_LoseSpecialHeart(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if player:GetPlayerType() ~= PlayerType.PLAYER_THELOST then -- The lost nunca puede perder los corazones que almacene.
		if alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts > 0 then
			if ((dmgFlag & 2368608) == 0) or (((player:GetHearts() + player:GetSoulHearts()) <= 1) and (dmgFlag & 2097152 == 0)) then -- Este número corresponde a 10 0100 0010 0100 0110 0000,
																																	  --solo seguimos si no fue ninguno de esos flags
				CJ_doVanishAnim = true
				CJ_tLostHeartEffects[alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts]](alphaMod.data.run.CJ_tPlayerSpHearts.CantHearts)
				player:TakeDamage(1, 2097152, source, dmgCountdownFrames) --Fake dmg
				return false
			end
		end
	end
end

local CJ_tLightBlueAnim = {
		"LightBlueHeart1Hit",
		"LightBlueHeart2Hits"
}
	
function ABppmod:CJ_RenderHearts()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	-- TODO No hacer nada de esto si somos PH
	for i=1, 3 do -- Mira los 3 posibles corazones especiales del jugador
		CJ_tSprites[i]:Load("gfx/ui/ui_specialhearts.anm2",true)
		if alphaMod.data.run.CJ_tPlayerSpHearts ~= nil then --Evitamos error al inicio
			if alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[i] == nil then -- Si es nulo (está vacío)
				if player:HasCollectible(Isaac.GetItemIdByName("Chemistry Jar")) then -- Si el jugador tiene la jarra
					CJ_tSprites[i]:Play("EmptySpecialHeart",true) -- Pon el sprite de corazón vacío
				end
			else
				for j=1, 10 do -- Ahora para los 10 posibles subtipos de corazones
					if alphaMod.data.run.CJ_tPlayerSpHearts.tHearts[i] == j then -- Si el subtipo coincide con el almacenado
						if j == 5	-- Si es un corazón azul claro ya dañado 
						and alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken > 0	-- hay que tener en cuenta los 2 posibles estados
						and i == CJ_whereIs3To1(5) then -- Solo si es el último corazón azúl
							if alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken < 3 then -- Tras recibir golpe se hace la animación de vanish y ya.
								CJ_tSprites[i]:Play(CJ_tLightBlueAnim[alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken],true)
								break
							else
								CJ_tSprites[i]:Play(CJ_tLightBlueAnim[2],true)
								CJ_doVanishAnim = true
								alphaMod.data.run.CJ_tSpecialHeartsData.tLightBlue.hitsTaken = 2
							end
						else
							CJ_tSprites[i]:Play(CJ_tAnimationNames[j],true) -- Reproduce la animación correspondiente de la tabla
							break -- Sal del for
						end
					end
				end
			end
		end
	end
	local v0 = Vector(0,0)
	local room = AlphaAPI.GAME_STATE.ROOM
	if not (room:GetType() == 5 and room:GetFrameCount() <= 1 and room:IsFirstVisit()) then -- Esto evita renderizar las cosas en el VS screen
		CJ_tSprites[1]:Render(Vector(48,35),v0,v0)
		CJ_tSprites[2]:Render(Vector(60,35),v0,v0)
		CJ_tSprites[3]:Render(Vector(72,35),v0,v0)
	end
end

local CJ_tSpritesActivo = {
	Sprite(), -- Jarra
	Sprite(), -- Primer Corazón
	Sprite()  -- Segundo corazón
	}

local CJ_tCorrespondenciasSpritesActivo = {
	"Rojo","MedioRojo","Azul","Blanco",nil,"Negro","Amarillo","MedioAzul"
	}
	
function ABppmod:CJ_RenderActive()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	-- TODO No hacer nada de esto si somos PH
	if player:HasCollectible(Isaac.GetItemIdByName("Chemistry Jar")) then -- Si el jugador tiene la jarra
		for i=1, 3 do
			CJ_tSpritesActivo[i]:Load("gfx/items/Collectibles/ChemistryJar.anm2",true)
		end
		if alphaMod.data.run.CJ_tMainJar.CoverState then -- Si está abierto		
			CJ_tSpritesActivo[1]:Play("Abierta",true) -- Pon el sprite de la barra verde
		else
			CJ_tSpritesActivo[1]:Stop()
		end
		for i=2, 3 do
			if alphaMod.data.run.CJ_tMainJar.tHearts[i-1] ~= nil then -- Si el corazón no está vacío
				text = CJ_tCorrespondenciasSpritesActivo[alphaMod.data.run.CJ_tMainJar.tHearts[i-1]]
				if i==2 then -- Añadimos el texto al nombre de la animación
					text = text .. "Izquierda"
				else
					text = text .. "Derecha"
				end
				CJ_tSpritesActivo[i]:Play(text,true) -- Pon el sprite del corazón que toque
			else
				CJ_tSpritesActivo[i]:Stop() -- Si el corazón se vacía para de animarlo en la jarra
			end
		end
		local v0 = Vector(0,0)
		local room = AlphaAPI.GAME_STATE.ROOM
		if not (room:GetType() == 5 and room:GetFrameCount() <= 1 and IsFirstVisit ()) then -- Esto evita renderizar las cosas en el VS screen
			CJ_tSpritesActivo[1]:Render(Vector(17,16),v0,v0) 
			CJ_tSpritesActivo[2]:Render(Vector(18,16),v0,v0)
			CJ_tSpritesActivo[3]:Render(Vector(17,16),v0,v0)
		end
	end		
end

ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.CJ_DarkBlueHeartEffect_KilledEnemy)
ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.CJ_LoseSpecialHeart, EntityType.ENTITY_PLAYER)
ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.CJ_RenderHearts)
ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.CJ_RenderHeartVanish)
ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.CJ_RenderActive)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.CJ_DarkRedPurpleHeartEffect_DamageCache)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.CJ_GreyHeartEffect_FlightCache)
ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.CJ_DarkYellowHeartEffect_Pierce)

function ABppmod:CJ_gameExit()
	alphaMod:saveData()
end

function ABppmod:CJ_gameStart()
	alphaMod:loadData()
end

ABppmod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, ABppmod.CJ_gameExit)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ABppmod.CJ_gameStart)

-----------------------------------------------------------

-- D26 -- 

--[[
 POOL_TREASURE				0
 POOL_SHOP					1
 POOL_BOSS					2
 POOL_DEVIL					3
 POOL_ANGEL					4
 POOL_SECRET					5
 POOL_LIBRARY			  		6
 POOL_CHALLENGE				7
 POOL_GOLDEN_CHEST			8
 POOL_RED_CHEST				9
 POOL_BEGGAR					10
 POOL_DEMON_BEGGAR			11
 POOL_CURSE					12
 POOL_KEY_MASTER				13
 POOL_BOSSRUSH				14
 
 POOL_DUNGEON					15
 
 POOL_GREED_TREASURE		16
 POOL_GREED_BOSS				17
 POOL_GREED_SHOP				18
 POOL_GREED_DEVIL			19
 POOL_GREED_ANGEL			20
 POOL_GREED_CURSE			21
 POOL_GREED_SECRET			22
 POOL_GREED_LIBRARY			23
 POOL_GREED_GOLDEN_CHEST	24
 
 POOL_BOMB_BUM				25
 ]]

local D26_tOverlaysLeft = {"gfx/ui/giantbook/Treasure__.png","gfx/ui/giantbook/Shop__.png","gfx/ui/giantbook/Boss__.png","gfx/ui/giantbook/Devil__.png",
							"gfx/ui/giantbook/Angel__.png","gfx/ui/giantbook/Secret__.png","gfx/ui/giantbook/Library__.png","gfx/ui/giantbook/Challenge__.png",
							"gfx/ui/giantbook/GoldenChest__.png","gfx/ui/giantbook/RedChest__.png","gfx/ui/giantbook/Bum__.png","gfx/ui/giantbook/DevilBum__.png",
							"gfx/ui/giantbook/Curse__.png","gfx/ui/giantbook/KeyMaster__.png","gfx/ui/giantbook/BossRush__.png","gfx/ui/giantbook/BombBum__.png"}
							
local D26_tOverlaysRight = {"gfx/ui/giantbook/__Treasure.png","gfx/ui/giantbook/__Shop.png","gfx/ui/giantbook/__Boss.png","gfx/ui/giantbook/__Devil.png",
							"gfx/ui/giantbook/__Angel.png","gfx/ui/giantbook/__Secret.png","gfx/ui/giantbook/__Library.png","gfx/ui/giantbook/__Challenge.png",
							"gfx/ui/giantbook/__GoldenChest.png","gfx/ui/giantbook/__RedChest.png","gfx/ui/giantbook/__Bum.png","gfx/ui/giantbook/__DevilBum.png",
							"gfx/ui/giantbook/__Curse.png","gfx/ui/giantbook/__KeyMaster.png","gfx/ui/giantbook/__BossRush.png","gfx/ui/giantbook/__BombBum.png"}

local D26_tOverlaysGreedLeft = {"gfx/ui/giantbook/Treasure__.png","gfx/ui/giantbook/Boss__.png","gfx/ui/giantbook/Shop__.png","gfx/ui/giantbook/Devil__.png",
								"gfx/ui/giantbook/Angel__.png","gfx/ui/giantbook/Curse__.png","gfx/ui/giantbook/Library__.png","gfx/ui/giantbook/GoldenChest__.png",
								"gfx/ui/giantbook/BombBum__.png","gfx/ui/giantbook/RedChest__.png","gfx/ui/giantbook/Bum__.png","gfx/ui/giantbook/DevilBum__.png",
								"gfx/ui/giantbook/KeyMaster__.png"}
							
local D26_tOverlaysGreedRight = {"gfx/ui/giantbook/__Treasure.png","gfx/ui/giantbook/__Boss.png","gfx/ui/giantbook/__Shop.png","gfx/ui/giantbook/__Devil.png",
								"gfx/ui/giantbook/__Angel.png","gfx/ui/giantbook/__Curse.png","gfx/ui/giantbook/__Library.png","gfx/ui/giantbook/__GoldenChest.png",
								"gfx/ui/giantbook/__BombBum.png","gfx/ui/giantbook/__RedChest.png","gfx/ui/giantbook/__Bum.png","gfx/ui/giantbook/__DevilBum.png",
								"gfx/ui/giantbook/__KeyMaster.png"}

local D26_tUntouchableItems = {18,73,90,130,132,181,207,238,239,293,327,328} -- {A Dollar, Cube of Meat, Small Rock, A pony, Lump of Coal, White pony, Ball of Bandages,
																			 -- Key Piece 1 and 2, Krampus' Head, Polaroid, Negative}
function ABppmod.D26_Restart()
	alphaMod.data.run.D26_Used = false
	alphaMod.data.run.D26_tLostItems = {}
	alphaMod.data.run.D26_tLostItemPools = {}
	alphaMod.data.run.D26_tItemsDone = {}
	alphaMod.data.run.D26_tCurrPoolOrder = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,25}
	alphaMod.data.run.D26_tCurrPoolOrder_Greed = {16,17,18,19,20,21,23,24,25,9,10,11,13} -- Se ignora el secret pool (22)
end
																			 
local function D26_aux(game,cant,greed)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local rng = player:GetCollectibleRNG(Isaac.GetItemIdByName("D26"))
	local rand1 = rng:RandomInt(cant) + 1
	local rand2 = rng:RandomInt(cant) + 1
	while rand1 == rand2 do
		rand2 = rng:RandomInt(cant) + 1
	end
	if greed then
		local temp = alphaMod.data.run.D26_tCurrPoolOrder_Greed[rand1] -- Intercambiamos pools
		alphaMod.data.run.D26_tCurrPoolOrder_Greed[rand1] = alphaMod.data.run.D26_tCurrPoolOrder_Greed[rand2]
		alphaMod.data.run.D26_tCurrPoolOrder_Greed[rand2] = temp
	else
		local temp = alphaMod.data.run.D26_tCurrPoolOrder[rand1] -- Intercambiamos pools
		alphaMod.data.run.D26_tCurrPoolOrder[rand1] = alphaMod.data.run.D26_tCurrPoolOrder[rand2]
		alphaMod.data.run.D26_tCurrPoolOrder[rand2] = temp
	end
	return rand1,rand2
end

local function D26_doOverlays(greed,rand1,rand2)
	local Paper = AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK, "gfx/ui/giantbook/Paper.png")
	Paper.PlaybackSpeed = Paper.PlaybackSpeed / 1.3
	local Equals = AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK, "gfx/ui/giantbook/_=_.png")
	Equals.PlaybackSpeed = Equals.PlaybackSpeed / 1.3
	if greed then
		local first = AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK,D26_tOverlaysGreedLeft[rand1])
		local second = AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK,D26_tOverlaysGreedRight[rand2])
		first.PlaybackSpeed = first.PlaybackSpeed / 1.3
		second.PlaybackSpeed = second.PlaybackSpeed / 1.3
	else
		local first = AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK,D26_tOverlaysLeft[rand1])
		local second = AlphaAPI.playOverlay(AlphaAPI.OverlayType.GIANT_BOOK,D26_tOverlaysRight[rand2])
		first.PlaybackSpeed = first.PlaybackSpeed / 1.3
		second.PlaybackSpeed = second.PlaybackSpeed / 1.3
	end
end

function ABppmod.D26()
	local game = AlphaAPI.GAME_STATE.GAME
	alphaMod.data.run.D26_Used = true
	local RandomInt
	local RandomInt2
	local greed = game:IsGreedMode()
	if greed then
		RandomInt,RandomInt2 = D26_aux(game,13,true)
	else
		RandomInt,RandomInt2 = D26_aux(game,16,false)
	end
	D26_doOverlays(greed,RandomInt,RandomInt2)
	return true
end

local function D26_beggarPool(variant)
	if variant == 9 then -- Bomb beggar
		return 25 -- Bomb beggar pool
	elseif variant == 6 then -- Shell game
		return -2 -- No rerollear skatole
	else -- Los otros 3 beggars
		return (variant+6) -- La variante del beggar es 4, y su pool es la 10. Con el demon beggar es 5-11, y el key master es 7-13
	end
end

local function D26_chestPool(greed,frame)
	if frame == 0 or frame == 7 or frame == -1 then -- Pedestales normales, cofres con púas o nada
		return -1
	elseif frame <= 3 and frame >= 1 then -- Máquinas, no rerollear
		return -2
	elseif frame == 4 or frame == 6 or frame == 8 then -- Golden / Stone / Eternal Chest
		if greed then return 24	
		else return 8 -- Golden chest pool
		end
	else -- frame == 5
		return 9 -- Red chest pool
	end
end

local function D26_handleBreakfast(item,itempool)
	if item.SubType == CollectibleType.COLLECTIBLE_BREAKFAST then 
		if alphaMod.data.run.D26_tLostItems[1] ~= nil then 
			for i,v in ipairs(alphaMod.data.run.D26_tLostItemPools) do 
				if v == itempool then 
					item:ToPickup():Morph(item.Type,item.Variant,alphaMod.data.run.D26_tLostItems[i],true) 
					alphaMod.data.run.D26_tItemsDone[alphaMod.data.run.D26_tLostItems[i]] = false
					table.remove(alphaMod.data.run.D26_tLostItems,i)
					table.remove(alphaMod.data.run.D26_tLostItemPools,i)
					break
				end
			end
		end
	end
end

local function D26_subsLostItem(item,itempool)
	for i,v in ipairs(alphaMod.data.run.D26_tLostItemPools) do -- Intenta usar items perdidos anteriormente antes que generar otros nuevos
		if v == itempool then -- Estos items perdidos se almacenan en alphaMod.data.run.D26_tLostItems, junto con su Pool en alphaMod.data.run.D26_tLostItemPools
			item:ToPickup():Morph(item.Type,item.Variant,alphaMod.data.run.D26_tLostItems[i],true) -- Si coinciden las pools de el item que se intentó crear, 
			alphaMod.data.run.D26_tItemsDone[alphaMod.data.run.D26_tLostItems[i]] = false -- Y un item que tengamos almacenado, usaremos el item almacenado como substituto, y lo quitamos de la lista de perdidos
			table.remove(alphaMod.data.run.D26_tLostItems,i) -- alphaMod.data.run.D26_tLostItems[i] contendrá el subtipo requerido en [i]
			table.remove(alphaMod.data.run.D26_tLostItemPools,i)
			return true
		end
	end
	return false
end

local function D26_changeItem(greed,itemsPoolPos,itemsPool,item,pool,seed)
	local SubType = 0
	local tempSubType = item.SubType -- Almacenamos el subtipo por si acaso el subsLostItem nos cambia el item
	local doX = false
	local doY = true
	if greed then
		if alphaMod.data.run.D26_tCurrPoolOrder_Greed[itemsPoolPos] ~= itemsPool then -- Si no coinciden es que se cambiaron las pools. Se resta 15 para que se pueda usar en el array (16 - 1, 17 - 2,...)
			SubType = pool:GetCollectible(alphaMod.data.run.D26_tCurrPoolOrder_Greed[itemsPoolPos],true,seed)
			doY = D26_subsLostItem(item,alphaMod.data.run.D26_tCurrPoolOrder_Greed[itemsPoolPos])
			doX = true
		end
	else
		if alphaMod.data.run.D26_tCurrPoolOrder[itemsPoolPos] ~= itemsPool then -- Si no coinciden es que se cambiaron las pools
			SubType = pool:GetCollectible(alphaMod.data.run.D26_tCurrPoolOrder[itemsPoolPos],true,seed)
			doY = D26_subsLostItem(item,alphaMod.data.run.D26_tCurrPoolOrder[itemsPoolPos])
			doX = true
		end
	end
	if doX then
		if item.SubType ~= CollectibleType.COLLECTIBLE_BREAKFAST then
			table.insert(alphaMod.data.run.D26_tLostItems,tempSubType)  -- Se almacenan los ítems substituídos para usarlos en un futuro
			table.insert(alphaMod.data.run.D26_tLostItemPools,itemsPool) -- Y evitar desperdiciar items
		end
	end
	if not doY then
		item:ToPickup():Morph(item.Type,item.Variant,SubType,true)
		alphaMod.data.run.D26_tItemsDone[item.SubType] = false
	end
	-- Aquí cambiamos el item que estaba por otro random de la pool que corresponda
	-- según los cambios hechos a las pools que se almacenan en alphaMod.data.run.D26_tCurrPoolOrder
end

function ABppmod.D26_ChangeSpawnedItem(item)
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if item.SpawnerType >= 46 and item.SpawnerType <= 52 then
		alphaMod.data.run.D26_tItemsDone[item.SubType] = false
		return 0
	end -- Los items dropeados por Minibosses se ignoran pero se almacenan como ya vistos
	if item.SpawnerType ~= EntityType.ENTITY_PLAYER
	or player:HasCollectible(Isaac.GetItemIdByName("Eden's Soul")) -- Evitamos randomizar cosas fijas como moving box,
	or player:HasCollectible(Isaac.GetItemIdByName("Mystery Gift")) then -- peró si cosas variantes como con esos dos items
		if player:HasCollectible(Isaac.GetItemIdByName("Chaos")) then
			return 0
		end -- Si el jugador tiene Chaos, no hacer nada
		if not alphaMod.data.run.D26_Used then
			return 0
		end -- Si nunca llegamos a usar el D26, no hacer nada
		for _,v in ipairs(D26_tUntouchableItems) do
			if item.SubType == v then 
				return 0
			end
		end
		if item.SubType ~= 0 then
			if alphaMod.data.run.D26_tItemsDone[item.SubType] == nil or item.SubType == CollectibleType.COLLECTIBLE_BREAKFAST then
				local game = AlphaAPI.GAME_STATE.GAME
				local ent = AlphaAPI.entities.friendly
				local room = AlphaAPI.GAME_STATE.ROOM
				local pool = game:GetItemPool()
				local seed = game:GetSeeds():GetStartSeed()
				local itemsPool = -1
				for _,beggar in ipairs(ent) do -- Miramos beggars
					if beggar.Type == 6 then -- Beggars
						if (beggar:GetSprite():IsPlaying("Teleport") and beggar:GetSprite():GetFrame() == 1) then
							itemsPool = D26_beggarPool(beggar.Variant)
							break
						end
					end
				end
				if itemsPool == -1 then -- Miramos chests
					itemsPool = D26_chestPool(game:IsGreedMode(),item:GetSprite():GetOverlayFrame()) -- Si no es chest, se meterá -1 de nuevo
				end
				if itemsPool == -1 then -- Miramos habitación
					itemsPool = pool:GetPoolForRoom(room:GetType(),seed)
				end
				if itemsPool ~= -2 then -- -2 = Abortar cambio de item
					local pos = 0
					if game:IsGreedMode() then
						if itemsPool == 22 then return 0 end -- Si por alguna razón sale el 22 pues pasamos
						if itemsPool == -1 then itemsPool = 16 end -- Treasure
						if itemsPool <= 11 then -- 11 , 10 y 9
							pos = itemsPool + 1 -- Coincide que la posición es la pool + 1 en el array
						elseif itemsPool == 13 then
							pos = itemsPool
						elseif itemsPool >= 23 then -- 21, 22 y 23
							pos = itemsPool - 16
						else -- 16 - 21
							pos = itemsPool - 15
						end
						D26_changeItem(true,pos,itemsPool,item,pool,seed)
					else
						if itemsPool == -1 then itemsPool = 0 end -- Treasure
						if itemsPool == 25 then
							pos = 16
						else
							pos = itemsPool + 1 
						end
						D26_changeItem(false,pos,itemsPool,item,pool,seed)
					end
				else
					alphaMod.data.run.D26_tItemsDone[item.SubType] = false
				end
			end
		end
	elseif alphaMod.data.run.D26_tItemsDone ~= nil then
		alphaMod.data.run.D26_tItemsDone[item.SubType] = false
	end
end

function ABppmod:removeActiveFromPool() -- Metemos en items hechos Activos con el que empiece un personaje
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if alphaMod.data.run.D26_tItemsDone ~= nil then
		alphaMod.data.run.D26_tItemsDone[player:GetActiveItem()] = false
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ABppmod.removeActiveFromPool)

-----------------------------------------------------------

-- Mini-Void --

local MV_tStats = {CacheFlag.CACHE_FIREDELAY,CacheFlag.CACHE_SHOTSPEED,CacheFlag.CACHE_DAMAGE,
					CacheFlag.CACHE_RANGE,CacheFlag.CACHE_SPEED,CacheFlag.CACHE_LUCK}
local MV_tOneUseItems = {CollectibleType.COLLECTIBLE_FORGET_ME_NOW,CollectibleType.COLLECTIBLE_BLUE_BOX,
						CollectibleType.COLLECTIBLE_DIPLOPIA,CollectibleType.COLLECTIBLE_PLAN_C,
						CollectibleType.COLLECTIBLE_MAMA_MEGA,CollectibleType.COLLECTIBLE_EDENS_SOUL,
						CollectibleType.COLLECTIBLE_MYSTERY_GIFT}

function ABppmod.MV_Restart()
	alphaMod.data.run.MV_StoredActive = 0
	alphaMod.data.run.MV_tStatsAcum = {0,0,0,0,0,0}
end

local function MV_voidPassive()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local rng = player:GetCollectibleRNG(Isaac.GetItemIdByName("Mini-Void"))
	local Stat = rng:RandomInt(6) + 1
	for i,v in ipairs(MV_tStats) do
		if Stat == i then
			alphaMod.data.run.MV_tStatsAcum[i] = alphaMod.data.run.MV_tStatsAcum[i] + 1
			player:AddCacheFlags(v)
			player:EvaluateItems()
			break
		end
	end
end

function ABppmod.MV_cachePassive(player,cacheFlag)
	if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
		player.MaxFireDelay = player.MaxFireDelay - alphaMod.data.run.MV_tStatsAcum[1]
	end
	if (cacheFlag == CacheFlag.CACHE_SHOTSPEED) then
		player.ShotSpeed = player.ShotSpeed + 0.2*alphaMod.data.run.MV_tStatsAcum[2]
	end
	if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
		player.Damage = player.Damage + alphaMod.data.run.MV_tStatsAcum[3]
	end
	if (cacheFlag == CacheFlag.CACHE_RANGE) then
		player.TearFallingSpeed = player.TearFallingSpeed + 0.5*alphaMod.data.run.MV_tStatsAcum[4]
	end
	if (cacheFlag == CacheFlag.CACHE_SPEED) then
		player.MoveSpeed = player.MoveSpeed + 0.2*alphaMod.data.run.MV_tStatsAcum[5]
	end
	if (cacheFlag == CacheFlag.CACHE_LUCK) then
		player.Luck = player.Luck + alphaMod.data.run.MV_tStatsAcum[6]
	end
end

function ABppmod.MiniVoid()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local ent = AlphaAPI.entities.friendly
	local activeDone = false
	for i,v in ipairs(ent) do
		if v.Type == 5 and v.Variant == 100 then -- Collectible
			if v.SubType ~= 0 then -- No hacer nada con pedestales vacíos
				local itemType = Isaac.GetItemConfig():GetCollectible(v.SubType).Type
				if itemType == ItemType.ITEM_PASSIVE or itemType == ItemType.ITEM_FAMILIAR then
					MV_voidPassive()
					v:Remove()
				elseif not activeDone and itemType == ItemType.ITEM_ACTIVE then
					alphaMod.data.run.MV_StoredActive = v.SubType
					v:Remove()
					activeDone = true
				end
			end
		end
	end
	if alphaMod.data.run.MV_StoredActive ~= 0 then
		player:UseActiveItem(alphaMod.data.run.MV_StoredActive,true,false,false,false)
		for i,v in ipairs(MV_tOneUseItems) do
			if alphaMod.data.run.MV_StoredActive == v then
				alphaMod.data.run.MV_StoredActive = 0
			end
		end
	end
	return true
end

-----------------------------------------------------------

-- Trump Card (Trinket) --

local TC_tAnm2s = {[Card.CARD_FOOL] = "gfx/00_TheFool.anm2",[Card.CARD_MAGICIAN] = "gfx/01_TheMagician.anm2",[Card.CARD_HIGH_PRIESTESS] = "gfx/02_TheHighPriestess.anm2",
					[Card.CARD_EMPRESS] = "gfx/03_TheEmpress.anm2",[Card.CARD_EMPEROR] = "gfx/04_TheEmperor.anm2",[Card.CARD_HIEROPHANT] = "gfx/05_TheHierophant.anm2",
					[Card.CARD_LOVERS] = "gfx/06_TheLovers.anm2",[Card.CARD_CHARIOT] = "gfx/07_TheChariot.anm2",[Card.CARD_JUSTICE] = "gfx/08_Justice.anm2",
					[Card.CARD_HERMIT] = "gfx/09_TheHermit.anm2",[Card.CARD_WHEEL_OF_FORTUNE] = "gfx/10_WheelOfFortune.anm2",[Card.CARD_STRENGTH] = "gfx/11_Strength.anm2",
					[Card.CARD_HANGED_MAN] = "gfx/12_TheHangedMan.anm2",[Card.CARD_DEATH] = "gfx/13_Death.anm2",[Card.CARD_TEMPERANCE] = "gfx/16_Temperance.anm2",
					[Card.CARD_DEVIL] = "gfx/15_TheDevil.anm2",[Card.CARD_TOWER] = "gfx/14_TheTower.anm2",[Card.CARD_STARS] = "gfx/17_TheStars.anm2",
					[Card.CARD_MOON] = "gfx/18_TheMoon.anm2",[Card.CARD_SUN] = "gfx/19_TheSun.anm2",[Card.CARD_JUDGEMENT] = "gfx/20_Judgement.anm2",
					[Card.CARD_WORLD] = "gfx/21_TheWorld.anm2",[Card.CARD_CLUBS_2] = "gfx/25_TwoOfClubs.anm2",[Card.CARD_DIAMONDS_2] = "gfx/26_TwoOfDiamonds.anm2",
					[Card.CARD_SPADES_2] = "gfx/24_TwoOfSpades.anm2",[Card.CARD_HEARTS_2] = "gfx/23_TwoOfHearts.anm2",[Card.CARD_ACE_OF_CLUBS] = "gfx/38_AceOfClubs.anm2",
					[Card.CARD_ACE_OF_DIAMONDS] = "gfx/39_AceOfDiamonds.anm2",[Card.CARD_ACE_OF_SPADES] = "gfx/36_AceOfSpades.anm2",
					[Card.CARD_ACE_OF_HEARTS] = "gfx/37_AceOfHearts.anm2",[Card.CARD_JOKER] = "gfx/22_TheJoker.anm2",[Card.CARD_CHAOS] = "gfx/28_ChaosCard.anm2",
					[Card.CARD_CREDIT] = "gfx/29_CreditCard.anm2",[Card.CARD_RULES] = "gfx/30_RulesCard.anm2",[Card.CARD_HUMANITY] = "gfx/31_CardAgainstHumanity.anm2",
					[Card.CARD_SUICIDE_KING] = "gfx/27_SuicideKing.anm2",[Card.CARD_GET_OUT_OF_JAIL] = "gfx/32_GetOutOfJail.anm2",
					[Card.CARD_QUESTIONMARK] = "gfx/33_MysteryCard.anm2",[Card.CARD_HOLY] = "gfx/40_HolyCard.anm2",[52] = "gfx/52_HugeGrowth.anm2",[53] = "gfx/53_AncientRecall.anm2",
					[54] = "gfx/54_EraWalk.anm2"}

function ABppmod.TCard(card)
	if card.SubType ~= Card.CARD_DICE_SHARD and card.SubType ~= Card.CARD_EMERGENCY_CONTACT then -- No aplicar a dice shard or Emergency contract ya que ya tienen un sprite único
		local sprite = card:GetSprite()
		sprite:Load(TC_tAnm2s[card.SubType],true)
		if card:ToPickup():IsShopItem() then
			sprite:Play("Idle",true)
		else
			sprite:Play("Appear",true)
		end
	end
end

-----------------------------------------------------------

-- Stuffed Die --

function ABppmod.SD_Restart()
	alphaMod.data.run.SD_doLuck = 0
end

function ABppmod.SDie()
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	alphaMod.data.run.SD_doLuck = alphaMod.data.run.SD_doLuck + 1
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
	return true
end

function ABppmod.SD_ChangeRoom()
	if alphaMod.data.run.SD_doLuck > 0 then
		alphaMod.data.run.SD_doLuck = alphaMod.data.run.SD_doLuck - 1
	end
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
end

function ABppmod.SD_cacheLuck(player,cacheFlag)
	if cacheFlag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + 15*alphaMod.data.run.SD_doLuck
	end
end

-----------------------------------------------------------

-- Eden's Spirit --

function ABppmod.ES_Restart()
	alphaMod.data.run.ES_livePos = 0
	alphaMod.data.run.ES_RNGDMG = 1
	alphaMod.data.run.ES_RNGTRS = 1
	alphaMod.data.run.ES_RNGRNG = 1
	alphaMod.data.run.ES_RNGSHSPE = 1
	alphaMod.data.run.ES_RNGSPE = 1
	alphaMod.data.run.ES_RNGLCK = 1
	alphaMod.data.run.ES_prevChar = 0
end

local function ES_change(player,rng)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D4)
	alphaMod.data.run.ES_RNGDMG = rng:RandomFloat()*1.30 + 0.85 -- Valor entre 0.85 y 2.15
	alphaMod.data.run.ES_RNGTRS = rng:RandomFloat()*1.75 + 0.5 -- Valor entre 0.50 y 2.25
	alphaMod.data.run.ES_RNGRNG = rng:RandomFloat()*1.30 + 0.85 
	alphaMod.data.run.ES_RNGSHSPE = rng:RandomFloat()*0.50 + 0.85 -- Valor entre 0.85 y 1.35
	alphaMod.data.run.ES_RNGSPE = rng:RandomFloat()*0.75 + 0.85 -- Valor entre 0.85 y 1.6
	alphaMod.data.run.ES_RNGLCK = rng:RandomFloat()*1.30 + 0.85
	ES_RNGHP = rng:RandomInt(10)
	if player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER then
		player:AddMaxHearts(-12,false) -- Eliminamos todos los contenedores de vida roja a menos que seamos keeper
	end
	if ES_RNGHP <= 4 then -- 50%
		player:AddSoulHearts(6)
	elseif ES_RNGHP <= 7 then -- 30%
		player:AddSoulHearts(8)
	else -- 20%
		player:AddSoulHearts(4)
	end
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
	player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
	player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/costume_eden_clean_body.anm2"))
	player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/costume_eden_clean_head.anm2"))
end

function ABppmod:ES_cache(player,cacheFlag)
	if alphaMod.data.run.ES_prevChar == player:GetPlayerType() then
		if (cacheFlag == CacheFlag.CACHE_DAMAGE) then
			player.Damage = player.Damage * alphaMod.data.run.ES_RNGDMG
		end
		if (cacheFlag == CacheFlag.CACHE_FIREDELAY) then
			player.MaxFireDelay = math.floor(player.MaxFireDelay / alphaMod.data.run.ES_RNGTRS)
		end
		if (cacheFlag == CacheFlag.CACHE_SPEED) then
			player.MoveSpeed = player.MoveSpeed * alphaMod.data.run.ES_RNGSPE
		end
		if (cacheFlag == CacheFlag.CACHE_SHOTSPEED) then
			player.ShotSpeed = player.ShotSpeed * alphaMod.data.run.ES_RNGSHSPE
		end
		if (cacheFlag == CacheFlag.CACHE_RANGE) then
			player.TearFallingSpeed = player.TearFallingSpeed * alphaMod.data.run.ES_RNGRNG
		end
		if (cacheFlag == CacheFlag.CACHE_LUCK) then
			player.Luck = player.Luck * alphaMod.data.run.ES_RNGLCK
		end
	else
		player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/costume_eden_clean_body.anm2"))
		player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/costume_eden_clean_head.anm2"))
	end
end

ABppmod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ABppmod.ES_cache)

function ABppmod.ESpirit() 
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if player:IsDead() then
		if alphaMod.data.run.ES_livePos == player:GetExtraLives() then -- Si en la cola de vidas esta es la primera
			if player:GetPlayerType() ~= PlayerType.PLAYER_THELOST then
				if player:GetSprite():IsPlaying("Death") then
					local frame = player:GetSprite():GetFrame()
					if frame == 54 then
						player:Revive()
						player:GetSprite():Stop()
						local rng = player:GetCollectibleRNG(Isaac.GetItemIdByName("Eden's Spirit"))
						player:RemoveCollectible(Isaac.GetItemIdByName("Eden's Spirit"))
						ES_change(player,rng)
					elseif frame == 48 then
						SFXManager():Play(SoundEffect.SOUND_HOLY,2,0,false,1)
						player:UseActiveItem(CollectibleType.COLLECTIBLE_CRACK_THE_SKY)
						player:UseActiveItem(CollectibleType.COLLECTIBLE_CRACK_THE_SKY)
					end
				end
			else --Si somos Lost, la animación es más corta. Revivimos al frame 0
				player:Revive()
				player:GetSprite():Stop()
				local rng = player:GetCollectibleRNG(Isaac.GetItemIdByName("Eden's Spirit"))
				player:RemoveCollectible(Isaac.GetItemIdByName("Eden's Spirit"))
				ES_change(player,rng)
				player:AddCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE,0,false)
				SFXManager():Play(SoundEffect.SOUND_HOLY,2,0,false,1)
				player:UseActiveItem(CollectibleType.COLLECTIBLE_CRACK_THE_SKY)
				player:UseActiveItem(CollectibleType.COLLECTIBLE_CRACK_THE_SKY)
			end
			alphaMod.data.run.ES_prevChar = player:GetPlayerType()
		end
	end
end

function ABppmod.ES_getItem(player)
	alphaMod.data.run.ES_livePos = player:GetExtraLives()
end

function ABppmod.ES_playerDied(player)
	local sprite = player:GetSprite()
	if player:HasCollectible(Isaac.GetItemIdByName("Eden's Spirit")) and alphaMod.data.run.ES_livePos == player:GetExtraLives() then
		sprite:Load("gfx/001.000_player_ES.anm2",true)
	else
		sprite:Load("gfx/001.000_player.anm2",true)
	end
end


-----------------------------------------------------------

-- Checklist --

-- TODO :	Problemas con Lamb (spawnear la cabeza spawnea al lamb entero),
--			Fallen (los minifallen respawnean como normal fallen),
--			Mom (No pierde vida).


function ABppmod.CL_Restart()
	alphaMod.data.run.CL_tRooms = {} -- alphaMod.data.run.CL_tRooms[X].enemies[Y].Z
end

local CL_tCurrRoomEntData = {}

local CL_tSpecialEnemies = {
		EntityType.ENTITY_GEMINI, -- Incluye Steven, las bolas del cordón y Ovum
		EntityType.ENTITY_PIN, -- Incluye Scolex y Frail (frail puede que de problemas ya que es 2 stages)
		EntityType.ENTITY_CHUB, -- Incluye CHAD y Carrion Queen
		EntityType.ENTITY_MASK_OF_INFAMY, -- Corazón?
		EntityType.ENTITY_SISTERS_VIS,
		EntityType.ENTITY_DADDYLONGLEGS, -- Incluye Triachnid
		EntityType.ENTITY_MOM,
		EntityType.ENTITY_FALLEN
		}

function ABppmod.CL_updateEnemiesData()
	local temp = {}
	local room = AlphaAPI.GAME_STATE.ROOM
	if not room:IsClear() then
		local entities = Isaac:GetRoomEntities()
		for i,v in ipairs(entities) do
			if v:IsEnemy() then
				table.insert(temp,v)
			end
		end
		CL_tCurrRoomEntData = temp
	else
		CL_tCurrRoomEntData = nil
	end
end

local function CL_storeEnemy(enemy)
	local enemyData = {
		Type = enemy.Type,
		Variant = enemy.Variant,
		SubType = enemy.SubType,
		HitPoints = enemy.HitPoints, -- Almacenamos la salud que le queda
		ChampionID = enemy:ToNPC():GetChampionColorIdx(),
		Pos = enemy.Position,
		InitSeed = enemy.InitSeed -- Esto se usará para diferenciar entre enemigos cuando no se puedan respawnear
		}
	return enemyData
end

--[[function ABppmod.CL_storeNewEnemy(entity,data)
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	local room = AlphaAPI.GAME_STATE.ROOM
	if room:GetFrameCount() > 1 then -- Evitamos almacenar cosas nada más entrar en una habitación
		if alphaMod.data.run.CL_tRooms[Index] ~= nil then -- Si aparecen nuevos enemigos en la habitación, se agregan a la tabla
			if entity:IsEnemy() and alphaMod.data.run.CL_tRooms[Index].enemies[entity.InitSeed] == nil then
				alphaMod.data.run.CL_tRooms[Index].enemies[entity.InitSeed] = CL_storeEnemy(entity)
				table.insert(alphaMod.data.run.CL_tRooms[Index].initSeeds,entity.InitSeed)
			end
		end
	end
end]]

--[[function ABppmod.CL_storePreviousRoom() -- Almacenamos la habitación de la que acabamos de salir,
	local level = AlphaAPI.GAME_STATE.LEVEL -- Así simplificamos las operaciones.
	local entities = level:GetLastRoomDesc().Data:GetEntities() -- Cuando volvamos a entrar se spawneará
	local Index = level:GetPreviousRoomIndex() -- lo que se almacenó.
	if not level:GetLastRoomDesc().Data:IsClear() then -- No se almacena nada si la habitación está vacía
		alphaMod.data.run.CL_tRooms[Index].roomIndex = Index
		for _,v in ipairs(entities) do
			if v:IsActiveEnemy(false) then
				table.insert(alphaMod.data.run.CL_tRooms[Index].enemies,CL_storeEnemy(v))
			end
		end
	end
end]]

local function CL_storeRoom(Index)
	local newroom = {
		roomIndex = Index,
		enemies = {}
		}
	for i,v in ipairs(CL_tCurrRoomEntData) do
		if v:IsEnemy() then
			table.insert(newroom.enemies, CL_storeEnemy(v))
		else -- Si no es un enemigo activo, lo borramos
			table.remove(CL_tCurrRoomEntData,i)
		end
	end
	alphaMod.data.run.CL_tRooms[Index] = newroom
end

function ABppmod.CL_clearedRoom()
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	if alphaMod.data.run.CL_tRooms[Index] ~= nil then -- Si hay datos en la habitación, se limpia
		alphaMod.data.run.CL_tRooms[Index] = nil -- Borramos los datos de la posición Index
		 CL_tCurrRoomEntData = nil
	end
end

--[[local function CL_damageMom(i,enemy)
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	local v = alphaMod.data.run.CL_tRooms[Index].enemies[i]
	if v.Type == EntityType.ENTITY_MOM then
		if v.HitPoints > 0 then
			enemy:TakeDamage(enemy.MaxHitPoints - v.HitPoints,0,EntityRef(enemy),0)
		else
			table.remove(alphaMod.data.run.CL_tRooms[Index].enemies,i)
		end
	end
end

function ABppmod.CL_spawnedFallen(fallen)
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	local room = AlphaAPI.GAME_STATE.ROOM
	if not room:IsFirstVisit() then -- Si es la primera visita no hay que hacer nada
		if fallen:GetData().Spawned == nil then
			for i,v in ipairs(alphaMod.data.run.CL_tRooms[Index].enemies) do
				if v.Scale then -- Mini Fallen, si es un fallen normal da igual
					fallen.HitPoints = v.HitPoints
				end
			end
		end
	end
end]]

local function CL_damageEnemy(enemy)
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	for i,v in ipairs(alphaMod.data.run.CL_tRooms[Index].enemies) do
		if enemy.InitSeed == v.InitSeed then
			if v.HitPoints > 0 then
				enemy.HitPoints = v.HitPoints
				break
			else
				table.remove(alphaMod.data.run.CL_tRooms[Index].enemies,i)
			end
		end
	end
end

local function CL_substituteEnemies()
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	local enemies = AlphaAPI.entities.enemies
	for _,v in ipairs(enemies) do
		local special = false
		for _,v2 in ipairs(CL_tSpecialEnemies) do
			special = (v2 == v.Type)
			if special then break end
		end 
		if special then
			CL_damageEnemy(v)
		else
			v:Remove()
		end
	end
	for i,v in ipairs(alphaMod.data.run.CL_tRooms[Index].enemies) do
		local special = false
		for _,v2 in ipairs(CL_tSpecialEnemies) do
			special = (v2 == v.Type)
			if special then break end
		end
		if not special then -- TODO
			if v.HitPoints > 0 then -- No está muerto
				enemy = Isaac.Spawn(v.Type,v.Variant,v.SubType,v.Pos,Vector(0,0),nil)
				enemy:ToNPC():Morph(v.Type,v.Variant,v.SubType,v.ChampionID)
				enemy.HitPoints = v.HitPoints
			else -- Si está muerto se elimina
				table.remove(alphaMod.data.run.CL_tRooms[Index].enemies,i)
			end
		end
	end
end

function ABppmod.CL_enterRoom(room)
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	if CL_tCurrRoomEntData ~= nil then -- Si la tabla temporal no está vacía
		CL_storeRoom(level:GetPreviousRoomIndex()) -- Almacenamos la anterior habitación
	end
	if not room:IsClear() then -- Si la habitación no tiene enemigos no spawneamos nada
		if not room:IsFirstVisit() then -- Si es la primera vez que entramos entonces por seguro no tenemos que cargar nada
			if alphaMod.data.run.CL_tRooms[Index] ~= nil then -- Nos aseguramos de que hay algo almacenado a sustituir.
				CL_substituteEnemies() -- Substituímos los enemigos por lo almacenado
			end
		end
	end
end

--[[function ABppmod:debug_text()
	--local enemies = AlphaAPI.entities.enemies
	if CL_tCurrRoomEntData ~= nil then
		for i,v in ipairs(CL_tCurrRoomEntData) do
			Isaac.RenderText(v.Type,50,100+10*i,255,0,0,255)
			Isaac.RenderText(v.Variant,80,100+10*i,255,0,0,255)
			Isaac.RenderText(v.SubType,100,100+10*i,255,0,0,255)
			Isaac.RenderText(v:ToNPC().State,120,100+10*i,255,0,0,255)
			Isaac.RenderText(math.floor(v.Position.X),140,100+10*i,255,0,0,255)
			Isaac.RenderText(math.floor(v.Position.Y),180,100+10*i,255,0,0,255)
			Isaac.RenderText(math.floor(v.HitPoints),220,100+10*i,255,0,0,255)
			Isaac.RenderText(v:GetSprite().Scale.X,250,100+10*i,255,0,0,255)
			Isaac.RenderText(v:GetSprite().Scale.Y,275,100+10*i,255,0,0,255)
		end
	end
	local level = AlphaAPI.GAME_STATE.LEVEL
	local Index = level:GetCurrentRoomIndex()
	if alphaMod.data.run.CL_tRooms ~= nil then
		if alphaMod.data.run.CL_tRooms[Index].enemies ~= nil then
			for i,v in ipairs(alphaMod.data.run.CL_tRooms[Index].enemies) do
				Isaac.RenderText(Index,260,200+10*i,255,0,0,255)
				Isaac.RenderText(v.Type,280,200+10*i,255,0,0,255)
				Isaac.RenderText(v.Variant,300,200+10*i,255,0,0,255)
				Isaac.RenderText(v.SubType,320,200+10*i,255,0,0,255)
				Isaac.RenderText(math.floor(v.Pos.X),360,200+10*i,255,0,0,255)
				Isaac.RenderText(math.floor(v.Pos.Y),400,200+10*i,255,0,0,255)
				Isaac.RenderText(math.floor(v.HitPoints),440,200+10*i,255,0,0,255)
				if v.Scale then
					Isaac.RenderText("True",470,200+10*i,255,0,0,255)
				end
			end
		end
	end
end
		
ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.debug_text)]]

-------------------
--Nuevo personaje-- PH = PlaceHolder
-------------------
--[[Se necesitarán:
	Función para cuando se recibe daño (Casi acabada)
	Función para los devil deals (Acabada)
	Función para cuando se coge vida
	Función para renderizar las barras de vida (Casi acabada)
	Función para items a los que influya la vida
	...
]]

local PH_DmgHudFont = Font()
local PH_TabFrame = 0
local PH_Fade = false
local PH_FrameDMGTaken = 0
local PH_invulFrames = 0
local PH_doInv = false
local PH_isOpaque = false

local PH_tChemJarPlayTypes = {
	[1] = "HPMorado_CJ",
	[2] = "HPRojoOscuro_CJ",
	[3] = "HPAzulOscuro_CJ",
	[4] = "HPAzulClaro_CJ",
	[5] = "HPSalmon_CJ",
	[6] = "HPGris_CJ",
	[7] = "HPVerdeOscuro_CJ",
	[8] = "HPNaranja_CJ",
	[9] = "HPAmarilloOscuro_CJ",
	[10] = "HPAmarilloClaro_CJ"
}
local PH_tHPBars = { -- Cada línea de vida roja es aprox 3.5 HP. Hay 41 líneas
					-- Cada trozo de vida roja es aprox 18 HP
	[1] = Sprite(), --Red
	[2] = Sprite(), --Blue
	[3] = Sprite(), --Black
	[4] = {  --ChemJar
		[1] = Sprite(), --1st Heart
		[2] = Sprite(), --2nd Heart
		[3] = Sprite()  --3rd Heart
 	},
	[5] = Sprite() --Bone
}
local PH_tOtherHPIcons = {
	[1] = Sprite(), --Eternal HP Icon
	[2] = {
		[1] = Sprite(), 
		[2] = Sprite(),
		[3] = Sprite(),
		[4] = Sprite(),
		[5] = Sprite(),
		[6] = Sprite(),
		[7] = Sprite(),
		[8] = Sprite()
	}, --Golden HP Square (max 8)
	[3] = Sprite(), --Blue HP Icon
	[4] = Sprite(), --Black HP Icon
	[5] = Sprite()	--Bone checkers pattern
}
local PH_tChemJarHPIcon = {
		[1] = Sprite(),
		[2] = Sprite(),
		[3] = Sprite() 
	}
local PH_tRed5HPBars = { --Máximo 8
	[1] = Sprite(),
	[2] = Sprite(),
	[3] = Sprite(),
	[4] = Sprite(),
	[5] = Sprite(),
	[6] = Sprite(),
	[7] = Sprite(),
	[8] = Sprite()
}
local PH_tRed1HPBars = { --Máximo 4
	[1] = Sprite(),
	[2] = Sprite(),
	[3] = Sprite(),
	[4] = Sprite()
}
local PH_tRed5HPBoneBars = { --Máximo 8
	[1] = Sprite(),
	[2] = Sprite(),
	[3] = Sprite(),
	[4] = Sprite(),
	[5] = Sprite(),
	[6] = Sprite(),
	[7] = Sprite(),
	[8] = Sprite()
}
local PH_tRed1HPBoneBars = { --Máximo 4
	[1] = Sprite(),
	[2] = Sprite(),
	[3] = Sprite(),
	[4] = Sprite()
}
local PH_tActiveBars = {
	[1] = Sprite(), --Red
	[2] = Sprite(), --Blue/Black
	[3] = Sprite(), --ChemJar (1 de las 3)
	[4] = Sprite()  --Bone
}
local PH_tChemColors = {
	[1] = {
		[1] = 255/255,  -- R
		[2] = 0/255,    -- G
		[3] = 255/255   -- B
	}, --Morado : 255 0 255
	[2] = {
		[1] = 127/255,  -- R
		[2] = 0/255,    -- G
		[3] = 0/255     -- B
	}, --Rojo Oscuro : 127 0 0
	[3] = {
		[1] = 0/255,    -- R
		[2] = 0/255,    -- G
		[3] = 127/255   -- B
	}, --Azul Oscuro : 0 0 127
	[4] = {
		[1] = 175/255,  -- R
		[2] = 175/255,  -- G
		[3] = 255/255   -- B
	}, --Azul Claro : 175 175 255
	[5] = {
		[1] = 255/255,  -- R
		[2] = 160/255,  -- G
		[3] = 122/255   -- B
	}, --Salmon : 255 160 122
	[6] = {
		[1] = 127/255,  -- R
		[2] = 127/255,  -- G
		[3] = 127/255   -- B
	}, --Gris : 127 127 127
	[7] = {
		[1] = 0/255,   -- R
		[2] = 100/255, -- G
		[3] = 0/255    -- B
	}, --Verde Oscuro : 0 100 0
	[8] = {
		[1] = 255/255,  -- R
		[2] = 127/255,  -- G
		[3] = 0/255     -- B
	}, --Naranja : 255 127 0
	[9] = {
		[1] = 127/255,  -- R
		[2] = 127/255,  -- G
		[3] = 0/255     -- B
	}, --Amarillo Oscuro : 127 127 0
	[10] = {
		[1] = 255/255,  -- R
		[2] = 255/255,  -- G
		[3] = 127/255   -- B
	}, --Amarillo Claro : 255 255 127
}

local PH_tDevilItemCosts = { -- Se podría poner coste a todos los items existentes (Chaos)
	[CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL] = 8,
	[CollectibleType.COLLECTIBLE_BOOK_OF_SIN] = 6,
	[CollectibleType.COLLECTIBLE_GUPPYS_HEAD] = 13,
	[CollectibleType.COLLECTIBLE_GUPPYS_PAW] = 13,
	[CollectibleType.COLLECTIBLE_MEGA_SATANS_BREATH] = 30,
	[CollectibleType.COLLECTIBLE_NECRONOMICON] = 7,
	[CollectibleType.COLLECTIBLE_PLAN_C] = 4,
	[CollectibleType.COLLECTIBLE_RAZOR_BLADE] = 6,
	[CollectibleType.COLLECTIBLE_VOID] = 12,
	[CollectibleType.COLLECTIBLE_WE_NEED_GO_DEEPER] = 6,
	[CollectibleType.COLLECTIBLE_THE_NAIL] = 18,
	[CollectibleType.COLLECTIBLE_SATANIC_BIBLE] = 22,
	[CollectibleType.COLLECTIBLE_ATHAME] = 11,
	[CollectibleType.COLLECTIBLE_BETRAYAL] = 7,
	[CollectibleType.COLLECTIBLE_BLACK_POWDER] = 8,
	[CollectibleType.COLLECTIBLE_BROTHER_BOBBY] = 5,
	[CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION] = 12,
	[CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES] = 20,
	[CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW] = 14,
	[CollectibleType.COLLECTIBLE_DARK_BUM] = 20,
	[CollectibleType.COLLECTIBLE_DARK_MATTER] = 18,
	[CollectibleType.COLLECTIBLE_DEAD_CAT] = 13,
	[CollectibleType.COLLECTIBLE_DEMON_BABY] = 8,
	[CollectibleType.COLLECTIBLE_DUALITY] = 11,
	[CollectibleType.COLLECTIBLE_EMPTY_VESSEL] = 24,
	[CollectibleType.COLLECTIBLE_GHOST_BABY] = 5,
	[CollectibleType.COLLECTIBLE_GIMPY] = 15,
	[CollectibleType.COLLECTIBLE_GOAT_HEAD] = 18,
	[CollectibleType.COLLECTIBLE_GUPPYS_COLLAR] = 13,
	[CollectibleType.COLLECTIBLE_GUPPYS_HAIRBALL] = 13,
	[CollectibleType.COLLECTIBLE_GUPPYS_TAIL] = 13,
	[CollectibleType.COLLECTIBLE_HEADLESS_BABY] = 6,
	[CollectibleType.COLLECTIBLE_MARK] = 15,
	[CollectibleType.COLLECTIBLE_MISSING_PAGE_2] = 7,
	[CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY] = 10,
	[CollectibleType.COLLECTIBLE_MY_SHADOW] = 5,
	[CollectibleType.COLLECTIBLE_PENTAGRAM] = 17,
	[CollectibleType.COLLECTIBLE_ROTTEN_BABY] = 24,
	[CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER] = 18,
	[CollectibleType.COLLECTIBLE_SHADE] = 7,
	[CollectibleType.COLLECTIBLE_SISTER_MAGGY] = 5,
	[CollectibleType.COLLECTIBLE_SUCCUBUS] = 22,
	[CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON] = 15,
	[CollectibleType.COLLECTIBLE_ABADDON] = 30,
	[CollectibleType.COLLECTIBLE_BRIMSTONE] = 27,
	[CollectibleType.COLLECTIBLE_DARK_PRINCESS_CROWN] = 9,
	[CollectibleType.COLLECTIBLE_DEATHS_TOUCH] = 20,
	[CollectibleType.COLLECTIBLE_EYE_OF_BELIAL] = 22,
	[CollectibleType.COLLECTIBLE_INCUBUS] = 24,
	[CollectibleType.COLLECTIBLE_JUDAS_SHADOW] = 20,
	[CollectibleType.COLLECTIBLE_LIL_BRIMSTONE] = 22,
	[CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT] = 15,
	[CollectibleType.COLLECTIBLE_MAW_OF_VOID] = 25,
	[CollectibleType.COLLECTIBLE_MOMS_KNIFE] = 27,
	[CollectibleType.COLLECTIBLE_PACT] = 22,
	[CollectibleType.COLLECTIBLE_SPIRIT_NIGHT] = 16,
	[CollectibleType.COLLECTIBLE_LIL_DELIRIUM] = 12,
	[CollectibleType.COLLECTIBLE_LIL_HARBINGERS] = 14,
	[CollectibleType.COLLECTIBLE_DEATH_LIST] = 12,
	[CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR] = 15,
	[Isaac.GetItemIdByName("Herpes")] = 5,
	[Isaac.GetItemIdByName("SunBurn")] = 5,
	[Isaac.GetItemIdByName("Ezcemas")] = 5,
	[Isaac.GetItemIdByName("Blisters")] = 5,
	[Isaac.GetItemIdByName("Stafilocus")] = 5,
	[Isaac.GetItemIdByName("Mini-Void")] = 10,
}
local PH_tDMGBomb = {
		[BombVariant.BOMB_NORMAL] = 13,
		[BombVariant.BOMB_BIG] = 18,
		[BombVariant.BOMB_DECOY] = 13,
		[BombVariant.BOMB_TROLL] = 13,
		[BombVariant.BOMB_SUPERTROLL] = 18,
		[BombVariant.BOMB_POISON] = 13,
		[BombVariant.BOMB_POISON_BIG] = 18,
		[BombVariant.BOMB_SAD] = 13,
		[BombVariant.BOMB_HOT] = 13,
		[BombVariant.BOMB_BUTT] = 13,
		[BombVariant.BOMB_MR_MEGA] = 18,
		[BombVariant.BOMB_BOBBY] = 13,
		[BombVariant.BOMB_GLITTER] = 13
		}
local PH_tEnemiesThatExplode = {
	[EntityType.ENTITY_BOOMFLY] = 13,
	[EntityType.ENTITY_TICKING_SPIDER] = 13,
	[EntityType.ENTITY_BOOMFLY] = 13,
	[EntityType.ENTITY_MULLIGAN] = 13,
	[EntityType.ENTITY_BLACK_BONY] = 13,
	[EntityType.ENTITY_LEECH] = 13,
	[EntityType.ENTITY_BLACK_MAW] = 13,
	[EntityType.ENTITY_MOM] = 18,
	[EntityType.ENTITY_SATAN] = 18,
	[EntityType.ENTITY_DADDYLONGLEGS] = 13,
	[EntityType.ENTITY_ULTRA_COIN] = 23,
	[EntityType.ENTITY_CORN_MINE] = 8,
	[EntityType.ENTITY_MEGA_SATAN] = 18,
	[EntityType.ENTITY_ULTRA_GREED] = 23
	}
local PH_tDMGContactRegular = { --Las llaves de las subtablas serán las variantes
	[EntityType.ENTITY_ATTACKFLY] = {
		[0] = 2
	},
	[EntityType.ENTITY_RING_OF_FLIES] = {
		[0] = 2
	},
	[EntityType.ENTITY_DART_FLY] = {
		[0] = 3
	},
	[EntityType.ENTITY_SWARM] = {
		[0] = 2
	},
	[EntityType.ENTITY_HUSH_FLY] = {
		[0] = 3
	},
	[EntityType.ENTITY_MOTER] = {
		[0] = 4
	},
	[EntityType.ENTITY_ETERNALFLY] = {
		[0] = 3
	},
	[EntityType.ENTITY_BOOMFLY] = {
		[0] = 2,
		[1] = 2, -- Red
		[2] = 2 -- Drowned
	},
	[EntityType.ENTITY_FLY_L2] = {
		[0] = 4
	},
	[EntityType.ENTITY_FULL_FLY] = {
		[0] = 4
	},
	[EntityType.ENTITY_SUCKER] = {
		[0] = 4,
		[1] = 4 -- Spit
	},
	[EntityType.ENTITY_DIP] = {
		[0] = 2,
		[1] = 3, -- Corn dip
		[2] = 3 -- Brownie dip
		},
	[EntityType.ENTITY_SQUIRT] = {
		[0] = 7,
		[1] = 7 -- Dank
	},
	[EntityType.ENTITY_DINGA] = {
		[0] = 6
	},
	[EntityType.ENTITY_SPIDER] = {
		[0] = 3
	},
	[EntityType.ENTITY_BIGSPIDER] = {
		[0] = 5
	},
	[EntityType.ENTITY_HOPPER] = {
		[0] = 4,
		[1] = 6 -- Trite
	},
	[EntityType.ENTITY_RAGLING] = {
		[0] = 6,
		[1] = 6 -- Ragman's
	},
	[EntityType.ENTITY_BLISTER] = {
		[0] = 7
	},
	[EntityType.ENTITY_SPIDER_L2] = {
		[0] = 5
	},
	[EntityType.ENTITY_TICKING_SPIDER] = {
		[0] = 3
	},
	[EntityType.ENTITY_BABY_LONG_LEGS] = {
		[0] = 2,
		[1] = 1 -- Small
	},
	[EntityType.ENTITY_CRAZY_LONG_LEGS] = {
		[0] = 6,
		[1] = 4
	},
	[EntityType.ENTITY_WALL_CREEP] = {
		[0] = 3
	},
	[EntityType.ENTITY_BLIND_CREEP] = {
		[0] = 1
	},
	[EntityType.ENTITY_RAGE_CREEP] = {
		[0] = 3
	},
	[EntityType.ENTITY_THE_THING] = {
		[0] = 4
	},
	[EntityType.ENTITY_WALKINGBOIL] = {
		[0] = 2,
		[1] = 2, -- Gut
		[2] = 2 -- Sack
	},
	[EntityType.ENTITY_ROUND_WORM] = {
		[0] = 3,
		[1] = 4 -- Tube worm
	},
	[EntityType.ENTITY_NIGHT_CRAWLER] = {
		[0] = 3
	},
	[EntityType.ENTITY_ROUNDY] = {
		[0] = 4
	},
	[EntityType.ENTITY_ULCER] = {
		[0] = 1
	},
	[EntityType.ENTITY_LEPER] = {
		[0] = 3,
		[1] = 3 -- Flesh
	},
	[EntityType.ENTITY_DUKIE] = {
		[0] = 2
	},
	[EntityType.ENTITY_FLAMINGHOPPER] = {
		[0] = 7
	},
	[EntityType.ENTITY_LEAPER] = {
		[0] = 6
	},
	[EntityType.ENTITY_MINISTRO] = {
		[0] = 4
	},
	[EntityType.ENTITY_GUSHER] = {
		[0] = 2,
		[1] = 2 -- Pacer
	},
	[EntityType.ENTITY_BLACK_GLOBIN_BODY] = {
		[0] = 3
	},
	[EntityType.ENTITY_GAPER] = {
		[0] = 6, -- Frown
		[1] = 4, -- Gaper
		[2] = 5 -- Flaming
	},
	[EntityType.ENTITY_CYCLOPIA] = {
		[0] = 4
	},
	[EntityType.ENTITY_HUSH_GAPER] = {
		[0] = 5
	},
	[EntityType.ENTITY_GREED_GAPER] = {
		[0] = 4
	},
	[EntityType.ENTITY_GURGLE] = {
		[0] = 5
	},
	[EntityType.ENTITY_SPLASHER] = {
		[0] = 2
	},
	[EntityType.ENTITY_SKINNY] = {
		[0] = 4,
		[1] = 5, -- Rotty
		[2] = 6 -- Crispy
	},
	[EntityType.ENTITY_MRMAW] = {
		[0] = 6, -- Head
		[1] = 2 -- Body
	},
	[EntityType.ENTITY_HORF] = {
		[0] = 3
	},
	[EntityType.ENTITY_PSY_HORF] = {
		[0] = 2
	},
	[EntityType.ENTITY_MAW] = {
		[0] = 4,
		[1] = 6, -- Red
		[2] = 4 -- Psy
	},
	[EntityType.ENTITY_BONY] = {
		[0] = 4
	},
	[EntityType.ENTITY_BLACK_BONY] = {
		[0] = 4
	},
	[EntityType.ENTITY_DEATHS_HEAD] = {
		[0] = 6,
		[1] = 6 --Dank
	},
	[EntityType.ENTITY_FLESH_DEATHS_HEAD] = {
		[0] = 6
	},
	[EntityType.ENTITY_ONE_TOOTH] = {
		[0] = 7
	},
	[EntityType.ENTITY_FAT_BAT] = {
		[0] = 3
	},
	[EntityType.ENTITY_WIZOOB] = { 
		[0] = 2
	},
	[EntityType.ENTITY_RED_GHOST] = {
		[0] = 2
	},
	[EntityType.ENTITY_FATTY] = {
		[0] = 4,
		[1] = 5, --Pale
		[2] = 6  --Flaming
	},
	[EntityType.ENTITY_CONJOINED_FATTY] = {
		[0] = 4,
		[1] = 4 --Blue
	},
	[EntityType.ENTITY_FAT_SACK] = {
		[0] = 7
	},
	[EntityType.ENTITY_BLUBBER] = {
		[0] = 2
	},
	[EntityType.ENTITY_HALF_SACK] = {
		[0] = 3
	},
	[EntityType.ENTITY_GLOBIN] = {
		[0] = 9, 
		[1] = 11, --Gazing
		[2] = 9   --Dank
	},
	[EntityType.ENTITY_BLACK_GLOBIN] = {
		[0] = 10
	},
	[EntityType.ENTITY_KNIGHT] = {
		[0] = 6,
		[1] = 8 --Selfless
	},
	[EntityType.ENTITY_FLOATING_KNIGHT] = {
		[0] = 5
	},
	[EntityType.ENTITY_BONE_KNIGHT] = {
		[0] = 10
	},
	[EntityType.ENTITY_MASK] = {
		[0] = 7
	},
	[EntityType.ENTITY_CLOTTY] = {
		[0] = 3,
		[1] = 3, --Clot
		[2] = 3  --I.Blob
	},
	[EntityType.ENTITY_MEGA_CLOTTY] = {
		[0] = 5
	},
	[EntityType.ENTITY_MOMS_HAND] = {
		[0] = 7
	},
	[EntityType.ENTITY_MOMS_DEAD_HAND] = {
		[0] = 8
	},
	[EntityType.ENTITY_MAGGOT] = {
		[0] = 3
	},
	[EntityType.ENTITY_CHARGER] = {
		[0] = 7,
		[1] = 5, -- Drowned
		[2] = 9 -- Dank
	},
	[EntityType.ENTITY_SPITY] = {
		[0] = 3
	},
	[EntityType.ENTITY_CONJOINED_SPITTY] = {
		[0] = 3
	},
	[EntityType.ENTITY_TUMOR] = {
		[0] = 3
	},
	[EntityType.ENTITY_PSY_TUMOR] = {
		[0] = 3
	},
	[EntityType.ENTITY_CAMILLO_JR] = {
		[0] = 3
	},
	[EntityType.ENTITY_BRAIN] = {
		[0] = 5
	},
	[EntityType.ENTITY_POISON_MIND] = {
		[0] = 5
	},
	[EntityType.ENTITY_MEMBRAIN] = {
		[0] = 4,
		[1] = 4 --Mama guts
	},
	[EntityType.ENTITY_GUTS] = {
		[0] = 6,
		[1] = 6 --Scarred
	},
	[EntityType.ENTITY_BUTTLICKER] = {
		[0] = 6
	},
	[EntityType.ENTITY_GRUB] = {
		[0] = 8
	},
	[EntityType.ENTITY_PARA_BITE] = {
		[0] = 7,
		[1] = 5 -- Scarred
	},
	[EntityType.ENTITY_COD_WORM] = {
		[0] = 2
	},
	[EntityType.ENTITY_FRED] = {
		[0] = 4
	},
	[EntityType.ENTITY_LUMP] = {
		[0] = 3
	},
	[EntityType.ENTITY_LEECH] = {
		[0] = 8,
		[1] = 8, --Kamikaze
		[2] = 8  --Holy
	},
	[EntityType.ENTITY_TARBOY] = {
		[0] = 6
	},
	[EntityType.ENTITY_MOBILE_HOST] = {
		[0] = 3
	},
	[EntityType.ENTITY_FLESH_MOBILE_HOST] = {
		[0] = 3
	},
	[EntityType.ENTITY_MUSHROOM] = {
		[0] = 2
	},
	[EntityType.ENTITY_MEATBALL] = {
		[0] = 3
	},
	[EntityType.ENTITY_NERVE_ENDING] = {
		[0] = 1,
		[1] = 7 -- 2
	},
	[EntityType.ENTITY_VIS] = {
		[0] = 3,
		[1] = 3, --Double
		[2] = 3, --Scarred
		[3] = 4, --Chubber
		[22] = 10 --Chubber projectile
	},
	[EntityType.ENTITY_WALL_HUGGER] = {
		[0] = 8
	},
	[EntityType.ENTITY_POKY] = {
		[0] = 6,
		[1] = 8 --Slide
	},
	[EntityType.ENTITY_EYE] = {
		[0] = 2,
		[1] = 2 --Bloodshot
	},
	[EntityType.ENTITY_EMBRYO] = {
		[0] = 1
	},
	[EntityType.ENTITY_BABY] = {
		[0] = 3,
		[1] = 3, --Angelic
		[2] = 3  --Ultra Pride
	},
	[EntityType.ENTITY_IMP] = {
		[0] = 5
	},
	[EntityType.ENTITY_HOMUNCULUS] = {
		[0] = 9
	},
	[EntityType.ENTITY_BEGOTTEN] = {
		[0] = 11
	},
	[EntityType.ENTITY_NULLS] = {
		[0] = 8
	},
	[EntityType.ENTITY_SWINGER] = {
		[0] = 2, --Body
		[1] = 7  --Head
	},
	[EntityType.ENTITY_KEEPER] = {
		[0] = 3
	},
	[EntityType.ENTITY_HANGER] = {
		[0] = 3
	},
	[311] = {--Mr Mine
		[0] = 8
	},
	[EntityType.ENTITY_FISTULOID] = {
		[0] = 4
	},
	[EntityType.ENTITY_OOB] = {
		[0] = 12
	},
	[EntityType.ENTITY_BLACK_MAW] = {
		[0] = 14
	},
	[EntityType.ENTITY_ULTRA_COIN] = {
		[0] = 7 --Spinning
	},
	[EntityType.ENTITY_GURGLING] = {
		[0] = 5
	},
	[EntityType.ENTITY_THE_HAUNT] = {
		[10] = 6 --Lil' Haunt
	},
	[EntityType.ENTITY_RAG_MAN] = {
		[1] = 7 --Head , todos los subtipos harán 7 de daño
	},
	[EntityType.ENTITY_LITTLE_HORN] = {
		[1] = 6 --Ball
	},
	[EntityType.ENTITY_PEEP] = {
		[10] = 5, -- Eyes
		[11] = 5  -- Eyes(Bloat)
	},
	[EntityType.ENTITY_RAG_MEGA] = {
		[1] = 5 -- Ball
	},
	[EntityType.ENTITY_DEATH] = {
		[10] = 8 -- Scythe
	},
	[EntityType.ENTITY_FIREPLACE] = {
		[0] = 5,
		[1] = 7, -- Red
		[2] = 6, -- Blue
		[3] = 8  -- Purple
	},
}
local PH_tDMGContactBoss = { --Las llaves de las subtablas serán los subtipos
	[EntityType.ENTITY_MONSTRO] = {
		[0] = {
			[0] = 7,
			[1] = 4, --Rosa
			[2] = 2  --Gris
		}
	},
	[EntityType.ENTITY_GEMINI] = {
		[0] = { --Gemini
			[0] = 7, --Normal
			[1] = 5, --Green
			[2] = 5  --Blue
		},
		[1] = {[0] = 7}, --Steven
		[2] = {[0] = 9}, --Blighted Ovum
		[10] = {[0] = 5}, --Baby
		[11] = {[0] = 5}, --Steven Baby
		[12] = {[0] = 2} --Blighted Baby
	},
	[EntityType.ENTITY_LARRYJR] = {
		[0] = { --Normal
			[0] = 7,
			[1] = 5, --Green
			[2] = 6  --Blue
		},
		[1] = { --Hollow
			[0] = 9,
			[1] = 5, --Green
			[2] = 7, --Black
			[3] = 8  --Gold
		}
	},
	[EntityType.ENTITY_DINGLE] = {
		[0] = { --Normal
			[0] = 8,
			[1] = 6, --Red
			[2] = 8  --Black
		},
		[1] = {[0] = 8} --Dangle
	},
	[EntityType.ENTITY_GURGLING] = { --[0] no es boss
		[1] = { --Boss
			[0] = 6,
			[1] = 6, --Yellow
			[2] = 4  --Black
		},
		[2] = {[0] = 6} --Turdling
	},
	[EntityType.ENTITY_PIN] = {
		[0] = {[0] = 8}, --Normal
		[1] = { --Scolex
			[0] = 8, --Normal
			[1] = 7  --Black
		},
		[2] = { --The Frail
			[0] = 8, --Normal
			[1] = 6  --Black
		}
	},
	[EntityType.ENTITY_WIDOW] = {
		[0] = { --Normal
			[0] = 8, --Normal
			[1] = 6, --Black
			[2] = 7   --Pink
		},
		[1] = {[0] = 11} --Wretched
	},
	[EntityType.ENTITY_FISTULA_BIG] = {
		[0] = {
			[0] = 10, --Normal
			[1] = 8	  --Black
		},
		[1] = {[0] = 10} --Teratoma
	},
	[EntityType.ENTITY_FISTULA_MEDIUM] = {
		[0] = {
			[0] = 9, --Normal
			[1] = 7	  --Black
		},
		[1] = {[0] = 9} --Teratoma
	},
	[EntityType.ENTITY_FISTULA_SMALL] = {
		[0] = {
			[0] = 8, --Normal
			[1] = 6	  --Black
		},
		[1] = {[0] = 8} --Teratoma
	},
	[EntityType.ENTITY_GURDY_JR] = {
		[0] = {
			[0] = 8,
			[1] = 5, --Blue
			[2] = 6  --Orange
		}
	},
	[EntityType.ENTITY_THE_HAUNT] = {
		[0] = {
			[0] = 8,
			[1] = 5, --Black
			[2] = 6  --Pink
		}
	},
	[EntityType.ENTITY_DUKE] = {
		[0] = {
			[0] = 3,
			[1] = 2, -- Green
			[2]	= 3	 -- Pink
		},
		[1] = { -- Husk
			[0] = 6,
			[1] = 2, -- Black
			[2]	= 8	 -- Red
		}
	},
	[EntityType.ENTITY_RAG_MAN] = {
		[0] = {
			[0] = 7,
			[1] = 2, -- Pink
			[2]	= 6	 -- Black
		}
	},
	[EntityType.ENTITY_LITTLE_HORN] = {
		[0] = {
			[0] = 3,
			[1] = 4, -- Orange
			[2]	= 4	 -- Black
		}
	},
	[EntityType.ENTITY_CHUB] = {
		[0] = {
			[0] = 9,
			[1] = 4, -- Blue
			[2]	= 6	 -- Orange
		},
		[1] = {[0] = 7}, --C.H.A.D
		[2] = { -- Carrion Queen
			[0] = 11,
			[1] = 8 -- Pink
		}
	},
	[EntityType.ENTITY_GURDY] = {
		[0] = {
			[0] = 5,
			[1] = 5 --Black
		}
	},
	[EntityType.ENTITY_MEGA_MAW] = {
		[0] = {
			[0] = 3,
			[1] = 2, -- Red
			[2]	= 3	 -- Black
		} 
	},
	[EntityType.ENTITY_MEGA_FATTY] = {
		[0] = {
			[0] = 7,
			[1] = 6, -- Red
			[2]	= 5	 -- Brown
		} 
	},
	[EntityType.ENTITY_DARK_ONE] = {
		[0] = {[0] = 9}
	},
	[EntityType.ENTITY_POLYCEPHALUS] = {
		[0] = {
			[0] = 7,
			[1] = 6, -- Red
			[2]	= 5	 -- Pink
		} 
	},
	[EntityType.ENTITY_STAIN] = {
		[0] = {
			[0] = 9,
			[1] = 9 -- Pale
		}
	},
	[EntityType.ENTITY_FORSAKEN] = {
		[0] = {
			[0] = 8,
			[1] = 8 -- Black
		}
	},
	[EntityType.ENTITY_PEEP] = {
		[0] = {
			[0] = 7,
			[1] = 5, -- Yellow
			[2]	= 5	 -- Dark Green
		},
		[1] = { --Bloat
			[0] = 8,
			[2]	= 5	 -- Green
		}
	},
	[EntityType.ENTITY_BIG_HORN] = {
		[0] = {[0] = 7},
		[1] = {
			[0] = 12, -- Todos son las posibles Manos
			[1] = 8,
			[2] = 8,
			[3] = 8,
			[4] = 8,
			[5] = 8,
			[6] = 8
		},
		[2] = {
			[0] = 12, -- Todos son las posibles Manos
			[1] = 8,
			[2] = 8,
			[3] = 8,
			[4] = 8,
			[5] = 8,
			[6] = 8
		}
	},
	[EntityType.ENTITY_RAG_MEGA] = {
		[0] = {[0] = 6}
	},
	[EntityType.ENTITY_CAGE] = {
		[0] = {
			[0] = 9,
			[1] = 7, -- Green
			[2] = 5  -- Pink
		}
	},
	[EntityType.ENTITY_LOKI] = {
		[0] = {[0] = 3},
		[1] = {[0] = 3} -- Lokii
	},
	[EntityType.ENTITY_MONSTRO2] = {
		[0] = {
			[0] = 8,
			[1] = 7 -- Red
		},
		[1] = {[0] = 10} -- Gish
	},
	[EntityType.ENTITY_GATE] = {
		[0] = {
			[0] = 5,
			[1] = 3, --Red
			[2] = 6  --Black
		}
	},
	[EntityType.ENTITY_ADVERSARY] = {
		[0] = {[0] = 10}
	},
	[EntityType.ENTITY_MASK_OF_INFAMY] = {
		[0] = {[0] = 9}
	},
	[EntityType.ENTITY_HEART_OF_INFAMY] = {
		[0] = {
			[0] = 2,
			[1] = 1 --Black
		}
	},
	[EntityType.ENTITY_BROWNIE] = {
		[0] = {
			[0] = 7,
			[1] = 5 --Black
		}
	},
	[EntityType.ENTITY_SISTERS_VIS] = {
		[0] = {[0] = 8}
	},
	[EntityType.ENTITY_FRED] = {
		[0] = {[0] = 5}
	},
	[EntityType.ENTITY_MAMA_GURDY] = {
		[0] = {[0] = 5},
		[1] = {[0] = 8}, -- Left hand
		[2] = {[0] = 8}  -- Right hand
	},
	[EntityType.ENTITY_BLASTOCYST_BIG] = {
		[0] = {[0] = 9}
	},
	[EntityType.ENTITY_BLASTOCYST_MEDIUM] = {
		[0] = {[0] = 7} 
	},
	[EntityType.ENTITY_BLASTOCYST_SMALL] = {
		[0] = {[0] = 5}
	},
	[EntityType.ENTITY_MATRIARCH] = {
		[0] = {[0] = 8}
	},
	[EntityType.ENTITY_DADDYLONGLEGS] = {
		[0] = {[0] = 9},
		[1] = {[0] = 10} -- Triachnid
	},
	[EntityType.ENTITY_FALLEN] = {
		[0] = {[0] = 12},
		[1] = {[0] = 6} --Krampus
	},
	[EntityType.ENTITY_FAMINE] = {
		[0] = {
			[0] = 12,
			[1] = 8 --Blue
		}
	},
	[EntityType.ENTITY_PESTILENCE] = {
		[0] = {
			[0] = 8,
			[1] = 8 --White
		}
	},
	[EntityType.ENTITY_WAR] = {
		[0] = {
			[0] = 12,
			[1] = 10 --Black
		},
		[1] = {[0] = 12}, -- Conquest
		[10] = { -- War w/o horse	
			[0] = 10,
			[1] = 8 -- Black
		}
	},
	[EntityType.ENTITY_DEATH] = {
		[0] = {
			[0] = 10,
			[1] = 7 --Black
		},
		[20] = {[0] = 12}, -- Horse
		[30] = { -- Death w/o horse
			[0] = 8,
			[1] = 5 -- Black
		}
	},
	[EntityType.ENTITY_HEADLESS_HORSEMAN] = {
		[0] = {[0] = 8}
	},
	[EntityType.ENTITY_HORSEMAN_HEAD] = {
		[0] = {[0] = 10}
	},
	[EntityType.ENTITY_MOM] = {
		[0] = {
			[0] = 10,
			[1] = 6, -- Blue
			[2] = 8  -- Red
		}
	},
	[EntityType.ENTITY_MOMS_HEART] = {
		[0] = {[0] = 5},
		[1] = {[0] = 5} --It lives
	},
	[EntityType.ENTITY_SATAN] = {
		[0] = {[0] = 9}
	},
	[EntityType.ENTITY_ISAAC] = {
		[0] = {[0] = 2},
		[1] = {[0] = 2}, --???
		[2] = {[0] = 3}  --Hush Baby
	},
	[EntityType.ENTITY_THE_LAMB] = {
		[0] = {[0] = 11},
		[10] = {[0] = 2} --Body
	},
	[EntityType.ENTITY_MEGA_SATAN] = { --[0] No hace daño
		[1] = {[0] = 8}, --Right Hand
		[2] = {[0] = 8}  --Left Hand
	},
	[EntityType.ENTITY_MEGA_SATAN_2] = {
		[0] = {[0] = 10}
	},
	[EntityType.ENTITY_HUSH] = {
		[0] = {[0] = 6}
	},
	[EntityType.ENTITY_ULTRA_GREED] = {
		[0] = {[0] = 15},
		[1] = {[0] = 15} --Greedier
	},
	[EntityType.ENTITY_DELIRIUM] = {
		[0] = {[0] = 5} --Low to compensate telefrags
	},
	[EntityType.ENTITY_ENVY] = {
		[0] = {[0] = 8},  --Complete
		[10] = {[0] = 6}, --Big Head
		[20] = {[0] = 4}, --Medium Head
		[30] = {[0] = 2}, --Small Head
		[1] = {[0] = 10}, --Complete (Super)
		[11] = {[0] = 8}, --Big Head (Super)
		[21] = {[0] = 6}, --Medium Head (Super)
		[31] = {[0] = 4}  --Small Head (Super)
	},
	[EntityType.ENTITY_GLUTTONY] = {
		[0] = {[0] = 2},
		[1] = {[0] = 4} --Super
	},
	[EntityType.ENTITY_WRATH] = {
		[0] = {[0] = 4},
		[1] = {[0] = 6} --Super
	},
	[EntityType.ENTITY_PRIDE] = {
		[0] = {[0] = 2},
		[1] = {[0] = 4} --Super
	},
	[EntityType.ENTITY_SLOTH] = {
		[0] = {[0] = 6},
		[1] = {[0] = 8}, --Super
		[2] = {[0] = 8} --Ultra Pride (?)
	},
	[EntityType.ENTITY_LUST] = {
		[0] = {[0] = 10},
		[1] = {[0] = 12} --Super
	},
	[EntityType.ENTITY_GREED] = {
		[0] = {[0] = 4},
		[1] = {[0] = 6} --Super
	}
}
local PH_tDMGLaser = { -- El daño es siempre el mismo, independientemente del enemigo. Será un daño muy constante casi sin I-frames
	[1] = 2, -- Brimstone
	[2] = 1, -- Tech
	[4] = 2, -- Pride (el [3] es el de Shoop, nunca podría darle al jugador)
	[5] = 2, -- Angelical laseres
	[6] = 5 -- Mega Brimstone
} -- El resto son láseres que nunca podrían darle a Isaac, el de Hush es un efecto que se manejará a parte.
local PH_tDMGProjectile = {
	[ProjectileVariant.PROJECTILE_NORMAL] = 5,
	[ProjectileVariant.PROJECTILE_BONE] = 7,
	[ProjectileVariant.PROJECTILE_FIRE] = 9,
	[ProjectileVariant.PROJECTILE_PUKE] = 5,
	[ProjectileVariant.PROJECTILE_TEAR] = 5,
	[ProjectileVariant.PROJECTILE_CORN] = 6,
	[ProjectileVariant.PROJECTILE_HUSH] = 5,
	[ProjectileVariant.PROJECTILE_COIN] = 6
}

local PH_tDMGFuncs = {}

local function PH_dmgBasedOnDistance(Distance,baseDmg)
	if baseDmg == 13 then
		if Distance == 85 then
			return 1
		else
			return math.ceil(baseDmg * (math.abs(Distance/85 - 1)))
		end
	elseif baseDmg == 18 then
		if Distance == 115 then
			return 1
		else
			return math.ceil(baseDmg * (math.abs(Distance/115 - 1)))
		end
	end
end

local function PH_dmgExplosion(source,entity) -- 85 distancia bomba normal, 115 Mr Mega
	local TempDMG
	if source.Type == 4 then -- Bomba
		TempDMG = PH_dmgBasedOnDistance(source.Position:Distance(entity.Position),PH_tDMGBomb[source.Variant])
	elseif source.Type == 1000 then -- Efectos como stomps
		TempDMG = PH_dmgBasedOnDistance(source.Position:Distance(entity.Position),13)
	elseif PH_tEnemiesThatExplode[source.Type] ~= nil then
		TempDMG = PH_dmgBasedOnDistance(source.Position:Distance(entity.Position),PH_tEnemiesThatExplode[source.Type])
	elseif source.Type == 9 then -- Projectil
		TempDMG = PH_dmgBasedOnDistance(source.Position:Distance(entity.Position),13)
	else -- Projectil, pero el callback da como source al que disparó el projectil
		local entities = AlphaAPI.entities.active
		for i,v in pairs(entities) do
			if v.Type == 9 then -- Es un projectil
				if v:ToProjectile().ProjectileFlags & ProjectileFlags.EXPLODE == ProjectileFlags.EXPLODE then -- Es un projectil explosivo
					if v.SpawnerType == source.Type then -- Es un projectil del que nos dañó
						if v.Position:Distance(entity.Position) < 85 then -- Si estamos en rango
							TempDMG = PH_dmgBasedOnDistance(v.Position:Distance(entity.Position),13)
							break
						end
					end
				end
			end
		end
	end
	if TempDMG == nil then
		TempDMG = 13 -- Por defecto
	end
	return TempDMG
end

--[[

-- TODO : Pedos de setas no tienen Tipo, casos así por defecto 5 de daño.
local PH_tDMGEffects = { -- 1000: Creep, RockWaves.... 
	[22] = 7, -- Creep Roja
	[23] = 7, -- ''    Verde
	[24] = 7, -- ''    Amarilla
	[28] = 13, -- Monstros Tooth
	[29] = 15, -- Mom's Foot (De carta/trinket)
	[31] = 15, -- Epic Fetus
	[55] = 10, -- Spikes
	[61] = 13, -- Rock Wave
	[67] = 13, -- Rock Wave
	[72] = 13, -- Rock Wave
	[73] = 13, -- Rock Wave
	[96] = 13 -- Hush Laser
}

local PH_tDMGExplosion = { -- Ipecacs, Rock Waves, Pisotones, etc
	[EntityType.ENTITY_BOOMFLY] = 8,
	[EntityType.ENTITY_SUCKER] = 13,
	[EntityType.ENTITY_TICKING_SPIDER] = 8,
	[EntityType.ENTITY_BOIL] = 13,
	[EntityType.ENTITY_WALKINGBOIL] = 13,
	[EntityType.ENTITY_ROUNDY] = 13,
	[EntityType.ENTITY_MULLIGAN] = 8,
	[EntityType.ENTITY_GURGLE] = 13,
	[EntityType.ENTITY_SPLASHER] = 13,
	[EntityType.ENTITY_BLACK_BONY] = 8,
	[EntityType.ENTITY_CONJOINED_FATTY] = 13,
	[EntityType.ENTITY_FRED] = 13,
	[EntityType.ENTITY_LEECH] = 8,
	[EntityType.ENTITY_STONEHEAD] = 13,
	[EntityType.ENTITY_BLACK_MAW] = 8,
	-- Bosses --
	[EntityType.ENTITY_PIN] = 13,
	[EntityType.ENTITY_PESTILENCE] = 13,
	[EntityType.ENTITY_MONSTRO2] = 13,
	[EntityType.ENTITY_PEEP] = 13,
	[EntityType.ENTITY_HEADLESS_HORSEMAN] = 13,
	[EntityType.ENTITY_THE_LAMB] = 13,
	[EntityType.ENTITY_ULTRA_COIN] = 15,
	[EntityType.ENTITY_ULTRA_GREED] = 15,
	[EntityType.ENTITY_SLOTH] = 13,
}]]	

local function PH_CheckChampion(source,Boss)
	if Boss then
		return (source.SubType ~= 0) --If the boss has any subtype different than 0, it's a Champion
	else
		return (source:ToNPC():IsChampion())
	end
end

local function PH_dmgLaser(source,entity) 
	local entities = AlphaAPI.entities.active
	for i,v in pairs(entities) do
		if v.Type == 7 then -- Es un laser
			if v.SpawnerType == source.Type then -- Es un laser del que nos dañó
				return PH_tDMGLaser[v.Variant]
			end
		end
	end
	return 2 -- Por defecto
end

local function PH_dmgBasedOnSize(source,BaseDmg)
	return math.ceil(BaseDmg*(source:ToProjectile().Scale))
end

local function PH_DamageTaken_Projectile(source)
	local TempDMG = PH_dmgBasedOnSize(source,PH_tDMGProjectile[source.Variant])
	if TempDMG == nil then
		TempDMG = 5 --Default
	end
	return TempDMG
end

local function PH_DamageTaken_Boss(source)
	local TempDMG = PH_tDMGContactBoss[source.Type][source.Variant][source.SubType]
	if TempDMG == nil then
		TempDMG = PH_tDMGContactBoss[source.Type][source.Variant][0]
	end
	if TempDMG == nil then
		TempDMG = 8 --Default
	end
	if PH_CheckChampion(source,true) then
		return math.ceil(TempDMG*1.5)
	else
		return TempDMG
	end
end

local function PH_DamageTaken_Regular(source)
	local TempDMG = PH_tDMGContactRegular[source.Type][source.Variant]
	if TempDMG == nil then
		TempDMG = PH_tDMGContactBoss[source.Type][0]
	end
	if TempDMG == nil then
		TempDMG = 5 --Default
	end
	if PH_CheckChampion(source,false) then
		return math.ceil(TempDMG*1.5)
	else
		return TempDMG
	end
end

--[[
local PH_tDMGFlags = {
	[DamageFlag.DAMAGE_FIRE] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_EXPLOSION] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_LASER] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_ACID] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_RED_HEARTS] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_SPIKES] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_POOP] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_TNT] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_CURSED_DOOR] = function(d) PH_returnDmg(d) end,
	[DamageFlag.DAMAGE_CHEST] = function(d) PH_returnDmg(d) end
}]]

local function PH_blinkingFrec(FrameCount)
	return math.ceil((PH_invulFrames - FrameCount + PH_FrameDMGTaken)/5) -- Rango desde 7 hasta 1
end

function ABppmod:PH_blinking()
	player = AlphaAPI.GAME_STATE.PLAYERS[1]
	if PH_doInv and ((player.FrameCount - PH_FrameDMGTaken) <= PH_invulFrames) then
		PH_isOpaque = false
		
		local Frec = PH_blinkingFrec(player.FrameCount)
		if Frec == 0 then Frec = 1 end
		if Frec > 12 then
			if ((Frec % 2) == 0) then
				PH_isOpaque = not(PH_isOpaque)
			end
		else
			if(player.FrameCount % Frec == 0) then
				PH_isOpaque = not(PH_isOpaque)
			end
		end
		if(PH_isOpaque) then
			player.Color = Color(1, 1, 1, 1, 0, 0, 0)
		else
			player.Color = Color(1, 1, 1, 0.05, 0, 0, 0)
		end
	elseif PH_doInv then
		PH_doInv = not(PH_doInv)
		if not PH_isOpaque then
			player.Color = Color(1, 1, 1, 1, 0, 0, 0)
		end
	end
end

local function round(x)
	if x % 1 >= 0.5 then return math.ceil(x)
	else return math.floor(x) end
end

local function PH_RedHPProportion()	
	if alphaMod.data.run.PH_RedHP ~= nil and alphaMod.data.run.PH_MaxRedHP ~= nil then
		local RedPixels = 41 * (alphaMod.data.run.PH_RedHP/alphaMod.data.run.PH_MaxRedHP)
		RedPixels = round(RedPixels)
		return Vector(math.floor(RedPixels/5) , round(((RedPixels/5) % 1) * 5)) --(5,1)
	end
	return Vector(0,0)
end

local function PH_BoneHPProportion()	
	if alphaMod.data.run.PH_BoneHP ~= nil and alphaMod.data.run.PH_MaxBoneHP ~= nil then
		local RedPixels = 44 * (alphaMod.data.run.PH_BoneHP/alphaMod.data.run.PH_MaxBoneHP)
		RedPixels = round(RedPixels)
		return Vector(math.floor(RedPixels/5) , round(((RedPixels/5) % 1) * 5)) --(5,1)
	end
	return Vector(0,0)
end

local function PH_GenericDmg(HP,leftovers)
	local dmg = math.abs(HP)
	if leftovers then
		alphaMod.data.run.PH_activeBar = alphaMod.data.run.PH_activeBar - 1 
		--Leftovers ==> Venimos de una iteración donde queda daño por distribuir, entonces vamos del 7 al 1 en orden
	elseif alphaMod.data.run.PH_ChemJarHPIsEmpty then --Si leftovers es falso, saltamos al 7 y lo ponemos true
		alphaMod.data.run.PH_activeBar = 4
	else --A menos que sepamos que están vacíos los del 7 al 5
		alphaMod.data.run.PH_activeBar = 7
	end
	leftovers = true
	if alphaMod.data.run.PH_activeBar == 0 then -- No queda vida
		PH_invulFrames = 0 --Evita el flasheo de las iframes al morir
		if (alphaMod.data.run.PH_RedHP+alphaMod.data.run.PH_BlueHP+alphaMod.data.run.PH_BlackHP+
		alphaMod.data.run.PH_ChemJar1HP+alphaMod.data.run.PH_ChemJar2HP+alphaMod.data.run.PH_ChemJar3HP+
		alphaMod.data.run.PH_BoneHP+alphaMod.data.run.PH_MaxBoneHP) <= 0 then --Nos aseguramos
			AlphaAPI.GAME_STATE.PLAYERS[1]:Kill()
		end
	else
		PH_tDMGFuncs[alphaMod.data.run.PH_activeBar](dmg,leftovers)
		--la recursividad se encargará de ir al primero que tenga algo de vida.
	end
end

local function PH_activeMove(left) end -- Inicializamos para uso de estas funciones

local PH_tAnimationsOnHold = {}

local function PH_animateDMGTaken(dmg,r,g,b,size,heal)
	local currFrame = AlphaAPI.GAME_STATE.GAME:GetFrameCount()
	local p = AlphaAPI.GAME_STATE.PLAYERS[1]
	local room = AlphaAPI.GAME_STATE.ROOM
	local pos = room:WorldToScreenPosition(p.Position)
	local tCurrAnim = {
		[1] = dmg,
		[2] = r,
		[3] = g,
		[4] = b,
		[5] = 60 + currFrame, -- La animación durará 60 frames (2s)
		[6] = pos.X,
		[7] = pos.Y,
		[8] = size,
		[9] = heal
		}
	table.insert(PH_tAnimationsOnHold,tCurrAnim)
end

local PH_maxTotDmg = 0 -- Para que solo muestre la máxima
local PH_maxTotHeal = 0 -- Para que solo muestre la máxima

function ABppmod:PH_renderAnimateDMGTaken() --TODO Perfecionar esto (Varios -'s al mismo tiempo, stacks arriba, etc)
	if next(PH_tAnimationsOnHold) ~= nil then --entra solo si hay animaciones en espera
		local totaldmg = 0
		local totalheal = 0
		local count = 0
		for i,v in ipairs(PH_tAnimationsOnHold) do
			count = count + 1
			if v[9] then
				totalheal = totalheal + v[1]
			else
				totaldmg = totaldmg + v[1]
			end
			local f = AlphaAPI.GAME_STATE.GAME:GetFrameCount()
			local posX
			if v[9] then -- heal
				posX = v[6] - 10 * (math.cos(((v[5]-f)*math.pi)/7.5))
			else	
				posX = v[6] - 10 * (math.sin(((v[5]-f)*math.pi)/7.5))
			end
			local posY = v[7] - (60 - v[5] + f) - 20
			local transp = (v[5]-f)/60
			local plusminus = "-"
			if v[9] then plusminus = "+" end
			PH_DmgHudFont:DrawStringScaled(plusminus..v[1],posX+(12*i*v[8]),posY,v[8],v[8],KColor(v[2],v[3],v[4],transp),0,true)
			if f >= v[5] then
				table.remove(PH_tAnimationsOnHold,i)
			end
		end
		
		if totaldmg > PH_maxTotDmg then
			PH_maxTotDmg = totaldmg
		end
		if totalheal > PH_maxTotHeal then
			PH_maxTotHeal = totalheal
		end
		if PH_maxTotDmg-PH_maxTotHeal < 0 then
			PH_DmgHudFont:DrawStringScaled("+"..math.abs(PH_maxTotDmg-PH_maxTotHeal),155,40,1.25,1.25,KColor(0,1,0,1 - PH_TabFrame / 9 ),0,true)
		else
			PH_DmgHudFont:DrawStringScaled("-"..PH_maxTotDmg-PH_maxTotHeal,155,40,1.25,1.25,KColor(1,0,0,1 - PH_TabFrame / 9 ),0,true)
		end
	elseif PH_maxTotDmg ~= 0 or PH_maxTotHeal ~= 0 then
		PH_maxTotDmg = 0
		PH_maxTotHeal = 0
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.PH_renderAnimateDMGTaken)

local function PH_RedDmg(dmg,leftovers)
	if alphaMod.data.run.PH_EternalHP then
		alphaMod.data.run.PH_EternalHP = false --Lo eliminamos sin restar daño
	end
	local hp = 0
	alphaMod.data.run.PH_RedHP = alphaMod.data.run.PH_RedHP - dmg
	if alphaMod.data.run.PH_RedHP < 0 then --Más daño que vida
		hp = alphaMod.data.run.PH_RedHP
		alphaMod.data.run.PH_RedHP = 0
		PH_GenericDmg(hp,leftovers)
	elseif alphaMod.data.run.PH_RedHP == 0 then
		PH_activeMove(true)
	end
	if (dmg+hp) > 0 then
		PH_animateDMGTaken(dmg+hp,(230/255),(1/255),0,1,false)
	end
	alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
end

local function PH_BoneDmg(dmg,leftovers)
	if alphaMod.data.run.PH_BoneHP == 0 then
		alphaMod.data.run.PH_MaxBoneHP = alphaMod.data.run.PH_MaxBoneHP - dmg * 2
		local hp = 0
		if alphaMod.data.run.PH_MaxBoneHP < 0 then
			hp = math.ceil(alphaMod.data.run.PH_MaxBoneHP / 2)
			alphaMod.data.run.PH_MaxBoneHP = 0
			PH_GenericDmg(hp,leftovers)
		elseif alphaMod.data.run.PH_MaxBoneHP == 0 then
			PH_activeMove(true)
		end
		if (dmg+hp) > 0 then
			PH_animateDMGTaken(dmg+hp,1,1,1,1,false) --hp es negativo
		end
	else
		alphaMod.data.run.PH_BoneHP = alphaMod.data.run.PH_BoneHP - dmg
		local hp = 0
		if alphaMod.data.run.PH_BoneHP < 0 then --Más daño que vida
			hp = alphaMod.data.run.PH_BoneHP
			alphaMod.data.run.PH_BoneHP = 0
			PH_BoneDmg(math.abs(hp),leftovers) --Recursividad (Solo se ejecutará 1 vez)
		end
		alphaMod.data.run.PH_BoneHPProportion = PH_BoneHPProportion()
		if (dmg+hp) > 0 then
			PH_animateDMGTaken(dmg+hp,(230/255),(1/255),0,1,false) --hp es negativo
		end
	end
end

local function PH_BlueDmg(dmg,leftovers)
	alphaMod.data.run.PH_BlueHP = alphaMod.data.run.PH_BlueHP - dmg
	local hp = 0
	if alphaMod.data.run.PH_BlueHP < 0 then 
		hp = alphaMod.data.run.PH_BlueHP
		alphaMod.data.run.PH_BlueHP = 0
		PH_GenericDmg(hp,leftovers)
	elseif alphaMod.data.run.PH_BlueHP == 0 then
		PH_activeMove(true)
	end
	if (dmg+hp) > 0 then
		PH_animateDMGTaken(dmg+hp,(80/255),(100/255),(149/255),1,false) --hp es negativo
	end
end

local function PH_BlackDmg(dmg,leftovers)
	alphaMod.data.run.PH_BlackHP = alphaMod.data.run.PH_BlackHP - dmg
	local hp = 0
	if alphaMod.data.run.PH_BlackHP < 0 then 
		hp = alphaMod.data.run.PH_BlackHP
		alphaMod.data.run.PH_BlackHP = 0
		PH_GenericDmg(hp,leftovers)
	elseif alphaMod.data.run.PH_BlackHP == 0 then
		PH_activeMove(true)
	end
	if (dmg+hp) > 0 then
		PH_animateDMGTaken(dmg+hp,(48/255),(48/255),(48/255),1,false) --hp es negativo
	end
end

local function PH_ChemJarDmg1(dmg,leftovers)
	alphaMod.data.run.PH_ChemJar1HP = alphaMod.data.run.PH_ChemJar1HP - dmg
	local hp = 0
	if alphaMod.data.run.PH_ChemJar1HP < 0 then 
		hp = alphaMod.data.run.PH_ChemJar1HP
		alphaMod.data.run.PH_ChemJar1HP = 0
		if leftovers then
			alphaMod.data.run.PH_ChemJarHPIsEmpty = true
		end
		PH_GenericDmg(hp,leftovers)
	elseif alphaMod.data.run.PH_ChemJar1HP == 0 then
		PH_activeMove(true)
		if leftovers then
			alphaMod.data.run.PH_ChemJarHPIsEmpty = true
		end
	end
	if (dmg+hp) > 0 then
		PH_animateDMGTaken(dmg+hp,PH_tChemColors[alphaMod.data.run.PH_ChemJar1T][1],PH_tChemColors[alphaMod.data.run.PH_ChemJar1T][2],PH_tChemColors[alphaMod.data.run.PH_ChemJar1T][3],1,false) --hp es negativo
	end
end

local function PH_ChemJarDmg2(dmg,leftovers)
	alphaMod.data.run.PH_ChemJar2HP = alphaMod.data.run.PH_ChemJar2HP - dmg
	local hp = 0
	if alphaMod.data.run.PH_ChemJar2HP < 0 then 
		hp = alphaMod.data.run.PH_ChemJar2HP
		alphaMod.data.run.PH_ChemJar2HP = 0
		PH_GenericDmg(hp,leftovers)
	elseif alphaMod.data.run.PH_ChemJar2HP == 0 then
		PH_activeMove(true)
	end
	if (dmg+hp) > 0 then
		PH_animateDMGTaken(dmg+hp,PH_tChemColors[alphaMod.data.run.PH_ChemJar2T][1],PH_tChemColors[alphaMod.data.run.PH_ChemJar2T][2],PH_tChemColors[alphaMod.data.run.PH_ChemJar2T][3],1,false) --hp es negativo
	end
end

local function PH_ChemJarDmg3(dmg,leftovers)
	alphaMod.data.run.PH_ChemJar3HP = alphaMod.data.run.PH_ChemJar3HP - dmg
	local hp = 0
	if alphaMod.data.run.PH_ChemJar3HP < 0 then 
		hp = alphaMod.data.run.PH_ChemJar3HP
		alphaMod.data.run.PH_ChemJar3HP = 0
		PH_GenericDmg(hp,leftovers)
	elseif alphaMod.data.run.PH_ChemJar3HP == 0 then
		PH_activeMove(true)
	end
	if (dmg+hp) > 0 then
		PH_animateDMGTaken(dmg+hp,PH_tChemColors[alphaMod.data.run.PH_ChemJar3T][1],PH_tChemColors[alphaMod.data.run.PH_ChemJar3T][2],PH_tChemColors[alphaMod.data.run.PH_ChemJar3T][3],1,false) --hp es negativo
	end
end

-- TODO : Unificar estas funciones copypasteadas

--[[ Iconos coste items en los devil deals
	TODO:
		Testear más casos
		...
]]


--[[ 	Se pondrán ambos precios debajo de cada item, el de vida roja y el de vida azul,
		al ponerse encima del item se reducirá la cantidad de vida según la barra de vida
		activa, ambos precios irán bajando a medida que se paga. El coste de la vida azul siempre
		será 1.5 veces el coste del item de vida roja.
		Solo se podrá coger el item una vez pagados uno de los dos precios]]

local PH_tDDSprites = {}
local PH_tDDSpritesPos = {}
local PH_DDIsTongueUpdated = false
local PH_tDDCostAnimsRed = {
	[0] = "0R",
	[1] = "1R",
	[2] = "2R",
	[3] = "3R",
	[4] = "4R",
	[5] = "5R",
	[6] = "6R",
	[7] = "7R",
	[8] = "8R",
	[9] = "9R",
	[10] = "HR"
}
local PH_tDDCostAnimsBlue = {
	[0] = "0A",
	[1] = "1A",
	[2] = "2A",
	[3] = "3A",
	[4] = "4A",
	[5] = "5A",
	[6] = "6A",
	[7] = "7A",
	[8] = "8A",
	[9] = "9A",
	[10] = "HA"
}

local function PH_DDAddAnimsToTableFromNum(x,red,i)
	local s = Sprite()
	s:Load("Devil item.anm2",true)
	local pos = x%10
	x = (x - pos)/10
	if red then
		s:Play(PH_tDDCostAnimsRed[pos],true)
		table.insert(PH_tDDSprites[i][1],s)
	else
		s:Play(PH_tDDCostAnimsBlue[pos],true)
		table.insert(PH_tDDSprites[i][2],s)
	end
	if x == 0 then
		local s2 = Sprite()
		s2:Load("Devil item.anm2",true)
		if red then
			s2:Play(PH_tDDCostAnimsRed[10],true)
			table.insert(PH_tDDSprites[i][1],s2)
		else
			s2:Play(PH_tDDCostAnimsBlue[10],true)
			table.insert(PH_tDDSprites[i][2],s2)
		end
	else
		PH_DDAddAnimsToTableFromNum(x,red,i)
	end
end

local function PH_reposDDPriceSprites()
	for i,v in ipairs(AlphaAPI.entities.friendly) do
		if (v.Type == 5) and (v.Variant == 100) and v:ToPickup():IsShopItem() then
			PH_tDDSpritesPos[v.SubType] = AlphaAPI.GAME_STATE.ROOM:WorldToScreenPosition(v.Position)
		end
	end
end

function ABppmod:PH_didDDTongue(player)
	if not PH_DDIsTongueUpdated then
		if AlphaAPI.GAME_STATE.ROOM:GetType() == RoomType.ROOM_DEVIL then
			if player:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then --Nuevo item
				ABppmod:PH_loadDDPriceSprites()
				PH_DDIsTongueUpdated = true
			end
		end
	end
end

function ABppmod:PH_didDDItemChange(item)
	if AlphaAPI.GAME_STATE.ROOM:GetType() == RoomType.ROOM_DEVIL then
		if PH_tDDSprites[item.SubType] == nil then --Nuevo item
			ABppmod:PH_loadDDPriceSprites()
		end
	end
end

function ABppmod:PH_loadDDPriceSprites()
	PH_DDIsTongueUpdated = false
	PH_tDDSprites = {}
	PH_tDDSpritesPos = {}
	if AlphaAPI.GAME_STATE.ROOM:GetType() == RoomType.ROOM_DEVIL then
		for i,v in ipairs(AlphaAPI.entities.friendly) do
			if (v.Type == 5) and (v.Variant == 100) and v:ToPickup():IsShopItem() then
				local RedHPCost = PH_tDevilItemCosts[v.SubType]
				if RedHPCost == nil then RedHPCost = 10 end -- Caso por defecto para chaos
				if AlphaAPI.GAME_STATE.PLAYERS[1]:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
					RedHPCost = math.ceil(RedHPCost/1.5)
				end
				local BlueHPCost = math.floor(RedHPCost * 1.5)
				PH_tDDSprites[v.SubType] = {[1]={},[2]={}}
				PH_tDDSpritesPos[v.SubType] = AlphaAPI.GAME_STATE.ROOM:WorldToScreenPosition(v.Position)
				PH_DDAddAnimsToTableFromNum(RedHPCost,true,v.SubType)
				PH_DDAddAnimsToTableFromNum(BlueHPCost,false,v.SubType)
			end
		end
	end
end

function ABppmod:PH_renderDevilDealCost()
	v0 = Vector(0,0)
	for i,v in pairs(PH_tDDSprites) do  -- i : Num item
		for i2,v2 in pairs(v) do		-- i2 : 1 -> Rojo , 2 -> Azul 
			for i3,v3 in pairs(v2) do	-- i3 : Num Sprite
				if #v2 == i3 then -- El último elemento (<3)
					if #v2 == 2 then -- Coste 9 o menor,
						v3:Render(Vector(PH_tDDSpritesPos[i].X+i3*4,PH_tDDSpritesPos[i].Y+16*i2),v0,v0)
					else -- >10
						v3:Render(Vector(PH_tDDSpritesPos[i].X+i3*6,PH_tDDSpritesPos[i].Y+16*i2),v0,v0)
					end
				else
					if #v2 == 2 then -- Coste 9 o menor
						v3:Render(Vector(PH_tDDSpritesPos[i].X+12-i3*12,PH_tDDSpritesPos[i].Y+16*i2),v0,v0)
					else -- >10
						v3:Render(Vector(PH_tDDSpritesPos[i].X+20-i3*12,PH_tDDSpritesPos[i].Y+16*i2),v0,v0)
					end
				end
			end
		end
	end
	if SCREEN_SIZE ~= AlphaAPI.GAME_STATE.ROOM:GetRenderSurfaceTopLeft()*2 + Vector(442,286) then --La pantalla cambió de tamaño
		PH_reposDDPriceSprites()
		SCREEN_SIZE = AlphaAPI.GAME_STATE.ROOM:GetRenderSurfaceTopLeft()*2 + Vector(442,286)
	end
end	

function ABppmod:PH_DevilDealDMG(pickup,collider,low)
	if AlphaAPI.GAME_STATE.ROOM:GetType() == RoomType.ROOM_DEVIL then
		if collider.Type == EntityType.ENTITY_PLAYER then
			if pickup:IsShopItem() then
				if alphaMod.data.run.PH_activeBar == 1 then
					local cost = 10 --default
					if PH_tDevilItemCosts[pickup.SubType] ~= nil then
						cost = PH_tDevilItemCosts[pickup.SubType]
						if AlphaAPI.GAME_STATE.PLAYERS[1]:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
							cost = math.ceil(cost/1.5)
						end
					end
					if cost > alphaMod.data.run.PH_MaxRedHP then
						local bluecost = math.floor(1.5*(cost - alphaMod.data.run.PH_MaxRedHP))
						if bluecost > alphaMod.data.run.PH_BlueHP then
							return true -- no hay suficiente
						else
							PH_animateDMGTaken(alphaMod.data.run.PH_MaxRedHP,(230/255),(1/255),0,2,false)
							PH_animateDMGTaken(bluecost,(80/255),(100/255),(149/255),2,false)
							alphaMod.data.run.PH_RedHP = 0
							alphaMod.data.run.PH_BlueHP = alphaMod.data.run.PH_BlueHP - bluecost
							alphaMod.data.run.PH_MaxRedHP = 0
							alphaMod.data.run.PH_activeBar = 2
						end
					else
						PH_animateDMGTaken(cost,(230/255),(1/255),0,2,false)
						alphaMod.data.run.PH_MaxRedHP = alphaMod.data.run.PH_MaxRedHP - cost
						if alphaMod.data.run.PH_RedHP > alphaMod.data.run.PH_MaxRedHP then
							alphaMod.data.run.PH_RedHP = alphaMod.data.run.PH_MaxRedHP
						end
					end
				elseif alphaMod.data.run.PH_activeBar == 2 then
					local cost = 15 --default
					if PH_tDevilItemCosts[pickup.SubType] ~= nil then
						cost = math.floor(PH_tDevilItemCosts[pickup.SubType]*1.5)
					end
					if AlphaAPI.GAME_STATE.PLAYERS[1]:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
						cost = math.ceil(cost/1.5)
					end
					if cost > alphaMod.data.run.PH_BlueHP then
						local redcost = math.ceil((cost - alphaMod.data.run.PH_BlueHP)/1.5)
						if redcost > alphaMod.data.run.PH_MaxRedHP then
							return true -- no hay suficiente
						else
							PH_animateDMGTaken(redcost,(230/255),(1/255),0,2,false)
							PH_animateDMGTaken(alphaMod.data.run.PH_BlueHP,(80/255),(100/255),(149/255),2,false)
							alphaMod.data.run.PH_BlueHP = 0
							alphaMod.data.run.PH_MaxRedHP = alphaMod.data.run.PH_MaxRedHP - redcost
							if alphaMod.data.run.PH_RedHP > alphaMod.data.run.PH_MaxRedHP then
								alphaMod.data.run.PH_RedHP = alphaMod.data.run.PH_MaxRedHP
							end
							alphaMod.data.run.PH_activeBar = 1
						end
					else
						PH_animateDMGTaken(cost,(230/255),(1/255),0,2,false)
						alphaMod.data.run.PH_BlueHP = alphaMod.data.run.PH_BlueHP - cost
					end
				else --No se puede pagar con vida negra, de hueso o del chemjar
					return true --Ignorar el item
				end
				-- Solo se llega aquí si no se returneó (Se compró el item)
				AlphaAPI.GAME_STATE.PLAYERS[1]:AddMaxHearts(24,true) -- Para evitar muertes por detrás
				PH_tDDSprites[pickup.SubType] = nil
				PH_tDDSpritesPos[pickup.SubType] = nil
				alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.PH_renderDevilDealCost)	
ABppmod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ABppmod.PH_DevilDealDMG, PickupVariant.PICKUP_COLLECTIBLE)
ABppmod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ABppmod.PH_loadDDPriceSprites)
ABppmod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ABppmod.PH_didDDItemChange)
ABppmod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, ABppmod.PH_didDDTongue)


PH_tDMGFuncs = { --Declarada antes, inicializada ahora
	[1] = function(dmg,leftovers) PH_RedDmg(dmg,leftovers) end,
	[2] = function(dmg,leftovers) PH_BlueDmg(dmg,leftovers) end,
	[3] = function(dmg,leftovers) PH_BlackDmg(dmg,leftovers) end,
	[4] = function(dmg,leftovers) PH_BoneDmg(dmg,leftovers) end,
	[5] = function(dmg,leftovers) PH_ChemJarDmg1(dmg,leftovers) end,
	[6] = function(dmg,leftovers) PH_ChemJarDmg2(dmg,leftovers) end,
	[7] = function(dmg,leftovers) PH_ChemJarDmg3(dmg,leftovers) end
}

local function PH_ReduceRealHP(RealDMG)
	PH_tDMGFuncs[alphaMod.data.run.PH_activeBar](RealDMG,false)
end

function ABppmod:PH_DamageTaken(entity, dmgAmount, dmgFlag, source, dmgCountdownFrames)
	if dmgFlag & DamageFlag.DAMAGE_FAKE == 0 then
		if entity.FrameCount >= PH_FrameDMGTaken + PH_invulFrames then 
			local RealDmg
			local halveFrames = false
			local Ezcemas = false
			local SunBurn = false
			
			-- TODO : Entablar este anidamiento de ifelses
			local sourceRef = source
			source = AlphaAPI.getEntityFromRef(source)
			--if source ~= nil then
			if dmgFlag == 0 then -- Contacto / Projectil
				SunBurn = true
				if source.Type == 9 then -- Projectil
					SunBurn = false
					RealDmg = PH_DamageTaken_Projectile(source) 
				elseif source:ToNPC():IsBoss() then --Contacto Boss
					RealDmg = PH_DamageTaken_Boss(source)
				else --Contacto regular
					RealDmg = PH_DamageTaken_Regular(source)
				end	
			elseif dmgFlag & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE then
				RealDmg = 8
			elseif dmgFlag & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
				RealDmg = PH_dmgExplosion(source,entity)
			elseif dmgFlag & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER then
				RealDmg = PH_dmgLaser(source,entity)
				halveFrames = true
			elseif dmgFlag & DamageFlag.DAMAGE_ACID == DamageFlag.DAMAGE_ACID then
				RealDmg = 1
				Ezcemas = true
				halveFrames = true
			elseif dmgFlag & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS then
				RealDmg = 5
			elseif dmgFlag & DamageFlag.DAMAGE_SPIKES == DamageFlag.DAMAGE_SPIKES then
				RealDmg = 10
				Ezcemas = true
			elseif dmgFlag & DamageFlag.DAMAGE_POOP == DamageFlag.DAMAGE_POOP then
				RealDmg = 7
				Ezcemas = true
			elseif dmgFlag & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT then
				RealDmg = PH_dmgBasedOnDistance(source,18)
			elseif dmgFlag & DamageFlag.DAMAGE_CURSED_DOOR == DamageFlag.DAMAGE_CURSED_DOOR then
				RealDmg = 5
				Ezcemas = true
			elseif dmgFlag & DamageFlag.DAMAGE_CHEST == DamageFlag.DAMAGE_CHEST then
				RealDmg = 5
				Ezcemas = true 
			end
			--end
			if RealDmg == nil then
				RealDmg = 5 --Default
			end
			
			if (AlphaAPI.GAME_STATE.PLAYERS[1]:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)) 
				or AlphaAPI.GAME_STATE.PLAYERS[1]:HasCollectible(Isaac.GetItemIdByName("The Wafer")) then
				RealDmg = math.ceil(RealDmg / 2)
			end	
			if (AlphaAPI.GAME_STATE.LEVEL:GetStage() >= 7) then -- Womb>>
				RealDmg = math.ceil(RealDmg * 1.5)
			end
			if entity:ToPlayer():HasCollectible(Isaac.GetItemIdByName("Ezcemas")) then
				if Ezcemas then RealDmg = math.ceil(RealDmg * 1.5) end
			end
			if entity:ToPlayer():HasCollectible(Isaac.GetItemIdByName("SunBurn")) then
				if SunBurn then RealDmg = math.ceil(RealDmg * 1.5) end
			end
			
			-- 5 dmg = 30 frames
			-- 10 dmg = 60 frames
			-- 2 dmg = 12 frames
			
			-- Los frames de invul dependerán de cuanto daño nos hayan hecho
			
			--TODO : Invul frames animation
				-- TODO : Stop anim Creep/Laser
				-- TODO : Stop sound Creep/Laser
		
			PH_invulFrames = RealDmg * 6 -- RealDmg / 5 * 30
			if entity:ToPlayer():HasTrinket(TrinketType.TRINKET_BLIND_RAGE) then
				if entity:ToPlayer():GetActiveItem() == CollectibleType.COLLECTIBLE_MOMS_BOX then
					PH_invulFrames = PH_invulFrames * 4
				else
					PH_invulFrames = PH_invulFrames * 2
				end
			end
			if halveFrames then PH_invulFrames = math.ceil(PH_invulFrames / 2) end
			PH_FrameDMGTaken = entity.FrameCount
			PH_ReduceRealHP(RealDmg)
			entity:TakeDamage(0,DamageFlag.DAMAGE_FAKE ,sourceRef,30)
			PH_doInv = true
		end
		return false -- El daño se anula y se envia uno falso
	end	
end

ABppmod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ABppmod.PH_DamageTaken, EntityType.ENTITY_PLAYER)
ABppmod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, ABppmod.PH_blinking)

local function PH_DeletAfterGrab(h)
	h:GetData().PH_Collected = true
	h:ToPickup():PlayPickupSound()
	h:GetSprite():Play("Collect", true)
	h.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	h.Velocity = Vector(0,0)
	h.Friction = 0
end

local function PH_GrabGoldenHeart(heart,player,value)
	if alphaMod.data.run.PH_EternalHP then
		local TotHp = (alphaMod.data.run.PH_MaxRedHP + alphaMod.data.run.PH_BlueHP + alphaMod.data.run.PH_BlackHP + alphaMod.data.run.PH_MaxBoneHP)
		value = 10
		if TotHp >= 150 then
			return true
		elseif TotHp >= 141 then
			value = (150 - TotHp)
		end
		alphaMod.data.run.PH_MaxRedHP = alphaMod.data.run.PH_MaxRedHP + value
		alphaMod.data.run.PH_EternalHP = false
		PH_animateDMGTaken(value,0,1,0,1,true)
		PH_DeletAfterGrab(heart)
		alphaMod.data.run.PH_BoneHPProportion = PH_BoneHPProportion()
		--TODO : Animation
	else
		alphaMod.data.run.PH_EternalHP = true
		PH_DeletAfterGrab(heart)
	end
end

local function PH_GrabEternalHeart(heart,player,value)
	if alphaMod.data.run.PH_EternalHP then
		local TotHp = (alphaMod.data.run.PH_MaxRedHP + alphaMod.data.run.PH_BlueHP + alphaMod.data.run.PH_BlackHP + alphaMod.data.run.PH_MaxBoneHP)
		value = 10
		if TotHp >= 150 then
			return true
		elseif TotHp >= 141 then
			value = (150 - TotHp)
		end
		alphaMod.data.run.PH_MaxRedHP = alphaMod.data.run.PH_MaxRedHP + value
		alphaMod.data.run.PH_EternalHP = false
		PH_animateDMGTaken(value,0,1,0,1,true)
		PH_DeletAfterGrab(heart)
		alphaMod.data.run.PH_BoneHPProportion = PH_BoneHPProportion()
		--TODO : Animation
	else
		alphaMod.data.run.PH_EternalHP = true
		PH_DeletAfterGrab(heart)
	end
end

local function PH_GrabGenericHeart(heart,player,value) -- Soul , black , bone
	local TotHp = (alphaMod.data.run.PH_MaxRedHP + alphaMod.data.run.PH_BlueHP + alphaMod.data.run.PH_BlackHP + alphaMod.data.run.PH_MaxBoneHP)
	if TotHp >= 150 then
		return true
	elseif TotHp >= 141 then
		value = (150 - TotHp)
	end
	if heart.SubType == HeartSubType.HEART_BLACK then
		alphaMod.data.run.PH_BlackHP = alphaMod.data.run.PH_BlackHP + value
	elseif heart.SubType == HeartSubType.HEART_BONE then
		alphaMod.data.run.PH_MaxBoneHP = alphaMod.data.run.PH_MaxBoneHP + value
		alphaMod.data.run.PH_BoneHPProportion = PH_BoneHPProportion()
	else --Soul / Half soul
		alphaMod.data.run.PH_BlueHP = alphaMod.data.run.PH_BlueHP + value
	end		
	PH_animateDMGTaken(value,0,1,0,1,true)
	PH_DeletAfterGrab(heart)
end

local function PH_GrabRedHeart(heart,player,value) end

local function PH_GrabRedBoneHeart(heart,player,value,maxred)
	if alphaMod.data.run.PH_BoneHP == alphaMod.data.run.PH_MaxBoneHP then
		if maxred then
			return true
		else
			alphaMod.data.run.PH_activeBar = 1
			PH_GrabRedHeart(heart,player,value)
			alphaMod.data.run.PH_activeBar = 4
		end
	else
		alphaMod.data.run.PH_BoneHP = alphaMod.data.run.PH_BoneHP + value
		if alphaMod.data.run.PH_BoneHP > alphaMod.data.run.PH_MaxBoneHP then
			value = value - (alphaMod.data.run.PH_BoneHP - alphaMod.data.run.PH_MaxBoneHP)
			PH_animateDMGTaken(value,0,1,0,1,true)
			alphaMod.data.run.PH_BoneHP = alphaMod.data.run.PH_MaxBoneHP
		end
		alphaMod.data.run.PH_activeBar = 1
		PH_GrabRedHeart(heart,player,value)
		alphaMod.data.run.PH_activeBar = 4
		alphaMod.data.run.PH_BoneHPProportion = PH_BoneHPProportion()
		PH_DeletAfterGrab(heart)
	end
end

function PH_GrabRedHeart(heart,player,value)
	if alphaMod.data.run.PH_activeBar == 1 then
		if alphaMod.data.run.PH_RedHP == alphaMod.data.run.PH_MaxRedHP then
			PH_GrabRedBoneHeart(heart,player,value,true)
		else
			alphaMod.data.run.PH_RedHP = alphaMod.data.run.PH_RedHP + value
			if alphaMod.data.run.PH_RedHP > alphaMod.data.run.PH_MaxRedHP then
				value = value - (alphaMod.data.run.PH_RedHP - alphaMod.data.run.PH_MaxRedHP)
				alphaMod.data.run.PH_RedHP = alphaMod.data.run.PH_MaxRedHP
				PH_GrabRedBoneHeart(heart,player,value,true)
			end
			PH_animateDMGTaken(value,0,1,0,1,true)
			alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
			PH_DeletAfterGrab(heart)
		end
	elseif alphaMod.data.run.PH_activeBar == 4 then
		PH_GrabRedBoneHeart(heart,player,value,false)
	else
		return true
	end
end

local PH_HeartFunc = {
	[HeartSubType.HEART_FULL] = function(heart,collider,hp) PH_GrabRedHeart(heart,collider,10) end,
	[HeartSubType.HEART_HALF] = function(heart,collider,hp) PH_GrabRedHeart(heart,collider,5) end,
	[HeartSubType.HEART_SOUL] = function(heart,collider,hp) PH_GrabGenericHeart(heart,collider,10) end,
	[HeartSubType.HEART_HALF_SOUL] = function(heart,collider,hp) PH_GrabGenericHeart(heart,collider,5) end,
	[HeartSubType.HEART_ETERNAL] = function(heart,collider,hp) PH_GrabEternalHeart(heart,collider,0) end,		--TODO
	[HeartSubType.HEART_GOLDEN] = function(heart,collider,hp) PH_GrabGoldenHeart(heart,collider,0) end,			--TODO
	[HeartSubType.HEART_DOUBLEPACK] = function(heart,collider,hp) PH_GrabRedHeart(heart,collider,20) end,
	[HeartSubType.HEART_BLACK] = function(heart,collider,hp) PH_GrabGenericHeart(heart,collider,10) end,
	[HeartSubType.HEART_SCARED] = function(heart,collider,hp) PH_GrabRedHeart(heart,collider,10) end,
	[HeartSubType.HEART_BONE] = function(heart,collider,hp) PH_GrabGenericHeart(heart,collider,10) end
}

function ABppmod:PH_GrabHeart(heart,collider,low)
	if collider.Type == EntityType.ENTITY_PLAYER then
		if not heart:GetData().PH_Collected then
			if heart.SubType == HeartSubType.HEART_BLENDED then
				if alphaMod.data.run.PH_MaxRedHP == alphaMod.data.run.PH_RedHP then
					PH_HeartFunc[HeartSubType.HEART_SOUL](heart,collider,10)
				else
					PH_HeartFunc[HeartSubType.HEART_FULL](heart,collider,10)
				end
			else
				local hp = 0
				PH_HeartFunc[heart.SubType](heart,collider,hp)
			end
		end
	end
end

function ABppmod:PH_RemoveHeart(h)
	if h:GetData().PH_Collected then
		if h:GetSprite():IsFinished("Collect") then
			h:Remove()
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ABppmod.PH_RemoveHeart, PickupVariant.PICKUP_HEART)
ABppmod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ABppmod.PH_GrabHeart, PickupVariant.PICKUP_HEART)

------------------------------------------------------------------------

--TODO : 
--		: Reducir operaciones en la función showHPBars (MC_POST_RENDER) : Hay muchas cosas que solo deberían cambiar en un momento dado
--			(Como cuando le cambia la vida al player, no todos los frames)
--		: Sprite():Stop y cleanear
--		: Perder Golden con daño
--		: Eternal -> 10 Vida roja al cambiar de nivel o coger otro -> Animación
--		: No mostrar corazones de ChemJar en el HUD
--		: Que funcionen los efectos de ChemJar
--		: No hay vidas extras, estas se transforman en más vida (?)
--		: Lógica de mover cosas según el espacio disponible.
--		: Mostrar el daño recibido por cosas como Potato peeler
--		: Lógica de cambiar la vida al coger corazones/items

function ABppmod:PH_Restart(continue)
	if not continue then
		alphaMod.data.run.PH_RedHP = 27
		alphaMod.data.run.PH_MaxRedHP = 50
		alphaMod.data.run.PH_BlueHP = 5
		alphaMod.data.run.PH_BlackHP = 1
		alphaMod.data.run.PH_EternalHP = true
		alphaMod.data.run.PH_GoldenHP = 2
		alphaMod.data.run.PH_BoneHP = 5
		alphaMod.data.run.PH_MaxBoneHP = 10
		alphaMod.data.run.PH_activeBar = 1 -- 1 : Red, 2 : Blue, 3 : Black, 4 : Bone, 5 : CJar1, 6: CJar2, 7: CJar3
		alphaMod.data.run.PH_ChemJarHPIsEmpty = false
		--[[Type = {
			1, --Morado
			2, --Rojo Oscuro
			3, --Azul Oscuro
			4, --Color Salmón
			5, --Azul Claro
			6, --Gris
			7, --Naranja
			8, --Verde Oscuro
			9, --Amarillo Oscuro
			10 --Amarillo Claro
		}]]
		
		alphaMod.data.run.PH_ChemJar1HP = 1
		alphaMod.data.run.PH_ChemJar2HP = 2 
		alphaMod.data.run.PH_ChemJar3HP = 3
		alphaMod.data.run.PH_ChemJar1T = 5 
		alphaMod.data.run.PH_ChemJar2T = 4
		alphaMod.data.run.PH_ChemJar3T = 6
	end -- Se decidió no hacer tabla por que no se guardaba en save1.dat
	alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
	alphaMod.data.run.PH_BoneHPProportion = PH_BoneHPProportion()
	--[[if alphaMod.data.run.PH_ChemJarHPIsEmpty then
		alphaMod.data.run.PH_tChemJarHP = {
			[1] = Vector(0,0),
			[2] = Vector(0,0), 
			[3] = Vector(0,0)
		}
	end]]
	PH_TabFrame = 0
	PH_Fade = false
	PH_FrameDMGTaken = 0
	PH_invulFrames = 0
	PH_doInv = false
	PH_isOpaque = true
end

function ABppmod:PH_loadSprites(continue,anm2File)
	if anm2File == nil then
		anm2File = "gfx/ui/ui_bars.anm2"
	end
	for i=1,3 do --Las 4 barras
		PH_tHPBars[i]:Load(anm2File,true)
		PH_tHPBars[4][i]:Load(anm2File,true)
		PH_tHPBars[4][i]:Play("SmallHealthCube",true)
		PH_tActiveBars[i]:Load(anm2File,true)
		PH_tChemJarHPIcon[i]:Load(anm2File,true)
	end
	PH_tHPBars[5]:Load("gfx/ui/ui_bars.anm2",true)
	PH_tHPBars[5]:Play("BoneHealthBar",true)
	PH_tHPBars[1]:Play("RedHealthBar",true)
	PH_tHPBars[2]:Play("HealthCube",true)
	PH_tHPBars[3]:Play("HealthCube",true)
	PH_tActiveBars[1]:Play("ActiveRedBar",true)
	PH_tActiveBars[2]:Play("ActiveHealthCube",true)
	PH_tActiveBars[3]:Play("ActiveSmallCube",true)
	PH_tActiveBars[4]:Load(anm2File,true)
	PH_tActiveBars[4]:Play("ActiveBoneBar",true)
	
	for i=1,4 do --Iconos Vida no roja
		PH_tRed1HPBars[i]:Load(anm2File,true)
		PH_tRed1HPBoneBars[i]:Load(anm2File,true)
		PH_tRed1HPBars[i]:Play("1RedHP",true)
		PH_tRed1HPBoneBars[i]:Play("1RedBoneHP",true)
		if i~=2 then
			PH_tOtherHPIcons[i]:Load(anm2File,true)
		end
	end
	PH_tOtherHPIcons[1]:Play("EternalHP",true)
	PH_tOtherHPIcons[3]:Play("BlueHP",true)
	PH_tOtherHPIcons[4]:Play("BlackHP",true)
	for i=1, 8 do --Iconos 5HPRed y Golden
		PH_tRed5HPBars[i]:Load(anm2File,true)
		PH_tRed5HPBars[i]:Play("5RedHP",true)
		PH_tRed5HPBoneBars[i]:Load(anm2File,true)
		PH_tRed5HPBoneBars[i]:Play("5RedBoneHP",true)
		PH_tOtherHPIcons[2][i]:Load(anm2File,true)
		PH_tOtherHPIcons[2][i]:Play("GoldenHP",true)
	end
	PH_DmgHudFont:Load("font/pftempestasevencondensed.fnt")
end 

ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ABppmod.PH_loadSprites)
ABppmod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ABppmod.PH_Restart)

function PH_activeMove(left)
	local i = alphaMod.data.run.PH_activeBar
	if not left then
		if i == 7 then
			i = 1
		elseif i>=4 and alphaMod.data.run.PH_ChemJarHPIsEmpty then
			i = 1
		else
			i = i + 1
		end
	else
		if i == 1 then
			if alphaMod.data.run.PH_ChemJarHPIsEmpty then
				i = 4
			else
				i = 7
			end
		else
			i = i - 1
		end
	end
	if alphaMod.data.run.PH_activeBar ~= nil then
		alphaMod.data.run.PH_activeBar = i
		if (i == 1 and alphaMod.data.run.PH_RedHP == 0) or
		(i == 2 and alphaMod.data.run.PH_BlueHP == 0) or
		(i == 3 and alphaMod.data.run.PH_BlackHP == 0) or
		(i == 4 and alphaMod.data.run.PH_MaxBoneHP == 0) or
		(i == 5 and alphaMod.data.run.PH_ChemJar1HP == 0) or
		(i == 6 and alphaMod.data.run.PH_ChemJar2HP == 0) or
		(i == 7 and alphaMod.data.run.PH_ChemJar3HP == 0) then
			PH_activeMove(left)
		end
	end
end

local function PH_fadeSprites(Frame)
	local newColor = Color(1,1,1,1 - Frame / 9,0,0,0)
	for i=1,3 do --Las 4 barras
		PH_tHPBars[i].Color = newColor
		PH_tHPBars[4][i].Color = newColor
		PH_tActiveBars[i].Color = newColor
		PH_tChemJarHPIcon[i].Color = newColor
	end
	PH_tHPBars[5].Color = newColor
	for i=1,4 do --Iconos Vida no roja
		PH_tRed1HPBars[i].Color = newColor
		PH_tRed1HPBoneBars[i].Color = newColor
		if i~=2 then
			PH_tOtherHPIcons[i].Color = newColor
		end
	end
	for i=1, 8 do --Iconos 5HPRed y Golden
		PH_tRed5HPBars[i].Color = newColor
		PH_tOtherHPIcons[2][i].Color = newColor
		PH_tRed5HPBoneBars[i].Color = newColor
	end
	for i,v in pairs(PH_tDDSprites) do  -- i : Num item
		for i2,v2 in pairs(v) do		-- i2 : 1 -> Rojo , 2 -> Azul 
			for i3,v3 in pairs(v2) do	-- i3 : Num Sprite
				v3.Color = newColor
			end
		end
	end
end

local function PH_OffsetTextAux(Max,Base)
	if Max < 100 then
		if Max < 10 then
			return (10-Base) -- Base + 1 : 1
		else
			return (6-Base) -- Base + 1 : 2
		end
	else
		return(4-Base) -- Base + 1 : 3
	end
end

local function PH_OffsetText(Max,Base)
	if Base < 100 then
		if Base < 10 then
			return PH_OffsetTextAux(Max,0)
		else
			return PH_OffsetTextAux(Max,2)
		end
	else
		return PH_OffsetTextAux(Max,4)
	end
end

local function PH_ColorText(RHP) -- 100% : 0 rojo 1 verde -- 50% : 1 rojo 1 verde -- 0% : 1 rojo 0 verde
	local green = 0
	local red = 0
	if RHP >= 0.5 then
		green = 1
		red = math.abs(RHP-1) * 2		-- 2 = 1 * 2  | 2 = 0 * 2			0.75 ==> 0.5
	else
		red = 1
		green = RHP * 2					-- ~1 = 0.4999 * 2  | 0 = 0 * 2	0.25 ==> 0.5
	end
	return Vector(red,green)
end

local function PH_BlueBlackOffset(HP)
	if HP < 100 then
		if HP < 10 then
			return 0
		else
			return 3
		end
	else
		return 5
	end
end

--function ABppmod:PH_FadeAtNewRoom() end TODO : Posible opción de mod de auto fade al entrar en habitación con enemigos

function ABppmod:PH_showHPBars() -- La barra roja tiene 41 píxeles , la de hueso 44
	local player = AlphaAPI.GAME_STATE.PLAYERS[1]
	local v0 = Vector(0,0)
	
	local room = AlphaAPI.GAME_STATE.ROOM
	if not (room:GetType() == 5 and room:GetFrameCount() <= 1 and room:IsFirstVisit()) then -- Esto evita renderizar las cosas en el VS screen
		if alphaMod.data.run.PH_MaxRedHP > 0 then 
			PH_tHPBars[1]:Render(Vector(58,13),v0,v0) --Red
		end
		if alphaMod.data.run.PH_BlueHP > 0 then 
			PH_tHPBars[2]:Render(Vector(98,17),v0,v0) --Blue
		end
		if alphaMod.data.run.PH_BlackHP > 0 then 
			PH_tHPBars[3]:Render(Vector(122,17),v0,v0) --Black
		end
		
		if player:HasCollectible(Isaac.GetItemIdByName("Chemistry Jar")) or not -- Si el jugador tiene la jarra
			alphaMod.data.run.PH_ChemJarHPIsEmpty then -- O tiene algún corazón especial
			for i=1,3 do
				PH_tHPBars[4][i]:Render(Vector(60+i*17,40),v0,v0)
			end
		end
				
		if alphaMod.data.run.PH_RedHPProportion ~= nil then
			for i=1,alphaMod.data.run.PH_RedHPProportion.X do
				PH_tRed5HPBars[i]:Render(Vector(53+i*5,22),v0,v0)
				--55 22 es la pos del [], +2 píxeles de grosor
			end
			
			for i=1,alphaMod.data.run.PH_RedHPProportion.Y do
				PH_tRed1HPBars[i]:Render(Vector(58+5 * alphaMod.data.run.PH_RedHPProportion.X + (i-1),22),v0,v0)
				--Primero metemos los de 5, luego los de 1
			end
		end
			
		if alphaMod.data.run.PH_BoneHPProportion ~= nil then
			for i=1,alphaMod.data.run.PH_BoneHPProportion.X do
				PH_tRed5HPBoneBars[i]:Render(Vector(152+i*5,22),v0,v0)
				--55 22 es la pos del [], +2 píxeles de grosor
			end
			
			for i=1,alphaMod.data.run.PH_BoneHPProportion.Y do
				PH_tRed1HPBoneBars[i]:Render(Vector(158+5 * alphaMod.data.run.PH_BoneHPProportion.X + (i-1),22),v0,v0)
				--Primero metemos los de 5, luego los de 1
			end
		end
		
		if alphaMod.data.run.PH_BoneHP ~= nil then
			if alphaMod.data.run.PH_MaxBoneHP > 0 then
				PH_tHPBars[5]:Render(Vector(156,21),v0,v0)
			end
		end
		
		if alphaMod.data.run.PH_BlueHP ~= nil then
			if alphaMod.data.run.PH_BlueHP > 0 then
				PH_tOtherHPIcons[3]:Render(Vector(100,19),v0,v0)
			end
		end
		if alphaMod.data.run.PH_BlackHP ~= nil then
			if alphaMod.data.run.PH_BlackHP > 0 then
				PH_tOtherHPIcons[4]:Render(Vector(124,19),v0,v0)
			end
		end
		if alphaMod.data.run.PH_ChemJar1HP ~= nil then
			if alphaMod.data.run.PH_ChemJar1HP > 0 then
				local PlayString = PH_tChemJarPlayTypes[alphaMod.data.run.PH_ChemJar1T] 
				if not PH_tChemJarHPIcon[1]:IsPlaying(PlayString) then
						PH_tChemJarHPIcon[1]:Play(PlayString)
				end
				PH_tChemJarHPIcon[1]:Render(Vector(76,42),v0,v0)
			end
		end
		if alphaMod.data.run.PH_ChemJar2HP ~= nil then
			if alphaMod.data.run.PH_ChemJar2HP > 0 then
				local PlayString = PH_tChemJarPlayTypes[alphaMod.data.run.PH_ChemJar2T] 
				if not PH_tChemJarHPIcon[2]:IsPlaying(PlayString) then
						PH_tChemJarHPIcon[2]:Play(PlayString)
				end
				PH_tChemJarHPIcon[2]:Render(Vector(93,42),v0,v0)
			end
		end
		if alphaMod.data.run.PH_ChemJar3HP ~= nil then
			if alphaMod.data.run.PH_ChemJar3HP > 0 then
				local PlayString = PH_tChemJarPlayTypes[alphaMod.data.run.PH_ChemJar3T]
				if not PH_tChemJarHPIcon[3]:IsPlaying(PlayString) then
						PH_tChemJarHPIcon[3]:Play(PlayString)
				end
				PH_tChemJarHPIcon[3]:Render(Vector(110,42),v0,v0)
			end
		end		
		--[[for i=1, 3 do   
			if alphaMod.data.run.PH_tChemJarHP ~= nil then
				if alphaMod.data.run.PH_tChemJarHP[i].X > 0 then
					local PlayString = PH_tChemJarPlayTypes[alphaMod.data.run.PH_tChemJarHP[i].Y] 
					if not PH_tChemJarHPIcon[i]:IsPlaying(PlayString) then
						PH_tChemJarHPIcon[i]:Play(PlayString)
					end
					PH_tChemJarHPIcon[i]:Render(Vector(129+i*17,23),v0,v0)
				end
			end
		end]]
		
		if alphaMod.data.run.PH_GoldenHP ~= nil then
			local LineasRojas = alphaMod.data.run.PH_RedHPProportion.X * 5 + alphaMod.data.run.PH_RedHPProportion.Y
			local offset = 0
			if alphaMod.data.run.PH_EternalHP and LineasRojas > 38 then
				offset = 3 - (41 - LineasRojas)
			end
			for i=1, alphaMod.data.run.PH_GoldenHP do
				PH_tOtherHPIcons[2][i]:Render(Vector(53+LineasRojas-i*2-offset,24),v0,v0)
			end
		end
		if alphaMod.data.run.PH_EternalHP then
			PH_tOtherHPIcons[1]:Render(Vector(54,22),v0,v0)
		end
		
		if not AlphaAPI.GAME_STATE.GAME:IsPaused() then
			if Input.IsButtonTriggered(Keyboard.KEY_LEFT_SHIFT,0) then
				PH_activeMove(true) -- true : left
			end
			if Input.IsButtonTriggered(Keyboard.KEY_RIGHT_SHIFT,0) then
				PH_activeMove(false)
			end
			if Input.IsButtonTriggered(Keyboard.KEY_TAB,0) then
				PH_Fade = not(PH_Fade)
			end
		end
		
		if PH_Fade then
			if PH_TabFrame < 6 then
				PH_TabFrame = PH_TabFrame + 1
				PH_fadeSprites(PH_TabFrame)
			end
		else
			if PH_TabFrame > 0 then
				PH_TabFrame = PH_TabFrame - 1
				PH_fadeSprites(PH_TabFrame)
			end
		end
		
		
		if Input.IsButtonTriggered(Keyboard.KEY_LEFT_ALT,0) then 	--DEBUG
			alphaMod.data.run.PH_RedHP = alphaMod.data.run.PH_RedHP + 1
			alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
		end
		if Input.IsButtonTriggered(Keyboard.KEY_RIGHT_ALT,0) then
			alphaMod.data.run.PH_RedHP = alphaMod.data.run.PH_RedHP - 1
			alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
		end															
		if Input.IsButtonTriggered(Keyboard.KEY_LEFT_CONTROL,0) then
			alphaMod.data.run.PH_MaxRedHP = alphaMod.data.run.PH_MaxRedHP + 1
			alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
		end
		if Input.IsButtonTriggered(Keyboard.KEY_RIGHT_CONTROL,0) then
			alphaMod.data.run.PH_MaxRedHP = alphaMod.data.run.PH_MaxRedHP - 1
			alphaMod.data.run.PH_RedHPProportion = PH_RedHPProportion()
		end															
																	--FIN DEBUG
		if alphaMod.data.run.PH_activeBar ~= nil then
			local i = alphaMod.data.run.PH_activeBar
			if i==1 then
				PH_tActiveBars[1]:Render(Vector(63,14),v0,v0)
			elseif i==2 then
				PH_tActiveBars[2]:Render(Vector(99,17),v0,v0)
			elseif i==3 then
				PH_tActiveBars[2]:Render(Vector(123,17),v0,v0)
			elseif i==4 then
				PH_tActiveBars[4]:Render(Vector(153,16),v0,v0)
			elseif i>4 then
				PH_tActiveBars[3]:Render(Vector(60+(i-4)*17,44),v0,v0) 
			end
		end
		if alphaMod.data.run.PH_RedHP ~= nil then
			local RedHPText = tostring(alphaMod.data.run.PH_RedHP) .. " / " .. tostring(alphaMod.data.run.PH_MaxRedHP)
			local TotalHPText = tostring(alphaMod.data.run.PH_RedHP+alphaMod.data.run.PH_BlueHP+alphaMod.data.run.PH_BlackHP+
										alphaMod.data.run.PH_ChemJar1HP+alphaMod.data.run.PH_ChemJar2HP+alphaMod.data.run.PH_ChemJar3HP+
										alphaMod.data.run.PH_BoneHP) .. " / 150"
			local BoneHPText = tostring(alphaMod.data.run.PH_BoneHP) .. " / " .. tostring(alphaMod.data.run.PH_MaxBoneHP)
			local offsetB = PH_OffsetText(alphaMod.data.run.PH_MaxBoneHP,alphaMod.data.run.PH_BoneHP)
			local offset = PH_OffsetText(alphaMod.data.run.PH_MaxRedHP,alphaMod.data.run.PH_RedHP)
		
			local offset2 = PH_BlueBlackOffset(alphaMod.data.run.PH_BlueHP)
			local offset3 = PH_BlueBlackOffset(alphaMod.data.run.PH_BlackHP)
			local UnusedHP = 150 - (alphaMod.data.run.PH_MaxRedHP + alphaMod.data.run.PH_BlackHP + alphaMod.data.run.PH_BlueHP + alphaMod.data.run.PH_MaxBoneHP)
			local vRed = PH_ColorText(alphaMod.data.run.PH_RedHP / alphaMod.data.run.PH_MaxRedHP) --(red,green)
			local vBlue = PH_ColorText(alphaMod.data.run.PH_BlueHP / (UnusedHP + alphaMod.data.run.PH_BlueHP))
			local vBlack = PH_ColorText(alphaMod.data.run.PH_BlackHP / (UnusedHP + alphaMod.data.run.PH_BlackHP))
			local vChem1 = PH_ColorText(alphaMod.data.run.PH_ChemJar1HP/10)
			local vChem2 = PH_ColorText(alphaMod.data.run.PH_ChemJar2HP/10)
			local vChem3 = PH_ColorText(alphaMod.data.run.PH_ChemJar3HP/10)
			local vBone = PH_ColorText(alphaMod.data.run.PH_BoneHP / alphaMod.data.run.PH_MaxBoneHP)
		
			--[[PH_DmgHudFont:DrawString(UnusedHP,100,100,KColor(1,1,1,1,0,0,0),0,true)
			PH_DmgHudFont:DrawString(vBlue.X,100,120,KColor(1,1,1,1,0,0,0),0,true)
			PH_DmgHudFont:DrawString(vBlue.Y,100,140,KColor(1,1,1,1,0,0,0),0,true)]]
			if alphaMod.data.run.PH_MaxRedHP > 0 then 
				PH_DmgHudFont:DrawString(RedHPText,44+offset,7,KColor(vRed.X,vRed.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
			end
			PH_DmgHudFont:DrawString(TotalHPText,145,27,KColor(1,1,1, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
			if alphaMod.data.run.PH_BlueHP > 0 then 
				PH_DmgHudFont:DrawString(tostring(alphaMod.data.run.PH_BlueHP),99-offset2,6,KColor(vBlue.X,vBlue.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
			end
			if alphaMod.data.run.PH_BlackHP > 0 then 
				PH_DmgHudFont:DrawString(tostring(alphaMod.data.run.PH_BlackHP),123-offset3,6,KColor(vBlack.X,vBlack.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
			end
			if alphaMod.data.run.PH_MaxBoneHP > 0 then
				PH_DmgHudFont:DrawString(BoneHPText,143+offsetB,6,KColor(vBone.X,vBone.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
			end
			if player:HasCollectible(Isaac.GetItemIdByName("Chemistry Jar"))
				or not alphaMod.data.run.PH_ChemJarHPIsEmpty then
				if alphaMod.data.run.PH_ChemJar1HP == 10 then				
					PH_DmgHudFont:DrawString(tostring(math.ceil(alphaMod.data.run.PH_ChemJar1HP)),75,27,KColor(vChem1.X,vChem1.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
				elseif alphaMod.data.run.PH_ChemJar1HP > 0 then
					PH_DmgHudFont:DrawString(tostring(math.ceil(alphaMod.data.run.PH_ChemJar1HP)),75,27,KColor(vChem1.X,vChem1.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
				end
				if alphaMod.data.run.PH_ChemJar2HP == 10 then				
					PH_DmgHudFont:DrawString(tostring(math.ceil(alphaMod.data.run.PH_ChemJar2HP)),92,27,KColor(vChem2.X,vChem2.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
				elseif alphaMod.data.run.PH_ChemJar2HP > 0 then
					PH_DmgHudFont:DrawString(tostring(math.ceil(alphaMod.data.run.PH_ChemJar2HP)),92,27,KColor(vChem2.X,vChem2.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
				end
				if alphaMod.data.run.PH_ChemJar3HP == 10 then				
					PH_DmgHudFont:DrawString(tostring(math.ceil(alphaMod.data.run.PH_ChemJar3HP)),109,27,KColor(vChem3.X,vChem3.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
				elseif alphaMod.data.run.PH_ChemJar3HP > 0 then
					PH_DmgHudFont:DrawString(tostring(math.ceil(alphaMod.data.run.PH_ChemJar3HP)),109,27,KColor(vChem3.X,vChem3.Y,0, 1 - PH_TabFrame / 9 ,0,0,0),0,true)
				end
			end
		end
	end
end

ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.PH_showHPBars)

function ABppmod:debug_text()
	--Isaac.RenderText(PH_invulFrames,50,100,255,0,0,255)
	--Isaac.RenderText(PH_FrameDMGTaken,75,100,255,0,0,255)
	--Isaac.RenderText(AlphaAPI.GAME_STATE.PLAYERS[1].FrameCount,225,100,255,0,0,255)
	--if PH_isOpaque then 
	--	Isaac.RenderText("Yes",125,100,255,0,0,255)
	--else
	--	Isaac.RenderText("No",125,100,255,0,0,255)
	--end
	--local num = math.ceil((PH_invulFrames - AlphaAPI.GAME_STATE.PLAYERS[1].FrameCount + PH_FrameDMGTaken)/3)
	--Isaac.RenderText(num,150,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_RedHP,50,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_BlueHP,75,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_BlackHP,100,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_RedHPProportion.X,125,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_RedHPProportion.Y,150,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_BoneHPProportion.X,175,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_BoneHPProportion.Y,200,100,255,0,0,255)
	--Isaac.RenderText(alphaMod.data.run.PH_activeBar,175,100,255,0,0,255)
	--Isaac.RenderText(AlphaAPI.GAME_STATE.PLAYERS[1].Position.X,75,100,255,0,0,255)
	--Isaac.RenderText(AlphaAPI.GAME_STATE.PLAYERS[1].Position.Y,75,135,255,0,0,255)
end

ABppmod:AddCallback(ModCallbacks.MC_POST_RENDER, ABppmod.debug_text)

-------------------
--  API Init
-------------------
local START_FUNC = start

if AlphaAPI then START_FUNC()
else if not __alphaInit then
    __alphaInit={} end __alphaInit
[#__alphaInit+1]=START_FUNC end

local player = Isaac.GetPlayer(0) 
if player ~= nil then
	alphaMod:loadData()
end
