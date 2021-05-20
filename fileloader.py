from tkinter.filedialog import askopenfilename
from tkinter import Tk
from datetime import date
import random, re
import sqlite3 as sl
from data import Database

class FileLoader():
    """A wrapper that converts the files from the workshop skrim tool to the database"""
    def __init__(self):
        self.db = Database()

    def LoadFile(self):
        """Prompts to select a file, extracts data and writes them to the database"""
        filename = self.__OpenFileDialogue()
        data = self.__ConvertFileToList(filename)

        #Get all teams and players
        teams, players = self.__GetTeamsAndPlayersFromData(data)

        #Create Match
        matchID = self.db.CreateMatch()

        #Create Teams
        teamIDs = []
        for team in teams:
            teamIDs.append(self.db.CreateTeam(matchID))

        #Create Players
        playerIDs = []
        for playerTeams in players:
            playerIDs.append([])
            for player in playerTeams:
                playerIDs[len(playerIDs)-1].append(self.db.CreatePlayer(str(player[1]), str(player[0]), str(teamIDs[players.index(playerTeams)])))

        #Create Events
        for line in data:
            pID = playerIDs[teams.index(line[1])][int(line[2])]
            self.db.CreateEvent(line[0], pID, line[4], line[5], line[6])

        self.db.Commit()
    
    #TODO: Implement this in Website
    def __OpenFileDialogue(self) -> str:
        """Opens the windows file dialogue to select a match file"""
        Tk().withdraw()
        return askopenfilename()

    def __ConvertFileToList(self, filename: str) -> [[str]]:
        """Converts the file to a readable list format"""
        with open (filename, mode="r", encoding="utf-8") as myfile:
            data = myfile.read().replace("\"", "").replace("[", "").replace("]","").splitlines()
        return [item.split(" , ") for item in data]

    def __GetTeamsAndPlayersFromData(self, data: str) -> ([str], [str]):
        """Extracts the Teams and Players from the list"""
        teams = []
        players = []
        for line in data:
            if not line[1] in teams:
                teams.append(line[1])
                players.append([])
            index = teams.index(line[1])
            if not (line[2], line[3]) in players[index]:
                players[index].append((line[2], line[3]))
        players = [sorted(item, key=lambda x: int(x[0])) for item in players]
        return (teams, players)

    def ResetDatabase(self):
        """Deletes every non-permanent entry in the Database. Use with caution"""
        self.db.Submit("DELETE FROM tbl_Events")
        self.db.Submit("DELETE FROM tbl_Events_Tmp")
        self.db.Submit("DELETE FROM tbl_Match")
        self.db.Submit("DELETE FROM tbl_Player")
        self.db.Submit("DELETE FROM tbl_Team")
        self.db.Submit("DELETE FROM tbl_Player_Statistic_Total")
        self.db.Submit("DELETE FROM tbl_Player_Statistic_Hero")
        self.db.Submit("DELETE FROM tbl_Player_Position")
        self.db.Submit("DELETE FROM tbl_Player_Communication")
        self.db.Submit("DELETE FROM tbl_Player_UltimateCharge")
        self.db.Commit()

FileLoader().ResetDatabase()
#FileLoader().LoadFile()

