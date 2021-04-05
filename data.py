import sqlite3 as sl
from datetime import date
import random, re

class Singleton(object):
    """An object that will only exist once, even if you initialize it multiple times"""
    def __new__(cls, *args, **kwds):
        it = cls.__dict__.get("__it__")
        if it is not None:
            return it
        cls.__it__ = it = object.__new__(cls)
        it.__init__(*args, **kwds)
        return it

    def __init__(self, *args, **kwds):
        pass

#TODO: Split up in multiple classes
#I hate these wishy washy class implementations in python to be honest XD
class Database(Singleton):
    """A class to connect, get and edit data in the database"""
    def __init__(self , *args, **kwds):
        self.db = sl.connect('stats.db')

    #Matches
    def GetMatchDates(self) -> [str]:
        """Returns a list of date strings of all the matches"""
        matchDates = self.Submit("SELECT DISTINCT matchDate FROM tbl_Match ORDER BY matchDate DESC;").fetchall()
        return [item[0] for item in matchDates]
    def GetMatchesOnDate(self, date: str) -> [(int, int, int, str)]:
        """Returns all the matches on a specific date"""
        return self.Submit("SELECT * FROM tbl_Match WHERE matchDate = '" + date + "'").fetchall()
    def GetMatch(self, matchID: int) -> (int, int, int, str):
        """Gets the data from a match for a specific match id"""
        return self.Submit("SELECT * FROM tbl_Match WHERE matchID = '" + str(matchID) + "'").fetchone()
    def GetMatchType(self, matchID: int) -> (str, str):
        """Returns the typename and the typecolor for a match"""
        return self.Submit("SELECT typeName, typeColor FROM tbl_Match INNER JOIN cst_MatchType ON tbl_Match.matchTypeID_F = cst_MatchType.typeID WHERE matchID = " + str(matchID)).fetchone()
    def GetMatchLength(self, matchID: int) -> str:
        """Returns the length of a match in the time format 00:00:00"""
        return self.Submit("SELECT Max(gameTime) FROM tbl_Team INNER JOIN (tbl_Events INNER JOIN tbl_Player ON tbl_Events.playerID_F = tbl_Player.playerID) ON tbl_Team.teamID = tbl_Player.teamID_F WHERE tbl_Team.matchID_F = " + str(matchID)).fetchone()[0]

    #Players
    def GetPlayerID(self, teamID: int, playerSlot: int, playerName: str = None) -> int:
        """Try to find a specific player ID by team, slot and name"""
        sqlStr = "SELECT playerID FROM tbl_Player WHERE teamID_F = " & str(teamID) & " AND playerSlot = " & str(playerSlot)
        if teamID != None:
            sqlStr += " AND playerName = '" & str(playerName) & "'"
        return self.Submit(sqlStr).fetchone()[0]
    def GetPlayersOfTeam(self, teamID: int) -> (int, str):
        """Returns all id's and names of players in a specific team"""
        return self.Submit("SELECT playerID, playerName FROM tbl_Player WHERE teamID_F = " + str(teamID) + " ORDER BY playerName").fetchall()
    def GetPlayerName(self, playerID: int) -> str:
        """Get the name of a specific player"""
        return self.Submit("SELECT playerName FROM tbl_Player WHERE playerID = " + str(playerID)).fetchone()[0]

    #Player Summary Stats
    def GetPlayerHeroSummary(self, playerID: int, hero: str, eventName: str) -> (str, float):
        """Returns the text and value for a specific player stat, for a specific hero"""
        if not eventName.startswith("HS_"):
            return None
        return self.Submit("SELECT eventText, eventValue FROM tbl_Events INNER JOIN cst_EventName ON tbl_Events.eventName = cst_EventName.eventName WHERE playerID_F = " + str(playerID) + " AND eventTarget = '" + str(hero) + "' AND tbl_Events.eventName = '" + str(eventName) + "'").fetchone()
    def GetPlayerSummary(self, playerID: int, eventName: str) -> (str, float):
        """Returns the text and value for a specific player stat"""
        if not eventName.startswith("HS_"):
            return None
        return self.Submit("SELECT eventText, Sum(eventValue) FROM tbl_Events INNER JOIN cst_EventName ON tbl_Events.eventName = cst_EventName.eventName WHERE playerID_F = " + str(playerID) + " AND tbl_Events.eventName = '" + str(eventName) + "'").fetchone()
    def GetAllSummaryTypes(self) -> [(str, str)]:
        return self.Submit("SELECT * FROM cst_EventName ORDER BY eventText").fetchall()

    #Events
    def GetEventName(self, eventName: str) -> str:
        if not eventName.startswith("HS_"):
            return None
        return self.Submit("SELECT eventText FROM tbl_EventName WHERE eventName = '" + str(eventName) + "'").fetchone()[0]
    def GetEvents(self, eventName: str = None, eventPlayerID: int = None) -> [(int, str, int, str, str, str)]:
        sqlStr = "SELECT * FROM tbl_Events"
        if eventName != None or eventPlayerID != None:
            sqlStr += " WHERE "
            if(eventName != None):
                sqlStr += "eventName = '" + str(eventName) + "' AND "
            if(eventPlayerID != None):
                sqlStr += "playerID_F = '" + str(eventPlayerID) + "' AND "
            sqlStr = sqlStr[:-5]
        return self.Submit(sqlStr).fetchall()

    #Teams
    def GetTeamID(self, matchID: int, teamName: str = None) -> int:
        sqlStr = "SELECT teamID FROM tbl_Team WHERE matchID_F = " + str(matchID) + ((" AND teamName = '" & str(teamName) & "'") if teamName != None else "")
        return self.Submit(sqlStr).fetchone()[0]
    def GetTeamIDOfPlayer(self, playerID: int) -> int:
        return self.Submit("SELECT teamID_F FROM tbl_Player WHERE playerID = " + str(playerID)).fetchone()[0]

    #Maps
    def GetMapName(self, mapID: int) -> str:
        """Returns the readable name of the map"""
        return self.Submit("SELECT mapName FROM cst_Maps WHERE mapID = " + str(mapID)).fetchone()[0]
    def GetMapImageName(self, mapID: int) -> str:
        """Returns the image name of the map, to show images on the website"""
        return self.GetImageName(self.GetMapName(mapID))

    #Format various strings
    def FormatDate(self, date: str) -> str:
        nums = date.split(".")
        return nums[2] + "-" + nums[1] + "-" + nums[0]
    def FormatTimeToSeconds(self, timeStr: str) -> int:
        return sum(x * int(t) for x, t in zip([3600, 60, 1], timeStr.split(":"))) 
    def GetImageName(self, name: str) -> str:
        return name.lower().replace(" ", "")

    #Wrapper to send SQL Strings to database
    def Submit(self, SQLString: str) -> sl.Cursor:
        return self.db.execute(SQLString)

    #Write data to database
    def CreateMatch(self, matchTypeID: int = 2, mapID_F: int = 19, matchDate: str = date.today()) -> int:
        self.Submit("INSERT INTO tbl_Match(matchTypeID_F, mapID_F, matchDate) VALUES(" + str(matchTypeID) + ", " + str(mapID_F) + ",'" + str(matchDate) + "')")
        return self.Submit("SELECT Max(matchID) FROM tbl_Match").fetchone()[0]
    def CreateTeam(self, matchID: int = None, teamName: str = None) -> int: 
        #Select last created match if none given
        if matchID == None:
            matchID = self.Submit("SELECT Max(matchID) FROM tbl_Match").fetchone()[0]
        
        #Try to generate a team name if none was given
        if teamName == None:
            teamName = self.Submit("SELECT teamName FROM tbl_Team WHERE matchID_F = " + str(matchID) + " ORDER BY teamID DESC").fetchone()
            if teamName != None:
                teamName = teamName[0]
                if re.match("Team [1-24]", teamName):
                    teamName = "Team " + str(int(teamName.split(" ")[1])+1)
            else:
                teamName = "Team 1"
        self.Submit("INSERT INTO tbl_Team(matchID_F, teamName) VALUES(" + str(matchID) + ", '" + str(teamName) + "')")
        return self.Submit("SELECT Max(teamID) FROM tbl_Team").fetchone()[0]
    def CreatePlayer(self, playerName, playerSlot, teamID = None) -> int:
        if teamID == None:
            teamID = self.Submit("SELECT Max(teamID) FROM tbl_Team").fetchone()[0]
        self.Submit("INSERT INTO tbl_Player(teamID_F, playerName, playerSlot) VALUES(" + str(teamID) + ", '" + str(playerName) + "', " + str(playerSlot) + ")")
        return self.Submit("SELECT Max(playerID) FROM tbl_Player").fetchone()[0]
    def CreateEvent(self, gameTime, playerID_F, eventName, eventValue = "", eventTarget = None):
        self.Submit("INSERT INTO tbl_Events(gameTime, playerID_F, eventName, eventValue, eventTarget) VALUES('" + str(gameTime) + "', " + str(playerID_F) + ", '" + str(eventName) + "', '" + str(eventValue) + "', '" + str(eventTarget) + "')")

    #Wrapper to commit the database changes
    def Commit(self):
        """Commits the pending changes to the database. Before calling this, UPDATE, DELETE and INSERT functions won't be commited."""
        self.db.commit()

#Dumb implementation, will be a table later
class Heroes():
    ANA = 0
    ASHE = 1
    BAPTISTE = 2
    BASTION = 3
    BRIGITTE = 4
    DVA = 5
    DOOMFIST = 6
    ECHO = 7
    GENJI = 8
    HANZO = 9
    JUNKRAT = 10
    LUCIO = 11
    MCCREE = 12
    MEI = 13
    MERCY = 14
    MOIRA = 15
    ORISA = 16
    PHARAH = 17
    REAPER = 18
    REINHARDT = 19
    ROADHOG = 20
    SIGMA = 21
    SOLDIER76 = 22
    SOMBRA = 23
    SYMMETRA = 24
    TORBJÖRN = 25
    TRACER = 26
    WIDOWMAKER = 27
    WINSTON = 28
    WRECKINGBALL = 29
    ZARYA = 30
    ZENYATTA = 31

    def GetHeroName(index):
        return ["Ana", "Ashe", "Baptiste", "Bastion", "Brigitte", "Dva", "Doomfist", "Echo", "Genji", "Hanzo", "Junkrat", "Lucio", "Mccree", "Mei", "Mercy", "Moira", "Orisa", "Pharah", "Reaper", "Reinhardt", "Roadhog", "Sigma", "Soldier76", "Sombra", "Symmetra", "Torbjörn", "Tracer", "Widowmaker", "Winston", "Wreckingball", "Zarya", "Zenyatta"][index]

#Same as above
class Maps():
    HANAMURA = 0
    HORIZON = 1
    PARIS = 2
    TEMPLEOFANUBIS = 3
    VOLSKAYAINDUSTRIES = 4
    DORADO = 5
    HAVANA = 6
    JUNKERTOWN = 7
    RIALTO = 8
    ROUTE66 = 9
    WATCHPOINTGIBRALTAR = 10
    BLIZZARDWORLD = 11
    EICHENWALDE = 12
    HOLLYWOOD = 13
    KINGSROW = 14
    NUMBANI = 15
    BUSAN = 16
    ILIOS = 17
    LIJIANGTOWER = 18
    NEPAL = 19
    OASIS = 20
    BLACKFOREST = 21
    CASTILLO = 22
    ECOPOINTANTARCTICA = 23
    NECROPOLIS = 24
    CHATEAUGUILLARD = 25
    KANEZAKA = 26
    PETRA = 27
    AYUTTHAYA = 28

    def GetName(index : int):
        return ["Hanamura", "Horizon", "Paris", "Temple Of Anubis", "Volskaya Industries", 
        "Dorado", "Havana", "Junkertown", "Rialto", "Route 66", "Watchpoint Gibraltar", "Blizzard World", "Eichenwalde", "Hollywood",
        "Kings Row", "Numbani", "Busan", "Ilios", "Lijiang Tower", "Nepal", "Oasis", "Black Forest", "Castillo", "Ecopoint Antarctica",
        "Necropolis", "Chateau Guillard", "Kanezaka", "Petra", "Ayutthaya"][index]
    
    def GetImageName(index: int):
        return Maps.GetName(index).lower().replace(" ", "")