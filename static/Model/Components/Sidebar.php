<?php
    include_once("static/Model/Model.php");
?>

<nav class="navigator">
    <header class="navigatorElement", style="padding-left: 13px; margin-bottom: 50px; font-family: 'montseratBold';">
        <img src="/icon.png", style="width: 50px; height:50px; background-color: transparent; margin-right: 20px;">
        <?= (isset($model->account) ? $model->account->name : "Overview") ?>
    </header>
    <article class='navigatorElement' onclick='changeIframe("mainPage.php")'><i class="fas fa-th-large"></i>Match Overview</article>
    <article class='navigatorElement' onclick='changeIframe("uploadFile.php")'><i class="fas fa-upload"></i>Upload File</article>
    <article class='navigatorElement'style="position: absolute; bottom: 80px;" onClick="openDiscord()"><i class='fab fa-discord'></i>Join our Discord</a></article>
    <article class='navigatorElement' style="position: absolute; bottom: 0;" onclick='changeIframe("login.php")'><i class='<?= isset($model->account) ? "fas fa-sign-out-alt'></i>Logout" : "fas fa-sign-in-alt'></i>Login" ?></article>
</nav>

<script>
        function changeIframe(targetPage) {
            document.getElementById('content').src = targetPage;
        }
        function openDiscord(){
            window.open('https://www.discord.gg/DjarSGwmM5', '_blank');
        }
</script>