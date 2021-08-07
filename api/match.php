<?php
    $db = new PDO("sqlite:..\stats.db");
    $arr = array();
    

    $matchData = $db->query("SELECT * FROM tbl_Match")->fetch();

    //Fetch Match Data
    $arr["id"] = $matchData["matchID"];
    $arr["type"] = $db->query("SELECT typeName FROM cst_MatchType WHERE typeID = " . $matchData["matchTypeID_F"])->fetch()["typeName"];
    $arr["map"] = $db->query("SELECT mapName FROM cst_Maps WHERE mapID = " . $matchData["mapID_F"])->fetch()["mapName"];
    $arr["length"] = $matchData["matchLength"];
    $arr["date"] = $matchData["matchDate"];
    $arr["time"] = $matchData["matchTime"];

    //Fetch Team Data
    $arr["teams"] = array();
    $teamsData = $db->query("SELECT * FROM tbl_Team WHERE matchID_F = " . $matchData["matchID"])->fetchAll();
    foreach($teamsData as $teamData){

        //Fetch Player Data
        $players = array();
        $playersData = $db->query("SELECT * FROM tbl_Player WHERE teamID_F = " . $teamData["teamID"] . " ORDER BY playerSlot ASC")->fetchAll();
        foreach($playersData as $playerData){
            $player = array();
            $player["name"] = $playerData["playerName"];
            $player["slot"] = $playerData["playerSlot"];
            $player["joinTime"] = $playerData["joinTime"];

            //Fetch Player Stats
            $statsData = $db->query("SELECT * FROM tbl_Player_Statistic_Total WHERE playerID_F = " . $playerData["playerID"])->fetch(PDO::FETCH_ASSOC);
            array_shift($statsData);
            $player["stats"] = $statsData;

            //Fetch Player Communication
            $statsData = $db->query("SELECT * FROM tbl_Player_Communication WHERE playerID_F = " . $playerData["playerID"])->fetch(PDO::FETCH_ASSOC);
            array_shift($statsData);
            $player["communication"] = $statsData;

            //Fetch Hero Data
            $statsData = $db->query("SELECT heroName, tbl_Player_Statistic_Hero.* FROM tbl_Player_Statistic_Hero INNER JOIN cst_Heroes ON heroID = heroID_F WHERE playerID_F = " . $playerData["playerID"])->fetch(PDO::FETCH_ASSOC);
            $hero = array_shift($statsData);
            array_shift($statsData);
            array_shift($statsData);
            array_shift($statsData);
            $player["heroes"][$hero] = $statsData;

            $player["data"] = array();
            $player["data"]["timeStamps"] = array();
            $player["data"]["timeStamps"]["ultimateCharge"] = array();
            $player["data"]["timeStamps"]["positions"] = array();
            $player["data"]["events"] = array();
            
            //Fetch Ultimate Logs
            $statsData = $db->query("SELECT gameTime, chargeValue FROM tbl_Player_UltimateCharge WHERE playerID_F = " . $playerData["playerID"])->fetchAll(PDO::FETCH_ASSOC);
            foreach($statsData as $statData){
                $player["data"]["timeStamps"]["ultimateCharge"][$statData["gameTime"]] = intval($statData["chargeValue"]);
            }

            $statsData = $db->query("SELECT gameTime, positionX, positionY, positionZ FROM tbl_Player_Position WHERE playerID_F = " . $playerData["playerID"])->fetchAll(PDO::FETCH_ASSOC);
            foreach($statsData as $statData){
                $player["data"]["timeStamps"]["positions"][$statData["gameTime"]] = array( "x" => floatval($statData["positionX"]), "y" => floatval($statData["positionY"]), "z" => floatval($statData["positionZ"]));
            }

            array_push($players, $player);
        }
        array_push($arr["teams"], array(
            "name" => $teamData["teamName"],
            "score" => $teamData["teamScore"],
            "players" => $players
        ));
        
    }

    $json = json_encode(array("match" => $arr), JSON_PRETTY_PRINT);
    echo $json;
?>