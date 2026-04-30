-- ============================================================

-- 🛒 Apollo Shop | Auto Trade Script
-- 
-- 📌 สคริปต์นี้ใช้สำหรับเทรดไอเทมอัตโนมัติในเกม Roblox
-- 📌 ใช้ UI Library: Rayfield
-- 📌 ระบบเทรด: ง่าย (ไม่มีตรวจสอบ inventory)
-- ============================================================

-- 🔌 โหลด Rayfield UI Library จาก URL
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 🪟 สร้างหน้าต่างหลักของสคริปต์
local Window = Rayfield:CreateWindow({
   Name = "Apollo Shop",
   LoadingTitle = "Apollo Shop",
   LoadingSubtitle = "Item & Character Presets",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- ─────────────────────────────────────────────────────────────
-- 🔔 ฟังก์ชันแสดง Notification
-- ─────────────────────────────────────────────────────────────
local function notify(msg)
    Rayfield:Notify({
        Title = "Apollo Shop",
        Content = msg,
        Duration = 3,
        Image = 4483345998,
    })
end

-- ─────────────────────────────────────────────────────────────
-- 🔗 ฟังก์ชันเชื่อมต่อ Remote
-- ─────────────────────────────────────────────────────────────
local function getTradeRemote()
    return game:GetService("ReplicatedStorage")
        :WaitForChild("Remotes")
        :WaitForChild("TradeRemotes")
        :WaitForChild("AddItemToTrade")
end

-- ─────────────────────────────────────────────────────────────
-- 📦 ฟังก์ชันยิงของเข้า Trade
-- ─────────────────────────────────────────────────────────────
local function fireItems(items, setCount)
    local remote = getTradeRemote()
    local count = math.max(1, math.floor(tonumber(setCount) or 1))

    for _ = 1, count do
        for _, item in ipairs(items) do
            local ok = pcall(function()
                remote:FireServer("Items", item[1], item[2])
            end)
            if not ok then
                return false
            end
            task.wait(0.5)
        end
    end

    return true
end

local function trim(text)
    return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function lower(text)
    return trim(text):lower()
end

-- ─────────────────────────────────────────────────────────────
-- 📊 ข้อมูลสำหรับ Search
-- ─────────────────────────────────────────────────────────────
local Presets = {
    Item = {},
    Character = {},
}

local CurrentSetCount = 1

local function clampSetCount(value)
    value = tonumber(value) or 1
    value = math.floor(value)
    if value < 1 then value = 1 end
    if value > 100 then value = 100 end
    return value
end

local function setSetCount(value)
    CurrentSetCount = clampSetCount(value)
end

local function registerPreset(category, name, items, notifMsg)
    Presets[category][#Presets[category] + 1] = {
        name = name,
        items = items,
        notifMsg = notifMsg,
    }
end

-- inventory check removed; trade works exactly like before

local function addButton(tab, category, name, items, notifMsg)
    registerPreset(category, name, items, notifMsg)
    tab:CreateButton({
        Name = name,
        Callback = function()
            local ok = fireItems(items, CurrentSetCount)
            if ok == false then
                notify("ของไม่ครบ")
                return
            end

            notify(notifMsg or ('✅ '..name..' — ใส่ครบแล้ว') .. " x" .. CurrentSetCount)
        end
    })
end

local function searchPreset(category, query)
    query = lower(query)
    if query == "" then
        notify("⚠️ กรุณาพิมพ์คำค้นหา")
        return
    end

    local found = {}
    for _, preset in ipairs(Presets[category]) do
        if lower(preset.name):find(query, 1, true) then
            found[#found + 1] = preset
        end
    end

    if #found == 0 then
        notify("ไม่พบรายการที่ตรงกับ: " .. query)
        return
    end

    if #found == 1 then
        local preset = found[1]
        local ok = fireItems(preset.items, CurrentSetCount)
        if ok == false then
            notify("ของไม่ครบ")
            return
        end
        notify((preset.notifMsg or ('✅ '..preset.name..' — ใส่ครบแล้ว')) .. " x" .. CurrentSetCount)
        return
    end

    local names = {}
    for i = 1, math.min(#found, 5) do
        names[#names + 1] = found[i].name
    end

    notify("พบ " .. #found .. " รายการ: " .. table.concat(names, ", "))
end

-- ═══════════════════════════════════════════════════════════
-- 🛍️ TAB 1: ITEM
-- ═══════════════════════════════════════════════════════════
local ItemTab = Window:CreateTab("Item", 4483362458)

ItemTab:CreateLabel("Apollo Shop", 4483362458, Color3.fromRGB(255, 255, 255), false)
ItemTab:CreateParagraph({
    Title = "Item Presets",
    Content = "ปรับจำนวนเซ็ตด้านล่าง แล้วกดปุ่มของที่ต้องการได้เลย",
})
ItemTab:CreateDivider()

ItemTab:CreateSlider({
    Name = "จำนวนเซ็ต Item",
    Range = {1, 100},
    Increment = 1,
    Suffix = "เซ็ต",
    CurrentValue = 1,
    Flag = "ItemSetCount",
    Callback = function(value)
        setSetCount(value)
    end,
})

ItemTab:CreateInput({
    Name = "ค้นหา Item",
    PlaceholderText = "พิมพ์ชื่อเซ็ตหรือไอเทม",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        searchPreset("Item", text)
    end,
})

ItemTab:CreateDivider()
ItemTab:CreateLabel("Item List", 4483362458, Color3.fromRGB(255, 255, 255), false)

addButton(ItemTab, "Item", "🛠️ B1-B10 Set", {
    {"Wood", 1185}, {"Iron", 575}, {"Obsidian", 365},
    {"Mythril", 170}, {"Adamantite", 40}
}, '✅ B1-B10 Set — ใส่ครบแล้ว')

addButton(ItemTab, "Item", "🔑 Crystal Key ×2500", {
    {"Crystal Key", 2500}
}, '✅ Crystal Key ×2500 — ใส่ครบแล้ว')

addButton(ItemTab, "Item", "✨ Aura Crate ×500", {
    {"Aura Crate", 500}
}, '✅ Aura Crate ×500 — ใส่ครบแล้ว')

addButton(ItemTab, "Item", "💼 Mythical Chest ×50000", {
    {"Mythical Chest", 50000}
}, '✅ Mythical Chest ×50000 — ใส่ครบแล้ว')

addButton(ItemTab, "Item", "🏷️ Clan Reroll ×50000", {
    {"Clan Reroll", 50000}
}, '✅ Clan Reroll ×50000 — ใส่ครบแล้ว')

addButton(ItemTab, "Item", "🔷 Passive Shard ×50000", {
    {"Passive Shard", 50000}
}, '✅ Passive Shard ×50000 — ใส่ครบแล้ว')

addButton(ItemTab, "Item", "⚡ Power Shard ×50000", {
    {"Power Shard", 50000}
}, '✅ Power Shard ×50000 — ใส่ครบแล้ว')

addButton(ItemTab, "Item", "🩸 Bloodline Stone ×5000", {
    {"Bloodline Stone", 5000}
}, '✅ Bloodline Stone ×5000 — ใส่ครบแล้ว')

-- ═══════════════════════════════════════════════════════════
-- ⚔️ TAB 2: CHARACTER
-- ═══════════════════════════════════════════════════════════
local CharTab = Window:CreateTab("Character", 4483362458)

CharTab:CreateLabel("Apollo Shop", 4483362458, Color3.fromRGB(255, 255, 255), false)
CharTab:CreateParagraph({
    Title = "Character Presets",
    Content = "ปรับจำนวนเซ็ตด้านล่าง แล้วกดชุดตัวละครที่ต้องการ",
})
CharTab:CreateDivider()

CharTab:CreateSlider({
    Name = "จำนวนเซ็ต Character",
    Range = {1, 100},
    Increment = 1,
    Suffix = "เซ็ต",
    CurrentValue = 1,
    Flag = "CharacterSetCount",
    Callback = function(value)
        setSetCount(value)
    end,
})

CharTab:CreateInput({
    Name = "ค้นหา Character",
    PlaceholderText = "พิมพ์ชื่อเช็ตตัวละคร",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        searchPreset("Character", text)
    end,
})

CharTab:CreateDivider()
CharTab:CreateLabel("Character List", 4483362458, Color3.fromRGB(255, 255, 255), false)

addButton(CharTab, "Character", "🔥 Relic Full Set", {
    {"Relic Part #1",70},{"Relic Part #2",15},
    {"Relic Part #3",75},{"Relic Part #4",20},
    {"Relic Part #5",30},{"Relic Part #6",25},
    {"Relic Part #7",40},{"Relic Part #8",30},
}, '✅ Relic Full Set — ใส่ครบแล้ว')

addButton(CharTab, "Character", "👑 Rank Set +F", {
    {"Atomic Core",2},{"Blood Ring",4},{"Cursed Flesh",2},
    {"Hōgyoku Fragment",2},{"Infinity Essence",2},{"Phantasm Core",2},
    {"Slime Core",3},{"Soul Flame",3},{"Reiatsu Core",4},
    {"Dark Ring",5},{"Dismantle Fang",7},{"Void Fragment",5},
    {"Limitless Ring",2},{"Azure Heart",2},{"Evolution Fragment",2},
    {"Path Fragment",2},{"Corrupt Crown",3}
}, '✅ Rank Set +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🔥 Madara +F", {
    {"Path Fragment",3},{"Eternal Core",8},
    {"Battle Sigil",18},{"Power Remnant",15}
}, '✅ Madara +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🧊 Esdeath +F", {
    {"Ice Core",3},{"Frozen Brand",14},
    {"Glacier Remnant",9},{"Battle Shard",17},{"Frost Relic",250}
}, '✅ Esdeath +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🌙 Moon Slayer +F", {
    {"Moon Crest",3},{"Crescent Shard",14},
    {"Lunar Essence",9},{"Upper Seal",150},{"Demonic Fragment",30},
    {"Demon Remnant",16}
}, '✅ Moon Slayer +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🤺 Aizen V2 +F", {
    {"Fusion Ring",15},{"Chrysalis Sigil",120},
    {"Evolution Fragment",1},{"Transcendent Core",3},
    {"Transmutation Shard",5},{"Divinity Essence",8}
}, '✅ Aizen V2 +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "⚔️ Saber +F", {
    {"Corrupt Crown",3},{"Corruption Core",12},
    {"Alter Essence",8},{"Morgan Remnant",15},
    {"Demon Remnant",15},{"Dark Grail",110}
}, '✅ Saber +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🌑 Cid V2 +F", {
    {"Atomic Omen",1},{"Eminence Essence",3},
    {"Shadow Remnant",9},{"Magic Shard",16},{"Abyss Sigil",80}
}, '✅ Cid V2 +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🧝 Firen +F", {
    {"Mana Core",1},{"Magic Essence",5},
    {"Ancient Fragment",10},{"Spell Echo",18},{"Easter Egg",500}
}, '✅ Firen +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🕛 Dio +F", {
    {"Vampire Omen",2},{"World Core",6},
    {"Time Remnant",12},{"Dominion Brand",80},{"Power Fragment",20}
}, '✅ Dio +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🌌 Garo Set +F", {
    {"Monster Pulse",2},{"Galaxy Shard",5},
    {"Star Mark",8},{"Cosmic Essence",12}
}, '✅ Garo Set +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "👑 Gilgamesh +F", {
    {"Phantasm Core",3},{"Ancient Shard",6},
    {"Golden Essence",8},{"Broken Sword",100},{"Throne Remnant",12}
}, '✅ Gilgamesh +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🌊 Cartethyia +F", {
    {"Aero Core",11},{"Celestial Mark",3},
    {"Gale Essence",8},{"Tide Remnant",14},{"Tempest Relic",75}
}, '✅ Cartethyia +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🕐 Gojo V1+2 +F", {
    {"Void Fragment",6},{"Limitless Ring",3},
    {"Infinity Core",1},{"Cursed Flesh",2},{"Six Eye",6},
    {"Blue Singularity",3},{"Reversal Pulse",9},{"Energy Shard",6},{"Infinity Essence",1}
}, '✅ Gojo V1+2 +F — ใส่ครบแล้ว')

addButton(CharTab, "Character", "🦸 Sukuna V1+2 +F", {
    {"Cursed Finger",6},{"Crimson Heart",1},
    {"Dismantle Fang",3},{"Infinity Essence",2},{"Awakened Cursed Finger",20},
    {"Cursed Flesh",1},{"Vessel Ring",7},{"Malevolent Soul",6},{"Cursed Talisman",6}
}, '✅ Sukuna V1+2 +F — ใส่ครบแล้ว')

notify("Apollo Shop พร้อมใช้งาน 🔥")
