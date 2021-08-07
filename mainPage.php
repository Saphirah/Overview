<html>
    <head>
        <title>
            StatWatch
        </title>
        <link rel='stylesheet' href='/static/css/style.scss'>
        <link href="/static/css/css-circular-prog-bar.css" rel="stylesheet"/>
        <link href = "/static/fontawesome/css/all.css" rel="stylesheet"/>
        <script src="/static/JS/scrollFadeIn.js"></script>
    </head>
    <body>
        <?php
            include_once("static/Model/Model.php");
        ?>

        <!-- Header -->
        <header class='navigation' style='background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url("static/Images/Maps_Header/kingsrow.jpg"); height: 170px;'>
            <div>
                <h1>Overview</h1>
                <h5 style="font-family: 'montseratLight';">
                    <?= isset($_SESSION['userName']) ? "Welcome back ".$_SESSION['userName']."!" : "Overwatch Stat Analyzing Tool" ?>
                </h5>
            </div>
        </header>
        <!-- Matches -->
        <?php
            $matches = $model->Query('SELECT matchID, matchDate, mapName, imageName, typeName, typeColor, group_concat(teamScore, "-") AS score
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
                <a href=\"/match.php?matchID=" . $match['matchID'] . "\">
                    <article class=\"match enlargeField\" onclick=\"selectMatch_" . $match['matchID'] . "()\">
                        <header class=\"matchImage\" style=\"overflow: hidden; background-image: url('/static/Images/Maps_Prev/" . $match['imageName'] . ".jpg');\">
                            <div class=\"mapName\">" . $match['mapName'] . "</div>
                        </header>
                        <div style=\"padding: 10px;height: fit-content; background-color: " . $match['typeColor'] . "; border-radius:0;text-align: center; color: white; transform: translateZ(1px);\">" . $match['typeName'] . "</div>
                        <footer style=\"padding: 4px; background-color:#27ae60; text-align: center; color: white;transform: translateZ(1px);border-radius:0;\">" . $match["score"] . "</footer>");
                //TODO: Implement Hero Preview
                //$heroes = $db.query('SELECT eventValue FROM tbl_Events');
                //foreach([1,2,3,4,5,6] as $hero){
                //    print("<img src=\"/static/Images/Portrait/" . Heroes.GetHeroName(h).lower() . ".png\" class=\"heroIcon\">");
                //}
                print("</article></a>");
            }
        ?>
    </body>
</html>