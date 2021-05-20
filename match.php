<html>
    <head>
        <title>
            StatWatch
        </title>
        <link rel='stylesheet' href='/static/style.scss'>
        <link href="/static/css-circular-prog-bar.css" rel="stylesheet"/>
        <link href = "/static/fontawesome/css/all.css" rel="stylesheet"/>
    </head>
    <body>
        <?php
            session_start();
            if(!isset($_GET["matchID"])){
                echo("Invalid Match ID");
                exit();
            }

            function timeToSeconds($timeStr){
                $length = explode(":",$timeStr);
                return $length[0] * 3600 + $length[1] * 60 + $length[2];
            }

            $db  = new PDO("sqlite:c:/xampp/htdocs/stats.db");
            $match = $db->query('SELECT matchID, matchLength, matchDate, mapName, imageName, typeName, typeColor, group_concat(teamScore, " - ") AS score
            FROM tbl_Match INNER JOIN cst_MatchType ON matchTypeID_F = typeID INNER JOIN cst_Maps ON mapID = mapID_F INNER JOIN tbl_Team ON matchID = matchID_f
            WHERE matchID = '.$_GET["matchID"].'
            GROUP BY matchID, matchDate, mapName, imageName, typeName, typeColor
            ORDER BY matchDate DESC')->fetch();
            $date = explode("-", $match["matchDate"]);
            $match["matchDate"] = $date[2].".".$date[1].".".$date[0];

            $players = $db->query("SELECT playerID, playerName, teamName
                                    FROM tbl_Player INNER JOIN tbl_Team ON teamID = teamID_F
                                    WHERE matchID_F = ".$match["matchID"]." 
                                    ORDER BY teamName")->fetchAll();
        ?>
        <!-- Header -->
        <div class='navigation' style='padding-bottom: 0;background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url(/static/Images/Maps_Header/KingsRow.jpg);'>
            <div>
                <h1 style='line-height = 50%;'>
                    <?= $match["typeName"]. " on ". $match["mapName"]?>
                </h1>
            </div>
        </div>

        <div class="frame" style="padding: 20px; width: 100%; height: 440px; overflow: visible; box-sizing: border-box;">
            <?php
                include 'timeline.php';
            ?>
        </div>
    </body>
</html>