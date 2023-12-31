<?php
    session_start();
    require_once('../config/context.php');
    require_once('funcionesAuxiliares.php');
?>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registro</title>
    <link rel="icon" type="image/png" href="../favicon.ico" />
    <?php
    session_start();
    require_once('../config/context.php');
    require_once('funcionesAuxiliares.php');
    require_once('../config/publicImports.php');

    $registrado= 0;
    $registro_completado= 0;
    $contraseñas_iguales= 0;

    // Se inicia la sesion

    // Se comprueba si la sesion esta iniciada
    if(isset($_SESSION['email'])){
        header("Location: ".APPDASHBOARD);
    }
    else{
        // Se comprueba si los datos son correctos
        if( seteados(["password"])) /*alert("Entra")*/;
        if( seteados(["submit", "nombre", "email", "password", "repeat_password"])){
            $nombre = $_POST["nombre"];
            $email = $_POST["email"];
            $result= apiQuery('get_usuario', ["usuario"],[$usuario])['result'];
            
            // Si el usuario esta registrado 
            if (count($result)!=0) $registrado= 1;

            // Si no lo esta se recoge la informacion del form
            else {
                $password = $_POST["password"];
                $repeat_password = $_POST["repeat_password"];

                // Se comprueba si las dos contraseñas son iguales
                if ($password != $repeat_password)  $contraseñas_distintas= 1;

                else {
                    // Se obtiene la direccion ip del usuario
                    $dir_ip= "0.0.0.0";
                    // Se crea el JSON con los parametros de entrada y se hace la consulta a la API
                    //alert($nombre);
                    $data = '{"nombre": "'.$nombre.'", "email": "'.$email.'", "password": "'.$password.'", "repeat_password": "'.$repeat_password.'", "dir_ip": "'.$dir_ip.'", "imagen": ""}';
                    $url = APIURL.'insert_usuario';
                    $result= apiQueryBase($data, $url)['result'];
                    if ($result){ $registro_completado=1; }
                }
            }
        }
    }
    ?>

    <!-- Alertas por errores del formulario -->
    <?php 
        if ($contraseñas_distintas==1) mensaje("warning", "Las contraseñas son distintas por favor, inténtelo de nuevo.");
        if ($registrado==1) mensaje("warning", "Usuario ya registrado, pruebe con otro correo electrónico.");
        if ($registro_completado==1) {
            mensaje("success", "Registro completado");
            header("Location: ".APPPATH);
        }
        else mensaje("error", "Todos los campos son obligatorios");
        
    ?>
</head>

<body class="hold-transition register-page">
    <div class="register-box" style="width: 25em !important;">
        <div class="register-logo">
            <img src="<?php echo LOGOPATH;?>" width='300px'>
        </div>

        <div class="card" style="margin-top: 2em;">
            <div class="card-body register-card-body">
                <p class="login-box-msg">Completa los campos para registrarte</p>
                
                <!-- Formulario para el registro -->
                <form action="registro.php" method="post" enctype="multipart/form-data" onsubmit="verificarFormulario()">
                    <div class="input-group mb-3">
                        <input type="text" class="form-control" name="nombre" placeholder="Nombre completo" required />
                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-user"></span>
                            </div>
                        </div>
                    </div>
                    <div class="input-group mb-3">
                        <input type="email" class="form-control" name="email" placeholder="Email" required
                            pattern="[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$" />
                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-envelope"></span>
                            </div>
                        </div>
                    </div>
                    <div class="input-group mb-3">
                        <input type="password" class="form-control" name="password" id="password"
                            placeholder="Contraseña" required
                            pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}"
                            oninput="checkPasswordRequirements()" />
                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-lock"></span>
                            </div>
                        </div>
                    </div>
                    <div class="input-group mb-3">
                        <input type="password" class="form-control" name="repeat_password"
                            placeholder="Repetir contraseña" required />
                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-lock"></span>
                            </div>
                        </div>
                    </div>
                    
                    <div id="password-requirements">
                        <p>Requisitos de Contraseña:</p>
                        <ul>
                            <li>Al menos 8 caracteres</li>
                            <li>Al menos una letra mayúscula y una minúscula</li>
                            <li>Al menos un número</li>
                            <!-- Agrega más requisitos según sea necesario -->
                        </ul>
                    </div>

                    <div class="row">
                        <div class="col-7">
                            <a href="login.php" class="text-center">Ya estoy registrado</a>
                        </div>
                        <div class="col-5">
                            <button type="submit" name="submit" class="btn btn-primary btn-block">Registrarse</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Script para efectos visuales y validaciones -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function checkPasswordRequirements() {
            const password = document.getElementById('password');
            const requirementsDiv = document.getElementById('password-requirements');

            const requirements = [
                /(?=.*\d)/.test(password.value),
                /(?=.*[a-z])/.test(password.value),
                /(?=.*[A-Z])/.test(password.value),
                /.{8,}/.test(password.value),
            ];

            // Actualiza el estilo del div según se cumplan los requisitos
            if (requirements.every(Boolean)) {
                requirementsDiv.style.color = 'green';
            } else {
                requirementsDiv.style.color = 'red';
            }
        }
    </script>
</body>
</html>