from data import *
import random

#TODO: Split into different py files

class WebsiteComponent:
    def Draw():
        return ""

class CHeader(WebsiteComponent):
    """A big header, previewing a Map, usually on top of the page"""
    def __init__(self, titleText: str, subText: str, typeText: str = None, typeColor: str = None, imageSrc: str = "/static/Images/Maps_Header/KingsRow.jpg"):
        self.titleText = titleText
        self.subText = subText
        self.typeText = typeText
        self.typeColor = typeColor
        self.imageSrc = imageSrc

    def Draw(self):
        headerStyle = ""
        matchTypeBanner = ""
        if self.typeText != None and self.typeColor != None:
            headerStyle = "padding-bottom: 0px;"
            matchTypeBanner = "<div class=\"navigation\" style=\"background-color: " + self.typeColor + "; background-image: none; height: 20px; margin: 0px; padding:20px; border-radius: 0px;\">" + self.typeText + "</div>"

        websiteText = """
            <div class='navigation' style='background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url(\"" + self.ImageSrc + "\");""" + headerStyle + """'>
                <div>
                    <h1>""" + self.titleText + """</h1>
                    <h5 style=\"font-family: 'montseratLight';\">""" + self.subText + """</h5>
                    """ + matchTypeBanner + """
                </div>
            </div>"""
        return websiteText

class CMatchPreview(WebsiteComponent):
    """Boxes to preview the matches. Found on the main page"""

    def __init__(self, matchID: int, mapID: int, typeID: int, heroes: [int], score: str):
        self.matchID = str(matchID)
        self.mapID = mapID
        self.heroes = heroes
        self.typeID = typeID
        self.score = score

    def Draw(self):
        matchType = Database().GetMatchType(self.matchID)
        websiteText = "<a href=\"/match/" + self.matchID + """\">
                            <span class=\"match enlargeField\" onclick=\"selectMatch_""" + str(self.matchID) + """()\">
                                <div class=\"matchImage\" style=\"overflow: hidden; background-image: url('/static/Images/Maps_Prev/""" + Maps.GetImageName(self.mapID) + """.jpg');\">
                                    <div class=\"mapName\">""" + Maps.GetName(self.mapID) + """</div>
                                </div>
                                <div style=\"padding: 10px;height: fit-content; background-color: """ + matchType[1] + """; text-align: center; color: white;\">""" + matchType[0] + """</div>
                                <div style=\"padding: 4px; background-color:#27ae60; text-align: center; color: white;\">""" + self.score + "</div>"
        for h in self.heroes:
            websiteText += "<img src=\"/static/Images/Portrait/" + Heroes.GetHeroName(h).lower() + ".png\" class=\"heroIcon\">"
        websiteText += """  </span>
                        </a>"""
        return websiteText

class CTitle(WebsiteComponent):
    """Subcategories for dates and Data"""
    def __init__(self, title: str):
        self.title = title
    
    def Draw(self):
        return "<div class=\"dateField\">" + self.title + "</div>"
    
class CFieldCircularProgressBar(WebsiteComponent):
    """A small field to display percent value."""
    def __init__(self, barText: str, barProgress: float):
        self.barText = barText
        self.barProgress = barProgress
    
    def Draw(self):
        return "<div class=\"frame\" style='padding-top: 25px;'>" + str(self.barText) + """
                    <div class=\"progress-circle p""" + str(round(self.barProgress * 100)) + """\">
                        <span>""" + str(round(self.barProgress * 100)) + """%</span>
                        <div class=\"left-half-clipper\">
                            <div class=\"first50-bar\"></div>
                            <div class=\"value-bar\"></div>
                        </div>
                    </div>
                </div>"""

class CFieldStat(WebsiteComponent):
    """A small field to display single stats."""
    def __init__(self, barText, value):
        self.barText = barText
        self.value = value
    
    def Draw(self):
        return "<div class=\"frame\" style='padding-top: 25px;'>" + str(self.barText) + """
                    <div class=\"progress-circle\">
                        <span>""" + str(self.value) + """</span>
                        <div class=\"left-half-clipper\">
                            <div class=\"first50-bar\"></div>
                            <div class=\"value-bar\"></div>
                        </div>
                    </div>
                </div>"""

class CFieldDiagramTeamValues(WebsiteComponent):
    """A large field with a circle diagram, displaying the stats for all players of a specific team"""
    def __init__(self, teamID):
        self.teamID = teamID
        #TODO: Implement proper ID system, by using random there could be duplicate values
        self.seed = random.randint(0, 1000000)

    def Draw(self):
        db = Database()
        types = db.GetAllSummaryTypes()
        returnStr = "<script>function NewTeamValue_" + str(self.seed) + "(value){var chart = myChart" + str(self.seed) + ";switch(value){"
        players = db.GetPlayersOfTeam(self.teamID)
        print(players)
        for atype in types:
            returnStr += "case \"" + atype[0] + "\": chart.data.datasets[0].data = ["
            playerDamage = [db.GetPlayerSummary(item[0], atype[0])[1] for item in players]
            for value in playerDamage:
                returnStr += str(value) + ","
            returnStr = returnStr[:-1]
            returnStr += "];chart.data.labels = ["
            playerDamage = [item[1] for item in players]
            for value in playerDamage:
                returnStr += "'" + str(value) + "',"
            returnStr = returnStr[:-1]
            returnStr += "];break;"
        
        returnStr +="}chart.update()}</script>"

        returnStr += "<div class=\"largeframe\"><select id=\"teamcomparison\" onchange=\"NewTeamValue_" + str(self.seed) + "(this.value)\">"
        
        for atype in types:
            returnStr += "<option value=\"" + str(atype[0]) + "\">" + str(atype[1]) + "</option>"
        returnStr += "</select>"
        returnStr += """<canvas id=\"""" + str(self.seed) + """\"></canvas></div><script>
            var ctx = document.getElementById('""" + str(self.seed) + """').getContext('2d'); 
            var myChart""" + str(self.seed) + """ = new Chart(ctx, {
                type: 'doughnut', data: {
                    labels: ["""
        players = db.GetPlayersOfTeam(self.teamID)
        for label in players:
            returnStr += "'" + str(label[1]) + "',"
        returnStr = returnStr[:-1]
        returnStr +="""],
                    datasets: [{
                        label: 'Data',
                        data: [],
                        backgroundColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)',
                            'rgba(153, 102, 255, 1)',
                            'rgba(255, 159, 64, 1)'
                        ], 
                    hoverOffset: 4,
                    borderWidth: 0
                    }]
                }});
        NewTeamValue_""" + str(self.seed) + """("HS_Accuracy");
            </script>"""
        return returnStr

#TODO Not done yet
class CTimeline(WebsiteComponent):
    """A timeline, showing events such as kills, ultimates etc..."""
    def __init__(self, teamID):
        self.db = Database()
        self.teamID = teamID
        self.playerIDs = self.db.GetPlayersOfTeam(self.teamID)
        #TODO: Implement proper ID system, by using random there could be duplicate values
        self.seed = random.randint(0, 1000000)

    def Draw(self):
        matchID = self.db.Submit("SELECT matchID_F FROM tbl_Team WHERE teamID = " + str(self.teamID)).fetchone()[0]
        matchLength = self.db.FormatTimeToSeconds(self.db.GetMatchLength(matchID))
        returnStr = """
        <div class=\"longframe\" style=\"padding-left: 20px; padding-right: 0px;\">
            <svg height="22px" style="width: 100%; padding: 0px; margin-top: 15px;">
                <g fill="none" text-anchor="middle">
                    """
        #Create Timeline Header
        for x in range(8): 
            percent = 30 + 70/7*x - 10
            returnStr +="<line stroke=\"white\" x1=\"" + str(percent) + "%\" x2=\"" + str(percent) +  "%\" y1=\"70%\" y2=\"100%\" style=\"stroke-width:2;\"></line>"
            returnStr +="<text fill=\"white\" x=\"" + str(percent) + "%\" y=\"50%\">" + str(self.db.ShortenTime(self.db.FormatSecondsToTime(int(matchLength * x / 7)))) + "</text>"
        returnStr +="""
                </g>
            </svg>"""
        for player in self.playerIDs:
            returnStr += """
            <div>
                <div class=\"timelineFrame\" style=\"width: 16%; border-top-right-radius: 0; border-bottom-right-radius: 0;  height: 13px;\">""" + player[1] + """</div>
                <div class=\"timelineFrame\" style=\"width: 79%; border-top-left-radius: 0; border-bottom-left-radius: 0; padding: 5px; height: 43px;\">
                    <svg height="44px" style="width: 90%; padding: 0px;">"""
            events = self.db.GetEvents("EV_Died", player[0])
            for death in events:
                deathTimePercent = int(self.db.FormatTimeToSeconds(death[1]) / matchLength * 100)
                #returnStr += "<circle cx=\"" + str(deathTimePercent) + "%\" cy=\"50%\" r=\"8px\" fill=\"red\"/>"
                returnStr += "<image x=\"" + str(deathTimePercent) + "%\" y=\"14%\" href=\"/static/Images/Icons/skull.png\" height=\"35px\" width=\"25px\"/>"
            returnStr +="""
                    </svg>
                </div>
            </div>"""
        returnStr += "</div>"
        return returnStr

class WebsiteBuilder:

    def __init__(self, TitleText = "StatWatch"):
        self.TitleText = TitleText
        self.components = []
        
    def Draw(self):
        websiteText = """
        <html>
            <head>
                <title>""" + self.TitleText + """</title>
                <link rel='stylesheet' href='/static/style.scss'>
                <link href=\"/static/css-circular-prog-bar.css\" rel=\"stylesheet\" />
                <script type=\"text/javascript\" src=\"/static/chart.min.js\"></script>
            </head>
            <body>"""
        for c in self.components:
            websiteText += c.Draw()
        return websiteText