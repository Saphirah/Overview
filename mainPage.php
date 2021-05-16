<html>
    <head>
        <title>
            StatWatch
        </title>
        <link rel='stylesheet' href='/static/style.scss'>
        <link href="/static/css-circular-prog-bar.css" rel="stylesheet"/>
        <link href = "/static/fontawesome/css/all.css" rel="stylesheet"/>
        <script type="text/javascript" src="/static/chart.min.js"></script>
    </head>
    <body>
        <!-- Header -->
        <div class='navigation' style='background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url(/static/Images/Maps_Header/KingsRow.jpg);'>
            <div>
                <h1>Overview</h1>
                <h5 style="font-family: 'montseratLight';">
                    <?php
                        session_start();
                        if(isset($_SESSION['userName']))
                            echo("Welcome back ".$_SESSION['userName']."!");
                        else
                            echo("Overwatch Stat Analyzing Tool");
                    ?>
                </h5>
            </div>
        </div>
        <script>
            let root = document.documentElement;

            root.addEventListener("mousemove", e => {
                root.style.setProperty('--mouse-x', e.clientX / window.innerWidth -0.5);
                root.style.setProperty('--mouse-y', e.clientY / window.innerHeight -0.5);
            });
        </script>
        <!-- Matches -->
        <?php
            $db  = new PDO("sqlite:c:/xampp/htdocs/stats.db");
            $matches = $db->query('SELECT matchID, matchDate, mapName, imageName, typeName, typeColor, group_concat(teamScore, "-") AS score
                                        FROM tbl_Match INNER JOIN cst_MatchType ON matchTypeID_F = typeID INNER JOIN cst_Maps ON mapID = mapID_F INNER JOIN tbl_Team ON matchID = matchID_f
                                        GROUP BY matchID, matchDate, mapName, imageName, typeName, typeColor
                                        ORDER BY matchDate DESC');
            $lastMatchDate = "";
            foreach($matches->fetchAll() as $match){
                if($lastMatchDate != $match['matchDate']){
                    $lastMatchDate = $match['matchDate'];
                    print("<div class=\"dateField\">" . $match['matchDate'] . "</div>");
                }
                print("
                <a href=\"/match/" . $match['matchID'] . "-0\">
                    <span class=\"match enlargeField\" onclick=\"selectMatch_" . $match['matchID'] . "()\">
                        <div class=\"matchImage\" style=\"overflow: hidden; background-image: url('/static/Images/Maps_Prev/" . $match['imageName'] . ".jpg');\">
                            <div class=\"mapName\">" . $match['mapName'] . "</div>
                        </div>
                        <div style=\"padding: 10px;height: fit-content; background-color: '" . $match['typeColor'] . "'; text-align: center; color: white; transform: translateZ(1px);\">" . $match['typeName'] . "</div>
                        <div style=\"padding: 4px; background-color:#27ae60; text-align: center; color: white;transform: translateZ(1px);\">" . $match["score"] . "</div>");
                //TODO: Implement Hero Preview
                //$heroes = $db.query('SELECT eventValue FROM tbl_Events');
                //foreach([1,2,3,4,5,6] as $hero){
                //    print("<img src=\"/static/Images/Portrait/" . Heroes.GetHeroName(h).lower() . ".png\" class=\"heroIcon\">");
                //}
                print("</span></a>");
            }
        ?>
    </body>
</html>