<?php
    //A Timeline that shows ingame events

    //Inputs:
    //$teamID_F = the ID of the team that should be shown
?>

<?php
    class Timeline{
        function __construct($teamID_F){
            //Fetch data
            if(!isset($db))
                $db  = new PDO("sqlite:stats.db");
            $cEvents = $db->query("SELECT gameTime, playerSlot, eventValue, eventName, teamID_F, playerName, playerID
                FROM tbl_Events INNER JOIN tbl_Player ON playerID = playerID_F 
                WHERE (eventName = 'EV_Died' OR eventName = 'EV_SwitchedHero' OR eventName = 'EV_UsedAbility_Ultimate' OR eventName = 'EV_FinalBlow') AND (teamID_F = ".$teamID_F." OR teamID_F = ".($teamID_F+1).");")->fetchAll();

            $players = [[[],[],[],[],[],[]],[[],[],[],[],[],[]]];
            foreach($cEvents as $cEvent){
                $players[1-($cEvent["teamID_F"]-$teamID_F)][5-$cEvent["playerSlot"]] = [$cEvent["playerName"], $cEvent["playerID"]];
            }
?>
            <div class="frame" style="padding: 20px; width: 100%; height: 440px; overflow: visible; box-sizing: border-box;">
                <div style="height:80%; width: 6%; float: left; padding-top: 16px;">
                <?php
                    //Create Player Names next to Timeline
                    foreach($players as $teams){
                        ?>
                    <div style="margin-top: 28px; width: 100%; height: 143px;">
                        <?php
                        foreach($teams as $player){
                ?>

                    <div onclick="loadPage('player.php/?playerID=<?= $player[1] ?>');" 
                        class="timelineFrame enlargeField" data-tooltip="Click to open the player summary!" 
                        style="display: inline-block;width: 122%; border-top-right-radius: 0; border-bottom-right-radius: 0; position:relative; height: 21.4px;"><?= $player[0] ?></div>

                <?php
                        }
                ?>
                    </div>
                <?php
                    }
                ?>
                    </div>
                    <div style="width: 90%;  display: inline-block; vertical-align:top; float: left; ">
                        <canvas id="chart" style="background-color: rgb(50, 50, 50); height: 100%; z-index: -1;"></canvas>
                    </div>
                </div>
                <script>

                const skull = new Image(25, 25);
                skull.src = '/static/Images/Icons/skull.png'; 
                const knife = new Image(20, 20);
                knife.src = '/static/Images/Icons/knife.png'; 

                <?php
                    $all = [
                        "EV_SwitchedHero" => [
                            "name" => "Switched Hero",
                            "image" => "[",
                            "color" => "#16a085",
                            "tooltip" => "Player switched Hero",
                            "data" => "[",
                            "loadedImages" => [],
                            "folder" => "/static/Images/Icons/characters/"
                        ],
                        "EV_UsedAbility_Ultimate" => [
                            "name" => "Used Ultimate",
                            "image" => "[",
                            "color" => "#ecf0f1",
                            "tooltip" => "Player used Ultimate",
                            "data" => "[",
                            "loadedImages" => [],
                            "folder" => "/static/Images/Icons/ultimates/"
                        ],
                        "EV_FinalBlow" => [
                            "name" => "Final Blow",
                            "image" => "knife",
                            "color" => "#d35400",
                            "tooltip" => "Dealt Final Blow",
                            "data" => "["
                        ],
                        "EV_Died" => [
                            "name" => "Deaths",
                            "image" => "skull",
                            "color" => "#FF0000",
                            "tooltip" => "Player died",
                            "data" => "["
                        ],
                    ];

                    foreach($cEvents as $cEvent){
                        //Check if we need custom images
                        $cEvent["eventValue"] = str_replace(":", "", str_replace(" ", "", $cEvent["eventValue"]));
                        if(isset($all[$cEvent["eventName"]]["loadedImages"])){
                            //Check if image is already created
                            if(!in_array($cEvent["eventValue"], $all[$cEvent["eventName"]]["loadedImages"])){
                                //Add Hero to array
                                array_push($all[$cEvent["eventName"]]["loadedImages"],$cEvent["eventValue"]);
                                echo("const tl_".$cEvent["eventName"]."_".$cEvent["eventValue"]." = new Image(25, 25); 
                tl_".$cEvent["eventName"]."_".$cEvent["eventValue"].".src = '".$all[$cEvent["eventName"]]["folder"].$cEvent["eventValue"].".png';
                ");
                            }
                            $all[$cEvent["eventName"]]["image"] .= "tl_".$cEvent["eventName"]."_".$cEvent["eventValue"].", ";
                        }
                        $all[$cEvent["eventName"]]["data"] .= "{x:\"".$cEvent["gameTime"]."\", y: ".($cEvent["playerSlot"] + (($cEvent["teamID_F"] - $teamID_F)*6) + ($cEvent["teamID_F"] - $teamID_F) + 1)."}, ";
                    }

                    foreach($all as $key => $evt){
                        if(isset($all[$key]["loadedImages"]))
                            $all[$key]["image"] .= "]";  
                        $all[$key]["data"] .= "]";
                    }
                ?>

                var ctx = document.getElementById('chart').getContext('2d');
                var myChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        datasets: [


                    <?php foreach($all as $cData){ ?>
                        {
                            label: "<?= $cData["name"] ?>",
                            data: <?= $cData["data"] ?>,
                            pointStyle: <?= $cData["image"] ?>,
                            showLine: false,
                            fill: false,
                            tooltip: "<?= $cData["tooltip"] ?>",
                            borderColor: "<?= $cData["color"] ?>",
                            backgroundColor: "<?= $cData["color"] ?>"
                        },
                    <?php } ?>
                    ]},
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        transitions:{
                            show: {
                                animations:{
                                    visible: false
                                }
                            },
                            hide: {
                                animations:{
                                    visible: false
                                }
                            }
                        },
                        plugins: {
                            zoom: {
                                pan:{
                                    enabled: true,
                                    mode: 'x'
                                },
                                zoom: {
                                    wheel: {
                                        enabled: true,
                                    },
                                    pinch: {
                                        enabled: true
                                    },
                                    mode: 'x',
                                }
                            },
                            tooltip:{
                                custom: function(tooltip){
                                    if(!tooltip)return;
                                    tooltip.displayColors = false;
                                },
                                callbacks:{
                                    title: function(tooltipItem, data) {
                                        return data.datasets[tooltipItem[0].datasetIndex]['tooltip'];
                                    },
                                    label: function(tooltipItem, data) {
                                        return tooltipItem.xLabel;
                                    }
                                }
                            },
                            legend: {
                                display: true,
                                labels:{
                                    fontColor: "white",
                                    fontFamile: "montseratNormal"
                                }
                            }
                        },
                        scales: {
                            x: {
                                type: "time",
                                time: {
                                    parser: "HH:mm:ss",
                                    unit: "seconds",
                                    displayFormats: {
                                        'seconds': 'HH:mm:ss'
                                    },
                                    stepSize: "00:00:30"
                                },
                                min: "00:00:00",
                                ticks:{
                                    fontColor: "white"
                                },
                                grid: {
                                    display: true,
                                    drawBorder: false
                                }
                            },
                            y: {
                                min: 0,
                                max: 14,
                                
                                ticks: {
                                    display: false,
                                    stepSize: 1
                                },        
                                grid: {
                                    display: true,
                                    lineWidth: 10,
                                    drawBorder: false
                                }
                            }
                        }
                    }
                });
                </script>
<?php
        }
    }

?>