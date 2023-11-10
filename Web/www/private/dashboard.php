<?php
    require_once('securityFunctions.php');
?>
<!DOCTYPE html>
<html lang="es">

<head>
    <?php
        require_once('auxiliarfunctions.php');
        require_once('import.html');
        require_once('preloader.php');
        require_once('navbar.php');
        require_once('menu.php');
        require_once('../config/context.php');
    ?>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard</title>


</head>

<body class="hold-transition sidebar-mini layout-fixed">
    <div class="wrapper">
        <div class="content-wrapper">
            <div class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2">
                        <div class="col-sm-6">
                            <h1 class="m-0">Dashboard</h1>
                        </div>
                    </div>
                </div>
            </div>
            <section class="content">
                <div>
                    <div class="container-fluid">
                        <!-- Div para mostrar la informacion general -->
                        <div class="row">
                            <div class="col-lg-3 col-6">
                                <!-- small box -->
                                <div class="small-box bg-info">
                                    <div class="inner">
                                        <h3>
                                            <?php
                                                // Variable que viene de menu.php, cuenta el numero de calculadoras que hay en el drop down del menu
                                                echo $countCalculators++;
                                            ?>
                                        </h3>
                                        <p>Mis simuladores</p>
                                    </div>
                                    <div class="icon">
                                        <i class="ion ion-calculator"></i>
                                    </div>

                                </div>
                            </div>
                            <!-- ./col -->
                            <div class="col-lg-3 col-6">
                                <!-- small box -->
                                <div class="small-box bg-success">
                                    <div class="inner">
                                        <h3>
                                            <?php
                                                // Se cuentan el numero de clientes de todas las calculadoras
                                                $result= apiQueryPro('getUserEntities', ['usuario'], [$_SESSION["usuario"]])['result'];
                                                echo count($result);
                                            ?>
                                        </h3>
                                        <p>Mis entidades</p>
                                    </div>
                                    <div class="icon">
                                        <i class="ion ion-stats-bars"></i>
                                    </div>

                                </div>
                            </div>
                            
                            
                            <div class="col-lg-3 col-6">
                                <a href="descarga.php">
                                    <!-- small box -->
                                    <div class="small-box bg-warning">
                                        <div class="inner">
                                            <h3>
                                                <i class="fas fa-cloud-download-alt"></i>
                                            </h3>
                                            <p>Descargar plugin WordPress</p>
                                        </div>
                                        <div class="icon">
                                            <i class="fas fa-cog"></i>
                                        </div>

                                    </div>
                                </a>
                            </div>
                        </div>

                        <!-- Div para mostrar los ultimos presupuestos -->
                        <div>
                            <div class="card card-secondary" id="ultimos_presupuestos">
                                <div class="card-header">
                                    <h3 class="card-title">Ultimos Presupuestos</h3>
                                </div>

                                <div class="card-body">
                                    <table class="table table-bordered">
                                        <thead>
                                            <tr>
                                                <th>Simulador</th>
                                                <th>Fecha</th>
                                                <th>Email Cliente</th>
                                                <th>Telefono</th>
                                                <th>Nombre</th>
                                                <th>Resultado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                                $result_presupuestos_info= apiQueryPro('get_presupuestos_email', ['email'], [$_SESSION["usuario"]])['result'];

                                                $pos= 0;
                                                foreach ($result_presupuestos_info as $presupuesto) {
                                                    $pos++;
                                                    if ($presupuesto[6]==NULL) $presupuesto[6]= "Sin finalizar";
                                                    echo '
                                                    <tr>
                                                        <td>'.$presupuesto[0].'</td>
                                                        <td>'.$presupuesto[1].'</td>
                                                        <td>'.$presupuesto[2].'</td>
                                                        <td>'.$presupuesto[3].'</td>
                                                        <td>'.$presupuesto[4].'</td>
                                                        <td>'.$presupuesto[6].'</td>
                                                    </tr>';
                                                }
                                            ?>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <?php
                                if ($pos==0) {
                                    echo '  <script type="text/javascript">
                                                document.getElementById("ultimos_presupuestos").style.display = "none";
                                            </script>';
                                    }else{
                                    echo '<script type="text/javascript">
                                                document.getElementById("ultimos_presupuestos").style.display = "block";
                                    </script>';
                                    }
                            ?>
                        </div>
            </section>
        </div>
    </div>
</body>

</html>