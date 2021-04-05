#Global variables

globalvar V_Nametag 40
globalvar V_Value 41
globalvar V_Target 42
globalvar S_Debug 43


#Player variables

playervar CurrentHero 40
playervar PlayedHeroes 41
playervar Index 42


#Subroutine names

subroutine Log 20
subroutine HeroSummary 21
subroutine PlayerSummary 22


rule "==================STAT TRACK CODE=============================":


rule "Setup":
    S_Debug = createWorkshopSetting(bool, "DEBUG", "Enable Debug Mode", false, 0)
    V_Nametag = null
    V_Value = null
    V_Target = null


rule "Setup EventPlayer":
    @Event eachPlayer
    @Hero all
    
    eventPlayer.PlayedHeroes = []


rule "DEBUG: Shorter Match":
    @Condition isGameInProgress() == true
    @Condition S_Debug == true
    
    setMatchTime(20)


rule "DEBUG: Spawn Dummy Bot":
    @Event eachPlayer
    @Hero all
    @Condition S_Debug == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    
    createDummy(random.choice(getAllHeroes()), getOppositeTeam(eventPlayer.getTeam()), -1, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100, getAllPlayers(), eventPlayer, true).getHitPosition(), eventPlayer.getFacingDirection())


rule "DEBUG: UI":
    @Condition S_Debug == true
    
    hudText(getAllPlayers(), "Server Load: {0}".format(updateEveryTick(getServerLoad())), "Server Load Average: {0}".format(updateEveryTick(getAverageServerLoad())), "Server Load Peak: {0}".format(getPeakServerLoad()), HudPosition.LEFT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


def Log():
    @Name "==============================STATISTICS EVENTS================================"
    
    #Uses the 3 variables as function input. Uses them to log data and then clears the files
    printLog(", {0} , \"{1}\" , {2}".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), V_Nametag, "\"{0}\" , \"{1}\"".format(V_Value, V_Target)))
    V_Nametag = l""
    V_Value = l""
    V_Target = l""


rule "Switched Hero":
    @Event eachPlayer
    @Hero all
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
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Player joined Match", true, 0) == true
    
    V_Nametag = "EV_PlayerJoinedMatch"
    V_Value = eventPlayer
    Log()


rule "Player Left Match":
    @Event playerJoined
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Player left match", true, 0) == true
    
    V_Nametag = "EV_PlayerLeftMatch"
    V_Value = eventPlayer
    Log()


rule "Player Died":
    @Event playerDied
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Player Died", true, 0) == true
    
    V_Nametag = "EV_Died"
    V_Target = attacker
    Log()


rule "Ability 1":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isUsingAbility1() == true
    @Condition createWorkshopSetting(bool, "Enable Stats", "Used Ability 1", true, 0) == true
    
    V_Nametag = "EV_UsedAbility_1"
    Log()


rule "Ability 2":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isUsingAbility2() == true
    @Condition createWorkshopSetting(bool, "Enable Stats", "Used Ability 2", true, 0) == true
    
    V_Nametag = "EV_UsedAbility_2"
    Log()


rule "Ability Ultimate":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isUsingUltimate() == true
    @Condition createWorkshopSetting(bool, "Enable Stats", "Used Ultimate", true, 0) == true
    
    V_Nametag = "EV_UsedAbility_Ultimate"
    Log()


rule "============================STATISTICS TICK VALUES==============================":


rule "Dealt Damage":
    @Event playerDealtDamage
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Dealt Damage", true, 0) == true
    
    if eventWasEnvironment:
        V_Nametag = "TV_DealtDamage_Environmental"
    elif eventWasCriticalHit:
        V_Nametag = "TV_DealtDamage_Critical"
    else:
        V_Nametag = "TV_DealtDamage"
    V_Value = eventDamage
    V_Target = victim
    Log()


rule "Final Blows":
    @Event playerDealtFinalBlow
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Final Blow", true, 0) == true
    
    V_Nametag = "EV_FinalBlow"
    V_Value = victim
    Log()


rule "Kills":
    @Event playerEarnedElimination
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Kills/Assists", true, 0) == true
    
    V_Nametag = "EV_Kill"
    V_Value = victim
    Log()


rule "Took Damage":
    @Event playerTookDamage
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Took Damage", true, 0) == true
    
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
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Dealt Healing", true, 0) == true
    
    V_Nametag = "TV_DealtHealing"
    V_Value = eventHealing
    V_Target = healee
    Log()


rule "Received Healing":
    @Event playerReceivedHealing
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Received Healing", true, 0) == true
    
    V_Nametag = "TV_ReceivedHealing"
    V_Value = eventHealing
    V_Target = healer
    Log()


rule "Received Knockback":
    @Event playerDealtKnockback
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Received Knockbacks", true, 0) == true
    
    V_Nametag = "EV_Knockback_Received"
    V_Target = victim
    Log()


rule "Dealt Knockback":
    @Event playerReceivedKnockback
    @Hero all
    @Condition createWorkshopSetting(bool, "Enable Stats", "Dealt Knockbacks", true, 0) == true
    
    V_Nametag = "EV_Knockback_Dealt"
    V_Target = attacker
    Log()


rule "============================STATISTICS INCREMENTS==============================":


rule "Ultimate Percent Increment":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.getUltCharge() % createWorkshopSetting(int[1:100], "Increments", "Ultimate Increase Increment", 10, 0) == 0
    @Condition createWorkshopSetting(bool, "Enable Stats", "Ultimate Charge Percent", true, 0) == true
    
    V_Nametag = "INC_Charge_Ultimate"
    V_Value = eventPlayer.getUltCharge()
    Log()


rule "============================STATISTICS SUMMARY==============================":


def HeroSummary():
    @Name "HERO STATISTIC SUMMARY"
    
    for eventPlayer.Index in range(len(eventPlayer.PlayedHeroes)):
        printLog(", {0} , \"HS_Damage_All\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.DAMAGE_DEALT), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Damage_Barrier\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.BARRIER_DAMAGE_DEALT), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Accuracy_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.CRITICAL_HIT_ACCURACY), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Damage_Blocked\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.DAMAGE_BLOCKED), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Damage_Taken\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.DAMAGE_TAKEN), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Shot_Hit_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.CRITICAL_HITS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Deaths_All\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.DEATHS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Assists_Defensive\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.DEFENSIVE_ASSISTS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Eliminations\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.ELIMINATIONS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Deaths_Environmental\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.ENVIRONMENTAL_DEATHS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Kills_Environmental\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.ENVIRONMENTAL_KILLS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_FinalBlows\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.FINAL_BLOWS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Healing_Dealt\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.HEALING_DEALT), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Healing_Received\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.HEALING_RECEIVED), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Damage_Heroes\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.HERO_DAMAGE_DEALT), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Multikill_Best\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.MULTIKILL_BEST), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Multikills\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.MULTIKILLS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Kills_Objective\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.OBJECTIVE_KILLS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Assists_Offensive\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.OFFENSIVE_ASSISTS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Accuracy_Scoped\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SCOPED_ACCURACY), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Accuracy_Scoped_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SCOPED_CRITICAL_HIT_ACCURACY), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Kills_Scoped_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SCOPED_CRITICAL_HIT_KILLS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Shots_Hit_Scoped_Critical\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SCOPED_CRITICAL_HITS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Shots_Hit_Scoped\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SCOPED_HITS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Shots_Scoped\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SCOPED_SHOTS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Healing_Self\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SELF_HEALING), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Shots\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SHOTS_FIRED), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Shots_Hit\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SHOTS_HIT), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Shots_Missed\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SHOTS_MISSED), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Kills_Solo\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.SOLO_KILLS), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Ultimates_Earned\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.ULTIMATES_EARNED), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Ultimates_Used\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.ULTIMATES_USED), eventPlayer.PlayedHeroes[eventPlayer.Index]))
        printLog(", {0} , \"HS_Accuracy\" , \"{1}\" , \"{2}\"".format("\"{0}\" , \"{1}\" , \"{2}\"".format(eventPlayer.getTeam(), eventPlayer.getSlot(), eventPlayer), eventPlayer.getHeroStatistic(eventPlayer.PlayedHeroes[eventPlayer.Index], HeroStat.WEAPON_ACCURACY), eventPlayer.PlayedHeroes[eventPlayer.Index]))
    eventPlayer.PlayedHeroes = []


def PlayerSummary():
    @Name "TOTAL STATISTIC SUMMARY"
    
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
    @Hero all
    @Condition eventPlayer.isDummy() == false
    @Condition len(eventPlayer.PlayedHeroes) > 0
    @Condition isMatchComplete() == true
    
    HeroSummary()


