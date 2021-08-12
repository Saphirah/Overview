<html>
    <body>
        <?php
            include_once("static/Model/Model.php");
            if(!isset($_GET["matchID"])){
                echo("Invalid Match ID");
                exit();
            }
            $match = $model->query('SELECT mapName, typeName FROM tbl_Match INNER JOIN cst_MatchType ON matchTypeID_F = typeID INNER JOIN cst_Maps ON mapID = mapID_F WHERE matchID = '.$_GET["matchID"])->fetch();
            $playersInList = $model->query('SELECT playerName, playerID FROM tbl_Player INNER JOIN tbl_Team ON teamID = teamID_F WHERE matchID_F = '.$_GET["matchID"]." ORDER BY teamID")->fetchAll();
        ?>
        <!-- Header -->
        <?php
            new Header($match["typeName"]. " on ". $match["mapName"], "Compare Players");
        ?>
        <div style="width: 100%; display: flex; justify-content: center;">
            <div class="frame" style="width: 70%; float: center; padding-left: 27px; padding-right: 27px; height: auto;">
                
                <!-- Player Selection Frames -->
                <div style="width: 100%; height: 80px;">
                    <select class="enlargeField" style="float: left; width: 25%;" id="selectPlayer1">
                        <?php
                            foreach($playersInList as $playerName){
                                if($playerName[1] == $_GET["playerID1"]){
                                    echo("<option value=".$playerName[1]." selected>".$playerName[0]."</option>");
                                }
                                else{
                                    echo("<option value=".$playerName[1].">".$playerName[0]."</option>");
                                }
                            }
                        ?>
                    </select>
                    <select class="enlargeField" style="float: right; width: 25%;" id="selectPlayer2">
                        <?php
                            foreach($playersInList as $playerName){
                                if($playerName[1] == $_GET["playerID2"]){
                                    echo("<option value=".$playerName[1]." selected>".$playerName[0]."</option>");
                                }
                                else{
                                    echo("<option value=".$playerName[1].">".$playerName[0]."</option>");
                                }
                            }
                        ?>
                    </select>
                    <script>
                        var selectPlayer1 = document.getElementById("selectPlayer1");
                        selectPlayer1.addEventListener('change', function(){
                            var url = new URL(window.location.href);
                            url.searchParams.set("playerID1", selectPlayer1.value);
                            loadPage(decodeURIComponent(url.toString()));
                        });
                        var selectPlayer2 = document.getElementById("selectPlayer2");
                        selectPlayer2.addEventListener('change', function(){
                            var url = new URL(window.location.href);
                            url.searchParams.set("playerID2", selectPlayer2.value);
                            loadPage(decodeURIComponent(url.toString()));
                        });
                    </script>
                </div>

                <!-- Stat Table -->
                <div>
                    <div style="width: 45%; display: inline; float: left;">
                    <?php
                        $player1 = $model->query('SELECT * FROM ((tbl_Player INNER JOIN tbl_Player_Statistic_Total ON playerID = tbl_Player_Statistic_Total.playerID_F) INNER JOIN tbl_Player_Communication ON playerID = tbl_Player_Communication.playerID_F) WHERE playerID = '.$_GET["playerID1"])->fetch();
                        $player2 = $model->query('SELECT * FROM ((tbl_Player INNER JOIN tbl_Player_Statistic_Total ON playerID = tbl_Player_Statistic_Total.playerID_F) INNER JOIN tbl_Player_Communication ON playerID = tbl_Player_Communication.playerID_F) WHERE playerID = '.$_GET["playerID2"])->fetch();
                        $evals = ["<img href='' />Eliminations", ["Eliminations", "Kills"], ["FinalBlows", "Final Blows"], ["Kills_Solo","Solo Kills"], ["Kills_Environmental","Environmental Kills"],  ["Kills_Objective","Objective Kills"], ["Multikills", "Multikills"], ["Multikill_Best", "Best Multikill"],
                                    "Deaths", ["Deaths_All", "Deaths"], ["Deaths_Environmental", "Environmental Deaths"],
                                    "Abilities", ["Ability1_Used", "Used Ability 1"], ["Ability2_Used", "Used Ability 2"], ["Ultimates_Used", "Used Ultimates"], ["Ultimates_Earned", "Earned Ultimates"], ["Ultimates_EarnTime_Avg", "Avg Ultimate Time"], ["Ultimates_EarnTime_Min", "Best Ultimate Time"], ["Ultimates_EarnTime_Max", "Worst Ultimate Time"]];
                        
                        foreach($evals as $eval){
                            if(is_array($eval)){
                                new CompareField($eval[1], $player1[$eval[0]], $player2[$eval[0]]);
                            } else {
                                echo("<h2 style='margin: 20px;'>".$eval."</h2>");
                            }
                        }                        
                    ?>
                    </div>
                    <div style="width: 45%; display: inline; float: left;">
                        <?php
                            $player1 = $model->query('SELECT * FROM ((tbl_Player INNER JOIN tbl_Player_Statistic_Total ON playerID = tbl_Player_Statistic_Total.playerID_F) INNER JOIN tbl_Player_Communication ON playerID = tbl_Player_Communication.playerID_F) WHERE playerID = '.$_GET["playerID1"])->fetch();
                            $player2 = $model->query('SELECT * FROM ((tbl_Player INNER JOIN tbl_Player_Statistic_Total ON playerID = tbl_Player_Statistic_Total.playerID_F) INNER JOIN tbl_Player_Communication ON playerID = tbl_Player_Communication.playerID_F) WHERE playerID = '.$_GET["playerID2"])->fetch();
                            $evals = ["Damage", ["Damage_All", "Total Damage"], ["Damage_Barrier", "Barrier Damage"], ["Damage_Blocked","Damage Blocked"], ["Damage_Taken","Damage Taken"],
                                        "Healing", ["Healing_Dealt", "Healing"], ["Healing_Self", "Self Healing"],
                                        "Assists", ["Assists_Offensive", "Offensive Assists"], ["Assists_Defensive", "Defensive Assists"],
                                        "Crowd Control", ["Enemies_Knocked", "Enemies Knocked"], ["Got_Knocked","Got Knocked"]];
                            
                            foreach($evals as $eval){
                                if(is_array($eval)){
                                    new CompareField($eval[1], $player1[$eval[0]], $player2[$eval[0]]);
                                } else {
                                    echo("<h2 style='margin: 20px;'>".$eval."</h2>");
                                }
                            }                        
                        ?>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>