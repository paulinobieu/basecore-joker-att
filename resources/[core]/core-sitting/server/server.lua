-- Global variables (assuming these are accessed from other files)
local CURRENT_RESOURCE_VERSION_METADATA = nil
local GITHUB_METADATA = nil
local RAW_VERSION_URL = nil -- This will store the raw GitHub URL for version checking
local IS_UPDATE_CHECKER_ENABLED = false

-- Get initial resource metadata
CURRENT_RESOURCE_VERSION_METADATA = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
GITHUB_METADATA = GetResourceMetadata(GetCurrentResourceName(), "github", 0)

-- Function to update a specific resource (placeholder for the original UpdateResource function)
function UpdateResource(resourceName)
    if "fivem-checker" == resourceName then
        local resourceState = GetResourceState(resourceName)
        if "started" == resourceState or "starting" == resourceState then
            -- This block seems to enable the update checker if "fivem-checker" is active
            if Config.UpdateChecker then
                IS_UPDATE_CHECKER_ENABLED = true
            end
        end
    end
end

-- Thread to periodically update resources and run update checker
CreateThread(function()
    while true do
        -- Iterate through all resources and call a placeholder UpdateResource function
        for i = 0, GetNumResources() do
            local resourceName = GetResourceByFindIndex(i)
            UpdateResource(resourceName) -- Calls the custom UpdateResource function
        end

        Wait(0) -- Yield to prevent freezing the server

        -- Only run the UpdateChecker if it hasn't been enabled by the "fivem-checker" resource
        if not IS_UPDATE_CHECKER_ENABLED then
            if Config.UpdateChecker then
                IS_UPDATE_CHECKER_ENABLED = true -- Set to true so it only runs once unless reset
                RunUpdateChecker()
            end
        end
    end
end)

-- Parses a version string into a table with major, minor, and patch numbers
local function parseVersionString(versionString)
    local major, minor, patch = versionString:match("(%d+)%.(%d+)%.(%d+)")
    if not major then
        major, minor = versionString:match("(%d+)%.(%d+)")
        patch = 0
    end
    return {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch)
    }
end

-- Compares two version tables
local function compareVersions(version1, version2)
    if version1.major < version2.major then return -1 end
    if version1.major > version2.major then return 1 end
    if version1.minor < version2.minor then return -1 end
    if version1.minor > version2.minor then return 1 end
    if version1.patch < version2.patch then return -1 end
    if version1.patch > version2.patch then return 1 end
    return 0
end

-- Determines the type of update (Major, Minor, Patch)
local function getUpdateType(currentVersion, latestVersion)
    if currentVersion.major < latestVersion.major then
        return "Major"
    elseif currentVersion.minor < latestVersion.minor then
        return "Minor"
    else
        return "Patch"
    end
end

-- Formats a changelog string from raw text
local function formatChangelog(rawChangelog)
    local changes = {}
    for line in rawChangelog:gmatch([[
%s*-%s*([^
]+)]]) do
        table.insert(changes, "- " .. line)
    end
    return table.concat(changes, "\n")
end

-- Main update checker logic
function RunUpdateChecker()
    -- Determine the correct GitHub URL for version checking
    if string.find(GITHUB_METADATA, "github") then
        if string.find(GITHUB_METADATA, "github.com") then
            RAW_VERSION_URL = GITHUB_METADATA:gsub("github", "raw.githubusercontent") .. "/main/version"
        else
            RAW_VERSION_URL = GITHUB_METADATA:gsub("raw.githubusercontent", "github")
            RAW_VERSION_URL = RAW_VERSION_URL:gsub("/main", "")
            RAW_VERSION_URL = RAW_VERSION_URL .. "/version"
        end
    end

    PerformHttpRequest(RAW_VERSION_URL, function(statusCode, responseBody, headers)
        local currentVersionParsed = parseVersionString(CURRENT_RESOURCE_VERSION_METADATA)

        -- Extract the latest version string from the response body
        local latestVersionString = responseBody:match([[
[^
]*]])
        latestVersionString = latestVersionString:gsub("[<>]", "") -- Remove any HTML tags

        local latestVersionParsed = parseVersionString(latestVersionString)

        local comparisonResult = compareVersions(currentVersionParsed, latestVersionParsed)

        print("")
        print("^9Standalone " .. GetResourceMetadata(GetCurrentResourceName(), "name", 0) .. " (" .. GetCurrentResourceName() .. ")")

        if comparisonResult == 0 then
            print("^2Version " .. CURRENT_RESOURCE_VERSION_METADATA .. " - Up to date!")
        elseif comparisonResult == -1 then
            print("^1Version " .. CURRENT_RESOURCE_VERSION_METADATA .. " - Outdated!")
            print("^1New version: v" .. latestVersionString)
            local updateType = getUpdateType(currentVersionParsed, latestVersionParsed)
            print("^3Update type: " .. updateType)

            if Config.ChangeLog then
                print([[

^3Changelog:]])

                local changelogContent = ""
                local numNewlines = responseBody:gsub("\n", "\n") -- Count newlines
                if numNewlines > 0 then
                    -- Attempt to extract changelog entries after the current version
                    local tempChangelog = responseBody:gsub(latestVersionString, "")
                    tempChangelog = tempChangelog:match("(.*" .. CURRENT_RESOURCE_VERSION_METADATA .. ")")
                    if tempChangelog then
                        tempChangelog = tempChangelog:gsub(CURRENT_RESOURCE_VERSION_METADATA, "")
                        changelogContent = formatChangelog(tempChangelog)
                    end
                end
                print("^4" .. changelogContent .. "\n")
            end

            print("^1Please re-download the script from Cfx.re Keymaster:")
            print("^2https://keymaster.fivem.net/asset-grants")
        else
            print("^3Version " .. CURRENT_RESOURCE_VERSION_METADATA .. " - You are running a newer version than the latest release!")
        end
        print("")
    end)
end
