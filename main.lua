print("You are using QuestHerald! type \\QuestHerald or \\qh to enable or disable quest audio.")

-- Adds references to the libraries used in the addon
QuestHerald = LibStub("AceAddon-3.0"):NewAddon("QuestHerald", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0")

-- Returned API variables 
local rtnval, handle

-- Initializes the GUI and sets it to a variable
local AceGUI = LibStub("AceGUI-3.0")

-- Bools which determine which sounds will play
local checkPlayObjective = true
local checkPDescription = true
local checkPTitle = true
local checkPPlayVAAudio = true

-- Bool to make sure stop sound does not cause a message to be printed.
local soundStoped = false

-- Bool to determine which audio file is to be played
local usedVAAudio = true

function QuestHerald:OnInitialize()
    --self:Print("WelcomeHome:OnInitialize!")
	-- Register Slash Commands
    QuestHerald:RegisterChatCommand("QuestHerald", "QuestHeraldShowGui")
    QuestHerald:RegisterChatCommand("qh", "QuestHeraldShowGui")
    QuestHerald:RegisterChatCommand("toggleDescription", "QuestHeraldtoggleDes")
    QuestHerald:RegisterChatCommand("toggleObjective", "QuestHeraldtoggleObj")
    QuestHerald:RegisterChatCommand("toggleTitle", "QuestHeraldtoggleTit")
    QuestHerald:RegisterChatCommand("toggleVA", "QuestHeraldtoggleVA")
    QuestHerald:RegisterChatCommand("enableObjective", "EnableObj")
    QuestHerald:RegisterChatCommand("disableObjective", "DisableObj")
    QuestHerald:RegisterChatCommand("enableDescription", "EnableDes")
    QuestHerald:RegisterChatCommand("disableDescription", "DisableDes")
    QuestHerald:RegisterChatCommand("enableTitle", "EnableTit")
    QuestHerald:RegisterChatCommand("disableTitle", "DisableTit")
	QuestHerald:RegisterChatCommand("enableVA", "EnableVA")
    QuestHerald:RegisterChatCommand("disableVA", "DisableVA")	
    QuestHerald:RegisterChatCommand("va", "QuestHeraldtoggleVA")	
    QuestHerald:RegisterChatCommand("\sqh", "StopSounds")	
    QuestHerald:RegisterChatCommand("\stop", "StopSounds")	
    QuestHerald:RegisterChatCommand("\ss", "StopSounds")	
end

function QuestHerald:OnEnable()
	--self:Print("Hello World!")
   -- Need to register the event for it to be caught
   -- when the API fires it.
	QuestHerald:RegisterEvent("QUEST_DETAIL")
	QuestHerald:RegisterEvent("QUEST_FINISHED")
	QuestHerald:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
	QuestHerald:RegisterEvent("QUEST_PROGRESS")
	QuestHerald:RegisterEvent("QUEST_COMPLETE")
	QuestHerald:RegisterEvent("QUEST_TURNED_IN")
	--self:Print("Goodbye World!")
 end

 

function QuestHerald:QUEST_DETAIL(event)
   questInfo = GetQuestID()
   self:playSounds(questInfo, checkPlayObjective, checkPDescription, checkPTitle, checkPPlayVAAudio)
end


-- The words spoken when the play hits continue and plays the turn in quest text.
function QuestHerald:QUEST_TURNED_IN(event)
   -- TODO: Implement functionality and add voice acting to this part eventually.
   --print("Hit QUEST_TURNED_IN")
   	if handle ~= nil then
		StopSound(handle)
		soundStoped = true
	end
	
	self:CancelAllTimers()

end

-- The words spoken when the play hits continue and plays the turn in quest text.
function QuestHerald:QUEST_COMPLETE(event)
   -- TODO: Implement functionality and add voice acting to this part eventually.
   --print("Hit QUEST_COMPLETE")
   questInfo = GetQuestID()
   --print(questInfo .. "questInfo")
   self:playTurnInSound(questInfo,checkPPlayVAAudio)

end

-- Used when a quest is closed or accepted
-- stops the current mp3 playing and cancells the 
-- timer which would play the objective
function QuestHerald:QUEST_FINISHED()
	--print("Hit QUEST_DETAIL")
	--print(handle)
	if handle ~= nil then
		StopSound(handle)
		soundStoped = true
	end
	
	self:CancelAllTimers()
end

-- Used when a quest is Turned in
-- stops the current mp3 playing and cancells the 
-- timer which would play the objective
function QuestHerald:UNIT_QUEST_LOG_CHANGED()
	if handle ~= nil then
		StopSound(handle)
		soundStoped = true
	end
	
	self:CancelAllTimers()
end

-- Used when a quest is in progress and has progress text
function QuestHerald:QUEST_PROGRESS()
	soundStoped = false
	rtnval = nil
	
	questId = GetQuestID()
	if questId ~= nil then
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/VAQuestAudio/" .. questId .."_Progress.mp3")
		if rtnval == nil then
			-- If VA Audio does not exsist get TTS audio
			rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/QuestAudio/" .. questId .."_Progress.mp3")
		end
	else
		print("The questID could not be retrived when checking QUEST_PROGRESS " )
	end

	if rtnval == nil and soundStoped ~= true then
		print("The quest Progress " .. questId .. " has yet to be implimented or does not exist." )
	end
end



function QuestHerald:playSoundObjective(questId, playVAAudio)
	soundStoped = false
	rtnval = nil
	-- Try VA Audio First if its enabled
	if playVAAudio == true then
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/VAQuestAudio/" .. questId .."_Objective.mp3")
	end
	if rtnval == nil then
		-- If VA Audio does not exsist get TTS audio
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/QuestAudio/" .. questId .."_Objective.mp3")
	end

	if rtnval == nil and soundStoped ~= true then
		print("The quest Objective " .. questId .. " has yet to be implimented" )
	end
end


function QuestHerald:playSoundDescription(questId, playVAAudio)
	soundStoped = false
	rtnval = nil
	
	-- Try VA Audio First if its enabled
	if playVAAudio == true then
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/VAQuestAudio/" .. questId .."_Description.mp3")
	end
	if rtnval == nil then
		-- If VA Audio does not exsist get TTS audio
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/QuestAudio/" .. questId .."_Description.mp3")
	end
	
	if rtnval == nil and soundStoped ~= true  then
		print("The quest Description " .. questId .. " has yet to be implimented" )
	end
end

function QuestHerald:playWholeQuest(questId, playVAAudio)
	soundStoped = false
	usedVAAudio = true
	rtnval = nil
	
	-- Try VA Audio First
	if playVAAudio == true then
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/VAQuestAudio/" .. questId .."_Description.mp3")
	end
	
	if rtnval == nil then
		-- If VA Audio does not exsist get TTS audio
		usedVAAudio = false
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/QuestAudio/" .. questId .."_Description.mp3")
	end
	
	if soundStoped ~= true then 
		if rtnval ~= nil then
			if usedVAAudio == true then
				self:ScheduleTimer("playSoundObjective", questVADescriptionTable[questId .."_Description.mp3"], questId,playVAAudio)
			else
				self:ScheduleTimer("playSoundObjective", questDescriptionTable[questId .."_Description.mp3"], questId,playVAAudio)
			end
		else
			print("The quest Description " .. questId .. " has yet to be implimented" )
		end
	end
end

function QuestHerald:playSounds(questId, playObjective, playDescription, playTitle, playVAAudio)
	soundStoped = false
	-- This is needed to set the timer from when the title audio was played
	-- It helps determine if it uses the TTS title time or VA title Time
	usedVAAudio = true
	rtnval = nil
	
	if playTitle == true then
		-- Try VA Audio First
		if playVAAudio == true then
			rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/VAQuestAudio/" .. questId .."_Title.mp3")
		end
		if rtnval == nil then
			-- If VA Audio does not exsist get TTS audio
			usedVAAudio = false
			rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/QuestAudio/" .. questId .."_Title.mp3")
		end
		if soundStoped ~= true then
			-- If there is a title audio file
			if rtnval ~= nil then
				if playObjective == true and playDescription == true then
					--Check to see which audio length to set the timer to.
					if usedVAAudio == true then
						self:ScheduleTimer("playWholeQuest", questVATitleTable[questId .."_Title.mp3"], questId, playVAAudio)
					else
						self:ScheduleTimer("playWholeQuest", questTitleTable[questId .."_Title.mp3"], questId, playVAAudio)
					end
					
				else
					if playObjective == true then
						if usedVAAudio == true then
							self:ScheduleTimer("playSoundObjective", questVATitleTable[questId .."_Title.mp3"], questId, playVAAudio)
						else
							self:ScheduleTimer("playSoundObjective", questTitleTable[questId .."_Title.mp3"], questId, playVAAudio)
						end
					end
					if playDescription == true then
						if usedVAAudio == true then
							self:ScheduleTimer("playSoundDescription", questVATitleTable[questId .."_Title.mp3"], questId, playVAAudio)
						else
							self:ScheduleTimer("playSoundDescription", questTitleTable[questId .."_Title.mp3"], questId, playVAAudio)
						end
					end
				end
				
			else
				print("The quest " .. questId .. " has yet to be implimented" )
			end
		end
	
	else
		if playObjective == true and playDescription == true then
			self:playWholeQuest(questId)
		else
			if playObjective == true then
				 self:playSoundObjective(questId, playVAAudio)
			end
			if playDescription == true then
				 self:playSoundDescription(questId, playVAAudio)
			end
		end
	end
end

function QuestHerald:playTurnInSound(questId,playVAAudio)
	soundStoped = false
	rtnval = nil
	-- Try VA Audio First
	if playVAAudio == true then
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/VAQuestAudio/" .. questId .."_Completion.mp3")
	end
	
	if rtnval == nil then
		-- If VA Audio does not exsist get TTS audio
		rtnval, handle = PlaySoundFile("Interface/AddOns/QuestHerald/QuestAudio/" .. questId .."_Completion.mp3")
	end
	
	if rtnval == nil and soundStoped ~= true then
		print('The quest ' .. questId .. " has yet to be implimented" )
	end
end

---------------------------------------------------------------------
-- Slash inputs
---------------------------------------------------------------------


-- Opens up the GUI to manually modify the play sounds bool
function QuestHerald:QuestHeraldSlash(input)
    input = string.trim(input, " ");
	
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("Example Frame")
	frame:SetStatusText("AceGUI-3.0 Example Container Frame")
end

function QuestHerald:QuestHeraldtoggleObj(input)
	checkPlayObjective = not checkPlayObjective
	print("Objective changed to " .. tostring(checkPlayObjective))
end

function QuestHerald:QuestHeraldtoggleDes(input)
	checkPDescription = not checkPDescription
	print("Description changed to " .. tostring(checkPDescription))
end

function QuestHerald:QuestHeraldtoggleTit(input)
	checkPTitle = not checkPTitle
	print("Title changed to " .. tostring(checkPTitle))
end

function QuestHerald:QuestHeraldtoggleVA(input)
	checkPPlayVAAudio = not checkPPlayVAAudio
	print("Changed using VA to " .. tostring(checkPPlayVAAudio))
end

function QuestHerald:EnableObj(input)
	checkPlayObjective = true
	print("Playing Objective is set to" .. tostring(checkPlayObjective))
end


function QuestHerald:DisableObj(input)
	checkPlayObjective = false
	print("Playing Objective is set to" .. tostring(checkPlayObjective))
end


function QuestHerald:EnableDes(input)
	checkPDescription = true
	print("Playing Description is set to" .. tostring(checkPDescription))
end


function QuestHerald:DisableDes(input)
	checkPDescription = false
	print("Playing Description is set to" .. tostring(checkPDescription))
end


function QuestHerald:EnableTit(input)
	checkPTitle = true
	print("Playing Title is set to" .. tostring(checkPTitle))
end

function QuestHerald:DisableTit(input)
	checkPTitle = false
	print("Playing Title is set to" .. tostring(checkPTitle))
end

function QuestHerald:DisableVA(input)
	checkPPlayVAAudio = false
	print("Using VA is set to" .. tostring(checkPPlayVAAudio))
end

function QuestHerald:EnableVA(input)
	checkPPlayVAAudio = true
	print("Using VA is set to" .. tostring(checkPPlayVAAudio))
end

function QuestHerald:StopSounds()
	soundStoped = true
	self:CancelAllTimers()
	print("Sounds Stoped")
end

---------------------------------------------------------------------
-- Gui Set up
---------------------------------------------------------------------


function QuestHerald:QuestHeraldShowGui(input)
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("Example Frame")
	frame:SetStatusText("QuestHerald - Quest Reader")
	frame:SetWidth(350)
	frame:SetHeight(300)
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	frame:SetLayout("Flow")
	
	
	local objectiveCheckBox = AceGUI:Create("CheckBox")
    objectiveCheckBox:SetLabel("Play Objective")
	objectiveCheckBox:SetDescription("True to listen to the quest Objective text")
    objectiveCheckBox:SetValue(checkPlayObjective)
	objectiveCheckBox:SetCallback("OnValueChanged",function()
        --frame:SetValue(not frame:GetValue())
		QuestHerald:QuestHeraldtoggleObj()
    end)
	frame:AddChild(objectiveCheckBox)
	
	local descriptionCheckBox = AceGUI:Create("CheckBox")
    descriptionCheckBox:SetLabel("Play Description")
	descriptionCheckBox:SetDescription("True to listen to the quest Description text")
    descriptionCheckBox:SetValue(checkPDescription)
	descriptionCheckBox:SetCallback("OnValueChanged",function()
        --frame:SetValue(not frame:GetValue())
		QuestHerald:QuestHeraldtoggleDes()
    end)
	frame:AddChild(descriptionCheckBox)
	
	local titleCheckBox = AceGUI:Create("CheckBox")
    titleCheckBox:SetLabel("Play Title")
	titleCheckBox:SetDescription("True to listen to the quest Title text")
    titleCheckBox:SetValue(checkPTitle)
	titleCheckBox:SetCallback("OnValueChanged",function()
        --frame:SetValue(not frame:GetValue())
		QuestHerald:QuestHeraldtoggleTit()
    end)
	frame:AddChild(titleCheckBox)
		
	local VACheckBox = AceGUI:Create("CheckBox")
    VACheckBox:SetLabel("Use VA")
	VACheckBox:SetDescription("True to use voice acting where available.")
    VACheckBox:SetValue(checkPPlayVAAudio)
	VACheckBox:SetCallback("OnValueChanged",function()
        --frame:SetValue(not frame:GetValue())
		QuestHerald:QuestHeraldtoggleVA()
    end)
	frame:AddChild(VACheckBox)
end

