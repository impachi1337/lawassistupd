require "lib.moonloader"

local dlstatus = require("moonloader").download_status

local SCRIPT_VERSION = "1.0"

local VERSION_URL = "https://raw.githubusercontent.com/impachi1337/lawassistupd/refs/heads/main/version.json"
local TEMP_JSON = getWorkingDirectory() .. "\\update_info.json"

function main()
    repeat wait(0) until isSampAvailable()

    sampRegisterChatCommand("update", checkUpdate)

    sampAddChatMessage(
        string.format("[TEST] Çàãðóæåí. Âåðñèÿ: %s", SCRIPT_VERSION),
        -1
    )

    while true do
        wait(0)
    end
end

function checkUpdate()
    if doesFileExist(TEMP_JSON) then
        os.remove(TEMP_JSON)
    end

    sampAddChatMessage("[Updater] Ïðîâåðÿåì îáíîâëåíèÿ...", -1)

    downloadUrlToFile(VERSION_URL, TEMP_JSON, function(id, status)
        if status ~= dlstatus.STATUS_ENDDOWNLOADDATA then
            return
        end

        local file = io.open(TEMP_JSON, "r")
        if not file then
            sampAddChatMessage("[Updater] Íå óäàëîñü îòêðûòü JSON.", -1)
            return
        end

        local data = file:read("*a")
        file:close()

        os.remove(TEMP_JSON)

        local version = data:match('"version"%s*:%s*"([^"]+)"')
        local scriptUrl = data:match('"script_url"%s*:%s*"([^"]+)"')

        if not version or not scriptUrl then
            sampAddChatMessage("[Updater] Îøèáêà JSON.", -1)
            return
        end

        if version == SCRIPT_VERSION then
            sampAddChatMessage("[Updater] Îáíîâëåíèé íåò.", -1)
            return
        end

        sampAddChatMessage(
            string.format("[Updater] Íàéäåíà âåðñèÿ %s", version),
            -1
        )

        sampAddChatMessage("[Updater] ×òî íîâîãî:", -1)

        for change in data:gmatch('"%s*([^"]-)%s*"') do
            if change ~= version and change ~= scriptUrl then
                sampAddChatMessage("  • " .. change, -1)
            end
        end

        sampAddChatMessage("[Updater] Ñêà÷èâàåì...", -1)

        downloadUrlToFile(scriptUrl, thisScript().path, function(_, st)
            if st == dlstatus.STATUS_ENDDOWNLOADDATA then
                sampAddChatMessage(
                    "[Updater] Ãîòîâî. Ïåðåçàãðóæàåì...",
                    -1
                )

                lua_thread.create(function()
                    wait(1000)
                    thisScript():reload()
                end)
            end
        end)
    end)
end
