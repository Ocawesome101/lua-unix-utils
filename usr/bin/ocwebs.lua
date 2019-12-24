-- Less-based Web browser inspired by Lynx --

local function draw(tLines, start)
    if not tLines[start] then
        error("Value 'start' out of range")
        return false
    end
    
    local w,h = term.getSize()
    
    h = h - 1
    term.setCursorPos(1,1)
    
    local stop
    
    if #tLines > h then
        stop = h
    else
        stop = #tLines
    end
    
    for i=start, h+(start-1), 1 do
        term.clearLine()
        print((tLines[i] or ""))
    end
end

local function drawCtrl(url)
    local w,h = term.getSize()
    term.setCursorPos(1, h-1)
    
    term.setBackgroundColor(colors.blue)
    term.clearLine()
    print(url or "")
    term.setBackgroundColor(colors.black)
    write("G)o Q)uit")
end

local function redraw(l, st, url)
    draw(l, st)
    drawCtrl(url)
end

local function getLines(handle)
    local rtn = {}
    for line in handle:lines() do
        table.insert(rtn, line)
    end
    
    return rtn
end

local function createIterable(t)
    local i = 1
    local rtn = function()
        local x = t[i]
        i = i + 1
        return x 
    end
end

local function parsePage(sPageData)
    local temp = fs.open("/tmp/.ocwebs_temp")
    temp.write(sPageData)
    temp.close()
    
    local sbMt = {} -- Attempt at sandboxing webpage scripts
    sbMt.http = http 
    sbMt.renderPage = parsePage
    
    os.run(sbMt, "/tmp/.ocwebs_temp")
end

local function getPage(url)
    local h = http.get(url)

    local data = parsePage(h:readAll())

    local lines = data

    h:close()

    top = 1

    redraw(lines, top, url)

    sleep(0.1)
    while true do
        local tEvent = {os.pullEvent()}
        local w,h = term.getSize()
        if tEvent[1] == "key" and tEvent[2] == keys.down then
            if top + h < #lines+2 then
                top = top + 1
            end
        elseif tEvent[1] == "key" and tEvent[2] == keys.up then
            if top > 1 then
                top = top - 1
            end
        elseif tEvent[1] == "key" and tEvent[2] == keys.q then
            term.setCursorPos(1,1)
            term.clear()
            sleep(0.1)
            break
        elseif tEvent[1] == "key" and tEvent[2] == keys.g then
            term.setCursorPos(1,h-1)
            local goTo = read()
            getPage(goTo)
        end
        redraw(lines, top, url)
    end
end

local startPage = {
    "Welcome to OC Webs!",
    "OC Webs is a simple Lua-based Web browser for ComputerCraft.",
    "It may also become available for OpenComputers' OpenOS."
}

redraw(startPage, 1, "local://startpage")
