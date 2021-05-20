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
        <div class='navigation' style='background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url(/static/Images/Maps_Header/KingsRow.jpg); height: 170px;'>
            <div>
                <h1>Overview</h0>
                <h5 style="font-family: 'montseratLight';">
                    Overwatch Stat Analyzing Tool<br>
                </h5>
            </div>
        </div>

        <!-- Upload Field -->
        <div id="dragAndDropField" class='navigation enlargeField' style='background-image: linear-gradient(#2c3e5088, #2c3e5044); width: 50%; height: 250px; margin: 0 auto;' onclick="document.getElementById('file-input').click();"  ondrop="dropHandler(event);">
            <div>
                <i class="fas fa-upload" style="font-size: 60;"></i>
                <h1>Drag and drop files here!</h1>
                <h5 style="font-family: 'montseratLight';">
                    Pull in your match log files
                </h5>
            </div>
        </div>

        <!-- Upload Files, Hidden -->
        <form action="/uploadFile.php" id="file-form" enctype="multipart/form-data" method="POST">
            <input type="hidden" name="MAX_FILE_SIZE" value="4000000" />
            <input id="file-input" type="file" name="files[]" style="display: none;" accept=".txt" multiple/>
        </form>

        <!-- Handle Drag and Drop -->
        <script>
            let fileInput = document.getElementById('file-input')
            fileInput.onchange = function() {
                document.getElementById("file-form").submit();
            };

            let dragAndDropField = document.getElementById('dragAndDropField');

            dragAndDropField.ondrop = function (e) {
                e.preventDefault();
                fileInput.files = e.dataTransfer.files;
                document.getElementById("file-form").submit();
            };

            dragAndDropField.ondragover = function (e) { 
                e.preventDefault() 
            }
        </script>

        <!-- Process Uploaded Files -->
        <?php
            session_start();
            $db  = new PDO("sqlite:c:/xampp/htdocs/stats.db");
            
            if(isset($_FILES['files'])){
                $countfiles = count($_FILES['files']['name']);
                for( $i=0; $i<$countfiles; $i++ ){
                    $filename = $_FILES['files']['name'][$i];
                    
                    if($_FILES['files']['size'][$i] > 4000000){
                        echo('File ' . $filename . ' is larger than 4 MB!');
                        continue;
                    }
                    
                    $expl = explode('.',$_FILES['files']['name'][$i]);
                    if(strtolower(end($expl)) != "txt"){
                        echo('File ' . $filename . ' is not a txt file! Please only upload logs.');
                        continue;
                    }
                    move_uploaded_file($_FILES['files']['tmp_name'][$i],'MatchFiles/'.$filename);
                    
                    echo(saveFileToDB('MatchFiles/'.$filename, $i));
                }
            }

            function saveFileToDB($file) {
                global $db, $filename, $i;
                $entries = explode("\n", file_get_contents($file));
                $entries = str_replace('"', "", $entries);
                $entries = str_replace(']', "", $entries);
                $entries = str_replace('[', "", $entries);
                array_pop($entries);
                $db->beginTransaction();
                $db->query("DELETE FROM tbl_Events_Tmp");
                
                $error = "File " . $filename." is in an invalid format";

                if(count($entries) > 50){

                    //Save each record
                    foreach( $entries as $entry ){
                        $entry = explode(" , ", $entry );
                        $prepare = $db->prepare("INSERT INTO tbl_Events_Tmp(gameTime, team, slot, playerName, eventName, eventValue, eventTarget) VALUES(?,?,?,?,?,?,?);");
                        $prepare->execute($entry);
                    }

                    //Get Map
                    $mapID = $db->query("SELECT mapID FROM cst_Maps WHERE mapName = (SELECT eventValue FROM tbl_Events_Tmp WHERE eventName = 'EV_LoadMap')")->fetch();
                    $matchLength = $db->query("SELECT gameTime FROM tbl_Events_Tmp ORDER BY gameTime DESC LIMIT 1")->fetch()[0];
                    if(!isset($mapID)){
                        $error = "The map was not found";
                        goto cancel;
                    }

                    //Get Match Info
                    $tmp = explode("-", str_replace(".txt", "", $filename));
                    if(count($tmp) < 7){
                        $error = "The upload file was renamed";
                        goto cancel;
                    }
                    $matchDate = $tmp[1]."-".$tmp[2]."-".$tmp[3];
                    $matchTime = $tmp[4].":".$tmp[5].":".$tmp[6];
                    if(!preg_match("(\d{4}-\d{2}-\d{2})", $matchDate) or !preg_match("(\d{2}:\d{2}:\d{2})", $matchTime)){
                        $error = "The uploaded file was renamed";
                        goto cancel;
                    }

                    //Create Match Entry
                    $prepare = $db->prepare("INSERT INTO tbl_Match(matchTypeID_F, mapID_F, matchDate, matchTime, matchLength) VALUES(?, ?, ?, ?, ?)");
                    $prepare->execute(array(2, $mapID[0], $matchDate, $matchTime, $matchLength));

                    $matchID = $db->query("SELECT matchID FROM tbl_Match ORDER BY matchID DESC LIMIT 1")->fetch()[0];

                    //Create Teams Entry
                    $teams = $db->query("SELECT DISTINCT team FROM tbl_Events_Tmp;")->fetchAll();
                    foreach($teams as $team){
                        $teamScore = $db->query("SELECT eventValue FROM tbl_Events_Tmp WHERE team = '".$team[0]."' AND eventName = 'EV_Scored' ORDER BY eventValue DESC LIMIT 1")->fetch();
                        if(is_bool($teamScore))
                            $teamScore = 0;
                        else
                            $teamScore = $teamScore[0];
                        $prepare = $db->prepare("INSERT INTO tbl_Team(matchID_F, teamScore, teamName) VALUES(?, ?, ?)");
                        $prepare->execute(array($matchID, $teamScore, $team[0]));
                        
                        $teamID = $db->query("SELECT teamID FROM tbl_Team ORDER BY teamID DESC LIMIT 1")->fetch()[0];

                        //Create Player Entry
                        $players = $db->query("SELECT gameTime, eventValue, slot FROM tbl_Events_Tmp WHERE eventName = 'EV_PlayerJoinedMatch' AND team = '".$team[0]."' GROUP BY eventValue, slot")->fetchAll();
                        foreach($players as $player){
                            $prepare = $db->prepare("INSERT INTO tbl_Player(teamID_F, playerName, playerSlot, joinTime) VALUES(?, ?, ?, ?)");
                            $prepare->execute(array($teamID, $player["eventValue"], $player["slot"], $player["gameTime"]));
                            
                            $playerID = $db->query("SELECT playerID FROM tbl_Player ORDER BY playerID DESC LIMIT 1")->fetch()[0];

                            //Create Total Summary
                            $stats = $db->query("SELECT eventName, eventValue FROM tbl_Events_Tmp WHERE eventName Like 'TS_%' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"]);
                            if(isset($stats)){
                                $sqlFirstStr = "INSERT INTO tbl_Player_Statistic_Total(";
                                $sqlSecondStr = "VALUES(";
                                foreach($stats as $stat){
                                    $sqlFirstStr .= str_replace("TS_", "", $stat["eventName"]).", ";
                                    $sqlSecondStr .= str_replace(",", ".", $stat["eventValue"]).", ";
                                }
                                $db->query($sqlFirstStr . "playerID_F) " . $sqlSecondStr . $playerID . ");");
                            }

                            $ultEvents = $db->query("SELECT gameTime, eventName,  FROM tbl_Events_Tmp WHERE (eventName = 'EV_UsedAbility_Ultimate' OR eventName = 'EV_Charge_Ultimate') AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"])->fetch()[0];
                            $currentTime = "00:00:00";
                            
                            foreach($ultEvents as $ultEvent){

                            }

                            //Create Additional Total Summary
                            $enemiesKnocked = $db->query("SELECT COUNT(*) FROM tbl_Events_Tmp WHERE eventName = 'EV_Knockback_Dealt' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"])->fetch()[0];
                            $Ability2Use = $db->query("SELECT COUNT(*) FROM tbl_Events_Tmp WHERE eventName = 'EV_UsedAbility_2' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"])->fetch()[0];
                            $Ability1Use = $db->query("SELECT COUNT(*) FROM tbl_Events_Tmp WHERE eventName = 'EV_UsedAbility_1' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"])->fetch()[0];
                            $gotKnocked = $db->query("SELECT COUNT(*) FROM tbl_Events_Tmp WHERE eventName = 'EV_Knockback_Received' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"])->fetch()[0];
                            
                            $db->query("UPDATE tbl_Player_Statistic_Total 
                                        SET Enemies_Knocked = ".$enemiesKnocked.", Got_Knocked = ".$gotKnocked.", Ability1_Used = ".$Ability1Use.", Ability2_Used = ".$Ability2Use."
                                        WHERE playerID_F = ".$playerID);


                            //Create Hero Summary
                            $heroes = $db->query("SELECT DISTINCT eventValue, heroID 
                                                    FROM tbl_Events_Tmp INNER JOIN cst_Heroes ON heroName = eventValue
                                                    WHERE eventName = 'EV_SwitchedHero' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"]);
                            if(isset($heroes)){
                                foreach($heroes as $hero){
                                    if(strlen($hero['eventValue'])>0){
                                        $stats = $db->query("SELECT eventName, eventValue FROM tbl_Events_Tmp WHERE eventTarget = '".$hero['eventValue']."' AND eventName Like 'HS_%' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"]);
                                        if(isset($stats)){
                                            //Create Total Summary
                                            $sqlFirstStr = "INSERT INTO tbl_Player_Statistic_Hero(";
                                            $sqlSecondStr = "VALUES(";
                                            foreach($stats as $stat){
                                                $sqlFirstStr .= str_replace("HS_", "", $stat["eventName"]).", ";
                                                $sqlSecondStr .= str_replace(",", ".", $stat["eventValue"]).", ";
                                            }
                                            $db->query($sqlFirstStr . "playerID_F, heroID_F) " . $sqlSecondStr . $playerID . ", " . $hero["heroID"].");");
                                        }
                                    }
                                }
                            }

                            //Create Positions
                            $positions = $db->query("SELECT eventValue, gameTime FROM tbl_Events_Tmp WHERE eventName = 'EV_PlayerPosition' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"]);
                            if(isset($positions)){
                                foreach($positions as $position){
                                    $pos = explode(", ", str_replace(")", "", str_replace("(", "", $position["eventValue"])));
                                    $prepare = $db->prepare("INSERT INTO tbl_Player_Position(playerID_F, gameTime, positionX, positionY, positionZ) VALUES(?, ?, ?, ?, ?)");
                                    if(count($pos)==3)
                                        $prepare->execute(array($playerID, $position["gameTime"], $pos[0], $pos[1], $pos[2]));
                                }
                            }

                            //Create Communications
                            $coms = $db->query("PRAGMA table_info(tbl_Player_Communication);")->fetchAll();
                            array_shift($coms); //remove ID Value
                            $db->query("INSERT INTO tbl_Player_Communication(playerID_F) VALUES(".$playerID.");");
                            foreach($coms as $com){
                                $db->query("UPDATE tbl_Player_Communication SET ".$com[1]." = (SELECT COUNT(*) FROM tbl_Events_Tmp WHERE eventName = 'COM_".$com[1]."' AND playerName = '".$player["eventValue"]."' AND team = '".$team[0]."' AND slot = ".$player["slot"].") WHERE playerID_F = ".$playerID);
                            }
                        }
                    }

                    //Save Ultimate Charge
                    $db->query("INSERT INTO tbl_Player_UltimateCharge (playerID_F, gameTime, chargeValue) 
                                SELECT playerID, gameTime, eventValue
                                FROM tbl_Events_Tmp INNER JOIN tbl_Player ON (slot = playerSlot AND tbl_Events_Tmp.playerName = tbl_Player.playerName)
                                WHERE eventName = 'EV_Charge_Ultimate'");

                    //DEBUG
                    $db->query("DELETE FROM tbl_Events_Tmp WHERE eventName Like 'TS_%' OR eventName Like 'HS_%' OR eventName = 'EV_LoadMap' OR eventName = 'EV_PlayerPosition' OR eventName = 'EV_Charge_Ultimate'");
                    
                    //Save all events
                    $db->query("INSERT INTO tbl_Events (playerID_F, gameTime, eventName, eventValue, eventTarget)
                                SELECT playerID, gameTime, eventName, eventValue, eventTarget
                                FROM tbl_Events_Tmp INNER JOIN tbl_Player ON (slot = playerSlot AND tbl_Events_Tmp.playerName = tbl_Player.playerName)");

                    //Store Changes in DB
                    $db->commit();
                    return "<div class='uploadMessage_Frame' style=\"animation-delay: " . $i/5 . "s;\">Successfully Uploaded File " . $filename."</div>";
                }

                cancel:
                $db->rollBack();
                return "<div class='uploadMessage_Frame' style=\"animation-delay: " . $i/5 . "s; background-color: #c0392b;\">".$error."</div>";
            }
        ?>
    </body>
</html>