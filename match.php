<html>
    <body>
        <?php
            include_once("static/Model/Model.php");

            if(!isset($_GET["matchID"])){
                echo("Invalid Match ID");
                exit();
            }

            $match = $model->query('SELECT matchID, matchLength, matchDate, mapName, imageName, typeName, typeColor, group_concat(teamScore, " - ") AS score
            FROM tbl_Match INNER JOIN cst_MatchType ON matchTypeID_F = typeID INNER JOIN cst_Maps ON mapID = mapID_F INNER JOIN tbl_Team ON matchID = matchID_f
            WHERE matchID = '.$_GET["matchID"].'
            GROUP BY matchID, matchDate, mapName, imageName, typeName, typeColor
            ORDER BY matchDate DESC')->fetch();
            $date = explode("-", $match["matchDate"]);
            $match["matchDate"] = $date[2].".".$date[1].".".$date[0];

            $players = $model->query("SELECT playerID, playerName, teamName, teamID
                                    FROM tbl_Player INNER JOIN tbl_Team ON teamID = teamID_F
                                    WHERE matchID_F = ".$match["matchID"]." 
                                    ORDER BY teamName")->fetchAll();
        ?>
        <!-- Header -->
        <?php
            new Header($match["typeName"]. " on ". $match["mapName"]);
        ?>

        <!--Timeline-->
        <?php
            new Timeline($players[0]["teamID"] - ($players[0]["teamID"] % 2));
        ?>
    </body>
</html>