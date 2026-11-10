-- BY CYPHER SKR
-- https://discord.gg/KGTEfaTCSP

-- ============================================================
-- 🌸 ZENONETOP - TELETRANSPORTE RÁPIDO | ACTUALIZACIÓN COMPLETA + DESTRUCCIÓN EXTERNA
-- ============================================================
repeat task.wait() until game:IsLoaded()
-- ============================================================
-- 💾 GUARDAR/CARGAR SOLO LA CONFIGURACIÓN DE LA INTRO
-- ============================================================
local SelectedIntro = "zenone" -- PREDETERMINADO: SKULLCAP
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
-- ============================================================
-- 📸 LISTA DE FONDOS (Zenone 4 + Ace 4)
-- ============================================================
local WALLPAPERS = {
    -- Zenone + Ace original
    "rbxassetid://90746158236678",
    "rbxassetid://107977050874654",
    "rbxassetid://124475159163140",
    "rbxassetid://117085976067902",
    "rbxassetid://99416158073201",
    "rbxassetid://126860692354524",
    "rbxassetid://73226092831324",
    "rbxassetid://90280869222992",
    -- Bless.vs (original + adicional)
    "rbxassetid://103042929344358",
    "rbxassetid://126137370200580",
    "rbxassetid://129236724255771",
    "rbxassetid://109053968018578",
    "rbxassetid://76085007631338",
    "rbxassetid://76582249427748",
    "rbxassetid://131388128481309",
    "rbxassetid://106050493494582",
    -- Ace adicional (aún no está en TP)
    "rbxassetid://71852104184395",
    "rbxassetid://84453255265251",
    -- AdaptHub / Ace wallpapers
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
-- ============================================================
-- 🎵 MÚSICA DE DUELO (7 full catbox tracks)
-- ============================================================
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

local DUEL_VOLUME = 50 -- 1..100
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
-- Cargar la canción seleccionada anteriormente
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
    -- Solo detener la música aleatoria de la INTRO (sin tocar la canción del usuario)
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
    -- Chỉ hủy task đang load khi thật sự muốn hủy (hết intro), KHÔNG hủy khi chuẩn bị phát
    if cancelPending then
        _G._ZenoIntroPlayToken = tick()
    end
end
local function stopDuelSong()
    -- Detener toda la música de duelo que esté reproduciéndose (evita que se superponga)
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
-- Solo para la música de fondo de la intro Ace (7 pistas aleatorias) — canal separado
local function playIntroRandomSong(index)
    local opt = DUEL_SONGS[index]
    if not opt then return end
    local myToken = tick()
    _G._ZenoIntroPlayToken = myToken
    -- Dọn sound cũ nhưng KHÔNG hủy token (tránh mất nhạc sau khi download)
    stopIntroSong(false)
    task.spawn(function()
        local soundId = resolveSongId(opt, index)
        if _G._ZenoIntroPlayToken ~= myToken then return end
        if not soundId then
            -- fallback: thử lại 1 lần
            task.wait(0.15)
            if _G._ZenoIntroPlayToken ~= myToken then return end
            soundId = resolveSongId(opt, index)
        end
        if not soundId or _G._ZenoIntroPlayToken ~= myToken then return end
        -- Xóa sound cũ (nếu có) nhưng mantener token
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
        s.TimePosition = 0 -- phát từ đầu
        s.Parent = game:GetService("SoundService")
        currentDuelSound = s
        s:Play()
        s.Ended:Connect(function()
            if currentDuelSound == s then currentDuelSound = nil end
            pcall(function() s:Destroy() end)
        end)
    end)
end
-- Al terminar la intro Ace: CẮT 7 bài catbox intro → phát bài user đã nghe trước khi ao
local _restoredAfterIntro = false
local function restoreSavedDuelSongAfterIntro()
    if _restoredAfterIntro then
        pcall(function() stopIntroSong(true) end)
        return
    end
    _restoredAfterIntro = true
    pcall(function()
        stopIntroSong(true) -- dừng + hủy task intro đang load
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
        playDuelSong(n) -- bài CŨ trước khi ao, full từ đầu
    end)
end
-- ============================================================
-- 🎬 PAQUETES DE ANIMACIÓN (completo de Ace)
-- ============================================================
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
    -- === Añadidos de Bless.vs ===
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
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0) end) end
end
local function backupAnimations(char)
    local animate = getAnimate(char)
    if not animate or next(OriginalAnims) ~= nil then return end
    local function getId(obj) return obj and obj.AnimationId or nil end
    OriginalAnims = {
        idle1 = getId(animate.idle and animate.idle:FindFirstChild("Animation1")),
        idle2 = getId(animate.idle and animate.idle:FindFirstChild("Animation2")),
        walk = getId(animate.walk and animate.walk:FindFirstChild("WalkAnim")),
        run = getId(animate.run and animate.run:FindFirstChild("RunAnim")),
        jump = getId(animate.jump and animate.jump:FindFirstChild("JumpAnim")),
        fall = getId(animate.fall and animate.fall:FindFirstChild("FallAnim")),
        climb = getId(animate.climb and animate.climb:FindFirstChild("ClimbAnim")),
    }
end
local function setAnimId(obj, id) if obj and id then pcall(function() obj.AnimationId = id end) end end
local function reloadAnimate(animate)
    if not animate then return end
    pcall(function() animate.Disabled = true; task.wait(); animate.Disabled = false end)
end
local function resetAnimations()
    local char = game.Players.LocalPlayer.Character
    local animate = getAnimate(char)
    if not animate or next(OriginalAnims) == nil then return end
    stopCurrentAnimations(char)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), OriginalAnims.idle1)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), OriginalAnims.idle2)
    setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), OriginalAnims.walk)
    setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), OriginalAnims.run)
    setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), OriginalAnims.jump)
    setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), OriginalAnims.fall)
    setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"), OriginalAnims.climb)
    reloadAnimate(animate)
end
local function applyAnimationPack(packName)
    selectedAnimationPack = packName or "OFF"
    if selectedAnimationPack == "OFF" then resetAnimations(); return end
    local pack = AnimationPacks[selectedAnimationPack]
    local char = game.Players.LocalPlayer.Character
    local animate = getAnimate(char)
    if not pack or not animate then return end
    backupAnimations(char)
    stopCurrentAnimations(char)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), pack.idle[1][1])
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), pack.idle[2][1])
    setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), pack.walk)
    setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), pack.run)
    setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), pack.jump)
    setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), pack.fall)
    setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"), pack.climb)
    reloadAnimate(animate)
end
pcall(function()
    if not readfile or not isfile then return end
    local p = "Zeno_AnimPack_Config.txt"
    if isfile(p) then
        local name = readfile(p)
        for i, n in ipairs(AnimationPackList) do if n == name then AnimationPackIndex = i; selectedAnimationPack = name; break end end
    end
end)
local function SaveAnimPackCfg()
    pcall(function() if writefile then writefile("Zeno_AnimPack_Config.txt", selectedAnimationPack) end end)
end
-- ============================================================
-- 🌟 INTRO 1: SKULLCAP (ZENONETOP)
-- ============================================================
local function IntroSkullcap()
    local Tween = game:GetService("TweenService")
    local Content = game:GetService("ContentProvider")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local IntroScreen = Instance.new("ScreenGui")
    IntroScreen.Name = "TP_SCRIPT_INTRO"
    IntroScreen.DisplayOrder = 9999
    IntroScreen.ResetOnSpawn = false
    IntroScreen.IgnoreGuiInset = true
    IntroScreen.Parent = PlayerGui
    
    local IntroSound = Instance.new("Sound")
    IntroSound.Name = "IntroMusic"
    IntroSound.SoundId = "rbxassetid://140245756477343"
    IntroSound.Volume = 0.75
    IntroSound.Looped = false
    IntroSound.TimePosition = 2.5
    IntroSound.Parent = IntroScreen
    
    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundColor3 = Color3.fromRGB(8, 6, 15)
    Bg.BackgroundTransparency = 1
    Bg.ZIndex = 1
    Bg.Parent = IntroScreen
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new(Color3.fromRGB(100, 50, 200), Color3.fromRGB(150,90,255))
    Gradient.Rotation = 120
    Gradient.Parent = Bg
    
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 200, 0, 200)
    Logo.Position = UDim2.new(0.5, -100, 0.35, -100)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://71852104184395"
    Logo.ImageTransparency = 1
    Logo.ZIndex = 3
    Logo.Parent = IntroScreen
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Position = UDim2.new(0, 0, 0.65, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MIAU TP"
    Title.TextColor3 = Color3.fromRGB(150,90,255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 68
    Title.TextTransparency = 1
    Title.TextStrokeTransparency = 1
    Title.TextStrokeColor3 = Color3.fromRGB(100, 50, 200)
    Title.ZIndex = 4
    Title.Parent = IntroScreen
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, 0, 0, 22)
    SubTitle.Position = UDim2.new(0, 0, 0.78, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "by owners crossbow"
    SubTitle.TextColor3 = Color3.fromRGB(180, 150, 255)
    SubTitle.Font = Enum.Font.GothamMedium
    SubTitle.TextSize = 16
    SubTitle.TextTransparency = 1
    SubTitle.ZIndex = 4
    SubTitle.Parent = IntroScreen
    
    local Particles = {}
    for i = 1, 60 do
        local P = Instance.new("Frame")
        P.Size = UDim2.new(0, math.random(1, 3), 0, math.random(1, 3))
        P.Position = UDim2.new(math.random(), 0, math.random(), 0)
        P.BackgroundColor3 = Color3.fromRGB(150,90,255)
        P.BackgroundTransparency = 1
        P.BorderSizePixel = 0
        Instance.new("UICorner", P).CornerRadius = UDim.new(1, 0)
        P.ZIndex = 2
        P.Parent = IntroScreen
        Particles[i] = P
    end
    
    task.spawn(function() pcall(function() Content:PreloadAsync({IntroSound, Logo}) end) end)
    IntroSound:Play()
    Tween:Create(Bg, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    for _, p in ipairs(Particles) do
        task.delay(math.random() * 0.4, function()
            Tween:Create(p, TweenInfo.new(0.5), {BackgroundTransparency = 0.2}):Play()
        end)
    end
    task.wait(0.7)
    Tween:Create(Logo, TweenInfo.new(0.8), {ImageTransparency = 0}):Play()
    task.wait(0.9)
    Tween:Create(Title, TweenInfo.new(0.6), {TextTransparency = 0, TextStrokeTransparency = 0.2}):Play()
    task.wait(0.3)
    Tween:Create(SubTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    task.wait(2.2)
    Tween:Create(Title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    Tween:Create(SubTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    Tween:Create(Logo, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
    Tween:Create(Bg, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
    Tween:Create(IntroSound, TweenInfo.new(0.6), {Volume = 0}):Play()
    task.wait(0.7)
    IntroScreen:Destroy()
end
-- ============================================================
-- 🌟 INTRO 2: SHARINGAN (PHANTOM)
-- ============================================================
local function IntroSharingan()
    local localPlayer = game.Players.LocalPlayer
    local playerGui = localPlayer:FindFirstChild('PlayerGui')
    if not playerGui then return end
    local screenGui = Instance.new('ScreenGui')
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    local imageLabel = Instance.new('ImageLabel')
    imageLabel.Parent = screenGui
    imageLabel.Size = UDim2.new(0, 0, 0, 0)
    imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = 'rbxassetid://13879097036'
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.BorderSizePixel = 0
    imageLabel.ImageTransparency = 0
    local sound = Instance.new('Sound')
    sound.SoundId = 'rbxassetid://1592708450'
    sound.Parent = localPlayer.Character or localPlayer:WaitForChild('Character')
    sound:Play()
    task.spawn(function()
        local v5 = tick()
        while tick() - v5 < 1 do
            imageLabel.Rotation = imageLabel.Rotation + 10
            task.wait(0.01)
        end
    end)
    task.spawn(function()
        local v6 = tick()
        while tick() - v6 < 0.7 do
            local v7 = (tick() - v6) / 0.7 * 1.2
            imageLabel.Size = UDim2.new(v7, 0, v7, 0)
            if 0.5 <= v7 then
                local v8 = (v7 - 0.5) / (1.2 - 0.5)
                imageLabel.ImageTransparency = math.clamp(v8, 0, 1)
            end
            task.wait(0.01)
        end
        imageLabel.Size = UDim2.new(1.2, 0, 1.2, 0)
        imageLabel.ImageTransparency = 1
    end)
    task.delay(1, function() screenGui:Destroy() end)
    local screenGui2 = Instance.new('ScreenGui')
    screenGui2.IgnoreGuiInset = true
    screenGui2.ResetOnSpawn = false
    screenGui2.Parent = playerGui
    local crossbowTitle = Instance.new('TextLabel')
    crossbowTitle.Parent = screenGui2
    crossbowTitle.Size = UDim2.new(1, 0, 0, 70)
    crossbowTitle.Position = UDim2.new(0, 0, 0.68, 0)
    crossbowTitle.BackgroundTransparency = 1
    crossbowTitle.Text = 'MIAU TP'
    crossbowTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    crossbowTitle.Font = Enum.Font.GothamBlack
    crossbowTitle.TextSize = 52
    crossbowTitle.TextTransparency = 1
    crossbowTitle.ZIndex = 20

    local crossbowSubtitle = Instance.new('TextLabel')
    crossbowSubtitle.Parent = screenGui2
    crossbowSubtitle.Size = UDim2.new(1, 0, 0, 30)
    crossbowSubtitle.Position = UDim2.new(0, 0, 0.78, 0)
    crossbowSubtitle.BackgroundTransparency = 1
    crossbowSubtitle.Text = 'by owners crossbow'
    crossbowSubtitle.TextColor3 = Color3.fromRGB(255, 210, 210)
    crossbowSubtitle.Font = Enum.Font.GothamMedium
    crossbowSubtitle.TextSize = 18
    crossbowSubtitle.TextTransparency = 1
    crossbowSubtitle.ZIndex = 20

    task.spawn(function()
        task.wait(0.35)
        pcall(function()
            TweenService = game:GetService('TweenService')
            TweenService:Create(crossbowTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
            TweenService:Create(crossbowSubtitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        end)
    end)

    local frame = Instance.new('Frame')
    frame.Parent = screenGui2
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.ZIndex = 0
    local uIGradient = Instance.new('UIGradient')
    uIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 60)) })
    uIGradient.Rotation = 0
    uIGradient.Parent = frame
    task.spawn(function()
        while frame.Parent do
            uIGradient.Rotation = (uIGradient.Rotation + 1) % 360
            task.wait(0.02)
        end
    end)
    local imageLabel2 = Instance.new('ImageLabel')
    imageLabel2.Parent = screenGui2
    imageLabel2.Size = UDim2.new(0, 0, 0, 0)
    imageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel2.BackgroundTransparency = 1
    imageLabel2.Image = 'rbxassetid://13879097036'
    imageLabel2.ScaleType = Enum.ScaleType.Fit
    imageLabel2.BorderSizePixel = 0
    imageLabel2.ImageTransparency = 0
    local sound2 = Instance.new('Sound')
    sound2.SoundId = 'rbxassetid://1592708450'
    sound2.Parent = localPlayer.Character or localPlayer:WaitForChild('Character')
    sound2:Play()
    task.spawn(function()
        local u11 = 0
        while imageLabel2.Parent do
            u11 = math.min(u11 + 0.2, 12)
            imageLabel2.Rotation = imageLabel2.Rotation + u11
            task.wait(0.01)
        end
    end)
    task.spawn(function()
        local v16 = tick()
        while tick() - v16 < 2 do
            local v17 = (tick() - v16) / 2
            imageLabel2.Size = UDim2.new(v17, 0, v17, 0)
            task.wait(0.01)
        end
        imageLabel2.Size = UDim2.new(1, 0, 1, 0)
    end)
    task.spawn(function()
        task.wait(2.7)
        local v18 = tick()
        while tick() - v18 < 1.5 do
            local v19 = (tick() - v18) / 1.5
            imageLabel2.ImageTransparency = v19
            frame.BackgroundTransparency = 0.4 + v19 * 0.6
            uIGradient.Transparency = NumberSequence.new(v19)
            task.wait(0.01)
        end
    end)
    task.wait(4.2)
    pcall(function()
        if crossbowTitle then
            TweenService:Create(crossbowTitle, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
        end
        if crossbowSubtitle then
            TweenService:Create(crossbowSubtitle, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
        end
    end)
    task.wait(0.35)
    pcall(function() if screenGui2 then screenGui2:Destroy() end end)
    pcall(function() if screenGui and screenGui.Parent then screenGui:Destroy() end end)
end
-- ============================================================
-- 🌟 INTRO 3: CROSSBOW TP TOP (estilo cartas)
-- ============================================================
local function IntroAce()
    local TS = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    -- Random đúng 7 bài catbox đầu (Song 1–7) cho nhạc NỀN intro; bài user mantener nguyên
    _restoredAfterIntro = false
    pcall(function()
        local saved = tonumber(selectedDuelSong) or 1
        pcall(function()
            if readfile and isfile and isfile("Zeno_DuelSong_Config.txt") then
                local n = tonumber(readfile("Zeno_DuelSong_Config.txt"))
                if n and n >= 1 and n <= #DUEL_SONGS then saved = n end
            end
        end)
        saved = math.clamp(math.floor(saved), 1, #DUEL_SONGS)
        selectedDuelSong = saved
        _G._ZenoSavedDuelSong = saved -- bài CŨ trước khi ao (có thể là 8+ / bất kỳ)
        local n = math.random(1, 7) -- chỉ 7 catbox đầu
        INTRO_SONG_INDEX = n
        if playIntroRandomSong then playIntroRandomSong(n) end
    end)
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "AceDuelsIntro_Zeno"
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 99999
    introGui.ResetOnSpawn = false
    introGui.Parent = PlayerGui
    local introActive = true
    local function finishIntro()
        if not introActive then return end
        introActive = false
        pcall(function() introGui:Destroy() end)
        -- Skip intro → cũng chuyển về bài user đã lưu
        pcall(restoreSavedDuelSongAfterIntro)
    end
    -- Background
    local darkBg = Instance.new("Frame", introGui)
    darkBg.Size = UDim2.new(1, 0, 1, 0)
    darkBg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    darkBg.BackgroundTransparency = 1
    darkBg.BorderSizePixel = 0
    darkBg.ZIndex = 1
    local bgGrad = Instance.new("UIGradient", darkBg)
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(42,42,46)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(18,18,20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,12))
    })
    bgGrad.Rotation = 90
    -- Skip button
    local skipBtn = Instance.new("TextButton", introGui)
    skipBtn.Name = "SkipIntro"
    skipBtn.AnchorPoint = Vector2.new(1,0)
    skipBtn.Position = UDim2.new(1,-22,0,22)
    skipBtn.Size = UDim2.new(0,104,0,34)
    skipBtn.BackgroundColor3 = Color3.fromRGB(235,235,240)
    skipBtn.BackgroundTransparency = 0.08
    skipBtn.BorderSizePixel = 0
    skipBtn.Text = "SALTAR INTRO"
    skipBtn.TextColor3 = Color3.fromRGB(0,0,0)
    skipBtn.TextSize = 11
    skipBtn.Font = Enum.Font.GothamBlack
    skipBtn.AutoButtonColor = false
    skipBtn.ZIndex = 80
    Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0,10)
    local skipStroke = Instance.new("UIStroke", skipBtn)
    skipStroke.Color = Color3.fromRGB(255,255,255)
    skipStroke.Thickness = 1
    skipStroke.Transparency = 0.12
    skipBtn.MouseButton1Click:Connect(finishIntro)
    -- Card factory
    local function makeAceCard(parent, size, z)
        local card = Instance.new("Frame", parent)
        card.Size = UDim2.new(0, math.floor(size * 0.68), 0, size)
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.BackgroundColor3 = Color3.fromRGB(238, 238, 232)
        card.BackgroundTransparency = 1
        card.BorderSizePixel = 0
        card.ZIndex = z or 6
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, math.max(8, math.floor(size * 0.08)))
        local stroke = Instance.new("UIStroke", card)
        stroke.Color = Color3.fromRGB(190,190,190)
        stroke.Thickness = 1
        stroke.Transparency = 1
        local grad = Instance.new("UIGradient", card)
        grad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(195,198,200))
        grad.Rotation = 125
        local a1 = Instance.new("TextLabel", card)
        a1.Size = UDim2.new(0.28,0,0.25,0); a1.Position = UDim2.new(0.06,0,0.04,0)
        a1.BackgroundTransparency = 1; a1.Text = "A\n♠"; a1.TextColor3 = Color3.fromRGB(0,0,0)
        a1.Font = Enum.Font.GothamBlack; a1.TextScaled = true; a1.TextTransparency = 1; a1.ZIndex = (z or 6) + 1
        local suit = Instance.new("TextLabel", card)
        suit.Size = UDim2.new(0.62,0,0.52,0); suit.Position = UDim2.new(0.19,0,0.25,0)
        suit.BackgroundTransparency = 1; suit.Text = "♠"; suit.TextColor3 = Color3.fromRGB(0,0,0)
        suit.Font = Enum.Font.GothamBlack; suit.TextScaled = true; suit.TextTransparency = 1; suit.ZIndex = (z or 6) + 1
        local a2 = Instance.new("TextLabel", card)
        a2.Size = UDim2.new(0.28,0,0.25,0); a2.Position = UDim2.new(0.66,0,0.71,0)
        a2.BackgroundTransparency = 1; a2.Text = "A\n♠"; a2.TextColor3 = Color3.fromRGB(0,0,0)
        a2.Font = Enum.Font.GothamBlack; a2.TextScaled = true; a2.TextTransparency = 1; a2.Rotation = 180; a2.ZIndex = (z or 6) + 1
        return card, {a1, suit, a2}, stroke
    end
    -- Flying cards
    local cards = {}
    for i = 1, 24 do
        local size = math.random(46, 108)
        local card, labels, stroke = makeAceCard(introGui, size, 5 + i)
        local side = (i % 2 == 0) and -0.35 or 1.35
        local targetSide = (i % 2 == 0) and 1.35 or -0.35
        local y = math.random(4, 96) / 100
        card.Position = UDim2.new(side, 0, y, 0)
        card.Rotation = math.random(-40, 40)
        cards[i] = {frame=card, labels=labels, stroke=stroke, startX=side, endX=targetSide, y=y, speed=0.09+math.random()*0.10, bob=math.random()*6.28, rot=math.random(-55,55), drift=math.random(-14,14)/100}
    end
    -- Big center Ace card logo
    local aceLogo, aceLabels, aceStroke = makeAceCard(introGui, 170, 25)
    aceLogo.Position = UDim2.new(0.5,0,-0.35,0)
    aceLogo.Rotation = -12
    local t = 0
    local driftConn = RunService.Heartbeat:Connect(function(dt)
        if not introActive then return end
        t = t + dt
        for _, cd in ipairs(cards) do
            local currentX = cd.frame.Position.X.Scale
            local dir = cd.startX < cd.endX and 1 or -1
            local newX = currentX + dir * cd.speed * dt
            if (dir == 1 and newX > 1.40) or (dir == -1 and newX < -0.40) then newX = cd.startX end
            local newY = math.clamp(cd.y + math.sin(t * 1.5 + cd.bob) * 0.035 + cd.drift, -0.08, 1.08)
            cd.frame.Position = UDim2.new(newX, 0, newY, 0)
            cd.frame.Rotation = cd.rot + math.sin(t * 2.5 + cd.bob) * 14
        end
    end)
    -- Center title area
    local center = Instance.new("Frame", introGui)
    center.AnchorPoint = Vector2.new(0.5,0.5)
    center.Position = UDim2.new(0.5,0,0.5,0)
    center.Size = UDim2.new(0,660,0,250)
    center.BackgroundTransparency = 1
    center.ZIndex = 40
    local lineTop = Instance.new("Frame", center)
    lineTop.AnchorPoint = Vector2.new(0.5,0)
    lineTop.Position = UDim2.new(0.5,0,0,58)
    lineTop.Size = UDim2.new(0,0,0,2)
    lineTop.BackgroundColor3 = Color3.fromRGB(225,225,225)
    lineTop.BorderSizePixel = 0
    lineTop.ZIndex = 41
    local lineBot = Instance.new("Frame", center)
    lineBot.AnchorPoint = Vector2.new(0.5,1)
    lineBot.Position = UDim2.new(0.5,0,1,-8)
    lineBot.Size = UDim2.new(0,0,0,2)
    lineBot.BackgroundColor3 = Color3.fromRGB(225,225,225)
    lineBot.BorderSizePixel = 0
    lineBot.ZIndex = 41
    local titleShadow = Instance.new("TextLabel", center)
    titleShadow.Size = UDim2.new(1,0,0,86)
    titleShadow.Position = UDim2.new(0,4,0,83)
    titleShadow.BackgroundTransparency = 1
    titleShadow.Text = "MIAU TP"
    titleShadow.TextColor3 = Color3.fromRGB(0,0,0)
    titleShadow.Font = Enum.Font.GothamBlack
    titleShadow.TextSize = 64
    titleShadow.TextTransparency = 1
    titleShadow.TextStrokeTransparency = 1
    titleShadow.ZIndex = 42
    local title = Instance.new("TextLabel", center)
    title.Size = UDim2.new(1,0,0,86)
    title.Position = UDim2.new(0,0,0,78)
    title.BackgroundTransparency = 1
    title.Text = "MIAU TP"
    title.TextColor3 = Color3.fromRGB(245,245,245)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 64
    title.TextTransparency = 1
    title.TextStrokeTransparency = 1
    title.TextStrokeColor3 = Color3.fromRGB(35,35,35)
    title.ZIndex = 43
    local subtitle = Instance.new("TextLabel", center)
    subtitle.Size = UDim2.new(1,0,0,26)
    subtitle.Position = UDim2.new(0,0,0,169)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "by owners crossbow"
    subtitle.TextColor3 = Color3.fromRGB(200,200,200)
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 19
    subtitle.TextTransparency = 1
    subtitle.ZIndex = 43
    -- Nhạc đã phát lúc đầu intro (random 1–8), không restart mantenera chừng
    -- Animation sequence
    TS:Create(darkBg, TweenInfo.new(0.65), {BackgroundTransparency = 0.22}):Play()
    for _, cd in ipairs(cards) do
        task.delay(math.random() * 0.9, function()
            if not introActive then return end
            TS:Create(cd.frame, TweenInfo.new(0.65), {BackgroundTransparency = 0.08}):Play()
            if cd.stroke then TS:Create(cd.stroke, TweenInfo.new(0.65), {Transparency = 0.25}):Play() end
            for _, lbl in ipairs(cd.labels) do TS:Create(lbl, TweenInfo.new(0.65), {TextTransparency = 0}):Play() end
        end)
    end
    task.wait(0.85)
    if not introActive then pcall(function() driftConn:Disconnect() end); return end
    TS:Create(aceLogo, TweenInfo.new(1.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.20,0), BackgroundTransparency = 0.02, Rotation = 8}):Play()
    if aceStroke then TS:Create(aceStroke, TweenInfo.new(0.55), {Transparency = 0.15}):Play() end
    for _, lbl in ipairs(aceLabels) do TS:Create(lbl, TweenInfo.new(0.55), {TextTransparency = 0}):Play() end
    task.wait(1.05)
    if not introActive then pcall(function() driftConn:Disconnect() end); return end
    TS:Create(lineTop, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,500,0,2)}):Play()
    TS:Create(lineBot, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,500,0,2)}):Play()
    task.wait(0.12)
    TS:Create(titleShadow, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0.35, TextStrokeTransparency = 1}):Play()
    TS:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0.18}):Play()
    task.wait(0.42)
    TS:Create(subtitle, TweenInfo.new(0.42), {TextTransparency = 0}):Play()
    for i = 1, 3 do
        if not introActive then break end
        TS:Create(title, TweenInfo.new(0.06), {TextColor3 = Color3.fromRGB(185,185,185)}):Play(); task.wait(0.06)
        TS:Create(title, TweenInfo.new(0.06), {TextColor3 = Color3.fromRGB(245,245,245)}):Play(); task.wait(0.06)
    end
    task.wait(3.05)
    if not introActive then pcall(function() driftConn:Disconnect() end); return end
    TS:Create(center, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
    TS:Create(title, TweenInfo.new(0.36), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    TS:Create(titleShadow, TweenInfo.new(0.36), {TextTransparency = 1}):Play()
    TS:Create(subtitle, TweenInfo.new(0.32), {TextTransparency = 1}):Play()
    TS:Create(lineTop, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,2)}):Play()
    TS:Create(lineBot, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,2)}):Play()
    TS:Create(aceLogo, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5,0,1.25,0), BackgroundTransparency = 1, Rotation = 28}):Play()
    for _, lbl in ipairs(aceLabels) do TS:Create(lbl, TweenInfo.new(0.45), {TextTransparency = 1}):Play() end
    if aceStroke then TS:Create(aceStroke, TweenInfo.new(0.45), {Transparency = 1}):Play() end
    TS:Create(darkBg, TweenInfo.new(0.75), {BackgroundTransparency = 1}):Play()
    for _, cd in ipairs(cards) do
        TS:Create(cd.frame, TweenInfo.new(0.55), {BackgroundTransparency = 1}):Play()
        if cd.stroke then TS:Create(cd.stroke, TweenInfo.new(0.55), {Transparency = 1}):Play() end
        for _, lbl in ipairs(cd.labels) do TS:Create(lbl, TweenInfo.new(0.55), {TextTransparency = 1}):Play() end
    end
    task.wait(0.9)
    introActive = false
    pcall(function() driftConn:Disconnect() end)
    pcall(function() introGui:Destroy() end)
    -- Hết hiệu ứng Ace → dừng intro song random, phát lại bài CŨ user đã lưu
    pcall(restoreSavedDuelSongAfterIntro)
end
-- La intro se ejecutará DESPUÉS de crear la GUI y luego aparecerá el menú
local _introFinished = false
local _onIntroFinishedCbs = {}
local function onIntroFinished(cb)
    if _introFinished then task.defer(cb) else table.insert(_onIntroFinishedCbs, cb) end
end
local function markIntroFinished()
    if _introFinished then return end
    _introFinished = true
    for _, cb in ipairs(_onIntroFinishedCbs) do pcall(cb) end
    _onIntroFinishedCbs = {}
end
local function runSelectedIntro()
    task.spawn(function()
        pcall(function()
            if SelectedIntro == "phantom" then IntroSharingan()
            elseif SelectedIntro == "ace" then IntroAce()
            else IntroSkullcap() end
        end)
        markIntroFinished()
    end)
end
-- ============================================================
-- 📦 SERVICIOS Y VARIABLES
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local SAVE_BASE, SAVE_PET = nil, nil
local MARK_BASE, MARK_PET = nil, nil
local KEYBIND_TP = Enum.KeyCode.X
local KEYBIND_TURRET = Enum.KeyCode.C -- Phím búa destroy ngoài
local IS_SET_KEY = false
local IS_TPING = false
local DELAY_BASE, DELAY_PET = 0.07, 0.07
local MIN_DELAY, MAX_DELAY = 0.01, 0.50
local IS_RAGDOLL = false
local isGuiLocked = false
MINIMIZE = true -- iniciar compacto: encabezado + TP, sin zona vacía
local TP_MINI_SCALE = 1 -- 1..4 chỉ tăng CHIỀU CAO nút TP khi thu gọn
local MAIN_GUI_SCALE = 1 -- 1..2 scale cao main gui
local MAIN_WIDTH_SCALE = 1 -- 1..10 chiều ngang main + TP
local INTRO_SONG_INDEX = 1 -- nhạc mở đầu Ace 1..8
local CURRENT_WALLPAPER = DEFAULT_BG

-- === VARIABLES DE DESTRUCCIÓN EXTERNA ===
local AUTO_DESTROY_TURRET = false
local TURRET_BTN_SIZE = 50 -- MẶC ĐỊNH 50
local TURRET_MIN_SIZE, TURRET_MAX_SIZE = 10, 100
local TURRET_SHAPE = "tron" -- tron / vuong / ngang
local isTurretLocked = false
local turretBtn = nil
-- Botón flotante de Trap: independiente del TP y con bloqueo propio
local TRAP_FLOAT_LOCKED = false
local trapFloatBtn = nil
local trapFloatLockBtn = nil

-- ============================================================
-- 💾 CONFIGURACIÓN DE LA GUI (guardar la posición del menú, nút búa, intro, keybind, delay, anim)
-- NO guardar la música, KHÔNG lưu 2 điểm Base/Pet
-- ============================================================
local GUI_CFG_PATH = "Zeno_GUI_Config.txt"
local _UIRefs = { Main = nil }
local function SaveGuiConfig()
    pcall(function()
        if not writefile then return end
        local M = _UIRefs.Main
        local T = _UIRefs.TurretBtn or turretBtn
        local mp = M and M.Position
        local tp = T and T.Position
        local lines = {
            "intro=" .. tostring(SelectedIntro or "zenone"),
            "anim=" .. tostring(selectedAnimationPack or "OFF"),
            "keybind=" .. tostring(KEYBIND_TP and KEYBIND_TP.Name or "X"),
            "delayBase=" .. tostring(DELAY_BASE or 0.07),
            "delayPet=" .. tostring(DELAY_PET or 0.07),
            "turretSize=" .. tostring(TURRET_BTN_SIZE or 50),
            "turretShape=" .. tostring(TURRET_SHAPE or "tron"),
            "guiLocked=" .. tostring(isGuiLocked and true or false),
            "minimized=" .. tostring((MINIMIZE == true) and true or false),
            "wallpaper=" .. tostring(CURRENT_WALLPAPER or DEFAULT_BG or ""),
            "tpMiniScale=" .. tostring(TP_MINI_SCALE or 1),
            "mainGuiScale=" .. tostring(MAIN_GUI_SCALE or 1),
            "mainWidthScale=" .. tostring(MAIN_WIDTH_SCALE or 1),
            "trapFloatLocked=" .. tostring(TRAP_FLOAT_LOCKED and true or false),
            "introSong=" .. tostring(INTRO_SONG_INDEX or 1),
        }
        if mp then
            table.insert(lines, string.format("mainPos=%s|%s|%s|%s", tostring(mp.X.Scale), tostring(mp.X.Offset), tostring(mp.Y.Scale), tostring(mp.Y.Offset)))
        end
        if tp then
            table.insert(lines, string.format("turretPos=%s|%s|%s|%s", tostring(tp.X.Scale), tostring(tp.X.Offset), tostring(tp.Y.Scale), tostring(tp.Y.Offset)))
        end
        local trapPos = trapFloatBtn and trapFloatBtn.Position
        if trapPos then
            table.insert(lines, string.format("trapFloatPos=%s|%s|%s|%s", tostring(trapPos.X.Scale), tostring(trapPos.X.Offset), tostring(trapPos.Y.Scale), tostring(trapPos.Y.Offset)))
        end
        if _pickerPos then
            local pp = _pickerPos
            table.insert(lines, string.format("pickerPos=%s|%s|%s|%s", tostring(pp.X.Scale), tostring(pp.X.Offset), tostring(pp.Y.Scale), tostring(pp.Y.Offset)))
        end
        writefile(GUI_CFG_PATH, table.concat(lines, "\n"))
    end)
end
local function LoadGuiConfig()
    local data = {}
    pcall(function()
        if not readfile or not isfile or not isfile(GUI_CFG_PATH) then return end
        for line in readfile(GUI_CFG_PATH):gmatch("[^\r\n]+") do
            local k, v = line:match("^([^=]+)=(.*)$")
            if k and v then data[k] = v end
        end
    end)
    return data
end
local _guiCfg = LoadGuiConfig()
-- apply early values (before GUI widgets exist)
if _guiCfg.intro and _guiCfg.intro ~= "" then SelectedIntro = _guiCfg.intro end
if _guiCfg.anim and _guiCfg.anim ~= "" then
    selectedAnimationPack = _guiCfg.anim
    for i, n in ipairs(AnimationPackList or {}) do
        if n == selectedAnimationPack then AnimationPackIndex = i break end
    end
end
if _guiCfg.turretSize then TURRET_BTN_SIZE = math.clamp(tonumber(_guiCfg.turretSize) or 50, 10, 100) end
if _guiCfg.turretShape and (_guiCfg.turretShape == "tron" or _guiCfg.turretShape == "vuong" or _guiCfg.turretShape == "ngang") then
    TURRET_SHAPE = _guiCfg.turretShape
end
if _guiCfg.delayBase then DELAY_BASE = math.clamp(tonumber(_guiCfg.delayBase) or 0.07, 0.01, 0.50) end
if _guiCfg.delayPet then DELAY_PET = math.clamp(tonumber(_guiCfg.delayPet) or 0.07, 0.01, 0.50) end
if _guiCfg.guiLocked == "true" then isGuiLocked = true end
if _guiCfg.trapFloatLocked == "true" then TRAP_FLOAT_LOCKED = true end
MINIMIZE = true -- forzar inicio compacto
if _guiCfg.wallpaper and _guiCfg.wallpaper ~= "" then CURRENT_WALLPAPER = _guiCfg.wallpaper end
if _guiCfg.tpMiniScale then TP_MINI_SCALE = math.clamp(math.floor(tonumber(_guiCfg.tpMiniScale) or 1), 1, 4) end
if _guiCfg.mainGuiScale then MAIN_GUI_SCALE = math.clamp(math.floor(tonumber(_guiCfg.mainGuiScale) or 1), 1, 2) end
if _guiCfg.mainWidthScale then MAIN_WIDTH_SCALE = math.clamp(math.floor(tonumber(_guiCfg.mainWidthScale) or 1), 1, 10) end
-- introSong chỉ là bài random lúc intro — KHÔNG ghi đè bài user đã chọn
if _guiCfg.introSong then
    INTRO_SONG_INDEX = math.clamp(math.floor(tonumber(_guiCfg.introSong) or 1), 1, 7)
end

-- Ưu tiên Zeno_DuelSong_Config (bài user chọn trước khi nghỉ script)
pcall(function()
    if not readfile or not isfile then return end
    local p = "Zeno_DuelSong_Config.txt"
    if isfile(p) then
        local n = tonumber(readfile(p))
        if n and n >= 1 and n <= #DUEL_SONGS then
            selectedDuelSong = n
        end
    end
end)
if _guiCfg.keybind then
    pcall(function()
        local kc = Enum.KeyCode[_guiCfg.keybind]
        if kc then KEYBIND_TP = kc end
    end)
end
local function parseUDim2(str, default)
    if not str then return default end
    local a,b,c,d = str:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
    if a and b and c and d then
        return UDim2.new(tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0, tonumber(d) or 0)
    end
    return default
end
-- Posición de Gui Image (WallpaperIntroPicker) — lưu khi kéo
local _pickerPos = parseUDim2(_guiCfg and _guiCfg.pickerPos, nil)

-- ============================================================
-- 🛡️ DESTRUCCIÓN AUTOMÁTICA DE TORRETAS — 2 torretas a la vez | acercar a la mano derecha | destrucción muy rápida
-- (style LKZ / Chilli)
-- ============================================================
do
    local autoTurretEnabled  = false
    local turretConns        = {}
    local turretLoopRunning  = false
    local turretAttackBusy   = setmetatable({}, { __mode = "k" })
    local turretAttackQueued = setmetatable({}, { __mode = "k" })
    local turretAttackCD     = setmetatable({}, { __mode = "k" })
    local activeAttacks      = 0
    local MAX_CONCURRENT     = 2
    local RETRY_DELAY        = 0.08
    local MAX_ATTEMPTS       = 28
    local SWING_WAIT         = 0.018
    local PULL_WAIT          = 0.012
    local lp = LocalPlayer

    local function isEnemyTurret(obj)
        if not obj or not obj:IsA("BasePart") then return false end
        local name = obj.Name
        local nameLower = name:lower()
        local ownerId = name:match("^Sentry_(%d+)$")
        if not ownerId then
            if nameLower:find("candy") and nameLower:find("sentry") then
                ownerId = name:match("(%d+)$")
            end
        end
        if not ownerId and nameLower:find("sentry") then
            ownerId = name:match("(%d+)$")
        end
        if not ownerId then
            ownerId = name:match("^[Tt]urret_(%d+)$") or name:match("[Tt]urret_(%d+)")
        end
        if not ownerId then return false end
        return tostring(ownerId) ~= tostring(lp.UserId)
    end

    local function nameLooksTurret(n)
        if not n then return false end
        n = string.lower(n)
        return n:find("sentry", 1, true) or n:find("turret", 1, true)
    end

    local function setTurretNoClip(turret)
        pcall(function()
            turret.CanCollide = false
        end)
    end

    local function shouldAttackTurret(turret)
        if lp:GetAttribute("Stealing") ~= nil then return false end
        if not isEnemyTurret(turret) then return false end
        setTurretNoClip(turret)
        return true
    end

    -- Kéo sát TAY PHẢI (chỗ cầm Bat)
    local function pullTurretToRightHand(turret, char, hrp)
        if not turret or not hrp then return end
        local rightHand = char and (
            char:FindFirstChild("RightHand")
            or char:FindFirstChild("Right Arm")
            or char:FindFirstChild("RightLowerArm")
            or char:FindFirstChild("RightUpperArm")
        )
        local pos, look
        if rightHand then
            local rhCf = rightHand.CFrame
            pos = rhCf.Position + rhCf.LookVector * 0.55 + rhCf.RightVector * 0.05 + Vector3.new(0, 0.05, 0)
            look = rhCf.LookVector
        else
            local cf = hrp.CFrame
            pos = hrp.Position + cf.LookVector * 1.6 + cf.RightVector * 1.1 + Vector3.new(0, 0.45, 0)
            look = cf.LookVector
        end
        local targetCf = CFrame.lookAt(pos, pos + look)
        pcall(function()
            turret.CanCollide = false
            turret.Anchored = true
            turret.AssemblyLinearVelocity = Vector3.zero
            turret.AssemblyAngularVelocity = Vector3.zero
            pcall(function()
                turret.Velocity = Vector3.zero
                turret.RotVelocity = Vector3.zero
            end)
            turret.CFrame = targetCf
        end)
    end

    local function equipAndSwingBat(char, hum)
        local bp = lp:FindFirstChild("Backpack")
        local bat = char:FindFirstChild("Bat") or (bp and bp:FindFirstChild("Bat"))
        if bat and bat.Parent ~= char then
            pcall(function() hum:EquipTool(bat) end)
        end
        bat = char:FindFirstChild("Bat") or bat
        if bat then
            pcall(function() bat:Activate() end)
            task.defer(function()
                pcall(function() if bat and bat.Parent then bat:Activate() end end)
            end)
        end
        return bat
    end

    local function attackTurret(turret)
        local now = os.clock()
        if turretAttackBusy[turret] or turretAttackQueued[turret] then return end
        if not shouldAttackTurret(turret) then return end
        if (turretAttackCD[turret] or 0) > now then return end
        if activeAttacks >= MAX_CONCURRENT then return end

        turretAttackQueued[turret] = true
        turretAttackCD[turret] = now + RETRY_DELAY
        activeAttacks = activeAttacks + 1

        task.spawn(function()
            turretAttackQueued[turret] = nil
            if not shouldAttackTurret(turret) then
                activeAttacks = math.max(0, activeAttacks - 1)
                return
            end
            turretAttackBusy[turret] = true
            pcall(function()
                local attempts = 0
                while attempts < MAX_ATTEMPTS and autoTurretEnabled do
                    if not turret or not turret.Parent or not shouldAttackTurret(turret) then break end
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not hum or hum.Health <= 0 then break end
                    local okD, dist = pcall(function() return (turret.Position - hrp.Position).Magnitude end)
                    if okD and dist > 250 then break end

                    setTurretNoClip(turret)
                    pullTurretToRightHand(turret, char, hrp)
                    equipAndSwingBat(char, hum)
                    task.wait(SWING_WAIT)
                    if turret and turret.Parent then
                        pullTurretToRightHand(turret, char, hrp)
                        equipAndSwingBat(char, hum)
                    end
                    attempts = attempts + 1
                    task.wait(PULL_WAIT)
                end
            end)
            turretAttackBusy[turret] = nil
            activeAttacks = math.max(0, activeAttacks - 1)
        end)
    end

    local function disconnectAll()
        for _, conn in ipairs(turretConns) do pcall(function() conn:Disconnect() end) end
        turretConns = {}
    end

    local function scanAndAttack()
        if not autoTurretEnabled then return end
        pcall(function()
            local found = {}
            local function consider(obj)
                if #found >= 8 then return end
                if obj:IsA("BasePart") and nameLooksTurret(obj.Name) and isEnemyTurret(obj) then
                    setTurretNoClip(obj)
                    if shouldAttackTurret(obj) then
                        table.insert(found, obj)
                    end
                end
            end
            for _, obj in ipairs(Workspace:GetChildren()) do
                consider(obj)
                if obj:IsA("Folder") or obj:IsA("Model") then
                    for _, ch in ipairs(obj:GetChildren()) do
                        consider(ch)
                    end
                end
            end
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and #found > 1 then
                table.sort(found, function(a, b)
                    return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                end)
            end
            for i = 1, math.min(MAX_CONCURRENT, #found) do
                attackTurret(found[i])
            end
        end)
    end

    local function startAutoTurret()
        disconnectAll()
        autoTurretEnabled = true
        activeAttacks = 0
        table.insert(turretConns, Workspace.DescendantAdded:Connect(function(obj)
            if not autoTurretEnabled then return end
            if not obj:IsA("BasePart") then return end
            if not nameLooksTurret(obj.Name) then return end
            if isEnemyTurret(obj) then
                setTurretNoClip(obj)
                if shouldAttackTurret(obj) then
                    task.defer(attackTurret, obj)
                end
            end
        end))
        if not turretLoopRunning then
            turretLoopRunning = true
            task.spawn(function()
                while autoTurretEnabled do
                    scanAndAttack()
                    task.wait(0.12)
                end
                turretLoopRunning = false
            end)
        end
    end

    local function stopAutoTurret()
        autoTurretEnabled = false
        activeAttacks = 0
        disconnectAll()
    end

    function setAutoDestroyTurret(state)
        AUTO_DESTROY_TURRET = state and true or false
        if AUTO_DESTROY_TURRET then startAutoTurret() else stopAutoTurret() end
        pcall(function()
            if turretBtn then
                turretBtn.Text = AUTO_DESTROY_TURRET and "✅" or "🔨"
                turretBtn.BackgroundColor3 = AUTO_DESTROY_TURRET and Color3.fromRGB(30,120,70) or Color3.fromRGB(40,40,60)
                local st = turretBtn:FindFirstChildOfClass("UIStroke")
                if st then st.Color = AUTO_DESTROY_TURRET and Color3.fromRGB(80,255,140) or Color3.fromRGB(255,70,90) end
            end
            if BtnTurret then
                BtnTurret.Text = AUTO_DESTROY_TURRET and "Destrucción de torretas: ACTIVADA" or "Destrucción de torretas: DESACTIVADA"
            end
        end)
    end
end

-- === ACTUALIZAR TAMAÑO + FORMA DEL BOTÓN DE DESTRUCCIÓN ===
local function UpdateTurretBtnStyle()
    if not turretBtn then return end
    local corner = turretBtn:FindFirstChildOfClass("UICorner")
    if not corner then
        corner = Instance.new("UICorner")
        corner.Parent = turretBtn
    end
    if TURRET_SHAPE == "tron" then
        turretBtn.Size = UDim2.new(0, TURRET_BTN_SIZE, 0, TURRET_BTN_SIZE)
        corner.CornerRadius = UDim.new(1, 0)
    elseif TURRET_SHAPE == "vuong" then
        turretBtn.Size = UDim2.new(0, TURRET_BTN_SIZE, 0, TURRET_BTN_SIZE)
        corner.CornerRadius = UDim.new(0, 6)
    elseif TURRET_SHAPE == "ngang" then
        turretBtn.Size = UDim2.new(0, TURRET_BTN_SIZE * 1.8, 0, TURRET_BTN_SIZE * 0.55)
        corner.CornerRadius = UDim.new(1, 0)
    end
end

-- Botón flotante del martillo eliminado.
-- La lógica completa de Anti Ragdoll fue ELIMINADA
-- === ANTI GUMMY (mantener) — eliminado sơn / boogie / bee ===
local AntiGummy = true

local function ResetTool(Char)
    if not Char then Char = LocalPlayer.Character end
    if not Char then return end
    pcall(function()
        LocalPlayer:SetAttribute("BlockTools", false)
        LocalPlayer:SetAttribute("Web", false)
        Char:SetAttribute("BackpackReady", true)
    end)
end

do
    local _gummyAcc = 0
    RunService.Heartbeat:Connect(function(dt)
        if not AntiGummy then return end
        _gummyAcc = _gummyAcc + (dt or 0.016)
        if _gummyAcc < 0.35 then return end
        _gummyAcc = 0
        ResetTool()
    end)
end

-- ============================================================
-- 🧭 SISTEMA DE TP
-- ============================================================
local function FixCam()
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    if Hum then Camera.CameraSubject = Hum end
end
local function SmoothTP(hrp, pos)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    local tween = TweenService:Create(hrp, TweenInfo.new(0.065, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
    FixCam()
end
-- ============================================================
-- 🪽 OBJETO DE VUELO PARA TP
-- Permite elegir Cupid's Wings, Flying Carpet o Santa's Sleigh.
-- Si el elegido no está disponible, prueba automáticamente los demás.
-- ============================================================
local CARPET_LIST = {"Cupid's Wings", "Flying Carpet", "Santa's Sleigh"}
local SelectedFlyTool = "Cupid's Wings"

pcall(function()
    if readfile and isfile then
        local p = "Zeno_FlyTool_Config.txt"
        if isfile(p) then
            local saved = readfile(p)
            if saved == "Cupid's Wings" or saved == "Flying Carpet" or saved == "Santa's Sleigh" then
                SelectedFlyTool = saved
            end
        end
    end
end)

local function SaveFlyToolCfg()
    pcall(function()
        if writefile then
            writefile("Zeno_FlyTool_Config.txt", SelectedFlyTool)
        end
    end)
end

local function EquipFly(Char)
    local H = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Char or not H then return nil end

    -- Primero intenta SOLO el objeto seleccionado.
    local preferred = SelectedFlyTool
    local fallbackList = {}
    for _, toolName in ipairs(CARPET_LIST) do
        if toolName ~= preferred then
            table.insert(fallbackList, toolName)
        end
    end

    local function findAndEquip(toolName)
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        local foundGear = Char:FindFirstChild(toolName)
            or (backpack and backpack:FindFirstChild(toolName))
        if foundGear then
            local ok = pcall(function()
                H:EquipTool(foundGear)
            end)
            if ok then
                return foundGear
            end
        end
        return nil
    end

    -- Si está el elegido, NO equipa el otro.
    local equipped = findAndEquip(preferred)
    if equipped then
        return equipped
    end

    -- Si el elegido no existe, prueba los demás objetos de la lista como respaldo.
    for _, fallback in ipairs(fallbackList) do
        local backup = findAndEquip(fallback)
        if backup then
            return backup
        end
    end
    return nil
end
-- Noclip temporal durante el descenso (xuyên market / mái)
local function setCharNoclip(char, on)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.CanCollide = not on end)
        end
    end
end
-- Chilli TP to best + Anti Die (từ anti die full logic) — chỉ bọc lúc Chilli TP
local _chilliAntiDieToken = 0
local function enableChilliAntiDie(hum, char, duration)
    if not hum or not char then return function() end end
    _chilliAntiDieToken = _chilliAntiDieToken + 1
    local myToken = _chilliAntiDieToken
    local conns = {}

    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end)

    table.insert(conns, hum:GetPropertyChangedSignal("Health"):Connect(function()
        if myToken ~= _chilliAntiDieToken then return end
        if hum and hum.Parent and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end))

    local function onDied()
        if myToken ~= _chilliAntiDieToken then return end
        task.defer(function()
            if myToken ~= _chilliAntiDieToken then return end
            if hum and hum.Parent then
                pcall(function()
                    hum.Health = hum.MaxHealth
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end)
    end
    table.insert(conns, hum.Died:Connect(onDied))

    pcall(function()
        if char:GetAttribute("BreakJoints") ~= nil then
            char:SetAttribute("BreakJoints", false)
        end
    end)

    local function disable()
        if myToken ~= _chilliAntiDieToken then return end
        _chilliAntiDieToken = _chilliAntiDieToken + 1
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        pcall(function()
            if hum and hum.Parent then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end)
    end

    if duration and duration > 0 then
        task.delay(duration, disable)
    end
    return disable
end

local function getLandPos(targetPos, char, hrp, hum)
    local landY = targetPos.Y
    pcall(function()
        local ignore = {char}
        for _, p in ipairs(Workspace:GetChildren()) do
            if p.Name == "SavePoint" then table.insert(ignore, p) end
        end
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = ignore
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local origin = Vector3.new(targetPos.X, math.max(targetPos.Y, 0) + 100, targetPos.Z)
        local hit = Workspace:Raycast(origin, Vector3.new(0, -400, 0), rayParams)
        if hit then
            local offset = (hum and hum.HipHeight or 2) + ((hrp and hrp.Size.Y or 2) / 2)
            landY = hit.Position.Y + offset
        end
    end)
    return Vector3.new(targetPos.X, landY, targetPos.Z)
end

-- CHILLI TP RÁPIDO: elevación corta → vuelo directo → descenso inmediato al suelo (Ace style)
local function ChilliTPToBest(hrp, targetPos, char)
    if not hrp or not targetPos then return end
    char = char or LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    enableChilliAntiDie(hum, char, 1.2)
    pcall(function() hum.Health = hum.MaxHealth end)

    EquipFly(char)
    task.wait(0.02)

    local function stopVel()
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    -- 1) NHẤC BỔNG NHANH (Ace drop ascend rút ngắn)
    local ASCEND_DUR = 0.06
    local ASCEND_SPD = 120
    local t0 = tick()
    while tick() - t0 < ASCEND_DUR do
        if not hrp or not hrp.Parent then return end
        pcall(function()
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, ASCEND_SPD, v.Z)
        end)
        RunService.Heartbeat:Wait()
    end

    -- 2) BAY THẲNG QUA điểm save (CFrame 1 lần, cao vừa để drop nhanh)
    local airY = targetPos.Y + 8
    stopVel()
    pcall(function()
        hrp.CFrame = CFrame.new(targetPos.X, airY, targetPos.Z)
        hrp.AssemblyLinearVelocity = Vector3.new(0, -200, 0) -- bắt đầu đập ngay
    end)

    -- 3) DROP ĐẬP ĐẤT NGAY như Ace (raycast + snap, chờ tối đa rất ngắn)
    local landY = targetPos.Y
    pcall(function()
        local ignore = {char}
        for _, p in ipairs(Workspace:GetChildren()) do
            if p.Name == "SavePoint" then table.insert(ignore, p) end
        end
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = ignore
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local origin = Vector3.new(targetPos.X, airY + 5, targetPos.Z)
        local hit = Workspace:Raycast(origin, Vector3.new(0, -400, 0), rayParams)
        if hit then
            local offset = (hum.HipHeight or 2) + (hrp.Size.Y / 2)
            landY = hit.Position.Y + offset
        end
    end)
    local landPos = Vector3.new(targetPos.X, landY, targetPos.Z)

    -- Chỉ chờ 1–2 frame rơi rồi snap (nhanh như Ace drop)
    local fallT = tick()
    while tick() - fallT < 0.10 do
        if not hrp or not hrp.Parent then break end
        if hrp.Position.Y <= landY + 6 then break end
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(0, -220, 0)
        end)
        RunService.Heartbeat:Wait()
    end

    pcall(function()
        hrp.CFrame = CFrame.new(landPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    stopVel()

    pcall(function()
        hum.Sit = false
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum.Health = hum.MaxHealth
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
    FixCam()
end

local function Marker(Pos, Col)
    local P = Instance.new("Part")
    P.Shape = Enum.PartType.Ball
    P.Size = Vector3.new(2,2,2)
    P.Material = Enum.Material.Neon
    P.Anchored = true
    P.CanCollide = false
    P.CanQuery = false
    P.CanTouch = false
    P.Transparency = 0.15
    P.Position = Pos + Vector3.new(0,2,0)
    P.Color = Col
    P.Name = "SavePoint"
    P.Parent = Workspace
    return P
end
-- ============================================================
-- 🖥️ GUI PRINCIPAL
-- ============================================================
local UI = Instance.new("ScreenGui")
UI.Name = "MIAU_TP_UI"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.DisplayOrder = 10000
local Parent = nil
pcall(function() if syn and syn.protect_gui then syn.protect_gui(UI) end end)
pcall(function() if gethui then Parent = gethui() end end)
if not Parent then pcall(function() Parent = game:GetService("CoreGui") end) end
if not Parent then Parent = LocalPlayer.PlayerGui end
UI.Parent = Parent
local Main = Instance.new("ImageLabel")
Main.Size = UDim2.new(0,240,0,350)
Main.Position = UDim2.new(0.5,-120,0.5,-175)
Main.Image = CURRENT_WALLPAPER or DEFAULT_BG
Main.ImageColor3 = Color3.fromRGB(220,220,220)
Main.Active = true
Main.Draggable = true
Main.Visible = false -- ẩn đến khi intro xong
Main.Parent = UI
-- load vị trí main menu đã lưu
if _guiCfg and _guiCfg.mainPos then
    Main.Position = parseUDim2(_guiCfg.mainPos, Main.Position)
end
Main.Draggable = not isGuiLocked
_UIRefs.Main = Main
-- lưu vị trí khi kéo menu
Main:GetPropertyChangedSignal("Position"):Connect(function()
    task.delay(0.35, function() pcall(SaveGuiConfig) end)
end)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)
local Bg = Instance.new("Frame")
Bg.Size = UDim2.new(1,0,1,0)
Bg.BackgroundColor3 = Color3.fromRGB(12,8,18)
Bg.BackgroundTransparency = 0.45
Bg.BorderSizePixel = 0
Bg.Parent = Main
Instance.new("UICorner", Bg).CornerRadius = UDim.new(0,14)
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2.5
Stroke.Parent = Main
task.spawn(function() while true do
    TweenService:Create(Stroke, TweenInfo.new(1.5), {Color = Color3.fromRGB(255,105,180)}):Play()
    task.wait(1.5)
    TweenService:Create(Stroke, TweenInfo.new(1.5), {Color = Color3.fromRGB(140,85,255)}):Play()
    task.wait(1.5)
end end)
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 58, 0, 22)
LockBtn.Position = UDim2.new(0, 8, 0, 5)
LockBtn.BackgroundTransparency = 1
LockBtn.Text = "DESBLOQUEAR"
LockBtn.TextColor3 = Color3.new(1,1,1)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 12
LockBtn.Parent = Main
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 6)
local LockStroke = Instance.new("UIStroke")
LockStroke.Thickness = 1.5
LockStroke.Transparency = 0.3
LockStroke.Color = Color3.fromRGB(140, 85, 255)
LockStroke.Parent = LockBtn
LockBtn.MouseButton1Click:Connect(function()
    isGuiLocked = not isGuiLocked
    -- Unlock → kéo được cả khi thu gọn (chỉ còn TP)
    Main.Draggable = not isGuiLocked
    LockBtn.Text = isGuiLocked and "BLOQUEAR" or "DESBLOQUEAR"
    LockStroke.Color = isGuiLocked and Color3.fromRGB(255, 80, 110) or Color3.fromRGB(140, 85, 255)
    pcall(SaveGuiConfig)
end)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 22)
Title.Position = UDim2.new(0, 68, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MIAU TP"
Title.TextSize = 15
Title.Font = Enum.Font.FredokaOne
Title.TextColor3 = Color3.new(1,1,1)
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = Main
local BtnClose = Instance.new("TextButton")
BtnClose.Size = UDim2.new(0,22,0,22)
BtnClose.Position = UDim2.new(1,-26,0,5)
BtnClose.BackgroundTransparency = 1
BtnClose.Text = "X"
BtnClose.TextSize = 13
BtnClose.Font = Enum.Font.GothamBold
BtnClose.Parent = Main
Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(1,0)
local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 1.5
CloseStroke.Color = Color3.fromRGB(255,65,110)
CloseStroke.Parent = BtnClose
local Ping = Instance.new("TextButton")
Ping.Size = UDim2.new(0,32,0,22)
Ping.Position = UDim2.new(1,-62,0,5)
Ping.Text = "---ms"
Ping.TextSize = 11
Ping.Font = Enum.Font.GothamBold
Ping.TextColor3 = Color3.new(1,1,1)
Ping.BackgroundTransparency = 1
Ping.Parent = Main
Instance.new("UICorner", Ping).CornerRadius = UDim.new(0,6)
local PingStroke = Instance.new("UIStroke")
PingStroke.Thickness = 1.5
PingStroke.Color = Color3.fromRGB(80,80,80)
PingStroke.Parent = Ping
task.spawn(function() while true do
    local P = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
    Ping.Text = P.."ms"
    PingStroke.Color = P < 50 and Color3.fromRGB(40,200,90) or P < 100 and Color3.fromRGB(230,190,40) or P < 200 and Color3.fromRGB(255,110,40) or Color3.fromRGB(220,50,50)
    task.wait(0.5)
end end)
local State = Instance.new("TextLabel")
State.Size = UDim2.new(1,-15,0,16)
State.Position = UDim2.new(0,8,0,31)
State.BackgroundTransparency = 1
State.TextSize = 11
State.Font = Enum.Font.GothamBold
State.Parent = Main
do
    local _stAcc = 0
    RunService.Heartbeat:Connect(function(dt)
        _stAcc = _stAcc + (dt or 0.016)
        if _stAcc < 0.25 then return end
        _stAcc = 0
        if not State or not State.Parent then return end
        if not SAVE_BASE and not SAVE_PET then
            State.Text = "No hay puntos guardados"
            State.TextColor3 = Color3.fromRGB(255,180,80)
            return
        end
        if (SAVE_BASE and not SAVE_PET) or (SAVE_PET and not SAVE_BASE) then
            State.Text = "1 punto · Chilli JumpDrop"
            State.TextColor3 = Color3.fromRGB(255,200,80)
            return
        end
        State.Text = IS_RAGDOLL and "Ragdoll TP" or "2 puntos · Normal"
        State.TextColor3 = IS_RAGDOLL and Color3.fromRGB(255,80,80) or Color3.fromRGB(80,255,120)
    end)
end
local AR_Text = Instance.new("TextLabel")
AR_Text.Size = UDim2.new(1,-15,0,18)
AR_Text.Position = UDim2.new(0,8,0,48)
AR_Text.BackgroundTransparency = 1
AR_Text.Text = "Vua Tuat😏"
AR_Text.TextSize = 11
AR_Text.Font = Enum.Font.GothamBold
AR_Text.TextColor3 = Color3.fromRGB(80,255,140)
AR_Text.Parent = Main
-- Scroll body (kéo xuống như Gui Image) — header cố định
local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Name = "MainScroll"
MainScroll.Size = UDim2.new(1, -8, 1, -108)
MainScroll.Position = UDim2.new(0, 4, 0, 68)
MainScroll.BackgroundTransparency = 1
MainScroll.BorderSizePixel = 0
MainScroll.ScrollBarThickness = 5
MainScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 90, 255)
MainScroll.ScrollingDirection = Enum.ScrollingDirection.Y
MainScroll.CanvasSize = UDim2.new(0, 0, 0, 480)
MainScroll.Active = true
MainScroll.ClipsDescendants = true
MainScroll.Parent = Main

local ScrollContent = Instance.new("Frame")
ScrollContent.Name = "ScrollContent"
ScrollContent.Size = UDim2.new(1, -6, 0, 456)
ScrollContent.BackgroundTransparency = 1
ScrollContent.Parent = MainScroll


-- ============================================================
-- 🪤 SISTEMA DE TRAP | STEAL A BRAINROT
-- Usa ÚNICAMENTE la Tool llamada exactamente "Trap".
-- El botón es independiente del TP, circular, móvil y bloqueable.
-- ============================================================
local TRAP_ACTIVE = false

local function GetExactTrap()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

    -- Primero la que ya esté equipada.
    if char then
        local tool = char:FindFirstChild("Trap")
        if tool and tool:IsA("Tool") and tool.Name == "Trap" then
            return tool
        end
    end

    -- Después la del Backpack. No se aceptan variantes como Cake Trap,
    -- Bear Trap, Trampa, Subspace Mine, etc.
    if backpack then
        local tool = backpack:FindFirstChild("Trap")
        if tool and tool:IsA("Tool") and tool.Name == "Trap" then
            return tool
        end
    end

    return nil
end

local function EquipAndPlaceTrap()
    if TRAP_ACTIVE then return false, "Ya colocando..." end
    TRAP_ACTIVE = true

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then
        TRAP_ACTIVE = false
        return false, "Sin personaje"
    end

    -- IMPORTANTE: solo se acepta la Tool con el nombre EXACTO "Trap".
    -- No se equipa ni activa ninguna otra herramienta.
    local trap = GetExactTrap()
    if not trap or trap.Name ~= "Trap" or not trap:IsA("Tool") then
        TRAP_ACTIVE = false
        return false, "No tienes Trap"
    end

    local equipped = false
    local equipOk = pcall(function()
        if trap.Parent ~= char then
            hum:EquipTool(trap)
        end
        -- Comprobación inmediata: no continuar si no quedó equipada.
        equipped = trap.Parent == char and trap.Name == "Trap" and trap:IsA("Tool")
    end)

    if not equipOk or not equipped then
        TRAP_ACTIVE = false
        return false, "No se pudo equipar Trap"
    end

    -- EQUIPAR -> ACTIVAR inmediatamente.
    -- Solo se llama Activate() sobre la Tool exacta "Trap".
    local activated = pcall(function()
        if trap.Parent == char and trap.Name == "Trap" then
            trap:Activate()
        end
    end)

    TRAP_ACTIVE = false
    return activated, activated and "Trap colocada" or "No se pudo activar Trap"
end

local function NewBtn(Txt, Pos, Col)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0,220,0,32)
    B.Position = Pos
    B.BackgroundTransparency = 1
    B.Text = Txt
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.AutoLocalize = false
    B.Parent = ScrollContent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0,10)
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1.5
    BtnStroke.Transparency = 0.4
    BtnStroke.Color = Col
    BtnStroke.Parent = B
    B.MouseEnter:Connect(function() TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 0}) end)
    B.MouseLeave:Connect(function() TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 0.4}) end)
    return B
end
local function NewMinBtn(Txt, Pos, Col)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0,24,0,24)
    B.Position = Pos
    B.BackgroundTransparency = 1
    B.Text = Txt
    B.TextSize = 15
    B.Font = Enum.Font.GothamBold
    B.AutoLocalize = false
    B.Parent = ScrollContent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0,7)
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1.5
    BtnStroke.Transparency = 0.4
    BtnStroke.Color = Col
    BtnStroke.Parent = B
    B.MouseEnter:Connect(function() TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 0}) end)
    B.MouseLeave:Connect(function() TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Transparency = 0.4}) end)
    return B
end
local BtnSaveBase = NewBtn("Guardar Base", UDim2.new(0.5,-110,0,4), Color3.fromRGB(150,90,255))
local LblBase = Instance.new("TextLabel")
LblBase.Size = UDim2.new(0,100,0,24)
LblBase.Position = UDim2.new(0,8,0,40)
LblBase.BackgroundTransparency = 1
LblBase.Text = "Base: "..string.format("%.2f",DELAY_BASE).."s"
LblBase.TextColor3 = Color3.fromRGB(200,170,255)
LblBase.TextSize = 11
LblBase.Parent = ScrollContent
local BaseMin = NewMinBtn("-", UDim2.new(0,112,0,40), Color3.fromRGB(220,80,80))
local BasePlus = NewMinBtn("+", UDim2.new(0,140,0,40), Color3.fromRGB(70,190,120))
local BtnSavePet = NewBtn("Guardar Pet", UDim2.new(0.5,-110,0,72), Color3.fromRGB(255,130,45))
local LblPet = Instance.new("TextLabel")
LblPet.Size = UDim2.new(0,100,0,24)
LblPet.Position = UDim2.new(0,8,0,108)
LblPet.BackgroundTransparency = 1
LblPet.Text = "Pet: "..string.format("%.2f",DELAY_PET).."s"
LblPet.TextColor3 = Color3.fromRGB(255,200,150)
LblPet.TextSize = 11
LblPet.Parent = ScrollContent
local PetMin = NewMinBtn("-", UDim2.new(0,112,0,108), Color3.fromRGB(220,80,80))
local PetPlus = NewMinBtn("+", UDim2.new(0,140,0,108), Color3.fromRGB(70,190,120))

local BtnSetKey = Instance.new("TextButton")
BtnSetKey.Size = UDim2.new(0, 220, 0, 20)
BtnSetKey.Position = UDim2.new(0.5, -110, 0, 244)
BtnSetKey.BackgroundTransparency = 1
BtnSetKey.Text = "TECLA TP: ["..KEYBIND_TP.Name.."]"
BtnSetKey.TextColor3 = Color3.fromRGB(0, 120, 220)
BtnSetKey.Font = Enum.Font.GothamBold
BtnSetKey.TextSize = 11
BtnSetKey.AutoLocalize = false
BtnSetKey.Parent = ScrollContent
BtnSetKey.MouseEnter:Connect(function() BtnSetKey.TextColor3 = Color3.fromRGB(40, 160, 255) end)
BtnSetKey.MouseLeave:Connect(function() BtnSetKey.TextColor3 = Color3.fromRGB(0, 120, 220) end)
BtnSetKey.MouseButton1Click:Connect(function()
    if not IS_SET_KEY then
        IS_SET_KEY = true
        BtnSetKey.Text = "🔄 ELIGE UNA TECLA..."
    end
end)

-- ============================================================
-- 🪽 SELECTOR DE OBJETO DE VUELO
-- Al pulsar TP se equipa el objeto seleccionado.
-- Si no lo tienes, se prueba automáticamente otro disponible de la lista.
-- ============================================================
local BtnFlyTool = NewBtn("Objeto TP: "..SelectedFlyTool, UDim2.new(0.5,-110,0,272), Color3.fromRGB(100,80,200))
BtnFlyTool.MouseButton1Click:Connect(function()
    local currentIndex = table.find(CARPET_LIST, SelectedFlyTool) or 1
    currentIndex = (currentIndex % #CARPET_LIST) + 1
    SelectedFlyTool = CARPET_LIST[currentIndex]
    BtnFlyTool.Text = "Objeto TP: "..SelectedFlyTool
    SaveFlyToolCfg()
end)

-- Anim / Duel Song CHỈ trong Gui Image (không hiện main)
local BtnAnimPack = nil
local BtnDuelSong = nil
local BtnStopSong = nil
local BtnWallpaper = NewBtn("Gui Image", UDim2.new(0.5,-110,0,380), Color3.fromRGB(100,80,200))

-- TP thu gọn: chỉ cao hơn (1–4)
local LblTpScale = Instance.new("TextLabel")
LblTpScale.Size = UDim2.new(0, 140, 0, 22)
LblTpScale.Position = UDim2.new(0, 8, 0, 348)
LblTpScale.BackgroundTransparency = 1
LblTpScale.Text = "Altura TP: x"..tostring(TP_MINI_SCALE)
LblTpScale.TextColor3 = Color3.fromRGB(180, 220, 255)
LblTpScale.TextSize = 11
LblTpScale.Font = Enum.Font.GothamBold
LblTpScale.Parent = ScrollContent
local TpScaleMin = NewMinBtn("-", UDim2.new(0, 152, 0, 346), Color3.fromRGB(220,80,80))
local TpScalePlus = NewMinBtn("+", UDim2.new(0, 180, 0, 346), Color3.fromRGB(70,190,120))
TpScaleMin.MouseButton1Click:Connect(function()
    TP_MINI_SCALE = math.max(1, (TP_MINI_SCALE or 1) - 1)
    LblTpScale.Text = "Altura TP: x"..tostring(TP_MINI_SCALE)
    if MINIMIZE then ApplyMinimize(true) end
    pcall(SaveGuiConfig)
end)
TpScalePlus.MouseButton1Click:Connect(function()
    TP_MINI_SCALE = math.min(4, (TP_MINI_SCALE or 1) + 1)
    LblTpScale.Text = "Altura TP: x"..tostring(TP_MINI_SCALE)
    if MINIMIZE then ApplyMinimize(true) end
    pcall(SaveGuiConfig)
end)

-- Ancho de la GUI x1–x10 (+1 mỗi lần)
local LblMainW = Instance.new("TextLabel")
LblMainW.Size = UDim2.new(0, 140, 0, 22)
LblMainW.Position = UDim2.new(0, 8, 0, 340)
LblMainW.BackgroundTransparency = 1
LblMainW.Text = "Ancho GUI: x"..tostring(MAIN_WIDTH_SCALE or 1)
LblMainW.TextColor3 = Color3.fromRGB(180, 255, 200)
LblMainW.TextSize = 11
LblMainW.Font = Enum.Font.GothamBold
LblMainW.Parent = ScrollContent
local MainWMin = NewMinBtn("-", UDim2.new(0, 152, 0, 338), Color3.fromRGB(220,80,80))
local MainWPlus = NewMinBtn("+", UDim2.new(0, 180, 0, 338), Color3.fromRGB(70,190,120))
MainWMin.MouseButton1Click:Connect(function()
    MAIN_WIDTH_SCALE = math.max(1, (MAIN_WIDTH_SCALE or 1) - 1)
    LblMainW.Text = "Ancho GUI: x"..tostring(MAIN_WIDTH_SCALE)
    if type(ApplyMinimize) == "function" then ApplyMinimize(MINIMIZE) end
    pcall(SaveGuiConfig)
end)
MainWPlus.MouseButton1Click:Connect(function()
    MAIN_WIDTH_SCALE = math.min(10, (MAIN_WIDTH_SCALE or 1) + 1)
    LblMainW.Text = "Ancho GUI: x"..tostring(MAIN_WIDTH_SCALE)
    if type(ApplyMinimize) == "function" then ApplyMinimize(MINIMIZE) end
    pcall(SaveGuiConfig)
end)

MainScroll.CanvasSize = UDim2.new(0, 0, 0, 416)

-- TP siempre sobre Main (không trong scroll) — visible al minimizar
local BtnTP = Instance.new("TextButton")
BtnTP.Size = UDim2.new(0,220,0,42)
BtnTP.Position = UDim2.new(0.5,-110,1,-50)
BtnTP.BackgroundTransparency = 1
BtnTP.Text = "TP ["..KEYBIND_TP.Name.."]"
BtnTP.TextColor3 = Color3.new(1,1,1)
BtnTP.Font = Enum.Font.GothamBold
BtnTP.TextSize = 16
BtnTP.AutoLocalize = false
BtnTP.ZIndex = 5
BtnTP.Parent = Main
Instance.new("UICorner", BtnTP).CornerRadius = UDim.new(0,10)
local TpStroke = Instance.new("UIStroke")
TpStroke.Thickness = 1.8
TpStroke.Transparency = 0.3
TpStroke.Color = Color3.fromRGB(0,185,135)
TpStroke.Parent = BtnTP
BtnTP.MouseEnter:Connect(function() TweenService:Create(TpStroke, TweenInfo.new(0.2), {Transparency = 0}) end)
BtnTP.MouseLeave:Connect(function() TweenService:Create(TpStroke, TweenInfo.new(0.2), {Transparency = 0.3}) end)

-- 🪤 BOTÓN FLOTANTE DE TRAP — separado completamente del TP
local TrapFloatDefaultPos = UDim2.new(1, -88, 0.55, 0)
local BtnTrapMini = Instance.new("TextButton") -- se conserva el nombre interno para compatibilidad
BtnTrapMini.Name = "TrapFloating"
BtnTrapMini.Size = UDim2.new(0, 62, 0, 62)
BtnTrapMini.Position = TrapFloatDefaultPos
BtnTrapMini.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
BtnTrapMini.BackgroundTransparency = 0.08
BtnTrapMini.Text = "🪤"
BtnTrapMini.TextColor3 = Color3.new(1,1,1)
BtnTrapMini.Font = Enum.Font.GothamBold
BtnTrapMini.TextSize = 30
BtnTrapMini.AutoLocalize = false
BtnTrapMini.ZIndex = 20
BtnTrapMini.Visible = false
BtnTrapMini.Active = true
BtnTrapMini.Parent = UI
local trapCorner = Instance.new("UICorner", BtnTrapMini)
trapCorner.CornerRadius = UDim.new(1, 0)
local TrapFloatStroke = Instance.new("UIStroke")
TrapFloatStroke.Thickness = 2.2
TrapFloatStroke.Transparency = 0.05
TrapFloatStroke.Color = Color3.fromRGB(255, 80, 110)
TrapFloatStroke.Parent = BtnTrapMini

-- Restaurar posición guardada del botón flotante.
if _guiCfg and _guiCfg.trapFloatPos then
    BtnTrapMini.Position = parseUDim2(_guiCfg.trapFloatPos, TrapFloatDefaultPos)
end
trapFloatBtn = BtnTrapMini
_UIRefs.TrapBtn = BtnTrapMini

-- Candado pequeño e independiente. Al bloquear, el círculo deja de moverse.
local TrapLock = Instance.new("TextButton")
TrapLock.Name = "TrapLock"
TrapLock.Size = UDim2.new(0, 24, 0, 24)
TrapLock.Position = UDim2.new(1, -18, 0, -7)
TrapLock.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TrapLock.BackgroundTransparency = 0.05
TrapLock.Text = TRAP_FLOAT_LOCKED and "🔒" or "🔓"
TrapLock.TextSize = 13
TrapLock.Font = Enum.Font.GothamBold
TrapLock.ZIndex = 22
TrapLock.AutoLocalize = false
TrapLock.Parent = BtnTrapMini
Instance.new("UICorner", TrapLock).CornerRadius = UDim.new(1, 0)
local TrapLockStroke = Instance.new("UIStroke")
TrapLockStroke.Thickness = 1.3
TrapLockStroke.Color = TRAP_FLOAT_LOCKED and Color3.fromRGB(255,80,110) or Color3.fromRGB(140,85,255)
TrapLockStroke.Parent = TrapLock
trapFloatLockBtn = TrapLock

-- Evita que tocar el candado se interprete también como un toque para colocar Trap.
local trapLockTouching = false
TrapLock.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        trapLockTouching = true
    end
end)

local function UpdateTrapFloatLock()
    TrapLock.Text = TRAP_FLOAT_LOCKED and "🔒" or "🔓"
    TrapLockStroke.Color = TRAP_FLOAT_LOCKED and Color3.fromRGB(255,80,110) or Color3.fromRGB(140,85,255)
    BtnTrapMini.Active = not TRAP_FLOAT_LOCKED
    pcall(function() BtnTrapMini.Draggable = not TRAP_FLOAT_LOCKED end)
end
UpdateTrapFloatLock()

-- Movimiento táctil/ratón del círculo. Solo funciona cuando está desbloqueado.
local trapDragging = false
local trapDragStart = nil
local trapStartPos = nil
local trapMoved = false
local trapDragInput = nil
local trapPressInput = nil -- SOLO permite colocar Trap si el toque empezó en el botón

BtnTrapMini.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- El candado SOLO bloquea el movimiento; NO bloquea el uso de la Trap.
        -- Cuando está bloqueado, un toque corto sobre el círculo sigue colocando Trap.
        trapMoved = false
        trapDragStart = input.Position
        trapStartPos = BtnTrapMini.Position
        trapDragInput = input
        trapPressInput = input -- guardar exactamente el toque que empezó sobre el círculo
        trapDragging = not TRAP_FLOAT_LOCKED
    end
end)

BtnTrapMini.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        trapDragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if not trapDragging or TRAP_FLOAT_LOCKED then return end
    if input ~= trapDragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - trapDragStart
    if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then trapMoved = true end
    BtnTrapMini.Position = UDim2.new(
        trapStartPos.X.Scale, trapStartPos.X.Offset + delta.X,
        trapStartPos.Y.Scale, trapStartPos.Y.Offset + delta.Y
    )
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    -- MUY IMPORTANTE: este evento es global. Solo reaccionamos si el toque
    -- empezó realmente sobre el círculo de Trap. Así comprar Trap en la tienda
    -- o tocar cualquier otra parte de la pantalla NO la equipa ni la coloca.
    if input ~= trapPressInput then
        return
    end
    trapPressInput = nil

    if trapLockTouching then
        trapLockTouching = false
        trapDragging = false
        trapMoved = false
        return
    end

    local wasTap = not trapMoved
    local wasDragging = trapDragging
    trapDragging = false

    if wasTap then
        -- SOLO una pulsación real sobre el círculo coloca la Tool exacta "Trap".
        task.spawn(function()
            BtnTrapMini.Text = "⏳"
            local ok = EquipAndPlaceTrap()
            BtnTrapMini.Text = ok and "✅" or "🪤"
            task.wait(0.45)
            if BtnTrapMini.Parent then BtnTrapMini.Text = "🪤" end
        end)
    elseif wasDragging then
        pcall(SaveGuiConfig)
    end
end)

TrapLock.MouseButton1Click:Connect(function()
    TRAP_FLOAT_LOCKED = not TRAP_FLOAT_LOCKED
    UpdateTrapFloatLock()
    pcall(SaveGuiConfig)
end)

-- El círculo sigue siendo visible tanto con el menú abierto como minimizado.
-- ============================================================
-- 🎨 SELECTOR DE FONDO + INTRO (POSICIÓN FIJA)
-- ============================================================
local _wallpaperPickerGui = nil
local function ShowWallpaperIntroPicker()
    -- Pulsar por segunda vez → cerrar Gui Image (lưu vị trí trước)
    if _wallpaperPickerGui and _wallpaperPickerGui.Parent then
        pcall(function()
            local fr = _wallpaperPickerGui:FindFirstChildOfClass("Frame")
            if fr then
                _pickerPos = fr.Position
                pcall(SaveGuiConfig)
            end
        end)
        pcall(function() _wallpaperPickerGui:Destroy() end)
        _wallpaperPickerGui = nil
        return
    end
    -- Eliminar la versión anterior si quedó abierta
    pcall(function()
        local old = Parent and Parent:FindFirstChild("WallpaperIntroPicker")
        if old then old:Destroy() end
        local cg = game:GetService("CoreGui"):FindFirstChild("WallpaperIntroPicker")
        if cg then cg:Destroy() end
        if LocalPlayer.PlayerGui then
            local pg = LocalPlayer.PlayerGui:FindFirstChild("WallpaperIntroPicker")
            if pg then pg:Destroy() end
        end
    end)

    local picker = Instance.new("ScreenGui")
    picker.Name = "WallpaperIntroPicker"
    picker.IgnoreGuiInset = true
    picker.DisplayOrder = 999999
    picker.Parent = Parent
    _wallpaperPickerGui = picker
    picker.Destroying:Connect(function()
        if _wallpaperPickerGui == picker then _wallpaperPickerGui = nil end
    end)

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 360, 0, 480)
    bg.Position = _pickerPos or UDim2.new(0.02, 0, 0.5, -240)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    bg.BackgroundTransparency = 0.08
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", bg).Color = Color3.fromRGB(140, 90, 255)
    bg.Active = true
    bg.Draggable = true
    bg.Parent = picker

    -- Guardar la posición de Gui Image al arrastrar
    local function savePickerPos()
        if not bg or not bg.Parent then return end
        _pickerPos = bg.Position
        pcall(SaveGuiConfig)
    end
    bg:GetPropertyChangedSignal("Position"):Connect(function()
        task.delay(0.25, savePickerPos)
    end)
    if UIS then
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if bg and bg.Parent then savePickerPos() end
            end
        end)
    end

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "GUI IMAGE / MÚSICA / ANIMACIÓN"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 5
    title.Parent = bg

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -36, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(45,45,65)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,80,110)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.ZIndex = 5
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.Parent = bg
    closeBtn.MouseButton1Click:Connect(function()
        savePickerPos()
        picker:Destroy()
        if _wallpaperPickerGui == picker then _wallpaperPickerGui = nil end
    end)

    -- Desplazamiento vertical: kéo xuống che phần trên, kéo lên hiện lại
    local vScroll = Instance.new("ScrollingFrame")
    vScroll.Name = "ContentScroll"
    vScroll.Size = UDim2.new(1, -12, 1, -42)
    vScroll.Position = UDim2.new(0, 6, 0, 38)
    vScroll.BackgroundTransparency = 1
    vScroll.BorderSizePixel = 0
    vScroll.ScrollBarThickness = 6
    vScroll.ScrollBarImageColor3 = Color3.fromRGB(140, 90, 255)
    vScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    vScroll.CanvasSize = UDim2.new(0, 0, 0, 900)
    vScroll.ClipsDescendants = true
    vScroll.Parent = bg

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -8, 0, 0)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = vScroll

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = content

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.Parent = content

    local function sectionLabel(text, order)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(200, 180, 255)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = order
        l.Parent = content
        return l
    end

    sectionLabel("FONDOS (desliza horizontalmente)", 1)
    local wpRow = Instance.new("ScrollingFrame")
    wpRow.Size = UDim2.new(1, 0, 0, 100)
    wpRow.BackgroundTransparency = 1
    wpRow.ScrollBarThickness = 4
    wpRow.ScrollBarImageColor3 = Color3.fromRGB(140, 90, 255)
    wpRow.CanvasSize = UDim2.new(0, #WALLPAPERS * 110 + 10, 0, 0)
    wpRow.ScrollingDirection = Enum.ScrollingDirection.X
    wpRow.LayoutOrder = 2
    wpRow.Parent = content
    for i, assetId in ipairs(WALLPAPERS) do
        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(0, 100, 0, 90)
        btn.Position = UDim2.new(0, (i-1)*110, 0, 5)
        btn.Image = assetId
        btn.BackgroundTransparency = 1
        btn.ScaleType = Enum.ScaleType.Crop
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", btn).Color = Color3.fromRGB(140, 90, 255)
        btn.Parent = wpRow
        btn.MouseButton1Click:Connect(function()
            Main.Image = assetId
            CURRENT_WALLPAPER = assetId
            pcall(SaveGuiConfig)
        end)
    end

    sectionLabel("ELEGIR INTRO", 3)
    local introRow = Instance.new("Frame")
    introRow.Size = UDim2.new(1, 0, 0, 100)
    introRow.BackgroundTransparency = 1
    introRow.LayoutOrder = 4
    introRow.Parent = content
    local intros = {
        {id="zenone", label="MIAU TP", img="rbxassetid://71852104184395", col=Color3.fromRGB(150,90,255)},
        {id="phantom", label="Phantom", img="rbxassetid://13879097036", col=Color3.fromRGB(255,60,90)},
        {id="ace", label="MIAU TP", img="rbxassetid://84453255265251", col=Color3.fromRGB(200,200,220)},
    }
    local introBtns = {}
    for i, info in ipairs(intros) do
        local b = Instance.new("ImageButton")
        b.Size = UDim2.new(0, 105, 0, 85)
        b.Position = UDim2.new(0, (i-1)*115, 0, 0)
        b.Image = info.img
        b.BackgroundColor3 = SelectedIntro == info.id and Color3.fromRGB(40,30,70) or Color3.fromRGB(25,25,40)
        b.ScaleType = Enum.ScaleType.Fit
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        local st = Instance.new("UIStroke")
        st.Thickness = SelectedIntro == info.id and 2.5 or 1.5
        st.Color = SelectedIntro == info.id and info.col or Color3.fromRGB(80,80,120)
        st.Parent = b
        b.Parent = introRow
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,0,16)
        lbl.Position = UDim2.new(0,0,1,2)
        lbl.BackgroundTransparency = 1
        lbl.Text = info.label
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 11
        lbl.Parent = b
        introBtns[info.id] = {btn=b, stroke=st, col=info.col}
        b.MouseButton1Click:Connect(function()
            SelectedIntro = info.id
            SaveIntroCfg(info.id)
            for id, v in pairs(introBtns) do
                local on = (id == SelectedIntro)
                v.btn.BackgroundColor3 = on and Color3.fromRGB(40,30,70) or Color3.fromRGB(25,25,40)
                v.stroke.Thickness = on and 2.5 or 1.5
                v.stroke.Color = on and v.col or Color3.fromRGB(80,80,120)
            end
        end)
    end

    sectionLabel("MÚSICA DE DUELO (chọn / tắt nhạc)", 5)
    local songGrid = Instance.new("Frame")
    songGrid.Size = UDim2.new(1, 0, 0, 0)
    songGrid.BackgroundTransparency = 1
    songGrid.AutomaticSize = Enum.AutomaticSize.Y
    songGrid.LayoutOrder = 7
    songGrid.Parent = content
    local songLayout = Instance.new("UIGridLayout")
    songLayout.CellSize = UDim2.new(0, 100, 0, 36)
    songLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    songLayout.SortOrder = Enum.SortOrder.LayoutOrder
    songLayout.Parent = songGrid

    local songButtons = {}
    local stopSb = Instance.new("TextButton")
    stopSb.BackgroundColor3 = Color3.fromRGB(90, 35, 45)
    stopSb.Text = "APAGAR MÚSICA"
    stopSb.TextColor3 = Color3.fromRGB(255, 180, 180)
    stopSb.Font = Enum.Font.GothamBold
    stopSb.TextSize = 12
    stopSb.LayoutOrder = 0
    Instance.new("UICorner", stopSb).CornerRadius = UDim.new(0, 8)
    local stopSt = Instance.new("UIStroke")
    stopSt.Color = Color3.fromRGB(255, 80, 100)
    stopSt.Thickness = 1.5
    stopSt.Parent = stopSb
    stopSb.Parent = songGrid
    stopSb.MouseButton1Click:Connect(function()
        stopDuelSong()
        for _, b in ipairs(songButtons) do
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            local st2 = b:FindFirstChildOfClass("UIStroke")
            if st2 then st2.Color = Color3.fromRGB(80,80,100); st2.Thickness = 1 end
        end
        if BtnDuelSong then BtnDuelSong.Text = "Música de duelo: APAGADA" end
        if BtnStopSong then
            BtnStopSong.Text = "Música apagada"
            task.delay(0.8, function()
                if BtnStopSong and BtnStopSong.Parent then BtnStopSong.Text = "Apagar música" end
            end)
        end
    end)


    -- Volumen de la música de duelo 1-100 (predeterminado 50)
    local volRow = Instance.new("Frame")
    volRow.Size = UDim2.new(1, 0, 0, 36)
    volRow.BackgroundTransparency = 1
    volRow.LayoutOrder = 6
    volRow.Parent = content
    local volLbl = Instance.new("TextLabel")
    volLbl.Size = UDim2.new(0, 120, 1, 0)
    volLbl.BackgroundTransparency = 1
    volLbl.Text = "Vol: "..tostring(DUEL_VOLUME)
    volLbl.TextColor3 = Color3.fromRGB(255, 220, 140)
    volLbl.Font = Enum.Font.GothamBold
    volLbl.TextSize = 13
    volLbl.TextXAlignment = Enum.TextXAlignment.Left
    volLbl.Parent = volRow
    local function makeVolBtn(txt, x, col, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 40, 0, 28)
        b.Position = UDim2.new(0, x, 0.5, -14)
        b.BackgroundColor3 = col
        b.Text = txt
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.Parent = volRow
        b.MouseButton1Click:Connect(function()
            DUEL_VOLUME = math.clamp((DUEL_VOLUME or 50) + delta, 1, 100)
            volLbl.Text = "Vol: "..tostring(DUEL_VOLUME)
            applyLiveVolume()
            SaveDuelVolumeCfg()
        end)
    end
    makeVolBtn("-10", 130, Color3.fromRGB(180, 60, 70), -10)
    makeVolBtn("-1", 176, Color3.fromRGB(140, 50, 60), -1)
    makeVolBtn("+1", 222, Color3.fromRGB(50, 140, 90), 1)
    makeVolBtn("+10", 268, Color3.fromRGB(40, 160, 100), 10)

    for i, song in ipairs(DUEL_SONGS) do
        local sb = Instance.new("TextButton")
        sb.BackgroundColor3 = (i == selectedDuelSong) and Color3.fromRGB(60,50,30) or Color3.fromRGB(30,30,45)
        sb.Text = song.name
        sb.TextColor3 = Color3.new(1,1,1)
        sb.Font = Enum.Font.GothamBold
        sb.TextSize = 11
        sb.TextWrapped = true
        sb.LayoutOrder = i
        Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 8)
        local sst = Instance.new("UIStroke")
        sst.Color = (i == selectedDuelSong) and Color3.fromRGB(200,160,100) or Color3.fromRGB(80,80,100)
        sst.Thickness = (i == selectedDuelSong) and 2 or 1
        sst.Parent = sb
        sb.Parent = songGrid
        table.insert(songButtons, sb)
        sb.MouseButton1Click:Connect(function()
            selectedDuelSong = i
            SaveDuelSongCfg()
            if BtnDuelSong then BtnDuelSong.Text = "Música de duelo: "..song.name end
            playDuelSong(i)
            for j, b in ipairs(songButtons) do
                local on = (j == selectedDuelSong)
                b.BackgroundColor3 = on and Color3.fromRGB(60,50,30) or Color3.fromRGB(30,30,45)
                local st2 = b:FindFirstChildOfClass("UIStroke")
                if st2 then
                    st2.Color = on and Color3.fromRGB(200,160,100) or Color3.fromRGB(80,80,100)
                    st2.Thickness = on and 2 or 1
                end
            end
        end)
    end

    sectionLabel("PAQUETE DE ANIMACIÓN", 8)
    local animGrid = Instance.new("Frame")
    animGrid.Size = UDim2.new(1, 0, 0, 0)
    animGrid.BackgroundTransparency = 1
    animGrid.AutomaticSize = Enum.AutomaticSize.Y
    animGrid.LayoutOrder = 9
    animGrid.Parent = content
    local animLayout = Instance.new("UIGridLayout")
    animLayout.CellSize = UDim2.new(0, 100, 0, 36)
    animLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    animLayout.SortOrder = Enum.SortOrder.LayoutOrder
    animLayout.Parent = animGrid

    local animButtons = {}
    for i, name in ipairs(AnimationPackList) do
        local ab = Instance.new("TextButton")
        ab.BackgroundColor3 = (name == selectedAnimationPack) and Color3.fromRGB(30,60,50) or Color3.fromRGB(30,30,45)
        ab.Text = name
        ab.TextColor3 = Color3.new(1,1,1)
        ab.Font = Enum.Font.GothamBold
        ab.TextSize = 11
        ab.TextWrapped = true
        ab.LayoutOrder = i
        Instance.new("UICorner", ab).CornerRadius = UDim.new(0, 8)
        local ast = Instance.new("UIStroke")
        ast.Color = (name == selectedAnimationPack) and Color3.fromRGB(100,200,180) or Color3.fromRGB(80,80,100)
        ast.Parent = ab
        ab.Parent = animGrid
        table.insert(animButtons, ab)
        ab.MouseButton1Click:Connect(function()
            AnimationPackIndex = i
            selectedAnimationPack = name
            applyAnimationPack(name)
            SaveAnimPackCfg()
            if BtnAnimPack then BtnAnimPack.Text = "Animación: "..name end
            for _, b in ipairs(animButtons) do
                local on = (b.Text == selectedAnimationPack)
                b.BackgroundColor3 = on and Color3.fromRGB(30,60,50) or Color3.fromRGB(30,30,45)
                local st2 = b:FindFirstChildOfClass("UIStroke")
                if st2 then st2.Color = on and Color3.fromRGB(100,200,180) or Color3.fromRGB(80,80,100) end
            end
            pcall(SaveGuiConfig)
        end)
    end

    task.defer(function()
        local h = layout.AbsoluteContentSize.Y + 24
        vScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(h, 400))
    end)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local h = layout.AbsoluteContentSize.Y + 24
        vScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(h, 400))
    end)
end

-- === VINCULAR BOTONES PRINCIPALES ===
BtnWallpaper.MouseButton1Click:Connect(ShowWallpaperIntroPicker)
-- Anim / Duel Song / Tắt nhạc chỉ trong Gui Image panel

-- ============================================================
-- 🎯 BOTONES DE CONTROL Y TP + ACTUALIZAR EQUIPAMIENTO FLYING / WITCH BROOM
-- ============================================================
-- ✅ CẬP NHẬT LISTA DE EQUIPAMIENTO PRIORITARIO
local function getMainWidth()
    local s = math.clamp(MAIN_WIDTH_SCALE or 1, 1, 10)
    -- x1=240, x10 = 240+160 = 400 (tối đa tăng 160px)
    return math.floor(240 + (s - 1) * (160 / 9))
end
local function getMainExpandedSize()
    local s = math.clamp(MAIN_GUI_SCALE or 1, 1, 2)
    local w = getMainWidth()
    return UDim2.new(0, w, 0, math.floor(350 * s))
end
local function getTpMiniSize()
    -- Restaurado al tamaño anterior del TP: 220x42 en x1.
    local s = math.clamp(TP_MINI_SCALE or 1, 1, 4)
    local w = 220
    local h = math.floor(42 + (s - 1) * 10)
    local tsz = math.floor(16 + (s - 1) * 2)
    return w, h, tsz
end
local function ApplyMinimize(state)
    MINIMIZE = state and true or false
    if MINIMIZE then
        if MainScroll then MainScroll.Visible = false end
        if AR_Text then AR_Text.Visible = false end
        if State then State.Visible = false end
        local tw, th, tsz = getTpMiniSize()
        local ms = math.clamp(MAIN_GUI_SCALE or 1, 1, 2)
        Main.Size = UDim2.new(0, math.max(tw + 16, math.floor(240 * ms * 0.85)), 0, th + 38)
        BtnTP.Size = UDim2.new(0, tw, 0, th)
        BtnTP.Position = UDim2.new(0.5, -math.floor(tw/2), 0, 32)
        BtnTP.TextSize = tsz
        BtnTP.Visible = true
        -- El botón circular de Trap es independiente del TP; no se recoloca al minimizar.
        BtnTrapMini.Visible = true
        BtnClose.Text = "+"
        Main.Draggable = not isGuiLocked
    else
        if MainScroll then MainScroll.Visible = true end
        if AR_Text then AR_Text.Visible = true end
        if State then State.Visible = true end
        Main.Size = getMainExpandedSize()
        local mw = getMainWidth()
        local compactW = math.min(mw - 20, 220)
        BtnTP.Size = UDim2.new(0, compactW, 0, 38)
        BtnTP.Position = UDim2.new(0.5, -math.floor(compactW/2), 1, -48)
        BtnTP.TextSize = 16
        BtnTP.Visible = true
        BtnTrapMini.Visible = true
        BtnClose.Text = "X"
        Main.Draggable = not isGuiLocked
    end
end
BtnClose.MouseButton1Click:Connect(function()
    ApplyMinimize(not MINIMIZE)
    pcall(SaveGuiConfig)
end)

-- === NÚT TÙY CHỈNH PHÁ MÁY ===

BaseMin.MouseButton1Click:Connect(function() DELAY_BASE = math.max(MIN_DELAY, DELAY_BASE - 0.01); LblBase.Text = "Base: "..string.format("%.2f",DELAY_BASE).."s" end)
BasePlus.MouseButton1Click:Connect(function() DELAY_BASE = math.min(MAX_DELAY, DELAY_BASE + 0.01); LblBase.Text = "Base: "..string.format("%.2f",DELAY_BASE).."s" end)
PetMin.MouseButton1Click:Connect(function() DELAY_PET = math.max(MIN_DELAY, DELAY_PET - 0.01); LblPet.Text = "Pet: "..string.format("%.2f",DELAY_PET).."s" end)
PetPlus.MouseButton1Click:Connect(function() DELAY_PET = math.min(MAX_DELAY, DELAY_PET + 0.01); LblPet.Text = "Pet: "..string.format("%.2f",DELAY_PET).."s" end)
BtnSaveBase.MouseButton1Click:Connect(function()
    pcall(function()
        local C = LocalPlayer.Character
        if not C then BtnSaveBase.Text = "No hay personaje"; task.wait(0.8); BtnSaveBase.Text = "Guardar Base"; return end
        local HRP = C:FindFirstChild("HumanoidRootPart")
        if not HRP then BtnSaveBase.Text = "No se encontró la posición"; task.wait(0.8); BtnSaveBase.Text = "Guardar Base"; return end
        SAVE_BASE = HRP.Position
        if MARK_BASE then MARK_BASE:Destroy() end
        MARK_BASE = Marker(SAVE_BASE, Color3.fromRGB(255,105,180))
        BtnSaveBase.Text = "Base guardada"
        task.wait(0.8); BtnSaveBase.Text = "Guardar Base"
    end)
end)
BtnSavePet.MouseButton1Click:Connect(function()
    pcall(function()
        local C = LocalPlayer.Character
        if not C then BtnSavePet.Text = "No hay personaje"; task.wait(0.8); BtnSavePet.Text = "Guardar Pet"; return end
        local HRP = C:FindFirstChild("HumanoidRootPart")
        if not HRP then BtnSavePet.Text = "No se encontró la posición"; task.wait(0.8); BtnSavePet.Text = "Guardar Pet"; return end
        SAVE_PET = HRP.Position
        if MARK_PET then MARK_PET:Destroy() end
        MARK_PET = Marker(SAVE_PET, Color3.fromRGB(255,140,0))
        BtnSavePet.Text = "Pet guardado"
        task.wait(0.8); BtnSavePet.Text = "Guardar Pet"
    end)
end)
local function StartTP()
    task.spawn(function()
        pcall(function()
            -- Equipar Cupid's Wings automáticamente al pulsar el botón TP
            local C = LocalPlayer.Character
            if C then
                EquipFly(C)
                task.wait(0.05)
            end
            if not SAVE_BASE and not SAVE_PET then
                BtnTP.Text = "No hay puntos guardados"
                task.wait(1)
                BtnTP.Text = "TP ["..KEYBIND_TP.Name.."]"
                return
            end
            local C = LocalPlayer.Character
            local HRP = C and C:FindFirstChild("HumanoidRootPart")
            if not HRP then
                BtnTP.Text = "No hay personaje"
                task.wait(1)
                BtnTP.Text = "TP ["..KEYBIND_TP.Name.."]"
                return
            end
            IS_TPING = true
            BtnTP.Text = "Equipando "..SelectedFlyTool.."..."

            -- Equipar el objeto seleccionado ANTES de cualquier movimiento del TP.
            -- Si no está disponible, EquipFly() usa automáticamente el otro objeto.
            EquipFly(C)
            task.wait(0.08)

            BtnTP.Text = "Teletransportando..."

            -- 1 điểm → Chilli drop (nhấc thấp → xuyên market → đáp đất)
            if (SAVE_BASE and not SAVE_PET) or (SAVE_PET and not SAVE_BASE) then
                ChilliTPToBest(HRP, SAVE_BASE or SAVE_PET, C)
            else
                -- 2 điểm → TP bình thường: điểm 1 → delay → điểm 2
                SmoothTP(HRP, SAVE_BASE)
                task.wait(DELAY_BASE)
                SmoothTP(HRP, SAVE_PET)
            end

            pcall(function()
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if h then
                    h.AssemblyLinearVelocity = Vector3.zero
                    h.AssemblyAngularVelocity = Vector3.zero
                end
            end)
            IS_TPING = false
            BtnTP.Text = "TP ["..KEYBIND_TP.Name.."]"
        end)
    end)
end
BtnTP.MouseButton1Click:Connect(function() if not IS_SET_KEY then StartTP() end end)
UIS.InputBegan:Connect(function(Input, GameProcess)
    if GameProcess then return end
    if IS_SET_KEY and Input.UserInputType == Enum.UserInputType.Keyboard then
        KEYBIND_TP = Input.KeyCode
        IS_SET_KEY = false
        BtnSetKey.Text = "TECLA TP: ["..KEYBIND_TP.Name.."]"
        BtnTP.Text = "TP ["..KEYBIND_TP.Name.."]"
        pcall(SaveGuiConfig)
    elseif not IS_SET_KEY and Input.KeyCode == KEYBIND_TP then
        StartTP()
    end
end)
-- ============================================================
-- ✅ SCRIPT COMPLETADO — Primero la intro, después aparece la GUI
-- ============================================================
-- Apply loaded labels
pcall(function()
    if LblBase then LblBase.Text = "Base: "..string.format("%.2f", DELAY_BASE).."s" end
    if LblPet then LblPet.Text = "Pet: "..string.format("%.2f", DELAY_PET).."s" end
    if BtnSetKey then BtnSetKey.Text = "TECLA TP: ["..KEYBIND_TP.Name.."]" end
    if BtnTP then BtnTP.Text = "TP ["..KEYBIND_TP.Name.."]" end
    if BtnAnimPack then BtnAnimPack.Text = "Animación: "..selectedAnimationPack end
    if LockBtn then
        LockBtn.Text = isGuiLocked and "BLOQUEAR" or "DESBLOQUEAR"
        if LockStroke then LockStroke.Color = isGuiLocked and Color3.fromRGB(255, 80, 110) or Color3.fromRGB(140, 85, 255) end
    end
end)

-- Guardar al cambiar delay / tecla / animación
pcall(function()
    local _oldBaseMin = BaseMin.MouseButton1Click
end)
-- hook saves on delay buttons (append)
pcall(function()
    BaseMin.MouseButton1Click:Connect(function() pcall(SaveGuiConfig) end)
    BasePlus.MouseButton1Click:Connect(function() pcall(SaveGuiConfig) end)
    PetMin.MouseButton1Click:Connect(function() pcall(SaveGuiConfig) end)
    PetPlus.MouseButton1Click:Connect(function() pcall(SaveGuiConfig) end)
    BtnAnimPack.MouseButton1Click:Connect(function() pcall(SaveGuiConfig) end)
end)

-- Khi set keybind xong thì save
pcall(function()
    UIS.InputBegan:Connect(function(Input, GameProcess)
        if GameProcess then return end
        if not IS_SET_KEY and Input.UserInputType == Enum.UserInputType.Keyboard then
            -- after key set elsewhere; also save periodically when keybind changes
        end
    end)
end)

-- Wrap keybind set to save
local _origKeyConn = true
-- save when KEYBIND changes via existing handler - patch by connecting extra
pcall(function()
    local lastKey = KEYBIND_TP
    task.spawn(function()
        while true do
            task.wait(1)
            if KEYBIND_TP ~= lastKey then
                lastKey = KEYBIND_TP
                pcall(SaveGuiConfig)
            end
        end
    end)
end)

-- Intro xong → hiện Main + nút búa
onIntroFinished(function()
    pcall(function()
        if Main then Main.Visible = true end
        if BtnTrapMini then
            BtnTrapMini.Visible = true
            UpdateTrapFloatLock()
        end
        -- khôi phục thu gọn / mở rộng đã lưu
        if type(ApplyMinimize) == "function" then
            ApplyMinimize(MINIMIZE == true)
        end
        -- Ace: chắc chắn đã dừng 7 intro catbox + phát bài cũ
        pcall(function()
            if SelectedIntro ~= "ace" then return end
            pcall(restoreSavedDuelSongAfterIntro)
        end)
        pcall(SaveGuiConfig)
    end)
end)

-- Chạy intro (menu vẫn ẩn)
runSelectedIntro()

-- Apply saved animation pack on character (sau intro cũng OK)
task.spawn(function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    task.wait(1)
    if selectedAnimationPack ~= "OFF" then applyAnimationPack(selectedAnimationPack) end
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if selectedAnimationPack ~= "OFF" then applyAnimationPack(selectedAnimationPack) end
end)
print("https://discord.gg/KGTEfaTCSP")
