<html>
    <head>
        <title>
            Overview
        </title>

        <link rel="icon" href="/icon.png">

        <!--My Style Sheets-->
        <link rel="stylesheet" href='/static/CSS/controlPage.css'/>
        <link rel='stylesheet' href='/static/CSS/style.scss'/>
        <link rel='stylesheet' href='/static/CSS/customCheckbox.scss'>
        <link rel='stylesheet' href='/static/CSS/login.scss'>

        <!--Font Awesome-->
        <link href = "/static/fontawesome/css/all.css" rel="stylesheet"/>
        
        <!--Plugins-->
        <link href="/static/CSS/css-circular-prog-bar.css" rel="stylesheet"/>
        <script src="/static/JS/chart.min.js"></script>
        <script src="/static/JS/moment.min.js"></script>
        <script src="/static/JS/chartjs-adapter-moment.js"></script>
        <script src="/static/JS/hammer.min.js"></script>
        <script src="/static/JS/chartjs-plugin-zoom.min.js"></script>
        
    </head>
    <body>
    
        <?php 
            include_once("static/Model/Model.php");
        ?>
        <!--Sidebar-->
        <nav class="navigator">
            <header class="navigatorElement", style="padding-left: 13px; margin-bottom: 50px; font-family: 'montseratBold';">
                <img src="/icon.png", style="width: 50px; height:50px; background-color: transparent; margin-right: 20px;">
                <?= (isset($model->account) ? $model->account->name : "Overview") ?>
            </header>
            <article class='navigatorElement' onclick='loadPage("mainPage.php")'><i class="fas fa-th-large"></i>Match Overview</article>
            <article class='navigatorElement' onclick='loadPage("uploadFile.php")'><i class="fas fa-upload"></i>Upload File</article>
            <article class='navigatorElement'style="position: absolute; bottom: 80px;" onClick="openDiscord()"><i class='fab fa-discord'></i>Join our Discord</a></article>
            <article class='navigatorElement' style="position: absolute; bottom: 0;" onclick='loadPage("login.php")'><i class='<?= isset($model->account) ? "fas fa-sign-out-alt'></i>Logout" : "fas fa-sign-in-alt'></i>Login" ?></article>
        </nav>
        <!--Content-->
        <div id="content">
            <div class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </div>

        <script>
            function openDiscord(){
                window.open('https://www.discord.gg/DjarSGwmM5', '_blank');
            }
            function loadPage(pageURL) {
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function() {
                    if (this.readyState == 4 && this.status == 200) {
                        var content = document.getElementById("content");
                        content.innerHTML = this.responseText;
                        var arr = content.getElementsByTagName('script')
                        for (var n = 0; n < arr.length; n++)
                            eval(arr[n].innerHTML)
                    }
                };
                xhttp.open("GET", pageURL, true);
                window.history.pushState("page2", "Overview", "?pageURL="+pageURL+"");
                xhttp.send();
            }
            window.addEventListener('popstate', (event) => {
                var params = new URLSearchParams(window.location.search);
                loadPage(params.get("pageURL"));
            });
            
            <?php
                if(isset($_GET["pageURL"])){
                    echo("loadPage('".$_GET["pageURL"]."')");
                } else {
                    echo("loadPage('mainPage.php');");
                }
            ?>
        </script>
    </body>
</html>