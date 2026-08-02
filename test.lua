require "lib.moonloader"

local dlstatus = require("moonloader").download_status

local SCRIPT_VERSION = "1.0"

local VERSION_URL = "https://raw.githubusercontent.com/USER/REPO/main/version.json"
local TEMP_JSON = getWorkingDirectory() .. "\\update_info.json"

function main()
    repeat wait(0) until isSampAvailable()

    sampRegisterChatCommand("update", checkUpdate)

    sampAddChatMessage(
        string.format("[TEST] Загружен. Версия: %s", SCRIPT_VERSION),
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

    sampAddChatMessage("[Updater] Проверяем обновления...", -1)

    downloadUrlToFile(VERSION_URL, TEMP_JSON, function(id, status)
        if status ~= dlstatus.STATUS_ENDDOWNLOADDATA then
            return
        end

        local file = io.open(TEMP_JSON, "r")
        if not file then
            sampAddChatMessage("[Updater] Не удалось открыть JSON.", -1)
            return
        end

        local data = file:read("*a")
        file:close()

        os.remove(TEMP_JSON)

        local version = data:match('"version"%s*:%s*"([^"]+)"')
        local scriptUrl = data:match('"script_url"%s*:%s*"([^"]+)"')

        if not version or not scriptUrl then
            sampAddChatMessage("[Updater] Ошибка JSON.", -1)
            return
        end

        if version == SCRIPT_VERSION then
            sampAddChatMessage("[Updater] Обновлений нет.", -1)
            return
        end

        sampAddChatMessage(
            string.format("[Updater] Найдена версия %s", version),
            -1
        )

        sampAddChatMessage("[Updater] Что нового:", -1)

        for change in data:gmatch('"%s*([^"]-)%s*"') do
            if change ~= version and change ~= scriptUrl then
                sampAddChatMessage("  • " .. change, -1)
            end
        end

        sampAddChatMessage("[Updater] Скачиваем...", -1)

        downloadUrlToFile(scriptUrl, thisScript().path, function(_, st)
            if st == dlstatus.STATUS_ENDDOWNLOADDATA then
                sampAddChatMessage(
                    "[Updater] Готово. Перезагружаем...",
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