DEBUG = false;
charTalents = {}; -- table<spec, <row,column>>

function Debug(msg)
    if DEBUG then
        print(msg);
    end
end

Debug('loading');

--Register slash commands
SLASH_TALENTSAVER1, SLASH_TALENTSAVER2 = '/talentsaver', "/ts"

function SlashCmdList.TALENTSAVER(msg, editbox)
    Debug("Handling slash command");
    Debug("msg: " .. msg); 

    command, rest = msg:match("^(%S*)%s*(.-)$");
    command = strlower(command);  

    if command == "list" then
        List();
        return;
    end

    if command == "save" then      
        if(IsEmpty(rest)) then
            DisplayHelp();
        else
            Save(rest);
        end
        return;
    end

    if command == "restore" or command == "load" then
        if(IsEmpty(rest)) then
            DisplayHelp();
        else
            Restore(rest);
        end
        return;
    end

    if(command == "delete") then
       if(IsEmpty(rest)) then
            DisplayHelp();
        else
            Delete(rest);
        end
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
    specId, specName = GetCurrentSpecDetails();
    specTalentSets = charTalents[specId];

    if specTalentSets == nil then   
        print("No profile found for " .. setName);
        ListCurrentSpecTalentSets();
        return;
    end

    talentSetToDelete = specTalentSets[setName];

    if(talentSetToDelete == nil) then
        print("No profile found for " .. setName);
        ListCurrentSpecTalentSets();
        return;
    end
    
    charTalents[specId][setName] = nil;
    CleanUpEmptySpec(specId);
    print("Profile " .. setName .. " deleted succesfully!");
end

function CleanUpEmptySpec(specId)
   --tidy up table by removing specs with no talent profiles saved against them
    remainingTalentSetsForSpec = 0;
    for _,_ in pairs(charTalents[specId]) do
        remainingTalentSetsForSpec = remainingTalentSetsForSpec +1;
    end

    if(remainingTalentSetsForSpec == 0) then
        Debug("Cleaning up " .. specName);
        charTalents[specId] = nil;
    end
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
            talentID, name, texture, selected, available = GetTalentInfo(i,j,1);            
            if selected then
                  Debug(i.. " " .. j .. " selected")
                talents[i] = j;                
            end
        end      
    end
    return talents;
end

function IsEmpty(string)
    return string == nil or string == '';
end