<html>
    <head>
        <title>
            StatWatch
        </title>

        <link rel='stylesheet' href='/static/style.scss'>
        <link rel='stylesheet' href='/static/login.scss'>
        <link rel='stylesheet' href='/static/customCheckbox.scss'>
        <link href="/static/css-circular-prog-bar.css" rel="stylesheet"/>
        <link href = "/static/fontawesome/css/all.css" rel="stylesheet"/>
        <script type="text/javascript" src="/static/chart.min.js"></script>
    </head>

    <body>

        <!-- Header -->
        <div class='navigation' style='background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url(/static/Images/Maps_Header/KingsRow.jpg);'>
            <div>
                <h1>Overview</h0>
                <h5 style="font-family: 'montseratLight';">
                    Overwatch Stat Analyzing Tool<br>
                </h5>
            </div>
        </div>
        <div class="loginField" id="loginfield">
            <h1>LOGIN</h1>
            <form name="login" action="login.php" method="POST">
                <label for="username">Username:</label><br>
                <input class="loginInput" type="text" value="" id="username" name="username" /><br>
                <label for="password">Password:</label><br>
                <input class="loginInput" type="password" value="" id="password" name="password" /><br>
                <input class="loginButton enlargeField" type="submit" value="Login">
                <input id="s2" type="checkbox" class="switch" checked style="margin:15px; margin-right: 5px;">
                <label for="s2" style="margin-top:15px;">Stay Logged in</label>
            </form>
        </div>

        <div class="loginField" id="registerField">
            <h1>Register</h1>
            <form name="register" action="?register=1" method="POST">
                <label for="registerUsername">Username:</label><br>
                <input class="loginInput" type="text" value="" id="registerUsername" name="registerUsername" /><br>
                <label for="registerEmail">Email:</label><br>
                <input class="loginInput" type="email" value="" id="registerEmail" name="registerEmail" /><br>
                <label for="registerPassword">Password:</label><br>
                <input class="loginInput" type="password" value="" id="registerPassword" name="registerPassword"/><br>
                <input class="loginButton enlargeField" type="submit" value="Register">
            </form>
        </div>

        <?php
            session_start();
            if(isset($_SESSION['userid'])){
                unset($_SESSION['userid']);
                unset($_SESSION['userName']);
                echo("<script>parent.location.reload();</script>");
            }

            //Try to login
            if(isset($_POST['username']) && isset($_POST['password'])){
                $username = $_POST['username'];
                $password = $_POST['password'];
                if(strlen($username) == 0){
                    echo("<br>Please enter a valid username!");
                    exit();
                }
                if(strlen($password) == 0){
                    echo("<br>Please enter a valid password");
                    exit();
                }

                $db  = new PDO("sqlite:c:/xampp/htdocs/stats.db");
                $user = $db->query("SELECT * FROM wb_Account WHERE accountEmail = '" . $username . "' or accountName = '" . $username . "'")->fetch();
                if($user !== false && password_verify($password, $user["accountPassword"])){
                    $_SESSION['userid'] = $user['accountID'];
                    $_SESSION['userName'] = $user['accountName'];
                    echo("<script>parent.location.reload();</script>");
                } else {
                    echo("<br>Login failed. Please check your credentials!");
                }
            }

            if(isset($_POST['registerUsername']) && isset($_POST['registerEmail']) && isset($_POST['registerPassword'])) {
                $username = $_POST['registerUsername'];
                $email = $_POST['registerEmail'];
                $password = $_POST['registerPassword'];
              
                if(!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    echo '<br>Bitte eine gültige E-Mail-Adresse eingeben<br>';
                    exit();
                }     
                if(strlen($password) == 0) {
                    echo '<br>Please enter a password';
                    exit();
                }
                if(strlen($username) == 0) {
                    echo '<br>Please enter a username';
                    exit();
                }
                
                //Überprüfe, dass die E-Mail-Adresse noch nicht registriert wurde
                $db  = new PDO("sqlite:c:/xampp/htdocs/stats.db");
                $user = $db->query("SELECT * FROM wb_Account WHERE accountEmail = '" . $email . "' or accountName = '" . $username . "'")->fetch();
                
                if($user !== false) {
                    if($email == $user["accountEmail"])
                        echo '<br>Diese E-Mail-Adresse ist bereits vergeben';
                    else
                        echo '<br>Dieser Benutzername ist bereits vergeben';
                    exit();
                }    
            
                $password_hash = password_hash($password, PASSWORD_DEFAULT);
                $result = $db->query("INSERT INTO wb_Account(accountEmail, accountPassword, accountName) VALUES ('".$email."', '".$password_hash."', '".$username."')");

                if($result) {        
                    echo("<script>window.location.replace(\"http://example.com/\")</script>");
                    $showFormular = false;
                } else {
                    echo '<br>Saving your credentials failed!';
                }
            }
        ?>
    </body>
</html>
