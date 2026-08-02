local UPDATE_INFO = getWorkingDirectory() .. "\\resource\\update.txt"
local UPDATE_FILE = getWorkingDirectory() .. "\\resource\\lawassist_update.lua"
local INSTALLER_FILE = getWorkingDirectory() .. "\\installer.lua"

local INSTALLER_URL = "https://raw.githubusercontent.com/impachi1337/lawassistupd/refs/heads/main/installer.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/impachi1337/lawassistupd/refs/heads/main/test.lua"

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