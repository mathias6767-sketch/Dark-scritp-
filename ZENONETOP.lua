-- BY CYPHER SKR
-- https://discord.gg/KGTEfaTCSP

-- ============================================================
-- ZENONETOP - TELETRANSPORTE RÁPIDO
-- ============================================================
-- NOTA: El código recibido termina incompleto en:
-- local function getId(obj) retur
-- Por eso este archivo conserva el texto recibido y no puede
-- considerarse un script completo ni listo para ejecutar.

repeat task.wait() until game:IsLoaded()

-- CONFIGURACIÓN DE INTRO
local SelectedIntro = "zenone"
pcall(function()
    if not readfile or not writefile then return end
    local cfgPath = "Zeno_Intro_Config.txt"
    if isfile(cfgPath) then SelectedIntro = readfile(cfgPath) end
end)

local function SaveIntroCfg(sel)
    SelectedIntro = sel
    pcall(function()
        if not writefile then return end
        writefile("Zeno_Intro_Config.txt", sel)
    end)
    pcall(function() if SaveGuiConfig then SaveGuiConfig() end end)
end

-- LISTA DE FONDOS
local WALLPAPERS = {
    "rbxassetid://90746158236678",
    "rbxassetid://107977050874654",
    "rbxassetid://124475159163140",
    "rbxassetid://117085976067902",
    "rbxassetid://99416158073201",
    "rbxassetid://126860692354524",
    "rbxassetid://73226092831324",
    "rbxassetid://90280869222992",
    "rbxassetid://103042929344358",
    "rbxassetid://126137370200580",
    "rbxassetid://129236724255771",
    "rbxassetid://109053968018578",
    "rbxassetid://76085007631338",
    "rbxassetid://76582249427748",
    "rbxassetid://131388128481309",
    "rbxassetid://106050493494582",
    "rbxassetid://71852104184395",
    "rbxassetid://84453255265251",
    "rbxassetid://98541566010518",
    "rbxassetid://118963313877514",
    "rbxassetid://82757811555212",
    "rbxassetid://130451097419605",
    "rbxassetid://129030262345273",
    "rbxassetid://76292842640935",
    "rbxassetid://92910922537368",
    "rbxassetid://105960347086002",
    "rbxassetid://116720305084998",
    "rbxassetid://90341354549871",
    "rbxassetid://72399600208480",
    "rbxassetid://81834484116440",
    "rbxassetid://135088241492683",
    "rbxassetid://90453834580322",
    "rbxassetid://90631990302263",
    "rbxassetid://109619268613730",
    "rbxassetid://88369503310562",
    "rbxassetid://80708025126373",
    "rbxassetid://102253425322931",
    "rbxassetid://135181794444219",
    "rbxassetid://111941119745474",
    "rbxassetid://138739435956313",
    "rbxassetid://92966351305582",
}
local DEFAULT_BG = WALLPAPERS[1]

-- MÚSICA DE DUELO
local DUEL_SONGS = {
    {name="Canción 1", url="https://files.catbox.moe/mzvrir.mp3", file="ZenoDuelSong_1.mp3"},
    {name="Canción 2", url="https://files.catbox.moe/2a7jyx.mp3", file="ZenoDuelSong_2.mp3"},
    {name="Canción 3", url="https://files.catbox.moe/rcgr9f.mp3", file="ZenoDuelSong_3.mp3"},
    {name="Canción 4", url="https://files.catbox.moe/iknfuh.mp3", file="ZenoDuelSong_4.mp3"},
    {name="Canción 5", url="https://files.catbox.moe/6eigoh.mp3", file="ZenoDuelSong_5.mp3"},
    {name="Canción 6", url="https://files.catbox.moe/dvjtjk.mp3", file="ZenoDuelSong_6.mp3"},
    {name="Canción 7", url="https://files.catbox.moe/iyw1cb.mp3", file="ZenoDuelSong_7.mp3"},
    {name="Canción 8", rbx="rbxassetid://133921455883377"},
    {name="Canción de duelo 9", rbx="rbxassetid://108477308631109"},
    {name="Canción 10", rbx="rbxassetid://140637230317256"},
    {name="Canción 11", rbx="rbxassetid://87974344428504"},
    {name="Canción 12", rbx="rbxassetid://72740886806799"},
    {name="Canción 13", rbx="rbxassetid://139747933972576"},
    {name="Canción 14", rbx="rbxassetid://136208016606825"},
    {name="Canción 15", rbx="rbxassetid://121559463895939"},
    {name="Canción 16", rbx="rbxassetid://121242950842428"},
    {name="Canción 17", rbx="rbxassetid://110396752508363"},
    {name="Canción 19", rbx="rbxassetid://73423580532746"},
    {name="Canción 20", rbx="rbxassetid://107810773290624"},
    {name="Canción 21", rbx="rbxassetid://71214605813266"},
    {name="Canción 22", rbx="rbxassetid://92091993493107"},
    {name="Canción 23", rbx="rbxassetid://102579128761734"},
    {name="Canción 24", rbx="rbxassetid://103093530102792"},
    {name="Canción 25", rbx="rbxassetid://98184705510569"},
}

local selectedDuelSong = 1
local DUEL_VOLUME = 50

local function getDuelVolume()
    return math.clamp((tonumber(DUEL_VOLUME) or 50) / 100, 0.01, 1.0)
end

local function applyLiveVolume()
    local v = getDuelVolume()
    if currentDuelSound then pcall(function() currentDuelSound.Volume = v end) end
    if currentIntroSound then pcall(function() currentIntroSound.Volume = v * 1.15 end) end
end

local function SaveDuelVolumeCfg()
    pcall(function()
        if writefile then writefile("Zeno_DuelVolume_Config.txt", tostring(DUEL_VOLUME)) end
    end)
end

pcall(function()
    if not readfile or not isfile then return end
    if isfile("Zeno_DuelVolume_Config.txt") then
        local n = tonumber(readfile("Zeno_DuelVolume_Config.txt"))
        if n then DUEL_VOLUME = math.clamp(math.floor(n), 1, 100) end
    end
end)

local duelSongCache = {}
local currentDuelSound = nil

pcall(function()
    if not readfile or not isfile then return end
    local p = "Zeno_DuelSong_Config.txt"
    if isfile(p) then
        local n = tonumber(readfile(p))
        if n and n >= 1 and n <= #DUEL_SONGS then selectedDuelSong = n end
    end
end)

local function SaveDuelSongCfg()
    pcall(function()
        if writefile then writefile("Zeno_DuelSong_Config.txt", tostring(selectedDuelSong)) end
    end)
end

local currentIntroSound = nil

local function stopIntroSong(cancelPending)
    pcall(function()
        local SS = game:GetService("SoundService")
        for _, s in ipairs(SS:GetChildren()) do
            if s:IsA("Sound") and (s.Name == "ZenoIntroSong" or s.Name:find("IntroSong")) then
                pcall(function() s:Stop() end)
                pcall(function() s:Destroy() end)
            end
        end
    end)
    if currentIntroSound then
        pcall(function() currentIntroSound:Stop() end)
        pcall(function() currentIntroSound:Destroy() end)
        currentIntroSound = nil
    end
    if cancelPending then _G._ZenoIntroPlayToken = tick() end
end

local function stopDuelSong()
    pcall(function()
        local SS = game:GetService("SoundService")
        for _, s in ipairs(SS:GetChildren()) do
            if s:IsA("Sound") and (s.Name == "ZenoDuelSong" or s.Name:find("DuelSong")) then
                pcall(function() s:Stop() end)
                pcall(function() s:Destroy() end)
            end
        end
    end)
    if currentDuelSound then
        pcall(function() currentDuelSound:Stop() end)
        pcall(function() currentDuelSound:Destroy() end)
        currentDuelSound = nil
    end
end

local function resolveSongId(opt, index)
    if not opt then return nil end
    if opt.rbx and opt.rbx ~= "" then return opt.rbx end
    local cacheKey = opt.file or ("song_" .. tostring(index))
    local soundId = duelSongCache[cacheKey]
    if soundId then return soundId end
    if opt.url and writefile and getcustomasset then
        local has = false
        pcall(function() has = isfile and isfile(opt.file) end)
        if not has then
            pcall(function()
                local data = game:HttpGet(opt.url)
                if data and #data > 0 then writefile(opt.file, data) end
            end)
        end
        pcall(function()
            if isfile and isfile(opt.file) then
                duelSongCache[cacheKey] = getcustomasset(opt.file)
            end
        end)
        soundId = duelSongCache[cacheKey]
    end
    return soundId
end

local function playIntroRandomSong(index)
    local opt = DUEL_SONGS[index]
    if not opt then return end
    local myToken = tick()
    _G._ZenoIntroPlayToken = myToken
    stopIntroSong(false)
    task.spawn(function()
        local soundId = resolveSongId(opt, index)
        if _G._ZenoIntroPlayToken ~= myToken then return end
        if not soundId then
            task.wait(0.15)
            if _G._ZenoIntroPlayToken ~= myToken then return end
            soundId = resolveSongId(opt, index)
        end
        if not soundId or _G._ZenoIntroPlayToken ~= myToken then return end
        pcall(function()
            local SS = game:GetService("SoundService")
            for _, s in ipairs(SS:GetChildren()) do
                if s:IsA("Sound") and s.Name == "ZenoIntroSong" then
                    pcall(function() s:Stop() end)
                    pcall(function() s:Destroy() end)
                end
            end
        end)
        if currentIntroSound then
            pcall(function() currentIntroSound:Stop() end)
            pcall(function() currentIntroSound:Destroy() end)
            currentIntroSound = nil
        end
        if _G._ZenoIntroPlayToken ~= myToken then return end
        local s = Instance.new("Sound")
        s.Name = "ZenoIntroSong"
        s.SoundId = soundId
        s.Volume = getDuelVolume() * 1.15
        s.Looped = false
        s.TimePosition = 0
        s.Parent = game:GetService("SoundService")
        currentIntroSound = s
        s:Play()
        s.Ended:Connect(function()
            if currentIntroSound == s then currentIntroSound = nil end
            pcall(function() s:Destroy() end)
        end)
    end)
end

local function playDuelSong(index)
    stopDuelSong()
    index = index or selectedDuelSong
    local opt = DUEL_SONGS[index]
    if not opt then return end
    task.spawn(function()
        local myToken = tick()
        _G._ZenoDuelPlayToken = myToken
        local soundId = resolveSongId(opt, index)
        if _G._ZenoDuelPlayToken ~= myToken then return end
        if not soundId then return end
        stopDuelSong()
        if _G._ZenoDuelPlayToken ~= myToken then return end
        local s = Instance.new("Sound")
        s.Name = "ZenoDuelSong"
        s.SoundId = soundId
        s.Volume = getDuelVolume()
        s.Looped = false
        s.TimePosition = 0
        s.Parent = game:GetService("SoundService")
        currentDuelSound = s
        s:Play()
        s.Ended:Connect(function()
            if currentDuelSound == s then currentDuelSound = nil end
            pcall(function() s:Destroy() end)
        end)
    end)
end

local _restoredAfterIntro = false

local function restoreSavedDuelSongAfterIntro()
    if _restoredAfterIntro then
        pcall(function() stopIntroSong(true) end)
        return
    end
    _restoredAfterIntro = true
    pcall(function()
        stopIntroSong(true)
        local n = nil
        pcall(function()
            if readfile and isfile and isfile("Zeno_DuelSong_Config.txt") then
                n = tonumber(readfile("Zeno_DuelSong_Config.txt"))
            end
        end)
        n = tonumber(n) or tonumber(_G._ZenoSavedDuelSong) or tonumber(selectedDuelSong) or 1
        n = math.clamp(math.floor(n), 1, #DUEL_SONGS)
        selectedDuelSong = n
        _G._ZenoSavedDuelSong = n
        pcall(SaveDuelSongCfg)
        task.wait(0.05)
        stopIntroSong(true)
        playDuelSong(n)
    end)
end

-- PAQUETES DE ANIMACIÓN
local selectedAnimationPack = "OFF"
local AnimationPacks = {
    ["Zombie"]={idle={{"rbxassetid://616158929",1},{"rbxassetid://616158929",1}},walk="rbxassetid://616168032",run="rbxassetid://616163682",jump="rbxassetid://616161997",fall="rbxassetid://616157476",climb="rbxassetid://616156119"},
    ["Ninja"]={idle={{"rbxassetid://656117400",1},{"rbxassetid://656117400",1}},walk="rbxassetid://656121766",run="rbxassetid://656118852",jump="rbxassetid://656117878",fall="rbxassetid://656115606",climb="rbxassetid://656114359"},
    ["Knight"]={idle={{"rbxassetid://657595757",1},{"rbxassetid://657595757",1}},walk="rbxassetid://657552124",run="rbxassetid://657564596",jump="rbxassetid://658409194",fall="rbxassetid://657600338",climb="rbxassetid://658360781"},
    ["Elder"]={idle={{"rbxassetid://845397899",1},{"rbxassetid://845397899",1}},walk="rbxassetid://845403856",run="rbxassetid://845386501",jump="rbxassetid://845398858",fall="rbxassetid://845397673",climb="rbxassetid://845392038"},
    ["Levitate"]={idle={{"rbxassetid://616006778",1},{"rbxassetid://616006778",1}},walk="rbxassetid://616013216",run="rbxassetid://616013216",jump="rbxassetid://616008936",fall="rbxassetid://616005863",climb="rbxassetid://616003713"},
    ["Astronaut"]={idle={{"rbxassetid://891621366",1},{"rbxassetid://891621366",1}},walk="rbxassetid://891636393",run="rbxassetid://891636393",jump="rbxassetid://891627522",fall="rbxassetid://891617961",climb="rbxassetid://891609353"},
    ["Pirate"]={idle={{"rbxassetid://750781874",1},{"rbxassetid://750781874",1}},walk="rbxassetid://750785693",run="rbxassetid://750783738",jump="rbxassetid://750782230",fall="rbxassetid://750780242",climb="rbxassetid://750779899"},
    ["Toy"]={idle={{"rbxassetid://782841498",1},{"rbxassetid://782841498",1}},walk="rbxassetid://782843345",run="rbxassetid://782842708",jump="rbxassetid://782847020",fall="rbxassetid://782846423",climb="rbxassetid://782843869"},
    ["Vampire"]={idle={{"rbxassetid://1083445855",1},{"rbxassetid://1083445855",1}},walk="rbxassetid://1083473930",run="rbxassetid://1083462077",jump="rbxassetid://1083455352",fall="rbxassetid://1083443587",climb="rbxassetid://1083439238"},
    ["Werewolf"]={idle={{"rbxassetid://1083195517",1},{"rbxassetid://1083195517",1}},walk="rbxassetid://1083178339",run="rbxassetid://1083216690",jump="rbxassetid://1083218792",fall="rbxassetid://1083189019",climb="rbxassetid://1083182000"},
    ["Rthro"]={idle={{"rbxassetid://2510196951",1},{"rbxassetid://2510196951",1}},walk="rbxassetid://2510202577",run="rbxassetid://2510198475",jump="rbxassetid://2510197830",fall="rbxassetid://2510195892",climb="rbxassetid://2510192778"},
    ["Stylish"]={idle={{"rbxassetid://616136790",1},{"rbxassetid://616136790",1}},walk="rbxassetid://616146177",run="rbxassetid://616140816",jump="rbxassetid://616139451",fall="rbxassetid://616134815",climb="rbxassetid://616133594"},
    ["Adidas Sports"]={idle={{"rbxassetid://18537376492",1},{"rbxassetid://18537371272",1}},walk="rbxassetid://18537392113",run="rbxassetid://18537384940",jump="rbxassetid://18537380791",fall="rbxassetid://18537367238",climb="rbxassetid://18537363391"},
    ["Adidas Community"]={idle={{"rbxassetid://122257458498464",1},{"rbxassetid://102357151005774",1}},walk="rbxassetid://122150855457006",run="rbxassetid://82598234841035",jump="rbxassetid://75290611992385",fall="rbxassetid://98600215928904",climb="rbxassetid://88763136693023"},
    ["Adidas Aura"]={idle={{"rbxassetid://110211186840347",1},{"rbxassetid://114191137265065",1}},walk="rbxassetid://83842218823011",run="rbxassetid://118320322718866",jump="rbxassetid://109996626521204",fall="rbxassetid://95603166884636",climb="rbxassetid://97824616490448"},
    ["Wicked Popular"]={idle={{"rbxassetid://118832222982049",1},{"rbxassetid://76049494037641",1}},walk="rbxassetid://92072849924640",run="rbxassetid://72301599441680",jump="rbxassetid://104325245285198",fall="rbxassetid://121152442762481",climb="rbxassetid://131326830509784"},
    ["Mage"]={idle={{"rbxassetid://10921144709",1},{"rbxassetid://10921145797",1}},walk="rbxassetid://10921152678",run="rbxassetid://10921148209",jump="rbxassetid://10921149743",fall="rbxassetid://10921148939",climb="rbxassetid://10921143404"},
    ["Catwalk Glam"]={idle={{"rbxassetid://133806214992291",1},{"rbxassetid://94970088341563",1}},walk="rbxassetid://109168724482748",run="rbxassetid://81024476153754",jump="rbxassetid://116936326516985",fall="rbxassetid://92294537340807",climb="rbxassetid://119377220967554"},
    ["Wicked Dance"]={idle={{"rbxassetid://92849173543269",1},{"rbxassetid://132238900951109",1}},walk="rbxassetid://73718308412641",run="rbxassetid://135515454877967",jump="rbxassetid://78508480717326",fall="rbxassetid://78147885297412",climb="rbxassetid://129447497744818"},
    ["Superhero"]={idle={{"rbxassetid://10921288909",1},{"rbxassetid://10921290167",1}},walk="rbxassetid://10921298616",run="rbxassetid://10921291831",jump="rbxassetid://10921294559",fall="rbxassetid://10921293373",climb="rbxassetid://10921286911"},
    ["No Boundaries"]={idle={{"rbxassetid://18747067405",1},{"rbxassetid://18747063918",1}},walk="rbxassetid://18747074203",run="rbxassetid://18747070484",jump="rbxassetid://18747069148",fall="rbxassetid://18747062535",climb="rbxassetid://18747060903"},
    ["NFL"]={idle={{"rbxassetid://92080889861410",1},{"rbxassetid://74451233229259",1}},walk="rbxassetid://110358958299415",run="rbxassetid://117333533048078",jump="rbxassetid://119846112151352",fall="rbxassetid://129773241321032",climb="rbxassetid://134630013742019"},
    ["Amazon Unboxed"]={idle={{"rbxassetid://98281136301627",1},{"rbxassetid://98281136301627",1}},walk="rbxassetid://90478085024465",run="rbxassetid://134824450619865",jump="rbxassetid://121454505477205",fall="rbxassetid://94788218468396",climb="rbxassetid://121145883950231"},
    ["Robot"]={idle={{"rbxassetid://616088211",1},{"rbxassetid://616089559",1}},walk="rbxassetid://616095330",run="rbxassetid://616091570",jump="rbxassetid://616090535",fall="rbxassetid://616087089",climb="rbxassetid://616086039"},
    ["Bubbly"]={idle={{"rbxassetid://910004836",1},{"rbxassetid://910009958",1}},walk="rbxassetid://910034870",run="rbxassetid://910025107",jump="rbxassetid://910016857",fall="rbxassetid://910001910",climb="rbxassetid://909997997"},
    ["Cartoon"]={idle={{"rbxassetid://742637544",1},{"rbxassetid://742638445",1}},walk="rbxassetid://742640026",run="rbxassetid://742638842",jump="rbxassetid://742637942",fall="rbxassetid://742637151",climb="rbxassetid://742636889"},
}

local AnimationPackList = {"OFF","Zombie","Ninja","Knight","Elder","Levitate","Astronaut","Pirate","Toy","Vampire","Werewolf","Rthro","Stylish","Adidas Sports","Adidas Community","Adidas Aura","Wicked Popular","Mage","Catwalk Glam","Wicked Dance","Superhero","No Boundaries","NFL","Amazon Unboxed","Robot","Bubbly","Cartoon"}
local AnimationPackIndex = 1
local OriginalAnims = {}

local function getAnimate(char)
    char = char or game.Players.LocalPlayer.Character
    return char and char:FindFirstChild("Animate") or nil
end

local function stopCurrentAnimations(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        pcall(function() track:Stop(0) end)
    end
end

local function backupAnimations(char)
    local animate = getAnimate(char)
    if not animate or next(OriginalAnims) ~= nil then return end
    local function getId(obj) return obj end

-- FIN DEL TEXTO RECIBIDO: el original se corta aquí y faltan las funciones restantes.
