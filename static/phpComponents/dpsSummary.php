<div class="dateField">DPS Summary</div>

<?php
    $fields = [
        ["Eliminations", $player["Eliminations"]],
        ["Final Blows", $player["FinalBlows"]],
        ["Solo Kills", $player["Kills_Solo"]],
        ["Multikills", $player["Multikills"]],
        ["Best Multikill", $player["Multikill_Best"]],
        ["Accuracy", floor($player["Accuracy"]*100)."%"],
        ["Total Damage", floor($player["Damage_All"])],
        ["Barrier Damage", floor($player["Damage_Barrier"] / $player["Damage_All"] * 100)."%"],
        ["Hero Damage", floor($player["Damage_Heroes"] / $player["Damage_All"] * 100)."%"],
        ["Deaths", floor($player["Deaths_All"] / $player["Damage_All"] * 100)],
        ["Damage Taken", $player["Damage_Taken"]]
    ];

    foreach($fields as $field){
?>
    <div class="frame" style="padding-left: 5px; padding-right: 5px;">
            <div style="height: 50%;"><h5><?= $field[0] ?></h5></div>
            <div style="height: 50%;"><?= $field[1] ?></div>
    </div>
    
<?php } ?>
