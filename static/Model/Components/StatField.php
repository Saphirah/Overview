<?php
    //1x1 Field to display single stats

    //Inputs:
    //$title = Fat font at the top of the field
    //$data = Small font at the bottom of the field
?>

<?php
    class StatField{
        function __construct($title, $data){
?>
            <div class="frame">
                <div style="height: 50%;"><h5><?= $title ?></h5></div>
                <div style="height: 50%;"><?= $data ?></div>
            </div>
<?php
        }
    }
?>