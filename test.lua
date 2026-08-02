script_name("Updater Test")
script_version("1.0")

require "lib.moonloader"

local dlstatus = require("moonloader").download_status

local UPDATE_INFO = getWorkingDirectory() .. "\\resource\\update.txt"
local UPDATE_FILE = getWorkingDirectory() .. "\\resource\\lawassist_update.lua"
local INSTALLER_FILE = getWorkingDirectory() .. "\\installer.lua"

local INSTALLER_URL = "https://raw.githubusercontent.com/impachi1337/lawassistupd/main/installer.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/impachi1337/lawassistupd/main/test.lua"

function main()
    repeat wait(0) until isSampAvailable()

    sampRegisterChatCommand("update", installUpdate)

    sampAddChatMessage("[Updater] Loaded", -1)

    while true do
        wait(0)
    end
end

function installUpdate()

    local function startInstall()

        local f = io.open(UPDATE_INFO, "w")

        f:write(thisScript().path)

        f:close()

        sampAddChatMessage("[Updater] Выгружаюсь...", -1)

        thisScript():unload()
    end

    local function downloadScript()

        downloadUrlToFile(SCRIPT_URL, UPDATE_FILE,
            function(_, status)

                if status == dlstatus.STATUS_ENDDOWNLOADDATA then

                    sampAddChatMessage(
                        "[Updater] Новый файл скачан",
                        -1
                    )

                    startInstall()
                end
            end
        )
    end

    if not doesFileExist(INSTALLER_FILE) then

        sampAddChatMessage(
            "[Updater] Качаем installer.lua",
            -1
        )

        downloadUrlToFile(INSTALLER_URL, INSTALLER_FILE,
            function(_, status)

                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    downloadScript()
                end
            end
        )

    else
        downloadScript()
    end
end
