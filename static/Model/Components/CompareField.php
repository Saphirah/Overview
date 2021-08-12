<?php
    //A field that compares 2 values

    //Inputs:
    //
?>

<?php
    class CompareField{
        function __construct($name, $value1, $value2){
            if($value1 > $value2){
                $color1 = "39, 174, 96";
                $color2 = "182, 34, 34";
            }else if($value1 < $value2){
                $color2 = "39, 174, 96";
                $color1 = "182, 34, 34";
            } else {
                $color1 = "230, 126, 34";
                $color2 = "230, 126, 34";
            }

                ?>
            <div class="compareField">
                <div style="background-color: rgb(<?= $color1 ?>)">
                    <?= $value1 ?>
                </div>
                <div>
                    <?= $name ?>
                </div>
                <div style="background-color: rgb(<?= $color2 ?>)">
                    <?= $value2 ?>
                </div>
            </div>

<?php
        }
    }
?>