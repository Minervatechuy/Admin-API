<?php
    require_once('securityFunctions.php');
?>
<div class="wrapper">

    <!-- Preloader -->
    <nav class="main-header navbar navbar-expand navbar-white navbar-light" >
        <!-- Left navbar links
        <ul class="navbar-nav">

            Item to go to the dashboard 
            <li class="nav-item d-none d-sm-inline-block" style="margin-left: 1.5em;">
                <a href="dashboard.php" class="nav-link">
                    Dashboard
                </a>
            </li>

            Item for logout 
            <li class="nav-item d-none d-sm-inline-block">
                <a href="#" id="logout" class="nav-link">
                    Calculadoras
                </a>
            </li>

            Item for logout 
            <li class="nav-item d-none d-sm-inline-block">
                <a href="#" id="logout" class="nav-link">
                    Entidades
                </a>
            </li>

            Item for logout 
            <li class="nav-item d-none d-sm-inline-block">
                <a href="#" id="logout" class="nav-link">
                    Presupuestos
                </a>
            </li>

        </ul>
        -->
        <!-- Right navbar links -->
        <ul class="navbar-nav ml-auto">
            <!-- Item to do page full screen -->
            <li class="nav-item">
                <a class="nav-link" role="button" href="logout.php">
                    <i class="fas fa-sign-out-alt"></i>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" data-widget="fullscreen" role="button">
                    <i class="fas fa-expand-arrows-alt"></i>
                </a>
            </li>
        </ul>
    </nav>
</div>