local _G = _G
local hotpot = _G.ClientHotpot
---@type PlaceManager
local placeManager = hotpot.load.PlaceManager()
---@class UIList
local c = {}

---@type BagGui
c.bag_gui = hotpot.load.BagGui()
---@type HudGui
c.hud_gui = hotpot.load.HudGui()
---@type GachaGui
c.gacha_gui = hotpot.load.GachaGui()
---@type TipsGui
c.tips_gui = hotpot.load.TipsGui()
---@type MergeGui
c.merge_gui = hotpot.load.MergeGui()
---@type TaskGui
c.task_gui = hotpot.load.TaskGui()
---@type RewardGui
c.reward_gui = hotpot.load.RewardGui()
---@type RebornGui
c.reborn_gui = hotpot.load.RebornGui()
---@type ShopGui
c.shop_gui = hotpot.load.ShopGui()
---@type DailyGui
c.daily_gui = hotpot.load.DailyGui()
---@type OnlineGui
c.online_gui = hotpot.load.OnlineGui()
---@type RelicsGui
c.relics_gui = hotpot.load.RelicsGui()
---@type SettingGui
c.setting_gui = hotpot.load.SettingGui()
---@type OpenBoxGui
c.open_box_gui = hotpot.load.OpenBoxGui()
---@type TeleportGui
c.teleport_gui = hotpot.load.TeleportGui()
---@type FreePetGui
c.free_pet_gui = hotpot.load.FreePetGui()
---@type BPGui
c.battle_pass_gui = hotpot.load.BPGui()
---@type MapShopGui
c.map_shop_gui = hotpot.load.MapShopGui()
---@type EternalGui
c.eternal_gui = hotpot.load.EternalGui()
---@type PartyGui
c.party_gui = hotpot.load.PartyGui()
---@type PartyOverGui
c.party_over_gui = hotpot.load.PartyOverGui()
---@type SureExitPartyGui
c.sure_exit_party_gui = hotpot.load.SureExitPartyGui()
---@type ForgeRelicsGui
c.forge_relics_gui = hotpot.load.ForgeRelicsGui()
---@type BuyPosionGui
c.buy_posion_gui = hotpot.load.BuyPosionGui()
---@type MapScrollShopGui
c.map_scroll_shop_gui = hotpot.load.MapScrollShopGui()
---@type RelicsSmelterGui
c.relics_smelter_gui = hotpot.load.RelicsSmelterGui()
---@type StatsGui
c.stats_gui = hotpot.load.StatsGui()
---@type HalloweenPackGui
c.halloween_pack_gui = hotpot.load.HalloweenPackGui()
---@type JoinDiscordGui
c.join_discord_gui = hotpot.load.JoinDiscordGui()
---@type NewPartyGui
c.new_party_gui = hotpot.load.NewPartyGui()
---@type TitleGui
c.title_gui = hotpot.load.TitleGui()
---@type SkillGui
c.skill_gui = hotpot.load.SkillGui()
---@type OpenSkillGui
c.open_skill_gui = hotpot.load.OpenSkillGui()
---@type MountGui
c.mount_gui = hotpot.load.MountGui()
---@type GuildGui
c.guild_gui = hotpot.load.GuildGui()
---@type NPCGui
c.npc_gui = hotpot.load.NPCGui()
---@type GuildForgeGui
c.guild_forge_gui = hotpot.load.GuildForgeGui()
---@type PKGui
c.pk_gui = hotpot.load.PKGui()
---@type NewGuideGui
c.new_guide_gui = hotpot.load.NewGuideGui()
---@type TransferGui
c.transfer_gui = hotpot.load.TransferGui()
---@type NewDailyGui
c.new_daily_gui = hotpot.load.NewDailyGui()
---@type PowerChangeGui
c.power_change_gui = hotpot.load.PowerChangeGui()
---@type GuildWarGui
c.guild_war_gui = hotpot.load.GuildWarGui()

if placeManager:GetIdByName('pvpsence') == game.PlaceId then
    ---@type PvpShopGui
    c.pvp_shop_gui = hotpot.load.PvpShopGui()
    ---@type PvpBuffGui
    c.pvp_buff_gui = hotpot.load.PvpBuffGui()
    ---@type DieGui
    c.die_gui = hotpot.load.DieGui()
end

if placeManager:GetIdByName('challengesence') == game.PlaceId then
    ---@type ChallengeGui
    c.challenge_gui = hotpot.load.ChallengeGui()
end

return c
