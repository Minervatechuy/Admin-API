<?php
    require_once('securityFunctions.php');
?>
<!-- Main Sidebar Container -->
<aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Logo principal del sistema -->
    <a href="index.php" class="brand-link">
        <img src="<?php echo LOGOWHITEPATH; ?>" width="200px" style="display: block;
    margin-left: auto;
    margin-right: auto;">
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
        <!-- Sidebar user panel -->
        <div class="user-panel mt-3 pb-3 mb-3 d-flex">
            <!-- Foto de perfil del usuario -->
            <div class="image">
                <?php
                    if($_SESSION['foto_perfil'] != null) {
                    echo'<img src="'.$_SESSION['foto_perfil'].'" class="img-circle elevation-2" alt="Imagen de usuario">';
                    } else {
                    echo'<img src="../dist/img/defaultUserPhoto.png" class="img-circle elevation-2" alt="Imagen usuario anónimo">';
                    }
                ?>
            </div>

            <!-- Nombre y apellidos con link a editar perfil -->
            <div class="info">
                <a href="dashboard.php" class="d-block">
                    <?php
                        echo $_SESSION["nombre"].' '.$_SESSION['apellidos'];
                    ?>
                </a>
            </div>
        </div>


        <!-- Sidebar Menu -->
        <nav class="mt-2">
            <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">

                <!-- Lista de calculadoras a las que tiene acceso el usuario -->
                <li class="nav-item menu-open" id="option_calculators">
                    <a href="#" class="nav-link active">
                        <i class="nav-icon fas fa-calculator"></i>
                        <p>
                            Simuladores
                            <i class="right fas fa-angle-left"></i>
                        </p>
                    </a>
                    <ul class="nav nav-treeview">
                        <?php
                            // Se muestran las calculadoras del usuario
                            $url = APIURL.'getCalcsInfo';
                            $data = '{"user": "'.$_SESSION["usuario"].'"}';

                            $result= apiQuery($data, $url)['result'];

                            $countCalculators = 0;
                            foreach ($result as $calculator) {
                                $countCalculators++;
                                echo '<form action="editCalc.php" method="POST">
                                <li class="nav-item">
                                    <button type="submit" class="nav-link" style="
                                            background: none;
                                            border: none;
                                            color: #a1adb9;
                                            text-align: left;
                                    ">
                                        <i class="far fa-circle nav-icon" style="text-align: left !important;"></i>
                                        <p>'.$calculator[0].'</p>
                                        <input hidden readonly value="'.$calculator[7].'" name="token">
                                    </button>
                                </li>
                            </form>';
                            }

                            // Se muestran las entidades a las que pertenece el usuario
                            $url = APIURL.'getUserEntities';
                            $data = '{"usuario": "'.$_SESSION["usuario"].'"}';

                            $result_entidad= apiQuery($data, $url)['result'];

                            $countEntidades = 0;
                            foreach ($result_entidad as $entidad) $countEntidades++;

                            // Si no hay calculadoras se oculta el objeto mediante JS.
                            if ($countCalculators==0 || $countEntidades==0) {
                                echo    '<script type="text/javascript">
                                            document.getElementById("option_calculators").style.display = "none";
                                            document.getElementById("option_actual_plan").style.display = "none";
                                            document.getElementById("option_stadistics").style.display = "none";
                                        </script>';
                            }else{
                                echo    '<script type="text/javascript">
                                            document.getElementById("option_calculators").style.display = "block";
                                            document.getElementById("option_actual_plan").style.display = "block";
                                            document.getElementById("option_stadistics").style.display = "block";
                                        </script>';
                            }
                        ?>
                    </ul>
                </li>

                <!-- Lista de entidades a las que tiene acceso el usuario -->
                <li class="nav-item menu-open" id="option_entidades">
                    <a href="#" class="nav-link active">
                        <i class="nav-icon fas fa-briefcase"></i>
                        <p>
                            Entidades
                            <i class="right fas fa-angle-left"></i>
                        </p>
                    </a>
                    
                    <ul class="nav nav-treeview">
                        <?php
                            // Se muestran las entidades a las que pertenece el usuario
                            $url = APIURL.'getUserEntities';
                            $data = '{"usuario": "'.$_SESSION["usuario"].'"}';

                            $result_entidad= apiQuery($data, $url)['result'];

                            $countEntidades = 0;
                            foreach ($result_entidad as $entidad) {
                                $countEntidades++;
                                echo '  <form action="editarEntidadEspecifica.php" method="POST">
                                            <li class="nav-item">
                                                <button type="submit" class="nav-link" style="
                                                        background: none;
                                                        border: none;
                                                        color: #a1adb9;
                                                        text-align: left;
                                                ">
                                                    <i class="far fa-circle nav-icon" style="text-align: left !important;"></i>
                                                    <p>'.$entidad[0].'</p>
                                                    <input hidden readonly value="'.$entidad[5].'" name="entidad_id">
                                                </button>
                                            </li>
                                        </form>';
                            }

                            

                            // Si no hay entidades se oculta el objeto mediante JS.
                            if ($countEntidades==0) {
                                echo    '<script type="text/javascript">
                                            document.getElementById("option_entidades").style.display = "none"; 
                                        </script>';
                            }else{
                                echo    '<script type="text/javascript">
                                            document.getElementById("option_entidades").style.display = "block"; 
                                        </script>';
                            }
                        ?>
                    </ul>
                </li>

                <!-- Link a registrar calculadoras -->
                <li class="nav-item" id="crear_calc">
                    <a href="registrarCalculadora.php" class="nav-link">
                        <i class="nav-icon fas fa-plus"></i>
                        <p>
                            Registrar simulador
                        </p>
                    </a>
                </li>
                <?php
                            // Se muestran las entidades a las que pertenece el usuario
                            $url = APIURL.'getUserEntities';
                            $data = '{"usuario": "'.$_SESSION["usuario"].'"}';

                            $result_entidad= apiQuery($data, $url)['result'];

                            $countEntidades = 0;
                            foreach ($result_entidad as $entidad) $countEntidades++;

                            // Si no hay entidades se oculta el objeto mediante JS.
                            if ($countEntidades==0) {
                                echo    '<script type="text/javascript">
                                            document.getElementById("crear_calc").style.display = "none"; 
                                        </script>';
                            }else{
                                echo    '<script type="text/javascript">
                                            document.getElementById("crear_calc").style.display = "block"; 
                                        </script>';
                            }
                        ?>
                <li class="nav-item" >
                    <a href="crearEntidad.php" class="nav-link" >
                        <i class="nav-icon fas fa-plus"></i>
                        <p>
                            Crear entidad
                        </p>
                    </a>
                </li>


                <!-- Item to see the current plans 
                <li class="nav-item" id="option_actual_plan">
                    <a href="plan.php" class="nav-link">
                        <i class="nav-icon fas fa-copy"></i>
                        <p>Mis productos</p>
                    </a>
                </li>
                -->

                <!-- Item to see the stadistics of the calculators 
                <li class="nav-item">
                    <a href="estadisticas.php" class="nav-link" id="option_stadistics">
                        <i class="nav-icon fas fa-chart-pie"></i>
                        <p>
                            Estadisticas
                        </p>
                    </a>
                </li>
                -->
                <!-- Item to acces to the editing profile page 
                <li class="nav-item">
                    <a href="profile.php" class="nav-link">
                        <i class="nav-icon fas fa-edit"></i>
                        <p>
                            Editar Perfil
                        </p>
                    </a>
                </li>
                -->
                

            </ul>
        </nav>
    </div>
</aside>