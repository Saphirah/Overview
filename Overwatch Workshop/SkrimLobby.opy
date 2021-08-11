settings {
    "main": {
        "description": "Seita Scrim lobby v1.23 -- Improved by Saphirah"
    },
    "gamemodes": {
        "control": {"scoreToWin": 3},
        "assault": {},
        "escort": {},
        "hybrid": {},
        "general": {
            "enableCompetitiveRules": true,
            "gamemodeStartTrigger": "immediately",
            "enableKillCam": false,
            "roleLimit": "2OfEachRolePerTeam",
            "enableSkins": false
        }
    },
    "workshop": {
        "Dealt Damage": false,
        "Dealt Healing": false,
        "Received Healing": false,
        "Took Damage": false,
        "Ultimate Increase Increment": 20
    }
}

#Global variables
globalvar Team1Ready 0
globalvar Team2Ready 1
globalvar GameMode 2
globalvar TimeCooldown 3
globalvar BreakCooldown 4
globalvar T1ReadyCD 5
globalvar T2ReadyCD 6
globalvar RoundCounter 8
globalvar Team1Score 9
globalvar Team2Score 10
globalvar V_Nametag 11
globalvar V_Value 12
globalvar V_Target 13
globalvar S_Debug 14
globalvar DC_StoreVariablesTeam1 15
globalvar DC_StoreVariablesTeam2 16
globalvar DC_Temp 17
globalvar Index 20
globalvar Index2 21

#Player variables
playervar HeroList 0
playervar CurrentHero 1
playervar PlayedHeroes 2

#Subroutine names
subroutine Log 0
subroutine Summary 1
subroutine ResetVariables 2

rule "Seita Scrim lobby":

    #Create Ready Text
    hudHeader(getPlayers(Team.1) if Team1Ready else null, "Your team is ready", HudPosition.TOP, 20, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(getPlayers(Team.2) if Team1Ready else null, "Enemy team is ready", HudPosition.TOP, 20, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(getPlayers(Team.2) if Team2Ready else null, "Your team is ready", HudPosition.TOP, 20, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(getPlayers(Team.1) if Team2Ready else null, "Enemy team is ready", HudPosition.TOP, 20, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

    #Help Text
    hudSubtext(null if isGameInProgress() else getAllPlayers(), " ", HudPosition.RIGHT, 20, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext(null if isGameInProgress() else getAllPlayers(), " ", HudPosition.RIGHT, 21, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubheader(null if isGameInProgress() else getAllPlayers(), "[{0}]: Add 20 seconds to timer".format(buttonString(Button.ULTIMATE)), HudPosition.RIGHT, 23, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubheader(null if isGameInProgress() else getAllPlayers(), "[{0} + {1}]: Add 5 min break timer".format(buttonString(Button.INTERACT), buttonString(Button.ULTIMATE)), HudPosition.RIGHT, 24, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    
    #Spectator Help Text
    hudSubtext(null, " ", HudPosition.RIGHT, 27, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubheader(null, "Statistics are only shown to Spectators", HudPosition.RIGHT, 28, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubheader(null, "DPS&Tanks: Damage Done - Damage Taken - Ults used  - Deaths", HudPosition.RIGHT, 29, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubheader(null, "Supports: Damage Done - Healing Done - Ults used - Deaths", HudPosition.RIGHT, 30, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

    #Create Spectator Tables
    for Index in range(0,6):
        hudSubtext(null, l"{0} {1}".format(heroIcon(getPlayersInSlot(evalOnce(Index), Team.1).getCurrentHero()), l"{0} - {1} - {2}".format(round(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.DAMAGE_DEALT)), round(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.HEALING_DEALT)) if getPlayersInSlot(evalOnce(Index), Team.1).getCurrentHero() in getSupportHeroes() == true else round(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.DAMAGE_TAKEN)), l"{0} - {1}".format(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.ULTIMATES_USED), getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.DEATHS)))), HudPosition.LEFT, 1, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
        hudSubtext(null, l"{0} {1}".format(heroIcon(getPlayersInSlot(evalOnce(Index), Team.2).getCurrentHero()), l"{0} - {1} - {2}".format(round(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.DAMAGE_DEALT)), round(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.HEALING_DEALT)) if getPlayersInSlot(evalOnce(Index), Team.2).getCurrentHero() in getSupportHeroes() == true else round(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.DAMAGE_TAKEN)), l"{0} - {1}".format(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.ULTIMATES_USED), getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.DEATHS)))), HudPosition.RIGHT, 1, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    #Save Gamemode
    switch(getCurrentGamemode()):
        case Gamemode.ESCORT:
            GameMode = 1
            break
        case Gamemode.HYBRID:
            GameMode = 1
            break
        case Gamemode.ASSAULT:
            GameMode = 2
            break
        case Gamemode.CONTROL:
            GameMode = 3
            RoundCounter = -1
            break
    
    DC_StoreVariablesTeam1 = [[],[],[],[],[],[]]
    DC_StoreVariablesTeam2 = [[],[],[],[],[],[]]


rule "Add Defense Teleport HUD":
    @Event eachPlayer
    @Condition isTeamOnDefense(eventPlayer.getTeam()) or isTeamOnOffense(eventPlayer.getTeam())
    hudSubheader(eventPlayer if not(isGameInProgress()) and isTeamOnDefense(eventPlayer.getTeam()) and eventPlayer.isInSpawnRoom() else null, "Press {0}: Teleport".format(buttonString(Button.MELEE)), HudPosition.RIGHT, 25, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubheader(eventPlayer if not(isGameInProgress()) and isTeamOnDefense(eventPlayer.getTeam()) else null, "Hold {0}: Change hero".format(buttonString(Button.RELOAD)), HudPosition.RIGHT, 26, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    if(eventPlayer.getTeam() == Team.1):
        hudSubheader(null if isGameInProgress() else eventPlayer, "[{0} + {1}]: Cancel Ready".format(buttonString(Button.INTERACT), buttonString(Button.CROUCH)) if Team1Ready else "[{0} + {1}]: Ready".format(buttonString(Button.INTERACT), buttonString(Button.CROUCH)), HudPosition.RIGHT, 22, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    else:
        hudSubheader(null if isGameInProgress() else eventPlayer, "[{0} + {1}]: Cancel Ready".format(buttonString(Button.INTERACT), buttonString(Button.CROUCH)) if Team2Ready else "[{0} + {1}]: Ready".format(buttonString(Button.INTERACT), buttonString(Button.CROUCH)), HudPosition.RIGHT, 22, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

rule "Remove Assembling Heroes":
    @Condition isAssemblingHeroes() == true
    setMatchTime(0)
    wait(5)
    setMatchTime(50)


def ResetVariables():
    Team1Ready = false
    Team2Ready = false
    TimeCooldown = 0
    BreakCooldown = 0
    T1ReadyCD = 0
    T2ReadyCD = 0


rule "Game in Progress: Remove HUD, Reset variables":
    @Condition isGameInProgress() == true
    ResetVariables()


#rule "Ready Check":


rule "Both Teams Ready: Match starts in 5 sec, Remove HUD, Reset variables":
    @Condition isGameInProgress() == false
    @Condition Team1Ready == true
    @Condition Team2Ready == true
    setMatchTime(5)


rule "Ultimate: +20s match time while in setup":
    @Event eachPlayer
    @Condition isGameInProgress() == false
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == false
    setMatchTime(getMatchTime() + 20)
    smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "added 20 seconds"))
    if(eventPlayer.getTeam() == Team.1):
        Team1Ready = false
    else:
        Team2Ready = false


rule "Interact + Ultimate: +5min match time while in setup":
    @Event eachPlayer
    @Condition isGameInProgress() == false
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    setMatchTime(getMatchTime() + 300)
    smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "added 5 mins"))
    if(eventPlayer.getTeam() == Team.1):
        Team1Ready = false
    else:
        Team2Ready = false


rule "Crouch + Interact: Team 1 Ready":
    @Event eachPlayer
    @Team 1
    @Condition isGameInProgress() == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition T1ReadyCD == 0
    T1ReadyCD = 1
    wait(0.1)
    Team1Ready = not(Team1Ready)
    chase(T1ReadyCD, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    if(Team1Ready):
        smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "readied their team"))
    else:
        smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "unreadied their team"))
        setMatchTime(max(60, getMatchTime()))


rule "Crouch + Interact: Team 2 Ready":
    @Event eachPlayer
    @Team 2
    @Condition isGameInProgress() == false
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition T2ReadyCD == 0
    T2ReadyCD = 1
    wait(0.1)
    Team2Ready = not(Team2Ready)
    chase(T2ReadyCD, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    if(Team2Ready):
        smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "readied their team"))
    else:
        smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "unreadied their team"))
        setMatchTime(max(60, getMatchTime()))


#rule "Setting Score after failed attacks":


rule "Round Counter":
    @Condition isGameInProgress() == false
    RoundCounter += 1


rule "Set Team Score: Escort & Hybrid":
    @Condition RoundCounter > 1
    switch(GameMode):
        case 1:
            #Escort & Hybrid
            setTeamScore(Team.2, 3)
            break
        case 2:
            #Assault
            setTeamScore(Team.2, 2)
            break

rule "Reconnect Player":
    @Event playerJoined
    if eventPlayer.getTeam() == Team.1:
        DC_Temp = DC_StoreVariablesTeam1[eventPlayer.getSlot()]
    else:
        DC_Temp = DC_StoreVariablesTeam1[eventPlayer.getSlot()]
    eventPlayer.startForcingHero(DC_Temp[4])
    eventPlayer.setHealth(DC_Temp[0])
    eventPlayer.setUltCharge(DC_Temp[1])
    eventPlayer.teleport(DC_Temp[2])
    eventPlayer.setFacing(DC_Temp[3], Relativity.TO_WORLD)
    if DC_Temp[0] <= 0:
        kill(eventPlayer, null)
    eventPlayer.stopForcingCurrentHero()

rule "Store Team Values for Reconnect":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    if eventPlayer.getTeam() == Team.1:
        DC_StoreVariablesTeam1[eventPlayer.getSlot()] = [eventPlayer.getHealth(), eventPlayer.getUltCharge(), eventPlayer.getPosition(), eventPlayer.getFacingDirection(), eventPlayer.getCurrentHero()]
    else:
        DC_StoreVariablesTeam2[eventPlayer.getSlot()] = [eventPlayer.getHealth(), eventPlayer.getUltCharge(), eventPlayer.getPosition(), eventPlayer.getFacingDirection(), eventPlayer.getCurrentHero()]
    wait(2, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


#rule "Teleports for Defense team":


rule "Hold Reload: Change hero for Defense team":
    @Event eachPlayer
    @Condition isInSetup() == true
    @Condition isTeamOnDefense(eventPlayer.getTeam()) == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true    
    wait(0.2, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "keep holding reload to change hero")
    wait(0.7, Wait.ABORT_WHEN_FALSE)
    eventPlayer.HeroList = getAllHeroes()
    eventPlayer.HeroList.remove(eventPlayer.getCurrentHero())
    eventPlayer.setAllowedHeroes(eventPlayer.HeroList)
    wait(0.1)
    eventPlayer.setAllowedHeroes(getAllHeroes())


rule "Press Melee for all of the maps":
    @Event eachPlayer
    @Condition isInSetup() == true
    @Condition isTeamOnDefense(eventPlayer.getTeam()) == true
    @Condition eventPlayer.isInSpawnRoom() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    switch (getCurrentMap()):
        case Map.BLIZZ_WORLD:
        case Map.BLIZZ_WORLD_WINTER:
            eventPlayer.teleport(vect(-8.171, 3.824, 65.861))
            break
        case Map.EICHENWALDE:
        case Map.EICHENWALDE_HALLOWEEN:
            eventPlayer.teleport(vect(13.226, 12.981, -83.655))
            break
        case Map.HOLLYWOOD:
        case Map.HOLLYWOOD_HALLOWEEN:
            eventPlayer.teleport(vect(-19.248, 8.007, -9.802))
            break
        case Map.KINGS_ROW:
        case Map.KINGS_ROW_WINTER:
            eventPlayer.teleport(vect(-37.185, 10.346, -15.058))
            break
        case Map.NUMBANI:
            eventPlayer.teleport(vect(93.044, 5.53, -22.723))
            break
        case Map.HANAMURA:
        case Map.HANAMURA_WINTER:
            eventPlayer.teleport(vect(13.079, 1.346, -24.267))
            break
        case Map.HORIZON_LUNAR_COLONY:
            eventPlayer.teleport(vect(42.356, 15.84, -79.798))
            break
        case Map.PARIS:
            eventPlayer.teleport(vect(-40.379, 16.5, -14.259))
            break
        case Map.TEMPLE_OF_ANUBIS:
            eventPlayer.teleport(vect(-23.909, 3.312, 46.94))
            break
        case Map.VOLSKAYA:
            eventPlayer.teleport(vect(-35.545, -1.433, 73.561))
            break
        case Map.DORADO:
            eventPlayer.teleport(vect(57.088, 9.241, -16.884))
            break
        case Map.HAVANA:
            eventPlayer.teleport(vect(-18.059, 9.184, -70.117))
            break
        case Map.JUNKERTOWN:
            eventPlayer.teleport(vect(-28.382, 14.223, -68.289))
            break
        case Map.RIALTO:
            eventPlayer.teleport(vect(55.603, 2.452, -44.947))
            break
        case Map.ROUTE66:
            eventPlayer.teleport(vect(33.662, 10.325, -5.514))
            break
        case Map.WATCHPOINT_GIBRALTAR:
            eventPlayer.teleport(vect(32.488, 4.692, -71.941))
            break