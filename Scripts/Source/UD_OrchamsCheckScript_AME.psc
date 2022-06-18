Scriptname UD_OrchamsCheckScript_AME extends activemagiceffect 


UDCustomDeviceMain Property UDCDmain auto
UD_OrgasmManager Property UDOM 
	UD_OrgasmManager Function get()
		return UDCDmain.UDOM
	EndFunction
EndProperty
UD_ExpressionManager Property UDEM 
	UD_ExpressionManager Function get()
		return UDCDmain.UDEM
	EndFunction
EndProperty
zadlibs Property libs auto

Actor akActor = none
bool _finished = false
MagicEffect _MagickEffect = none

;local variables
float loc_currentUpdateTime 		= 1.0
bool loc_widgetShown 				= false
bool loc_forceStop 					= false
float loc_forcing					= 0.0
float loc_orgasmRate 				= 0.0
float loc_orgasmRate2 				= 0.0
float loc_orgasmRateAnti 			= 0.0
float loc_orgasmResistMultiplier	= 1.0
float loc_orgasmRateMultiplier		= 1.0
int loc_arousal 					= 0
int loc_tick 						= 1
int loc_tickS						= 0
int loc_expressionUpdateTimer 		= 0
bool loc_orgasmResisting 			= false
bool loc_expressionApplied 			= false
float loc_orgasmCapacity			= 100.0
float loc_orgasmResistence			= 2.5	
bool loc_enoughArousal 				= false
float loc_orgasmProgress 			= 0.0
float loc_orgasmProgress2			= 0.0
int loc_hornyAnimTimer 				= 0
bool[] loc_cameraState
int loc_msID 						= -1
sslBaseExpression expression

Event OnEffectStart(Actor akTarget, Actor akCaster)
	akActor = akTarget
	if UDCDmain.TraceAllowed()	
		UDCDmain.Log("UD_OrchamsCheckScript_AME started for " + UDCDmain.GetActorName(akActor) +"!",2)
	endif
	_MagickEffect = GetBaseObject()
	akActor.AddToFaction(UDOM.OrgasmCheckLoopFaction)
	expression = UDEM.getExpression("UDAroused");libs.SexLab.GetExpressionByName("UDAroused");

	if UDCDmain.ActorIsPlayer(akActor)
		loc_currentUpdateTime = UDOM.UD_OrgasmUpdateTime
	endif
	
	;init local variables
	loc_widgetShown 				= false
	loc_forceStop 					= false
	loc_orgasmRate 					= 0.0
	loc_orgasmRate2 				= 0.0
	loc_orgasmRateAnti 				= 0.0
	loc_orgasmResistMultiplier		= UDOM.getActorOrgasmResistMultiplier(akActor)
	loc_orgasmRateMultiplier		= UDOM.getActorOrgasmRateMultiplier(akActor)
	loc_arousal 					= UDOM.getArousal(akActor)
	loc_forcing 					= UDOM.getActorOrgasmForcing(akActor)
	loc_tick 						= 1
	loc_tickS						= 0
	loc_expressionUpdateTimer 		= 0
	loc_orgasmResisting 			= akActor.isInFaction(UDOM.OrgasmResistFaction)
	loc_expressionApplied 			= false;ActorHaveExpressionApplied(akActor)
	loc_orgasmCapacity				= UDOM.getActorOrgasmCapacity(akActor)
	loc_orgasmResistence			= UDOM.getActorOrgasmResist(akActor)
	loc_enoughArousal 				= false
	loc_orgasmProgress 				= 0.0
	loc_orgasmProgress2				= 0.0
	loc_hornyAnimTimer 				= 0
	loc_msID 						= -1
	
	registerForSingleUpdate(0.1)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_finished = true
	if UDCDmain.TraceAllowed()	
		UDCDmain.Log("UD_OrchamsCheckScript_AME - OnEffectFinish() for " + akActor,1)
	endif
	;stop moan sound
	if loc_msID != -1
		Sound.StopInstance(loc_msID)
	endif
	
	;end animation if it still exist
	if  loc_hornyAnimTimer > 0
		libs.EndThirdPersonAnimation(akActor, loc_cameraState, permitRestrictive=true)
		loc_hornyAnimTimer = 0
	EndIf
	
	;hide widget
	if loc_widgetShown
		UDCDmain.toggleWidget2(false)
	endif
	
	;reset expression
	UDEM.ResetExpression(akActor, expression)
	
	StorageUtil.UnsetFloatValue(akActor, "UD_OrgasmProgress")

	;end mutex
	akActor.RemoveFromFaction(UDOM.OrgasmCheckLoopFaction)
	if UDOM.UD_StopActorOrgasmCheckLoop == akActor
		UDOM.UD_StopActorOrgasmCheckLoop = none
	endif
EndEvent

Event OnUpdate()
	if IsRunning()
		if UDOM.OrgasmLoopBreak(akActor, UDOM.UD_OrgasmCheckLoop_ver) ;!UDCDmain.isRegistered(akActor) && !akActor.isDead()
			akActor.DispelSpell(UDCDmain.UDlibs.OrgasmCheckSpell)
		else
			loc_orgasmProgress2 = loc_orgasmProgress
			
			loc_orgasmResisting = akActor.isInFaction(UDOM.OrgasmResistFaction);StorageUtil.GetIntValue(akActor,"UD_OrgasmResisting",0)
			if loc_orgasmResisting
				loc_orgasmProgress = UDOM.getActorOrgasmProgress(akActor)
			else
				loc_orgasmProgress += loc_orgasmRate*loc_orgasmRateMultiplier*loc_currentUpdateTime
			endif
			
			loc_orgasmRateAnti = UDOM.CulculateAntiOrgasmRateMultiplier(loc_arousal)*loc_orgasmResistMultiplier*(loc_orgasmProgress*(loc_orgasmResistence/100.0))*loc_currentUpdateTime  ;edging, orgasm rate needs to be bigger then UD_OrgasmResistence, else actor will not reach orgasm
			
			if !loc_orgasmResisting
				if loc_orgasmRate*loc_orgasmRateMultiplier > 0.0
					loc_orgasmProgress -= loc_orgasmRateAnti
				else
					loc_orgasmProgress -= 3*loc_orgasmRateAnti
				endif
			endif
			
			if loc_widgetShown && !loc_orgasmResisting
				UDCDMain.widget2.SetPercent(loc_orgasmProgress/loc_orgasmCapacity)
			endif

			;check orgasm
			if loc_orgasmProgress > 0.99*loc_orgasmCapacity
				if UDCDmain.TraceAllowed()			
					UDCDmain.Log("Starting orgasm for " + getActorName())
				endif
				if loc_orgasmResisting
					akActor.RemoveFromFaction(UDOM.OrgasmResistFaction)
					;StorageUtil.SetIntValue(akActor,"UD_OrgasmResistMinigame_EndFlag",1)
				endif
				
				if loc_widgetShown
					loc_widgetShown = false
					UDCDMain.toggleWidget2(false)
					UDCDmain.widget2.SetPercent(0.0,true)
				endif
				
				loc_hornyAnimTimer = -30 ;cooldown
				
				Int loc_force = 0
				if loc_forcing < 0.5
					loc_force = 0
				elseif loc_forcing < 1.0
					loc_force = 1
				else
					loc_force = 2
				endif
				UDOM.startOrgasm(akActor,UDOM.UD_OrgasmDuration,75,loc_force,true)
				loc_orgasmProgress = 0.0
				UDOM.SetActorOrgasmProgress(akActor,loc_orgasmProgress)
			endif
			
			if loc_tick * loc_currentUpdateTime >= 1.0
				loc_orgasmRate2 = loc_orgasmRate
				if ActorIsPlayer()
					loc_currentUpdateTime = UDOM.UD_OrgasmUpdateTime
				endif
				
				loc_tick = 0
				loc_tickS += 1
				
				int loc_switch = (loc_tickS % 3)
				if loc_switch == 0
					loc_orgasmCapacity			= UDOM.getActorOrgasmCapacity(akActor)
				elseif loc_switch == 1
					loc_orgasmResistence 		= UDOM.getActorOrgasmResist(akActor)
				else
					loc_forcing 				= UDOM.getActorOrgasmForcing(akActor)
				endif
				
				if !loc_orgasmResisting
					loc_arousal 				= UDOM.getArousal(akActor)
					loc_orgasmRate 				= UDOM.getActorOrgasmRate(akActor)
					loc_orgasmRateMultiplier	= UDOM.getActorOrgasmRateMultiplier(akActor)
					loc_orgasmResistMultiplier 	= UDOM.getActorOrgasmResistMultiplier(akActor)
					UDOM.SetActorOrgasmProgress(akActor,loc_orgasmProgress)
				endif

				;expression
				if loc_orgasmRate >= loc_orgasmResistence*0.75 && (!loc_expressionApplied || loc_expressionUpdateTimer > 3) 
					;init expression
					UDEM.ApplyExpression(akActor, expression, iRange(Round(loc_orgasmProgress),25,100),false,10)
					loc_expressionApplied = true
					loc_expressionUpdateTimer = 0
				elseif loc_orgasmRate < loc_orgasmResistence*0.75 && loc_expressionApplied
					UDEM.ResetExpression(akActor, expression,10)
					loc_expressionApplied = false
				endif
				
				;can play horny animation ?
				if (loc_orgasmRate > 0.5*loc_orgasmResistMultiplier*loc_orgasmResistence) 
					if loc_enoughArousal
						;start moaning sound again
						if loc_msID == -1
							loc_msID = libs.MoanSound.Play(akActor)
							Sound.SetInstanceVolume(loc_msID, libs.GetMoanVolume(akActor))
						endif
					endif
				else
					;disable moaning sound when orgasm rate is too low
					if loc_msID != -1
						Sound.StopInstance(loc_msID)
						loc_msID = -1
					endif
				endif
				if !UDCDMain.actorInMinigame(akActor)
					if (loc_orgasmRate > 0.5*loc_orgasmResistMultiplier*loc_orgasmResistence) && !loc_orgasmResisting && !akActor.IsInCombat() ;orgasm progress is increasing
						if (loc_hornyAnimTimer == 0) && !libs.IsAnimating(akActor) && UDOM.UD_HornyAnimation ;start horny animation for UD_HornyAnimationDuration
							if Utility.RandomInt() <= (Math.ceiling(100/fRange(loc_orgasmProgress,15.0,100.0))) 
								; Select animation
								loc_cameraState = libs.StartThirdPersonAnimation(akActor, libs.AnimSwitchKeyword(akActor, "Horny01"), permitRestrictive=true)
								loc_hornyAnimTimer += UDOM.UD_HornyAnimationDuration
								if !loc_expressionApplied
									UDEM.ApplyExpression(akActor, expression, iRange(Round(loc_orgasmProgress),75,100),false,10)
									loc_expressionApplied = true
									loc_expressionUpdateTimer = 0
								endif
							endif
						EndIf
					endif
					
					if !loc_orgasmResisting
						if loc_hornyAnimTimer > 0 ;reduce horny animation timer 
							loc_hornyAnimTimer -= 1
							if (loc_hornyAnimTimer == 0)
								libs.EndThirdPersonAnimation(akActor, loc_cameraState, permitRestrictive=true)
								loc_hornyAnimTimer = -20 ;cooldown
							EndIf
						elseif loc_hornyAnimTimer < 0 ;cooldown
							loc_hornyAnimTimer += 1
						endif
					endif
				endif
				
				if UDOM.UD_UseOrgasmWidget && ActorIsPlayer()
					if (loc_widgetShown && loc_orgasmProgress < 2.5) ;|| (loc_widgetShown)
						UDCDMain.toggleWidget2(false)
						loc_widgetShown = false
					elseif !loc_widgetShown && loc_orgasmProgress >= 2.5
						UDCDMain.widget2.SetPercent(loc_orgasmProgress/loc_orgasmCapacity,true)
						UDCDMain.toggleWidget2(true)
						loc_widgetShown = true
					endif
				endif
				
				if loc_orgasmProgress < 0.0
					loc_orgasmProgress = 0.0
				endif
				
				loc_expressionUpdateTimer += 1
			endif
			if loc_widgetShown
				Utility.wait(loc_currentUpdateTime)
			else
				Utility.wait(1.0)
			endif
			
			loc_tick += 1
			
			if IsRunning()
				if loc_widgetShown
					registerForSingleUpdate(loc_currentUpdateTime)
				else
					registerForSingleUpdate(1.0)
				endif
			endif
		endif
	endif
EndEvent

bool Function IsRunning()
	return akActor.hasMagicEffect(_MagickEffect)
EndFunction

;wrappers
float Function fRange(float fValue,float fMin,float fMax) ;interface for UDmain
	return UDCDmain.fRange(fValue,fMin,fMax)
EndFunction
int Function iRange(int iValue,int iMin,int iMax) ;interface for UDmain
	return UDCDmain.iRange(iValue,iMin,iMax)
EndFunction
int Function Round(float fValue)
	return UDCDmain.Round(fValue)
EndFunction
bool Function ActorIsPlayer()
	return UDCDmain.ActorIsPlayer(akActor)
EndFunction
bool Function ActorIsFollower()
	return UDCDmain.ActorIsFollower(akActor)
EndFunction
string Function getActorName()
	return UDCDmain.getActorName(akActor)
EndFunction
Function Log(String msg, int level = 1)
	UDCDmain.Log(msg,level)
EndFunction
Function Error(String msg)
	UDCDmain.Error(msg)
EndFunction
Function Print(String strMsg, int iLevel = 1,bool bLog = false)
	UDCDmain.Print(strMsg,iLevel,bLog)
EndFunction
Bool Function TraceAllowed()
	return UDCDmain.TraceAllowed()
EndFunction
zadlibs_UDPatch Property libsp
	zadlibs_UDPatch function Get()
		return UDCDmain.libsp
	endfunction
endproperty