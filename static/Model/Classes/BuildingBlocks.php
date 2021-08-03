<?php
    include_once("static/Model/Model.php");

    class BuildingBlocks{
        public static function CreateSmallField($title, $value){
            echo("<div class='frame'>
                        <div style='height: 50%;'><h5>+ $title +</h5></div>
                        <div style='height: 50%;'>" + $value + "</div>
                    </div>");
        }
    }
?>