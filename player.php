<html>
    <body>
        <?php
            include_once("static/Model/Classes/BuildingBlocks.php");

            if(!isset($_GET["playerID"])){
                echo("Invalid Player ID");
                exit();
            }

            $player = $model->query('SELECT * FROM ((tbl_Player INNER JOIN tbl_Player_Statistic_Total ON playerID = tbl_Player_Statistic_Total.playerID_F) INNER JOIN tbl_Player_Communication ON playerID = tbl_Player_Communication.playerID_F) WHERE playerID = '.$_GET["playerID"])->fetch();
            $communications = $model->query('SELECT sql FROM sqlite_master WHERE tbl_name = "table_name" AND type = "table"')->fetchAll();
        ?>
        <!-- Header -->
        <?php
            new Header("Summary of ".$player["playerName"]);
        ?>

        <?php
        
            switch($player["roleID_F"]){
                case 1:
                    include './static/phpComponents/tankSummary.php';
                    break;
                case 2:
                    include './static/phpComponents/dpsSummary.php';
                    break;
                case 3:
                    include './static/phpComponents/supportSummary.php';
                    break;
            }
        
        ?>
        <article name="Ultimate">
            <section class="dateField">Ultimate Usage</section>
            <section style="width:100px; float: left; margin-right: 10px; margin-bottom: 10px;">
                <?php
                    new StatField("Ultimates Earned", $player["Ultimates_Earned"]);
                    new StatField("Ultimates Used", $player["Ultimates_Used"]);
                ?>
            </section>
            <section class="frame" style="height: 210px; width: 540px; padding: 10px; padding-top: 15px;padding-right: 15px;">
                <canvas id="ultChargeChart"></canvas>
            </section>
            <section style="width:100px; float: left; margin-right: 10px; margin-bottom: 10px;">
                <?php
                    new StatField("Avg Holdtime", $player["Ultimates_HoldTime_Avg"]);
                    new StatField("Max Holdtime", $player["Ultimates_HoldTime_Max"]);
                ?>
            </section>
            <script>
                var ctx = document.getElementById("ultChargeChart").getContext('2d'); 
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
                        gradient.addColorStop(0, "#d3540000");
                        gradient.addColorStop(1, "#d35400CC");
                    }
                    return gradient;
                }
                const config = {
                    type: 'scatter',
                    data: {
                        datasets: [
                        {
                        label: 'Ultimate Charge',
                        data: [
                            <?php
                                if(!isset($playerID))
                                    $playerID = $_GET["playerID"];
                                $UltCharges = $model->query('SELECT * FROM tbl_Player_UltimateCharge WHERE playerID_F = '.$playerID)->fetchAll();
                                foreach($UltCharges as $UltCharge){
                                    echo("{x: \"".$UltCharge["gameTime"]."\", y: ".$UltCharge["chargeValue"]."},");
                                }
                        ?>
                        ],
                        borderColor: "#d35400",
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
                    ]},
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
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
                                display: true,
                                type: "time",
                                time: {
                                    parser: "HH:mm:ss",
                                    unit: "seconds",
                                    displayFormats: {
                                        'seconds': 'HH:mm:ss'
                                    },
                                    stepSize: "00:02:00"
                                }
                            },
                            y: {
                                title: {
                                    display: true,
                                    text: 'Ultimate Charge'
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
                var ultChargeChart_<?= $playerID?> = new Chart(ctx, config);
            </script>
        </article>
        <article name="Communication">
            <section class="dateField">Communication</section>
            <?php
                foreach($communications as $com){
                    if($com != "playerID_F"){
                        BuildingBlocks.CreateSmallField("Hey", "Boy");
                    }
                }
            ?>
        </article>
    </body>
</html>