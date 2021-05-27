<div class="dateField">Support Summary</div>

<?php
    $fields = [
        ["Healing", $player["Healing_Dealt"]],
        ["Enemies Knocked", $player["Enemies_Knocked"]],
        ["Offensive Assists", $player["Assists_Offensive"]],
        ["Defensive Assists", $player["Assists_Defensive"]],
        ["Self Healing", $player["Multikill_Best"]],
        ["Accuracy", floor($player["Accuracy"]*100)."%"],
        ["Total Damage", floor($player["Damage_All"])],
        ["Barrier Damage", floor($player["Damage_Barrier"] / $player["Damage_All"] * 100)],
        ["Deaths", floor($player["Deaths_All"] / $player["Damage_All"] * 100)],
        ["Damage Taken", $player["Damage_Taken"]]
    ];

    foreach($fields as $field){
?>
    <div class="frame" style="padding-left: 0px; padding-right: 0px;">
            <div style="height: 50%;"><h5><?= $field[0] ?></h5></div>
            <div style="height: 50%;"><?= $field[1] ?></div>
    </div>
    
<?php } ?>
