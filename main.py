from pystray import Icon as icon, Menu as menu, MenuItem as item
from PIL import Image, ImageDraw
from flask import Flask, render_template, Blueprint, request, jsonify, redirect, url_for
from buildwebsite import *
import random, webbrowser, threading, time, d3dshot
import sqlite3 as sl


#Start webserver
app = Flask(__name__)

#TODO: put webserver into seperate py file
@app.route('/match/<matchID>')
def openMatch(matchID):
    """Build the match preview page"""
    wb = WebsiteBuilder("StatTrack - Match " + str(matchID))
    db = Database()
    match = db.GetMatch(matchID)
    matchType = db.GetMatchType(matchID)
    wb.components.append(CHeader(db.GetMapName(match[2]), "2-0", matchType[0], matchType[1], "/static/Images/Maps_Header/" + db.GetMapImageName(match[2]) + ".jpg"))
    
    #Team Summary
    #TODO: TeamIDs and Values Hardcoded
    wb.components.append(CTitle("Team Summary"))
    wb.components.append(CFieldCompareTeamValues(17))
    wb.components.append(CTimeline(17))

    #Player Summary
    #TODO PlayerID's Hardcoded

    #Accuracy Round Progress Bar
    wb.components.append(CTitle("Player Statistics"))
    Accuracy = db.GetPlayerSummary(97, "HS_Accuracy")
    wb.components.append(CFieldCircularProgressBar(Accuracy[0], float(Accuracy[1])))

    #All stats
    heroStats = db.Submit("SELECT DISTINCT eventName FROM Events WHERE eventName Like 'HS%' AND eventValue != '0';").fetchall()
    heroStats = [item[0] for item in heroStats]
    for stat in heroStats:
        Accuracy = db.GetPlayerSummary(97, stat)
        wb.components.append(CFieldStat(Accuracy[0], int(float(Accuracy[1]))))
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