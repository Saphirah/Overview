<?php
    //A page header

    //Inputs:
    //$headerTitle = the header title in big fonts
    //$headerSubtitle = the header subtitle in small fonts below the title
    //$headerImage = OPTIONAL: the background image URL
?>

<?php
    class Header{
        function __construct($headerTitle, $headerSubtitle = null, $headerImage = "static/Images/Maps_Header/kingsrow.jpg"){
                ?>
                    <header class='header' style='background-image: linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.2)), url("<?= $headerImage ?>"); height: 170px;'>
                        <div>
                            <h1><?= $headerTitle ?></h1>
                            <?php if(!is_null($headerSubtitle)){ ?>
                                <h5 style="font-family: 'montseratLight';">
                                    <?= $headerSubtitle ?>
                                </h5>
                            <?php } ?>
                        </div>
                    </header>
                <?php
        }
    }
?>

