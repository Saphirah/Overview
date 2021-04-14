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
            <div class='navigation' style='background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url(\"""" + self.imageSrc + "\");" + headerStyle + """'>
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
        websiteText = "<a href=\"/match/" + self.matchID + """-0\">
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
    def __init__(self, barText: str, value: str, fontColor:str = "#FFFFFF"):
        self.barText = barText
        self.value = value
        self.fontColor = fontColor
    
    def Draw(self):
        return "<div class=\"frame\" style='padding-top: 25px;'>" + str(self.barText) + """
                    <div class=\"progress-circle\">
                        <span style=\"color: """ + str(self.fontColor) + """;\">""" + str(self.value) + """</span>
                        <div class=\"left-half-clipper\">
                            <div class=\"first50-bar\"></div>
                            <div class=\"value-bar\"></div>
                        </div>
                    </div>
                </div>"""

class CFieldDiagram(WebsiteComponent):
    def __init__(self, yAxisLabel: str, color: str, data: (int, float)):
        self.db = Database()
        self.yAxisLabel = yAxisLabel
        self.color = color
        self.data = data
        self.maxTime = data[-1][0]
        #TODO: Implement proper ID system, by using random there could be duplicate values
        self.seed = random.randint(0, 1000000)

    def Draw(self):
        returnStr = """
        <div class=\"frame\" style=\"width:740px; height:145px;\">
            <svg height="22px" style="width: 100%; padding: 0px; margin-top: 0px;">
                <g fill="none" text-anchor="middle">
                    """
        #Create Timeline Header
        for x in range(8):
            percent = 20 + 80/7*x - 10
            returnStr +="<line stroke=\"white\" x1=\"" + str(percent) + "%\" x2=\"" + str(percent) +  "%\" y1=\"70%\" y2=\"100%\" style=\"stroke-width:2;\"></line>"
            returnStr +="<text fill=\"white\" x=\"" + str(percent) + "%\" y=\"50%\">" + str(self.db.ShortenTime(self.db.FormatSecondsToTime(int(self.maxTime * x / 7)))) + "</text>"
        returnStr +="""
                </g>
            </svg>
            <canvas id=\"""" + str(self.seed) + """\" height="55"></canvas>
        </div>
        <script>
            var ctx = document.getElementById('""" + str(self.seed) + """').getContext('2d'); 
            let width, height, gradient;
            function getGradient(ctx, chartArea) {
                const chartWidth = chartArea.right - chartArea.left;
                const chartHeight = chartArea.bottom - chartArea.top;
                if (gradient === null || width !== chartWidth || height !== chartHeight) {
                    // Create the gradient because this is either the first render
                    // or the size of the chart has changed
                    width = chartWidth;
                    height = chartHeight;
                    gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top);
                    gradient.addColorStop(0, \"""" + str(self.color) + """00");
                    gradient.addColorStop(1, \"""" + str(self.color) + """CC");
                }
                return gradient;
            }
            const data = {
                datasets: [
                    {
                    label: '""" + self.yAxisLabel + """',
                    data: ["""
        for summary in self.data:
            returnStr += "{x:" + str(summary[0]) + ", y:" + str(summary[1]) + "},"
        returnStr = returnStr[:-1]

        returnStr += """],
                    borderColor: \"""" + str(self.color) + """\",
                    backgroundColor: function(context) {
                        const chart = context.chart;
                        const {ctx, chartArea} = chart;

                        if (!chartArea) {
                        // This case happens on initial chart load
                        return null;
                        }
                        return getGradient(ctx, chartArea);
                    },
                    showLine: true,
                    cubicInterpolationMode: 'monotone',
                    tension: 0.4,
                    fill: true
                    }
                ]
            };
            const config = {
                type: 'scatter',
                data: data,
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            enabled: false,
                        }
                    },
                    scales: {
                        x: {
                            display: false
                        },
                        y: {
                            title: {
                                display: true,
                                text: '""" + str(self.yAxisLabel) + """'
                            }
                        }
                    },
                    elements:{
                        point:{
                            radius:0
                        }
                    }
                }
            };
            var ultChargeChart_""" + str(self.seed) + """ = new Chart(ctx, config);
        </script>
        """
        return returnStr

class CFieldDiagramCircle(WebsiteComponent):
    """A large field with a circle diagram, displaying the stats for all players of a specific team."""       

    def Draw(self):
        db = Database()
        returnStr = "<script>function NewTeamValue_" + str(self.seed) + "(value){var chart = myChart" + str(self.seed) + ";switch(value){"
        for dat in self.data:
            returnStr += "case \"" + dat[0][0] + "\": chart.data.datasets[0].data = ["
            for value in dat[1]:
                returnStr += str(value) + ","
            returnStr = returnStr[:-1]
            returnStr += "];chart.data.labels = ["
            for label in self.labels:
                returnStr += "'" + str(label) + "',"
            returnStr = returnStr[:-1]
            returnStr += "];break;"
        
        returnStr +="}chart.update()}</script>"

        returnStr += "<div class=\"frame\" style=\"width:340px; height:350px;\"><select id=\"teamcomparison\" class=\"enlargeField\" onchange=\"NewTeamValue_" + str(self.seed) + "(this.value)\">"
        
        for atype in self.data:
            returnStr += "<option value=\"" + str(atype[0][0]) + "\">" + str(atype[0][1]) + "</option>"
        returnStr += "</select>"
        returnStr += """<canvas id=\"""" + str(self.seed) + """\"></canvas></div><script>
            var ctx = document.getElementById('""" + str(self.seed) + """').getContext('2d'); 
            var myChart""" + str(self.seed) + """ = new Chart(ctx, {
                type: 'doughnut', data: {
                    labels: ["""
        for label in self.labels:
            returnStr += "'" + str(label) + "',"
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

class CFieldDiagramCircleTeamValues(CFieldDiagramCircle):
    def __init__(self, teamID: int):
        db = Database()
        #TODO: Implement proper ID system, by using random there could be duplicate values
        self.seed = random.randint(0, 1000000)
        types = db.GetAllSummaryTypes()
        labels = db.GetPlayersOfTeam(teamID)
        self.data = [(types[x],[db.GetPlayerSummary(item[0], types[x][0])[1] for item in labels]) for x in range(0,len(types))]
        self.labels = [item[1] for item in labels]

class CFieldDiagramCircleTeamComparison(CFieldDiagramCircle):
    def __init__(self, matchID: int):
        db = Database()
        #TODO: Implement proper ID system, by using random there could be duplicate values
        self.seed = random.randint(0, 1000000)
        teams = db.GetTeamsOfMatch(matchID)
        types = db.GetAllSummaryTypes()
        self.labels = [team[3] for team in teams]
        self.data = [(types[x],[db.GetTeamSummary(item[0], types[x][0])[1] for item in teams]) for x in range(0,len(types))]

#TODO: Implement more values
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
        <div class=\"frame\" style=\"padding: 0px;padding-left: 20px; padding-right: 0px;width: 1360px;height: 390px;\">
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
        
        #For each player create a timeline
        for player in self.playerIDs:
            returnStr += """
            <div>
                <div onclick="window.location.href='/player/""" + str(player[0]) + """';" class=\"timelineFrame enlargeField\" data-tooltip=\"Click to open the player summary!\" style=\"width: 16%; border-top-right-radius: 0; border-bottom-right-radius: 0;  height: 13px;margin-right: 3px;\">""" + player[1] + """</div>
                <div class=\"timelineFrame\" style=\"width: 79%; border-top-left-radius: 0; border-bottom-left-radius: 0; padding: 5px; height: 43px;\">
                    <svg height="44px" style="width: 90%; padding: 0px; overflow: visible;">"""
            events = self.db.GetEvents("EV_Died", player[0])

            #Create Death Icons
            for death in events:
                deathTimePercent = int(self.db.FormatTimeToSeconds(death[1]) / matchLength * 100)
                returnStr += "<image x=\"" + str(deathTimePercent) + "%\" y=\"14%\" href=\"/static/Images/Icons/skull.png\" height=\"35px\" width=\"25px\"/>"
            
            #Create Ultimate Icons
            events = self.db.GetEvents("EV_UsedAbility_Ultimate", player[0])
            for ult in events:
                deathTimePercent = int(self.db.FormatTimeToSeconds(ult[1]) / matchLength * 100)
                returnStr += "<image x=\"" + str(deathTimePercent) + "%\" y=\"14%\" href=\"/static/Images/Icons/ultimates/" + self.db.GetCharacterOnTimestamp(player[0], ult[1]).lower().replace(" ", "").replace(".", "").replace("ã¶", "ö").replace("ãº","ú")  + ".png\" height=\"35px\" width=\"25px\"/>"
            
            #Create Switched Heroes Icons
            events = self.db.GetEvents("EV_SwitchedHero", player[0])
            for ult in events:
                deathTimePercent = int(self.db.FormatTimeToSeconds(ult[1]) / matchLength * 100)
                returnStr += "<image x=\"" + str(deathTimePercent) + "%\" y=\"0%\" href=\"/static/Images/Icons/characters/" + ult[4].lower().replace(" ", "").replace(".", "").replace("ã¶", "ö").replace("ãº","ú")  + ".png\" height=\"45px\" width=\"30px\"/>"
            returnStr +="""
                    </svg>
                </div>
            </div>"""
        returnStr += "</div>"
        return returnStr

class CUltChargeTrack(WebsiteComponent):
    def __init__(self, playerID):
        self.db = Database()
        self.playerID = playerID
        #TODO: Implement proper ID system, by using random there could be duplicate values
        self.seed = random.randint(0, 1000000)
    
    def Draw(self):
        #Create Timeline Header
        teamID = self.db.GetTeamIDOfPlayer(self.playerID)
        matchID = self.db.GetMatchOfTeam(teamID)
        color = self.db.GetMatchType(matchID)[1]
        
        summaries = self.db.GetEvents("INC_Charge_Ultimate", self.playerID)
        summaries = [(self.db.FormatTimeToSeconds(item[1]), item[4]) for item in summaries]
        usedUlts = self.db.GetEvents("EV_UsedAbility_Ultimate", self.playerID)
        myUlts = [(self.db.FormatTimeToSeconds(item[1]), 100) for item in usedUlts]
        summaries += myUlts
        myUlts = [(self.db.FormatTimeToSeconds(item[1])+1, 0) for item in usedUlts]
        summaries += myUlts
        summaries = sorted(summaries, key=lambda tup: tup[0])
        return CFieldDiagram("Ultimate Charge", color, summaries).Draw()

class CFieldDiagramTeamDamage(WebsiteComponent):
    def __init__(self, teamID: int):
        self.teamID = teamID
        self.db = Database()
    
    def Draw(self):
        events = self.db.Submit("SELECT * FROM tbl_Events INNER JOIN tbl_Player ON tbl_Events.playerID_F = tbl_Player.playerID WHERE (eventName = 'TV_DealtDamage') AND teamID_F = " + str(self.teamID)).fetchall()
        
        time = 0
        data = []
        damage = 0
        teamfights = []
        for event in events:
            eventTime = self.db.FormatTimeToSeconds(event[1])
            if eventTime >= time+5:
                data.append((time, damage))
                time += 5
                damage = 0
            damage += int(float(event[4]))

        tfCounter = 0
        prevValue = 0
        for timestamp in data:
            if timestamp[1] >= 300 or timestamp[1] - prevValue >= 100:
                tfCounter = min(tfCounter + 1, 3)
            else:
                tfCounter = max(tfCounter - 1, 0)
            prevValue = timestamp[1]
            teamfights.append((timestamp[0], 1 if tfCounter >= 2 else 0))
        if teamfights != []:
            return CFieldDiagram("Teamfight Detect", "#FF0000", teamfights).Draw()
        return ""


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
                <link href=\"/static/css-circular-prog-bar.css\" rel=\"stylesheet\"/>
                <link href = \"/static/fontawesome/css/all.css\" rel=\"stylesheet\"/>
                <script type=\"text/javascript\" src=\"/static/chart.min.js\"></script>
            </head>
            <body>"""
        for c in self.components:
            websiteText += c.Draw()
        return websiteText