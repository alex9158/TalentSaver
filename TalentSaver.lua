DEBUG = false;
charTalents = {};

function Debug(msg)
    if DEBUG then
        print(msg);
    end
end

print('loading');


--Resgister slash commands
SLASH_TALENTSAVER1, SLASH_TALENTSAVER2 = '/talentsaver', "/ts"

function SlashCmdList.TALENTSAVER(msg, editbox)
    Debug("Handling slash command");
    Debug("msg: " .. msg); 
    command, rest = msg:match("^(%S*)%s*(.-)$");

    if command == "save" then      
        Save(rest);
    end

    if command == "list" then
        List();
    end

    if command == "restore" or command == "load" then
        Restore(rest);
    end
end

function Save(name) 
    Debug("HANDLING SAVE")
    talents = GetSelectedTalentInfo();
    charTalents[name] = talents;
    PrintCharTalents();
end

function List()
    Debug("HANDLING LIST")
    PrintCharTalents();
end

function Restore(name)
    talents = charTalents[name];
    if(talents == nil) then
        print("No profile found for " .. name)
        List();
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

function TalentsVisible()
  return PlayerTalentFrame:IsVisible();    
end


function FormatUIElementName(row, column)
    return "PlayerTalentFrameTalentsTalentRow"..row.."Talent"..column;
end

function PrintCharTalents() 
    print("Saved profiles for character:")   
    for k,_ in pairs(charTalents) do
        print(k);
    end
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