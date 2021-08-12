<?php
    session_start();
    
    /*foreach (glob("static/Model/Components/*.php") as $filename)
    {
        include_once $filename;
    }*/
    include_once("static/Model/Components/Header.php");
    include_once("static/Model/Components/Timeline.php");
    include_once("static/Model/Components/StatField.php");
    include_once("static/Model/Components/CompareField.php");

    include_once("static/Model/Classes/Account.php");
    include_once("static/Model/Classes/Database.php");

    class Model{
        function __construct(){
            //Connect to Database
            $this -> db = Database::getInstance();
            //Load User
            if(isset($_SESSION['userID'])){
                $this -> account = Account::GetExistingAccount($_SESSION['userID']);
            }
        }

        function query($sqlStr){
            return $this -> db -> query($sqlStr);
        }
    }

    $model = new Model();

    function include_args($files, $arguments) {
        global $_ARGS;
        if(isset($arguments))
            $_ARGS = $arguments;

        include_once($files);

        if(isset($arguments))
            unset($_ARGS);
    }

    function timeToSeconds($timeStr){
        $length = explode(":",$timeStr);
        return $length[0] * 3600 + $length[1] * 60 + $length[2];
    }

?>