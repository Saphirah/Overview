<?php

    class Database{
        private static $instance = null;
        private $db;

        private function __construct(){
            $this -> db = new PDO("sqlite:stats.db");
        }

        public function Query($sqlStr){
            return $this -> db -> query($sqlStr);
        }

        public static function getInstance(){
            if(self::$instance == null)
                self::$instance = new Database();
            return self::$instance;
        }
    }

?>