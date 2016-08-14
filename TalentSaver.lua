DEBUG = false;
charTalents = {};

function Debug(msg)
    if DEBUG then
        print(msg);
    end
end

Debug('loading');

--Resgister slash commands
SLASH_TALENTSAVER1, SLASH_TALENTSAVER2 = '/talentsaver', "/ts"

function SlashCmdList.TALENTSAVER(msg, editbox)
    Debug("Handling slash command");
    Debug("msg: " .. msg); 

    command, rest = msg:match("^(%S*)%s*(.-)$");
    command = strlower(command);

    if command == "save" then      
        Save(rest);
        return;
    end

    if command == "list" then
        List();
        return;
    end

    if command == "restore" or command == "load" then
        Restore(rest);
        return;
    end

    if(command == "delete") then
        Delete(rest);
        return;
    end

   DisplayHelp(); 
end

function DisplayHelp()
    print("Talent saver command usage:");
    print("/talentsaver save setName");
    print("/talentsaver restore setName");
    print("/talentsaver delete setName");
    print("/talentsaver list");
end

function Save(name) 
    Debug("HANDLING SAVE")
    talents = GetSelectedTalentInfo();
    specId, specName = GetCurrentSpecDetails();

    if charTalents[specId] == nil then
        charTalents[specId] = {};
    end

    charTalents[specId][name] = talents;

    print("Saved talent set " .. name .. " successfully!");
end

function List()
    Debug("HANDLING LIST")
    print("Saved talent sets for " .. UnitName("player") .. ":");
   for specId, talentTable in pairs(charTalents) do

        Debug("specid " .. specId);
        print("Specialisation: " .. GetSpecializationNameForSpecID(specId));

        if(talentTable == nil) then
            return;
        end

        for talentSetName, _ in pairs(talentTable) do
            print(talentSetName);
        end
    end
end

function Delete(setName)
    specId, _ = GetCurrentSpecDetails();
    specTalentSets = charTalents[specId];

    if specTalentSets == nil then   
        print("No profile found for " .. name);
        ListCurrentSpecTalentSets();
        return;
    end

    talentSetToDelete = specTalentSets[setName];

    if(talentSetToDelete == nil) then
        print("No profile found for " .. name);
        ListCurrentSpecTalentSets();
    end

    charTalents[specId][setName] = nil;

    print("Profile " .. setName .. " deleted succesfully!");
end

function ListCurrentSpecTalentSets()
    currentSpecId, specName = GetCurrentSpecDetails();
    talentSets = charTalents[currentSpecId];

    print("Talent sets for " .. specName .. ":");

    if talentSets == nil then
        return;
    end

    for talentSetName, _ in pairs(talentSets) do
        print(talentSetName);
    end
end


function Restore(name)
    specId, specName = GetCurrentSpecDetails();

    specTalentSets = charTalents[specId];    
    if specTalentSets == nil then
        print("No profile found for " .. name)
        ListCurrentSpecTalentSets();
        return;
    end

    talents = charTalents[specId][name];
    if talents == nil then
        print("No profile found for " .. name)
        ListCurrentSpecTalentSets();
        return;
    end

    OpenTalents();    

    for row, column in pairs(talents) do
        if column ~= -1 then        
            elementName = FormatUIElementName(row,column);    
            Debug(elementName);
            _G[elementName]:Click();
        end
    end
end

function OpenTalents()  
    if PlayerTalentFrame ==nill or not PlayerTalentFrame:IsVisible() then
        ToggleTalentFrame();    
    end

    PlayerTalentFrameTab2:Click();  --clicks talents tab
end

function FormatUIElementName(row, column)
    return "PlayerTalentFrameTalentsTalentRow"..row.."Talent"..column;
end

function GetCurrentSpecDetails()
 id, name = GetSpecializationInfo(GetSpecialization());
 return id, name
end

function GetSelectedTalentInfo()
    talents = {};
 
    for i = 1, GetMaxTalentTier() do
        talents[i] = -1;
        for j = 1, 3 do
            Debug("i = " .. i .. "j =" .. j);

            talentID, name, texture, selected, available = GetTalentInfo(i,j,1);
            --Debug( "talentid :" .. talentID .. "name: "..name .. "texture:" .. texture .. "selected" .. tostring(selected) .. "available" .. tostring(available) )
            if selected then
                  Debug(i.. " " .. j .. " selected")
                talents[i] = j;                
            end
        end      
    end
    return talents;
end