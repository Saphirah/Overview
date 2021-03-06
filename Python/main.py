from pystray import Icon as icon, Menu as menu, MenuItem as item
from PIL import Image, ImageDraw
from flask import Flask, render_template, Blueprint, request, jsonify, redirect, url_for
from buildwebsite import *
import random, webbrowser, threading, time
import sqlite3 as sl


#Start webserver
app = Flask(__name__)

#TODO: put webserver into seperate py file
@app.route('/player/<playerID>')
def openPlayer(playerID):
    db = Database()
    player = db.GetPlayer(playerID)
    team = db.GetTeam(player[1])
    match = db.GetMatch(team[1])
    matchType = db.GetMatchType(match[0])
    playerName = db.GetPlayerName(playerID)
    wb = WebsiteBuilder("StatTrack - Player - " + playerName)
    wb.components.append(CHeader(playerName, db.GetMapName(match[2]), matchType[0], matchType[1], "/static/Images/Maps_Header/" + db.GetMapImageName(match[2]) + ".jpg"))
    
    #Ultimate Statistic
    wb.components.append(CTitle("Ultimate Usage"))
    ultimatesUsed = db.Submit("SELECT Count(*) FROM tbl_Events WHERE playerID_F = " + str(playerID) + " AND eventName = 'EV_UsedAbility_Ultimate'").fetchone()[0]
    ultimatesEarned = db.Submit("SELECT Count(*) FROM tbl_Events WHERE playerID_F = " + str(playerID) + " AND eventName = 'INC_Charge_Ultimate' AND eventValue = '100'").fetchone()[0]
    wb.components.append(CFieldStat("Ults Used", str(ultimatesUsed) + "/" + str(ultimatesEarned)))
    wb.components.append(CUltChargeTrack(playerID))
    matchLength = db.FormatTimeToSeconds(db.GetMatchLength(match[0]))
    wb.components.append(CFieldStat("Ultimates/Min", str(round(int(ultimatesEarned) / (int(matchLength) / 60), 2)))) # + " <i class='fas fa-caret-up'></i>", "#00FF00"))

    #All stats
    wb.components.append(CTitle("Statistics"))
    heroStats = db.Submit("SELECT DISTINCT eventName FROM tbl_Events WHERE eventName Like 'HS%' AND eventValue != '0';").fetchall()
    heroStats = [item[0] for item in heroStats]
    for stat in heroStats:
        Accuracy = db.GetPlayerSummary(playerID, stat)
        if Accuracy[0] != None and int(Accuracy[1]) != 0:
            wb.components.append(CFieldStat(Accuracy[0], int(float(Accuracy[1]))))
    
    wb.components.append(CFieldMapLocations(playerID))

    return wb.Draw()

#TODO: put webserver into seperate py file
@app.route('/match/<matchID>')
def openMatch(matchID: int) -> str:
    """Build the match preview page"""
    matchID, teamID = matchID.split("-")
    matchID = int(matchID)
    wb = WebsiteBuilder("StatTrack - Match " + str(matchID))
    db = Database()
    match = db.GetMatch(matchID)
    matchType = db.GetMatchType(matchID)
    teamID = db.GetTeamID(matchID)
    wb.components.append(CHeader(db.GetMapName(match[2]), "2-0", matchType[0], matchType[1], "/static/Images/Maps_Header/" + db.GetMapImageName(match[2]) + ".jpg"))
    
    #Team Summary
    wb.components.append(CTitle("Team Summary"))
    wb.components.append(CFieldDiagramCircleTeamValues(teamID))
    wb.components.append(CTimeline(teamID))
    wb.components.append(CFieldDiagramTeamDamage(teamID))
    #Player Summary
    #TODO PlayerID's Hardcoded

    #Accuracy Round Progress Bar
    wb.components.append(CTitle("Team Comparison"))
    wb.components.append(CFieldDiagramCircleTeamComparison(matchID))

    #All stats
    heroStats = db.Submit("SELECT DISTINCT tbl_Events.eventName, eventText FROM tbl_Events INNER JOIN cst_EventName ON tbl_Events.eventName = cst_EventName.eventName WHERE tbl_Events.eventName Like 'HS%';").fetchall()
    for stat in heroStats:
        Accuracy = 0
        players = db.GetPlayersOfTeam(teamID)
        for player in players:
            Accuracy += db.GetPlayerSummary(player[0], stat[0])[1] or 0
        if Accuracy != 0:
            wb.components.append(CFieldStat(stat[1], round(Accuracy)))
    return wb.Draw()

@app.route('/')
def index():
    """Build the main page"""
    wb = WebsiteBuilder("StatTrack")
    wb.components.append(CHeader("STATWATCH", "Discord | Twitter"))

    db = Database()
    dates = db.GetMatchDates()
    
    for date in dates:
        wb.components.append(CTitle(date))
        matches = db.GetMatchesOnDate(date)
        #TODO: Heroes hardcoded
        for match in matches:
            wb.components.append(CMatchPreview(match[0], match[2], match[1], [Heroes.REINHARDT, Heroes.ZARYA, Heroes.MCCREE, Heroes.MEI, Heroes.BAPTISTE, Heroes.LUCIO], "2-0"))
    return wb.Draw()

webserverThread = threading.Thread(target=app.run, args=['localhost', 8080]).start()


#d = d3dshot.create()
#d.screenshot_to_disk_every(5)

#Start windows explorer system tray icon.
#TODO: Run System tray on thread
#TODO: Implement Screen capture

def quit():
    global d
    d.stop()
    tray.notify('Quitting StatWatch')
    time.sleep(2)
    tray.stop()

def openMatchHistory():
    webbrowser.open("http://localhost:8080/")

tray = icon('StatWatch')
tray.icon = Image.open('icon.png')
tray.menu = menu(
    item('Open Match History', openMatchHistory),
    item('Quit Application', quit)
)
tray.run()