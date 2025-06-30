banned_jokers = {}

if SMODS.Mods["Multiplayer"] and SMODS.Mods["Multiplayer"].can_load then

MP = SMODS.Mods["Multiplayer"]

    

--if SMODS.Mods["Pokermon"] and SMODS.Mods["Pokermon"].can_load then
--    banned_jokers = {
--    "j_hanging_chad", 
--    "j_poke_rattata",
--    "j_poke_raticate",
--    "j_poke_snubbull",
--    "j_poke_granbull",
--    "j_poke_remoraid",
--    "j_poke_octillery",
--    "j_poke_bonsly",
--    "j_poke_sudowoodo",
--    "j_dusk",
--    }
--end

for k, v in pairs(banned_jokers) do
    MP.DECK.ban_card(v)
end

-- Multiplayer injections to force banned cards to actually be banned
local joinlobbyref = MP.ACTIONS.join_lobby
function MP.ACTIONS.join_lobby(code)
    G.FUNCS.lock_banned_cards()
	joinlobbyref(code)
end

local createlobbyref = MP.ACTIONS.create_lobby
function MP.ACTIONS.create_lobby(gamemode)
    G.FUNCS.lock_banned_cards()
	createlobbyref(gamemode)
end

local leavelobbyref = MP.ACTIONS.leave_lobby
function MP.ACTIONS.leave_lobby()
    G.FUNCS.unlock_banned_cards()
	leavelobbyref()
end

function G.FUNCS.lock_banned_cards()
    for cardid, v in pairs(MP.DECK.BANNED_JOKERS) do
        G.P_CENTERS[cardid].unlocked = false
    end
end

function G.FUNCS.unlock_banned_cards()
    for cardid, v in pairs(MP.DECK.BANNED_JOKERS) do
        G.P_CENTERS[cardid].unlocked = true
    end
end


--allow for a seperate banlist to be edited
function Card:ban_card()
	local cardid = self.config.center_key
    MP.DECK.ban_card(cardid)
    print("banned " .. cardid)
	table.insert(banned_jokers, cardid)
end

G.FUNCS.ban_card = function(e)
    local card = e.config.ref_table
    card:ban_card()
end

--button func
G.FUNCS.can_ban_card = function(e)
    e.config.button = 'ban_card'
end

SMODS.Keybind{
    key = 'bancard',
	key_pressed = 'delete',
	action = function(self)
	    if G.CONTROLLER.hovering.target.cost then
		    local card = G.CONTROLLER.hovering.target
		    if card.area.config.type and card.area.config.type == 'title' and card.area.config.collection == true then
			    card.debuff = true
			    card:ban_card()
			end
		end
	end
}



local use_and_sell_buttonsref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	local retval = use_and_sell_buttonsref(card)

	if card.area and card.area.config.type == 'title' and card.ability.set == 'Joker' then
		local ban =
		{n=G.UIT.C, config={align = "cr"}, nodes={

		  {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.RED, one_press = true, button = 'sell_card', func = 'can_ban_card'}, nodes={
			{n=G.UIT.B, config = {w=0.1,h=0.6}},
			{n=G.UIT.C, config={align = "tm"}, nodes={
				{n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
					{n=G.UIT.T, config={text = localize('b_ban'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
				}}
			}}
		  }}
		}}
		retval.nodes[1].nodes[2].nodes = retval.nodes[1].nodes[2].nodes or {}
		table.insert(retval.nodes[1].nodes[2].nodes, ban)
		return retval
	end

	return retval
end

end