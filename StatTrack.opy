settings {
    "main": {
        "description": "Seita Scrim lobby v1.23 -- Including Stat Tracking -- By Saphirah"
    },
    "gamemodes": {
        "control": {
            "enabledMaps": [
                "lijiangTower"
            ],
            "scoreToWin": 3
        },
        "general": {
            "enableCompetitiveRules": true,
            "gamemodeStartTrigger": "immediately",
            "enableKillCam": false,
            "roleLimit": "2OfEachRolePerTeam",
            "enableSkins": true
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
globalvar Index 7
globalvar RoundCounter 8
globalvar Team1Score 9
globalvar Team2Score 10
globalvar V_Nametag 11
globalvar V_Value 12
globalvar V_Target 13
globalvar S_Debug 14


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
    hudSubheader(null if isGameInProgress() else getAllPlayers(), "Press {0} + {1}: Ready (or cancel Ready)".format(buttonString(Button.INTERACT), buttonString(Button.CROUCH)), HudPosition.RIGHT, 22, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubheader(null if isGameInProgress() else getAllPlayers(), "Press {0}: adds extra 20 seconds to setup".format(buttonString(Button.ULTIMATE)), HudPosition.RIGHT, 23, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubheader(null if isGameInProgress() else getAllPlayers(), "Press {0} + {1}: Adds 5 min break timer".format(buttonString(Button.INTERACT), buttonString(Button.ULTIMATE)), HudPosition.RIGHT, 24, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubheader(null if isGameInProgress() else getAllPlayers(), "Press {0}: Teleport (works only in Defense, in spawn)".format(buttonString(Button.MELEE)), HudPosition.RIGHT, 25, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubheader(null if isGameInProgress() else getAllPlayers(), "Hold {0}: Change hero (works only in Defense)".format(buttonString(Button.RELOAD)), HudPosition.RIGHT, 26, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudSubtext(null, " ", HudPosition.RIGHT, 27, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubheader(null, "Statistics are only shown to Spectators", HudPosition.RIGHT, 28, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubheader(null, "DPS&Tanks: Damage Done - Damage Taken - Ults used  - Deaths", HudPosition.RIGHT, 29, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudSubheader(null, "Supports: Damage Done - Healing Done - Ults used - Deaths", HudPosition.RIGHT, 30, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

    #Create Spectator Tables
    for Index in range(0,6):
        hudSubtext(null, l"{0} {1}".format(heroIcon(getPlayersInSlot(evalOnce(Index), Team.1).getCurrentHero()), l"{0} - {1} - {2}".format(round(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.DAMAGE_DEALT)), round(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.HEALING_DEALT)) if getPlayersInSlot(evalOnce(Index), Team.1).getCurrentHero() in getSupportHeroes() == true else round(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.DAMAGE_TAKEN)), l"{0} - {1}".format(getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.ULTIMATES_USED), getPlayersInSlot(evalOnce(Index), Team.1).getStatistic(Stat.DEATHS)))), HudPosition.LEFT, 1, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
        hudSubtext(null, l"{0} {1}".format(heroIcon(getPlayersInSlot(evalOnce(Index), Team.2).getCurrentHero()), l"{0} - {1} - {2}".format(round(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.DAMAGE_DEALT)), round(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.HEALING_DEALT)) if getPlayersInSlot(evalOnce(Index), Team.2).getCurrentHero() in getSupportHeroes() == true else round(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.DAMAGE_TAKEN)), l"{0} - {1}".format(getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.ULTIMATES_USED), getPlayersInSlot(evalOnce(Index), Team.2).getStatistic(Stat.DEATHS)))), HudPosition.RIGHT, 1, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
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

/*
rule "Ready Check":
*/

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
    @Condition TimeCooldown == 0
    TimeCooldown = 2
    setMatchTime(getMatchTime() + 20)
    chase(TimeCooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "added 20 seconds"))


rule "Interact + Ultimate: +5min match time while in setup":
    @Event eachPlayer
    @Condition isGameInProgress() == false
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition BreakCooldown == 0
    BreakCooldown = 10
    TimeCooldown = 10
    setMatchTime(getMatchTime() + 300)
    chase(BreakCooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    chase(TimeCooldown, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    smallMessage(getAllPlayers(), l"{0} {1}".format(eventPlayer, "added 5 mins"))


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

/*
rule "Setting Score after failed attacks":
*/

rule "Round Counter":
    @Condition isGameInProgress() == false
    RoundCounter += 1


rule "Set Team Score: Escort & Hybrid":
    @Condition RoundCounter > 0
    switch(GameMode):
        case 1:
            #Escort & Hybrid
            setTeamScore(Team.2, 3)
            break
        case 2:
            #Assault
            setTeamScore(Team.2, 2)
            break

/*
rule "Teleports for Defense team":
*/

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
            eventPlayer.teleport(vect(-8.171, 3.824, 65.861))
            break
        case Map.EICHENWALDE:
            eventPlayer.teleport(vect(13.226, 12.981, -83.655))
            break
        case Map.HOLLYWOOD:
            eventPlayer.teleport(vect(-19.248, 8.007, -9.802))
            break
        case Map.KINGS_ROW:
            eventPlayer.teleport(vect(-37.185, 10.346, -15.058))
            break
        case Map.NUMBANI:
            eventPlayer.teleport(vect(93.044, 5.53, -22.723))
            break
        case Map.HANAMURA:
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


#rule "==============================STATISTICS================================"


rule "Setup":
    S_Debug = createWorkshopSetting(bool, "DEBUG", "Enable Debug Mode", false, 0)
    V_Nametag = "EV_LoadMap"
    V_Value = getCurrentMap()
    Log()


rule "Setup EventPlayer":
    @Event eachPlayer
    eventPlayer.PlayedHeroes = []


rule "DEBUG: Spawn Dummy Bot":
    @Event eachPlayer
    @Condition S_Debug == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    createDummy(random.choice(getAllHeroes()), getOppositeTeam(eventPlayer.getTeam()), -1, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100, getAllPlayers(), eventPlayer, true).getHitPosition(), eventPlayer.getFacingDirection())


rule "DEBUG: UI":
    @Condition S_Debug == true
    hudText(getAllPlayers(), "Server Load: {0}".format(updateEveryTick(getServerLoad())), "Server Load Average: {0}".format(updateEveryTick(getAverageServerLoad())), "Server Load Peak: {0}".format(getPeakServerLoad()), HudPosition.LEFT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


#rule "==============================STATISTICS================================"


def Log():
    @Name "LOG EVENT"
    #Uses the 3 variables as function input. Uses them to log data and then clears the files
    printLog(", {0} , \"{1}\" , {2}".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), V_Nametag, "\"{0}\" , \"{1}\"".format(V_Value, V_Target)))
    V_Nametag = l""
    V_Value = l""
    V_Target = l""


rule "Switched Hero":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.CurrentHero != eventPlayer.getCurrentHero()
    @Condition createWorkshopSetting(bool, "Enable Stats", "Switched Heroes", true, 0) == true
    V_Nametag = "EV_SwitchedHero"
    V_Value = eventPlayer.getCurrentHero()
    Log()
    eventPlayer.CurrentHero = eventPlayer.getCurrentHero()
    if not eventPlayer.getCurrentHero() in eventPlayer.PlayedHeroes:
        eventPlayer.PlayedHeroes.append(eventPlayer.getCurrentHero())


rule "Player Joined Match":
    @Event playerJoined
    @Condition createWorkshopSetting(bool, "Enable Stats", "Player joined Match", true, 0) == true
    V_Nametag = "EV_PlayerJoinedMatch"
    V_Value = eventPlayer
    Log()


rule "Player Left Match":
    @Event playerLeft
    @Condition createWorkshopSetting(bool, "Enable Stats", "Player left match", true, 0) == true
    V_Nametag = "EV_PlayerLeftMatch"
    V_Value = eventPlayer
    Log()


rule "Player Died":
    @Event playerDied
    @Condition createWorkshopSetting(bool, "Enable Stats", "Player Died", true, 0) == true
    V_Nametag = "EV_Died"
    V_Target = attacker
    Log()


rule "Ability 1":
    @Event eachPlayer
    @Condition eventPlayer.isUsingAbility1() == true
    @Condition createWorkshopSetting(bool, "Enable Stats", "Used Ability 1", true, 0) == true
    V_Nametag = "EV_UsedAbility_1"
    Log()


rule "Ability 2":
    @Event eachPlayer
    @Condition eventPlayer.isUsingAbility2() == true
    @Condition createWorkshopSetting(bool, "Enable Stats", "Used Ability 2", true, 0) == true
    V_Nametag = "EV_UsedAbility_2"
    Log()


rule "Ability Ultimate":
    @Event eachPlayer
    @Condition eventPlayer.isUsingUltimate() == true
    @Condition createWorkshopSetting(bool, "Enable Stats", "Used Ultimate", true, 0) == true
    V_Nametag = "EV_UsedAbility_Ultimate"
    Log()

rule "Final Blows":
    @Event playerDealtFinalBlow
    @Condition createWorkshopSetting(bool, "Enable Stats", "Final Blow", true, 0) == true
    V_Nametag = "EV_FinalBlow"
    V_Value = victim
    Log()


rule "Kills":
    @Event playerEarnedElimination
    @Condition createWorkshopSetting(bool, "Enable Stats", "Kills/Assists", true, 0) == true
    V_Nametag = "EV_Kill"
    V_Value = victim
    Log()


rule "Received Knockback":
    @Event playerReceivedKnockback
    @Condition createWorkshopSetting(bool, "Enable Stats", "Received Knockbacks", true, 0) == true
    V_Nametag = "EV_Knockback_Received"
    V_Target = victim
    Log()


rule "Dealt Knockback":
    @Event playerDealtKnockback
    @Condition createWorkshopSetting(bool, "Enable Stats", "Dealt Knockbacks", true, 0) == true
    V_Nametag = "EV_Knockback_Dealt"
    V_Target = attacker
    Log()


rule "Team achieved point":
    @Event eachPlayer
    @Condition teamScore(eventPlayer.getTeam()) > (Team1Score if eventPlayer.getTeam() == Team.1 else Team2Score)
    if eventPlayer.getTeam() == Team.1:
        Team1Score = teamScore(eventPlayer.getTeam())
    else:
        Team2Score = teamScore(eventPlayer.getTeam())
    V_Nametag = "EV_Scored"
    V_Value = Team1Score
    V_Target = eventPlayer.getTeam()
    Log()


#rule "============================STATISTICS TICK VALUES==============================":


rule "Dealt Damage":
    @Event playerDealtDamage
    @Condition createWorkshopSetting(bool, "Enable Stats - Tick Values", "Dealt Damage", false, 0) == true
    if eventWasEnvironment:
        V_Nametag = "TV_DealtDamage_Environmental"
    elif eventWasCriticalHit:
        V_Nametag = "TV_DealtDamage_Critical"
    else:
        V_Nametag = "TV_DealtDamage"
    V_Value = eventDamage
    V_Target = victim
    Log()

    
rule "Took Damage":
    @Event playerTookDamage
    @Condition createWorkshopSetting(bool, "Enable Stats - Tick Values", "Took Damage", false, 0) == true
    if eventWasEnvironment:
        V_Nametag = "TV_TookDamage_Environmental"
    elif eventWasCriticalHit:
        V_Nametag = "TV_TookDamage_Critical"
    else:
        V_Nametag = "TV_TookDamage"
    V_Value = eventDamage
    V_Target = victim
    Log()


rule "Dealt Healing":
    @Event playerDealtHealing
    @Condition createWorkshopSetting(bool, "Enable Stats - Tick Values", "Dealt Healing", false, 0) == true
    V_Nametag = "TV_DealtHealing"
    V_Value = eventHealing
    V_Target = healee
    Log()


rule "Received Healing":
    @Event playerReceivedHealing
    @Condition createWorkshopSetting(bool, "Enable Stats - Tick Values", "Received Healing", false, 0) == true
    V_Nametag = "TV_ReceivedHealing"
    V_Value = eventHealing
    V_Target = healer
    Log()


#rule "============================STATISTICS INCREMENTS==============================":


rule "Ultimate Percent Increment":
    @Event eachPlayer
    @Condition eventPlayer.getUltCharge() % createWorkshopSetting(int[1:100], "Increments", "Ultimate Increase Increment", 10, 0) == 0
    @Condition createWorkshopSetting(bool, "Enable Stats", "Ultimate Charge Percent", true, 0) == true
    V_Nametag = "INC_Charge_Ultimate"
    V_Value = eventPlayer.getUltCharge()
    Log()


#rule "============================STATISTICS SUMMARY==============================":


def Summary():
    @Name "STATISTIC SUMMARY"
    if(len(eventPlayer.PlayedHeroes) > 0):
        for Index in range(len(eventPlayer.PlayedHeroes)):
            printLog(", {0} , \"HS_Damage_All\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.DAMAGE_DEALT), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Damage_Barrier\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.BARRIER_DAMAGE_DEALT), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Accuracy_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.CRITICAL_HIT_ACCURACY), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Damage_Blocked\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.DAMAGE_BLOCKED), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Damage_Taken\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.DAMAGE_TAKEN), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Shot_Hit_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.CRITICAL_HITS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Deaths_All\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.DEATHS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Assists_Defensive\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.DEFENSIVE_ASSISTS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Eliminations\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.ELIMINATIONS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Deaths_Environmental\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.ENVIRONMENTAL_DEATHS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Kills_Environmental\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.ENVIRONMENTAL_KILLS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_FinalBlows\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.FINAL_BLOWS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Healing_Dealt\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.HEALING_DEALT), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Healing_Received\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.HEALING_RECEIVED), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Damage_Heroes\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.HERO_DAMAGE_DEALT), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Multikill_Best\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.MULTIKILL_BEST), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Multikills\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.MULTIKILLS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Kills_Objective\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.OBJECTIVE_KILLS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Assists_Offensive\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.OFFENSIVE_ASSISTS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Accuracy_Scoped\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SCOPED_ACCURACY), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Accuracy_Scoped_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SCOPED_CRITICAL_HIT_ACCURACY), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Kills_Scoped_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SCOPED_CRITICAL_HIT_KILLS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Shots_Hit_Scoped_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SCOPED_CRITICAL_HITS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Shots_Hit_Scoped\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SCOPED_HITS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Shots_Scoped\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SCOPED_SHOTS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Healing_Self\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SELF_HEALING), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Shots\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SHOTS_FIRED), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Shots_Hit\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SHOTS_HIT), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Shots_Missed\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SHOTS_MISSED), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Kills_Solo\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.SOLO_KILLS), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Ultimates_Earned\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.ULTIMATES_EARNED), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Ultimates_Used\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.ULTIMATES_USED), eventPlayer.PlayedHeroes[Index]))
            printLog(", {0} , \"HS_Accuracy\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[Index], HeroStat.WEAPON_ACCURACY), eventPlayer.PlayedHeroes[Index]))
        eventPlayer.PlayedHeroes = []
        printLog(", {0} , \"TS_Damage_All\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.DAMAGE_DEALT), null))
        printLog(", {0} , \"TS_Damage_Barrier\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.BARRIER_DAMAGE_DEALT), null))
        printLog(", {0} , \"TS_Damage_Blocked\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.DAMAGE_BLOCKED), null))
        printLog(", {0} , \"TS_Damage_Taken\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.DAMAGE_TAKEN), null))
        printLog(", {0} , \"TS_DeatTS_All\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.DEATHS), null))
        printLog(", {0} , \"TS_Assists_Defensive\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS), null))
        printLog(", {0} , \"TS_Eliminations\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.ELIMINATIONS), null))
        printLog(", {0} , \"TS_DeatTS_Environmental\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.ENVIRONMENTAL_DEATHS), null))
        printLog(", {0} , \"TS_Kills_Environmental\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.ENVIRONMENTAL_KILLS), null))
        printLog(", {0} , \"TS_FinalBlows\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.FINAL_BLOWS), null))
        printLog(", {0} , \"TS_Healing_Dealt\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.HEALING_DEALT), null))
        printLog(", {0} , \"TS_Damage_Heroes\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.HERO_DAMAGE_DEALT), null))
        printLog(", {0} , \"TS_Multikill_Best\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.MULTIKILL_BEST), null))
        printLog(", {0} , \"TS_Multikills\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.MULTIKILLS), null))
        printLog(", {0} , \"TS_Kills_Objective\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.OBJECTIVE_KILLS), null))
        printLog(", {0} , \"TS_Assists_Offensive\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS), null))
        printLog(", {0} , \"TS_Kills_Solo\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.SOLO_KILLS), null))
        printLog(", {0} , \"TS_Ultimates_Earned\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.ULTIMATES_EARNED), null))
        printLog(", {0} , \"TS_Ultimates_Used\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.ULTIMATES_USED), null))
        printLog(", {0} , \"TS_Accuracy\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getStatistic(Stat.WEAPON_ACCURACY), null))

rule "Hero Summary on End of Match":
    @Event eachPlayer
    @Condition RoundCounter > 1
    Summary()
    wait(2)
    declareDraw()