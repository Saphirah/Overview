<?php
    include_once("static/Model/Model.php");

    class Account{

        public $name;
        public $email;

        public static function GetExistingAccount($accountID){
            $data = Database::getInstance()->query("SELECT * FROM wb_Account WHERE accountID = ".$accountID).fetch();
            if($data == null)
                return null;
            $obj = new Account();
            $obj->name = $data["accountName"];
            $obj->email = $data["accountEmail"];
            $obj->cookieString = $data["cookieString"];
            return $obj;
        }

        public static function Login($username, $password){
            if(strlen($username) == 0){
                echo("<br>Please enter a valid username!");
                return false;
            }
            if(strlen($password) == 0){
                echo("<br>Please enter a valid password");
                return false;
            }
            $user = $model->query("SELECT * FROM wb_Account WHERE accountEmail = '" . $username . "' or accountName = '" . $username . "'")->fetch();
            if($user !== false && password_verify($password, $user["accountPassword"])){
                $_SESSION['userid'] = $user['accountID'];
                $_SESSION['userName'] = $user['accountName'];
                echo("<script>parent.location.reload();</script>");
            } else {
                echo("<br>Login failed. Please check your credentials!");
                return false;
            }
        }

        public static function Logout(){
            unset($_SESSION['userid']);
            echo("<script>parent.location.reload();</script>");
        }

        public static function CreateNewAccount($username, $email, $password){

            if(!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                echo '<br>Bitte eine gültige E-Mail-Adresse eingeben<br>';
                return false;
            }
            if(strlen($password) == 0) {
                echo '<br>Please enter a password';
                return false;
            }
            if(strlen($username) == 0) {
                echo '<br>Please enter a username';
                return false;
            }

            //Überprüfe, dass die E-Mail-Adresse noch nicht registriert wurde
            $user = $model->Query("SELECT * FROM wb_Account WHERE accountEmail = '" . $email . "' or accountName = '" . $username . "'")->fetch();
            
            if($user !== false) {
                if($email == $user["accountEmail"])
                    echo '<br>Diese E-Mail-Adresse ist bereits vergeben';
                else
                    echo '<br>Dieser Benutzername ist bereits vergeben';
                return false;
            }    
            
            //Encrypt Password and create Account
            $password_hash = password_hash($password, PASSWORD_DEFAULT);
            $result = $model->Query("INSERT INTO wb_Account(accountEmail, accountPassword, accountName) VALUES ('".$email."', '".$password_hash."', '".$username."')");
            
            //Login user and redirect to main page
            if($result) {        
                $user = $db->query("SELECT * FROM wb_Account WHERE accountEmail = '" . $email . "' AND accountName = '" . $username . "'")->fetch();
                $_SESSION['userid'] = $user['accountID'];
                $_SESSION['userName'] = $user['accountName'];
                echo("<script>parent.location.reload();</script>");
                return true;
            } else {
                echo '<br>Saving your credentials failed!';
                return false;
            }
        }
    }
?>