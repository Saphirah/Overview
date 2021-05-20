<div class="dateField">DPS Summary</div>

    <div class="frame" style="padding-left: 0px; padding-right: 0px;">
        <div style="height: 50%;"><h5>Eliminations</h5></div>
        <div style="height: 50%;"><?= $player["Eliminations"] ?></div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Final Blows</h5></div>
        <div style="height: 50%;"><?= $player["FinalBlows"] ?></div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Solo Kills</h5></div>
        <div style="height: 50%;"><?= $player["Kills_Solo"] ?></div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Multikills</h5></div>
        <div style="height: 50%;"><?= $player["Multikills"] ?></div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Best Multikill</h5></div>
        <div style="height: 50%;"><?= $player["Multikill_Best"] ?></div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Accuracy</h5></div>
        <div style="height: 50%;"><?= floor($player["Accuracy"]*100) ?>%</div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Total Damage</h5></div>
        <div style="height: 50%;"><?= floor($player["Damage_All"]) ?></div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Barrier Damage</h5></div>
        <div style="height: 50%;"><?= floor($player["Damage_Barrier"] / $player["Damage_All"] * 100) ?>%</div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Hero Damage</h5></div>
        <div style="height: 50%;"><?= floor($player["Damage_Heroes"] / $player["Damage_All"] * 100) ?>%</div>
    </div>
    <div class="frame">
        <div style="height: 50%;"><h5>Hero Damage</h5></div>
        <div style="height: 50%;"><?= floor($player["Damage_Heroes"] / $player["Damage_All"] * 100) ?>%</div>
    </div>
