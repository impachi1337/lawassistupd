script_name("Installer")

require "lib.moonloader"

local UPDATE_INFO =
    getWorkingDirectory() ..
    "\\resource\\update.txt"

local UPDATE_FILE =
    getWorkingDirectory() ..
    "\\resource\\lawassist_update.lua"

function main()

    while true do
        wait(500)

        if doesFileExist(UPDATE_INFO) then

            local f = io.open(UPDATE_INFO, "r")

            if not f then
                goto continue
            end

            local target = f:read("*a")

            f:close()

            if target ~= "" and doesFileExist(UPDATE_FILE) then

                local backup = target .. ".bak"

                pcall(os.remove, backup)
                pcall(os.rename, target, backup)

                local ok, err =
                    os.rename(
                        UPDATE_FILE,
                        target
                    )

                print(
                    "[INSTALLER]",
                    ok,
                    err
                )

                if ok then

                    pcall(os.remove, UPDATE_INFO)

                    print(
                        "[INSTALLER] UPDATED"
                    )

                    thisScript():unload()
                    return
                end
            end
        end

        ::continue::
    end
end