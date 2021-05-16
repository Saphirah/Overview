<html>
    <head>
        <title>
            Overview
        </title>
        <link href = "/static/fontawesome/css/all.css" rel="stylesheet"/>
        <link rel="icon" href="/icon.png">
    <style>

        @font-face {
            font-family: "montseratNormal";
            src: url("/static/Fonts/Montserrat-Medium.ttf"); ;
        }

        @font-face {
            font-family: "montseratBold";
            src: url("/static/Fonts/Montserrat-Bold.ttf"); ;
        }

        * {
            padding: 0;
            margin: 0;
            border: 0 solid;
            background: #1a1a1a00;
            font-family: 'montseratNormal'; 
        }

        a, a:hover, a:focus, a:active {
            text-decoration: none;
            color: inherit;
        }
        
        iframe{
            height: 100%;
            width: calc(100% - 80px);
            padding-left: 60px;
            background-image: url("/static/Images/Background/background.jpg");
        }
        body{
            background-image: url("/static/Images/Background/background.jpg");
            background-repeat: no-repeat; 
            background-attachment: fixed;
            background-position: center;
            background-size: cover;
        }
        .navigator{
            width: 80px;
            height: 100%;
            background: #1a1a1a;
            position: absolute;
            transition: 0.5s;
            transition-property: width;
            overflow: hidden;
        }
        .navigator:hover{
            width: 250px;
        }

        .navigator:hover > .navigatorElement{
            color: white;
        }

        .navigatorElement{
            height: 80px;
            width: 100%;
            padding-left: 20px;
            padding-right: 10px;
            font-size: 18;
            color: rgba(1,1,1,0);
            transition: all 0.5s;
            display: flex;
            align-items: center;
            overflow:visible;
            white-space: nowrap;
            cursor: pointer;
        }

        .navigatorElement i{
            color: white;
            font-size: 30;
            margin-right: 15px;
        }

        .navigatorElement:hover{
            background: #101010;
            transform: translate(0px, -3px);
        }
    </style>
    </head>
    <body>
        <div class="navigator">
            <div class="navigatorElement", style="padding-left: 13px; margin-bottom: 50px; font-family: 'montseratBold';">
                <img src="/icon.png", style="width: 50px; height:50px; background-color: transparent; margin-right: 20px;">
                <?php 
                session_start();
                    if(isset($_SESSION['userName']))
                        echo($_SESSION['userName']);
                    else
                        echo("Overview");
                ?>
            </div>
            <?php
                $db  = new PDO("sqlite:c:/xampp/htdocs/stats.db");
                $pages = $db->query('SELECT pageLink, pageIcon, pageName FROM wb_Pages ORDER BY pageID');
                foreach($pages->fetchAll() as $page){
                    echo("<div class='navigatorElement' onclick='changeIframe(\"" . $page["pageLink"] . "\")'><i class='" . $page["pageIcon"] . "''></i>" . $page["pageName"] . "</div>");
                }
            ?>
            <div class='navigatorElement'style="position: absolute; bottom: 80px;" onClick="openDiscord()"><i class='fab fa-discord'></i>Join our Discord</a></div>
            <script>
                function changeIframe(targetPage) {
                    document.getElementById('content').src = targetPage;
                    console.log(targetPage);
                }
                function openDiscord(){
                    window.open('https://www.discord.gg/DjarSGwmM5', '_blank');
                }
            </script>
            <div class='navigatorElement' style="position: absolute; bottom: 0;" onclick='changeIframe("login.php")'><i class='
            <?php
                if(isset($_SESSION['userName']))
                    echo("fas fa-sign-out-alt'></i>Logout</div>");
                else
                    echo("fas fa-sign-in-alt'></i>Login</div>");
            ?>
        </div>
        <iframe src="mainPage.php", id="content" allowtransparency="true" frameborder="0" ></iframe><!-- sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts allow-forms" -->
    </body>
</html>