Scriptname UD_OutfitStorage extends Quest

Int Property UD_Priority = 0 Auto
UnforgivingDevicesMain _udmain
UnforgivingDevicesMain Property UDmain Hidden
    UnforgivingDevicesMain Function Get()
        if !_udmain
            _udmain = UnforgivingDevicesMain.GetUDMain()
        endif
        return _udmain
    EndFunction
EndProperty

Event OnInit()
    UDMain.Info(self+" - OnInit called")
    RegisterForSingleUpdate(10.0 - UD_Priority*0.02)
EndEvent

Event OnUpdate()
    UDmain.UDOTM.AddOutfitStorage(self)
EndEvent

Int Function GetOutfitNum()
    return self.GetNumAliases()
EndFunction

UD_Outfit Function GetNthOutfit(Int aiIndex)
    return self.GetNthAlias(aiIndex) as UD_Outfit
EndFunction

UD_Outfit Function GetOutfitByAlias(String asAlias)
    int loc_i = 0
    while loc_i < GetOutfitNum()
        UD_Outfit loc_outfit = GetNthOutfit(loc_i)
        if loc_outfit.NameAlias == asAlias
            return loc_outfit
        endif
        loc_i += 1
    endwhile
    return none
EndFunction

Function ValidateOutfits()
    int loc_i = 0
    while loc_i < GetOutfitNum()
        UD_Outfit loc_outfit = GetNthOutfit(loc_i)
        loc_outfit.ValidateRnd()
        loc_i += 1
    endwhile
EndFunction