-- ใช้ Tab เดียว
local MainTab = Window:CreateTab("Main", 4483362458)

-- =========================
-- Hot Set
-- =========================
MainTab:CreateButton({
	Name = "Set Relic (Parts 1-8)",
	Callback = function()
        fireItems({
            {"Relic Part #1", 70}, {"Relic Part #2", 15},
            {"Relic Part #3", 75}, {"Relic Part #4", 20},
            {"Relic Part #5", 30}, {"Relic Part #6", 25},
            {"Relic Part #7", 40}, {"Relic Part #8", 30},
        })
        notify('✅ Relic Set — ใส่ครบแล้ว')
  	end    
})

MainTab:CreateButton({
	Name = "Easter Egg×10000",
	Callback = function()
        fireItems({
            {"Easter Egg", 10000},  
        })
        notify('✅ Easter Egg×10000 — ใส่ครบแล้ว')
  	end    
})

-- =========================
-- Trade
-- =========================
MainTab:CreateButton({
	Name = "Set Rank",
	Callback = function()
        fireItems({
            {"Atomic Core", 2}, {"Blood Ring", 4}, {"Cursed Flesh", 2},
            {"Hōgyoku Fragment", 2}, {"Infinity Essence", 2}, {"Phantasm Core", 2},
            {"Slime Core", 3}, {"Soul Flame", 3}, {"Reiatsu Core", 4},
            {"Dark Ring", 5}, {"Dismantle Fang", 7}, {"Void Fragment", 5},
            {"Limitless Ring", 2}, {"Azure Heart", 2}, {"Evolution Fragment", 2},
            {"Path Fragment", 2}, {"Corrupt Crown", 3},
        })
        notify('✅ Rank — ใส่ครบแล้ว')
  	end    
})

MainTab:CreateButton({
	Name = "Set Madara",
	Callback = function()
        fireItems({
            {"Path Fragment", 3}, {"Eternal Core", 8}, {"Battle Sigil", 18}, {"Power Remnant", 15},
        })
        notify('✅ Madara — ใส่ครบแล้ว')
  	end    
})
