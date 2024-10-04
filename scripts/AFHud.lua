luaDebugMode = true

if hideHud then return end -- if you want to ultra optimizate it, just hide the hud
function onCreate()
    precacheImage('noteSplashes/noteSplashes')
    for i=0,10 do precacheImage('num'..i)end

    makeAnimatedLuaSprite('ratings', 'ratings/ratings'..(downscroll and '_downscroll' or ''), 1012, 465)
    for _, rates in pairs({'bad', 'good', 'shit', 'sick'}) do
	    addAnimationByPrefix('ratings', rates, rates, 24, false)end
    setObjectCamera('ratings', 'hud')
    addLuaSprite('ratings')
    setProperty('ratings.alpha', 0.001) -- using alpha cuz it's more optimized (i think)

    local indicators = {'score', 'misses', 'rating'}
    for k, i in pairs(indicators) do
        makeAnimatedLuaSprite('indicator'..k, 'scoreInfo', k*130+320, screenHeight-55)
        addAnimationByPrefix('indicator'..k, i, i, 0, false)
        playAnim('indicator'..k, i)
        setObjectCamera('indicator'..k, 'hud')
        addLuaSprite('indicator'..k)

        makeAnimatedLuaSprite('dash'..k, 'scoreInfo', getProperty('indicator'..k..'.x') + getProperty('indicator'..k..'.width') + 20, screenHeight-45)
        addAnimationByPrefix('dash'..k, 'dash', 'dash', 0, false)
        playAnim('dash'..k, 'dash')
        setObjectCamera('dash'..k, 'hud')
        addLuaSprite('dash'..k)

        screenCenter('indicator'..k, 'X')
        screenCenter('dash'..k, 'X')
    end
end

function onCreatePost()
    setProperty('comboGroup.visible', false)
    setProperty('timeTxt.visible', false)
    setProperty('healthBar.bg.visible', false)
    setProperty('scoreTxt.visible', false)

    setBlendMode('timeBar.bg', 'multiply')
    setProperty('timeBar.leftBar.color', getHealthColor('dad'))

    for i = 0,3 do
	    setPropertyFromGroup('playerStrums', i, 'x', _G['defaultPlayerStrumX'..i]+30)
	    setPropertyFromGroup('opponentStrums', i, 'x', _G['defaultOpponentStrumX'..i]-30)
    end

    setProperty('timeBar.y', getProperty('timeBar.y') + 70)

    for _, bars in pairs({'healthBar', 'iconP1', 'iconP2'}) do
	    setProperty(bars..'.y', getProperty(bars..'.y') - 30)end

    for i = 0, 7 do
	    setPropertyFromGroup('strumLineNotes', i, 'rgbShader.enabled', false)
    end
    for i = 1,3 do
        setObjectOrder('indicator'..i, getObjectOrder('uiGroup')+1)
        setObjectOrder('dash'..i, getObjectOrder('uiGroup')+1)end	

    local songImage = songName..(difficultyName:lower() == 'twist' and '-twist' or '')
    makeLuaSprite('songTitle', 'song/song-'..songImage, getProperty('timeTxt.x')+45, getProperty('timeTxt.y'))
    setObjectCamera('songTitle', 'hud')
    setObjectOrder('songTitle', getObjectOrder('uiGroup')+1)
    addLuaSprite('songTitle')

    makeAnimatedLuaSprite('healthBarOV', 'healthBarOV3', getProperty('healthBar.x'), getProperty('healthBar.y'))
    addAnimationByPrefix('healthBarOV', 'idle', 'healthBarOV3', 24, true)
    playAnim('healthBarOV', 'idle', true)
    setObjectCamera('healthBarOV', 'hud')
    runHaxeCode("uiGroup.insert(uiGroup.members.indexOf(game.healthBar)+1, game.getLuaObject('healthBarOV'));")

    loadGraphic('iconP1', 'icons/'..getProperty('boyfriend.healthIcon'), 150, 150, false)
    addAnimation('iconP1', 'idle', {0,1,2}, 0, false)
    setProperty('iconP1.flipX', true)

    loadGraphic('iconP2', 'icons/'..getProperty('dad.healthIcon'), 150, 150, false)
    addAnimation('iconP2', 'idle', {0,1,2}, 0, false)
end

function onUpdate()
    if getProperty('ratings.alpha') >= 1 and getProperty('ratings.animation.curAnim.finished') then
	    setProperty('ratings.alpha', 0.001)
    end
end

function onUpdatePost()
    setProperty('iconP1.offset.x', getProperty('iconP1.offset.x') - 45)
    setProperty('iconP2.offset.x', getProperty('iconP2.offset.x') - 45)

    setProperty('songTitle.alpha', getProperty('timeTxt.alpha')) -- yes

    if getHealth() > 1.6 then
	    setProperty('iconP1.animation.curAnim.curFrame', 2)
    elseif getHealth() < 0.4 then
	    setProperty('iconP2.animation.curAnim.curFrame', 2)
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then
	    callMethod('iconP1.scale.set', {1.15, 1.15})
	    callMethod('iconP2.scale.set', {0.85, 0.85})
	    startTween('iconScale1', 'iconP1.scale', {x = 1, y = 1}, (stepCrochet / 1000) * 2, {ease = 'quadInOut'})
	    startTween('iconScale2', 'iconP2.scale', {x = 1, y = 1}, (stepCrochet / 1000) * 2, {ease = 'quadInOut'})
    else
	    callMethod('iconP2.scale.set', {1.15, 1.15})
	    callMethod('iconP1.scale.set', {0.85, 0.85})
	    startTween('iconScale1', 'iconP1.scale', {x = 1, y = 1}, (stepCrochet / 1000) * 2, {ease = 'quadInOut'})
	    startTween('iconScale2', 'iconP2.scale', {x = 1, y = 1}, (stepCrochet / 1000) * 2, {ease = 'quadInOut'})
    end
end

function onSpawnNote(i)
    setPropertyFromGroup('notes', i, 'rgbShader.enabled', false)
    setPropertyFromGroup('notes', i, 'noteSplashData.useRGBShader', false)
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if not isSustainNote then
	    setProperty('ratings.alpha', 1)
	    playAnim('ratings', getPropertyFromGroup('notes', id, 'rating'), true)

	    popUpScoreNum(combo)
    end

    -- this is just for the testing phase
    if botPlay and not isSustainNote then combo = combo + 1 end
end


function popUpScoreNum(cu)
    local seperatedScore = {}

    -- the seperatedScore thing is from the PE source also
    if cu >= 1000 then
	    table.insert(seperatedScore, math.floor(cu / 1000) % 10)end
    table.insert(seperatedScore, math.floor(cu / 100) % 10)
    table.insert(seperatedScore, math.floor(cu / 10) % 10)
    table.insert(seperatedScore, cu % 10)

    local daLoop = 0
    local xThing = 0

    local placement = screenWidth - 100
    for v, i in pairs(seperatedScore) do
	    makeLuaSprite('numScore'..v, 'num'..tonumber(i))
	    screenCenter('numScore'..v, 'XY')
	    setObjectCamera('numScore'..v, 'hud')
	    setProperty('numScore'..v..'.x', placement + (30 * daLoop) - 65)
	    setProperty('numScore'..v..'.y', getProperty('numScore'..v..'.y') + 360+v*-30)
	    setProperty('numScore'..v..'.angle', -45)
	    scaleObject('numScore'..v, 0.65, 0.65, false)
	    addLuaSprite('numScore'..v)

	    cancelTween('numTweenOut'..v)
	    local finalX = placement + (30 * daLoop) - 60
	    local finalY = getProperty('numScore'..v..'.y') + 5
	    startTween('numTween'..v, 'numScore'..v, {x = finalX, y = finalY, ['scale.x'] = 0.5, ['scale.y'] = 0.5}, 0.1, {ease = 'backOut'})

	    setVar('v', v) -- why.........
	    runTimer('cuzinho', 1.065)
	    function onTimerCompleted(tag)
	        if tag == 'cuzinho' then
		    for id = 1, getVar('v') do
		        startTween('numTweenOut'..id, 'numScore'..id, {['scale.x'] = 0, ['scale.y'] = 0}, 1, {ease = 'backOut', onUpdate = 'updatenumxy'})end
		    function updatenumxy()
		        for id = 1, getVar('v') do
			        setProperty('numScore'..id..'.x', getProperty('numScore'..id..'.x') + 1)
			        setProperty('numScore'..id..'.y', getProperty('numScore'..id..'.y') + 1)
		        end
		    end
	    end
	end

	daLoop = daLoop + 1
    end

    -- this part it's for the score, not the combo thing
    -- idk how i will adjust the width when the score gets higher......
    local scores = stringSplit(score, '')
    local coiso = 0
    for f, n in ipairs(scores) do
        makeAnimatedLuaSprite('scorenum'..f, 'scoreInfo', coiso*25+250, screenHeight - 300)
        for s=0,9 do addAnimationByPrefix('scorenum'..f, tostring(s), s, 0, false)end
        playAnim('scorenum'..f, n)
        setObjectCamera('scorenum'..f, 'hud')
        setObjectOrder('scorenum'..f, getObjectOrder('uiGroup')+1)
        addLuaSprite('scorenum'..f)

        for i = 1,3 do
            setProperty('indicator'..i..'.width', getProperty('indicator'..i..'.width') - getProperty('scorenum'..f..'.width'))
        end

        coiso = coiso + 1
    end
end

function getHealthColor(arg)
    return getColorFromHex(rgbToHex(getProperty(arg..'.healthColorArray[0]'), getProperty(arg..'.healthColorArray[1]'), getProperty(arg..'.healthColorArray[2]')))
end

function rgbToHex(r,g,b)
    return string.format("%02X%02X%02X", r, g, b)
end