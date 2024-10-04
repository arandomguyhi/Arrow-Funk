local stagePrefix = 'stages/baladamedo/twistnightfall/'

luaDebugMode = true
function onCreate()
    makeLuaSprite('bg', stagePrefix..'layer0dark', -1047, -603) -- maybe im just paranoic
    addLuaSprite('bg')

    makeLuaSprite('flipershit', stagePrefix..'layer2', -1047, -603)
    setBlendMode('flipershit', 'add')
    addLuaSprite('flipershit')

    makeAnimatedLuaSprite('monstereyes', stagePrefix..'monsterdark', -342, 32) -- quem que teve a ideia de fazer sapoha
    addAnimationByPrefix('monstereyes', 'idle', 'monsterloop', 24, true)
    playAnim('monstereyes', 'idle')
    addLuaSprite('monstereyes')

    makeAnimatedLuaSprite('rainingtacos', stagePrefix..'layer3', -605, 705)
    addAnimationByPrefix('rainingtacos', 'idle', 'rain instance 1', 24, true)
    playAnim('rainingtacos', 'idle')
    setBlendMode('rainingtacos', 'add')
    setProperty('rainingtacos.alpha', 0.4)
    addLuaSprite('rainingtacos')

    makeAnimatedLuaSprite('speakers', stagePrefix..'sbookers', -720, 348)
    addAnimationByPrefix('speakers', 'idle', 'SPEAKERS', 24, false)
    playAnim('speakers', 'idle')
    addLuaSprite('speakers')

    makeLuaSprite('floorshit', stagePrefix..'layer4', 580, 884)
    addLuaSprite('floorshit')

    for _, i in pairs({'bg', 'flipershit', 'monstereyes', 'rainingtacos', 'speakers', 'floorshit', 'overlay', 'light'}) do
	setScrollFactor(i, 0.9, 0.9)
    end
end
    
function onCreatePost()
    -- it changes the vocals and inst (this took me awhile to figure out (a long time tbh :sob:))
    runHaxeCode([[
	game.inst.loadEmbedded(Paths.returnSound('songs', Paths.formatToSongPath(PlayState.SONG.song) + '/Inst-twist'));
	game.opponentVocals.loadEmbedded(Paths.returnSound('songs', Paths.formatToSongPath(PlayState.SONG.song) + '/Voices-twist-opponent'));
	game.vocals.loadEmbedded(Paths.returnSound('songs', Paths.formatToSongPath(PlayState.SONG.song) + '/Voices-twist-player'));
    ]])

    for _, i in pairs({'boyfriend', 'dad', 'gf'}) do
	setScrollFactor(i, 0.9, 0.9)
    end
end

function onBeatHit() if curBeat % 2 == 0 then playAnim('speakers', 'idle')end end