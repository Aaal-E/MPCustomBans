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


local function is_banned(card) 
	if card.config.center.set == "Joker" then 
		return MP.DECK.BANNED_JOKERS[card.config.center.key]
	end
	if card.config.center.set == "Tarot" or card.config.center.set == "Planet" or card.config.center.set == "Spectral" then 
		return MP.DECK.BANNED_CONSUMABLES[card.config.center.key]
	end
	if card.config.center.set == "Voucher" then 
		return MP.DECK.BANNED_VOUCHERS[card.config.center.key]
	end
	return false
end

function Card:ban_card()
	local card = self
	if card.config.center.set == "Joker" then 
		MP.DECK.BANNED_JOKERS[card.config.center.key] = true
	end
	if card.config.center.set == "Tarot" or card.config.center.set == "Planet" or card.config.center.set == "Spectral" then 
		MP.DECK.BANNED_CONSUMABLES[card.config.center.key] = true
	end
	if card.config.center.set == "Voucher" then 
		MP.DECK.BANNED_VOUCHERS[card.config.center.key] = true
	end
end

function Card:unban_card()
	local card = self
	if card.config.center.set == "Joker" then 
		MP.DECK.BANNED_JOKERS[card.config.center.key] = nil
	end
	if card.config.center.set == "Tarot" or card.config.center.set == "Planet" or card.config.center.set == "Spectral" then 
		MP.DECK.BANNED_CONSUMABLES[card.config.center.key] = nil
	end
	if card.config.center.set == "Voucher" then 
		MP.DECK.BANNED_VOUCHERS[card.config.center.key] = nil
	end
end

G.FUNCS.ban_card = function(e)
    local card = e.config.ref_table
    card:ban_card()
end

G.FUNCS.unban_card = function(e)
	local card = e.config.ref_table
	card:unban_card()
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
		    if card.area.config.type and (card.area.config.type == 'title' or card.area.config.type == 'voucher') and card.area.config.collection == true then
			    if is_banned(card) then
					card.debuff = false
					card:unban_card()
				else
					card.debuff = true
					card:ban_card()
				end
			end
		end
	end
}

--collection injection for UI
local ccref = SMODS.card_collection_UIBox
function SMODS.card_collection_UIBox(_pool, rows, args)
    local ret = ccref(_pool, rows, args)
	debuff_collection_page()
	return ret
end

local ccpref = G.FUNCS.option_cycle
function G.FUNCS.option_cycle(e)	
    local ret = ccpref(e)
	if e.config.ref_table.opt_callback == "SMODS_card_collection_page" then
		debuff_collection_page()
	end
	return ret
end


function debuff_collection_page() 
	if G.your_collection then
		for i = 1, #G.your_collection do
			for _, v in pairs(G.your_collection[i].cards) do
				if MP.DECK.BANNED_JOKERS[v.config.center_key] or MP.DECK.BANNED_CONSUMABLES[v.config.center_key] or MP.DECK.BANNED_VOUCHERS[v.config.center_key]then
					v.debuff = true
				end
			end
		end
	end
end

--code for a context button to ban cards, discarded since I couldn't figure out how to make it show up in the collection
--local use_and_sell_buttonsref = G.UIDEF.use_and_sell_buttons
--function G.UIDEF.use_and_sell_buttons(card)
--	local retval = use_and_sell_buttonsref(card)
--
--	if card.area and card.area.config.type == 'title' and card.ability.set == 'Joker' then
--		local ban =
--		{n=G.UIT.C, config={align = "cr"}, nodes={
--
--		  {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.RED, one_press = true, button = 'sell_card', func = 'can_ban_card'}, nodes={
--			{n=G.UIT.B, config = {w=0.1,h=0.6}},
--			{n=G.UIT.C, config={align = "tm"}, nodes={
--				{n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
--					{n=G.UIT.T, config={text = localize('b_ban'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
--				}}
--			}}
--		  }}
--		}}
--		retval.nodes[1].nodes[2].nodes = retval.nodes[1].nodes[2].nodes or {}
--		table.insert(retval.nodes[1].nodes[2].nodes, ban)
--		return retval
--	end
--
--	return retval
--end

end