<?php
    // Si el usuario esta seteado se le manda al login

    session_start();
    require_once('../config/context.php');
    require_once('funcionesAuxiliares.php');
    

    if(isset($_SESSION["usuario"])){
        unset($_POST["submit"]);
        header("Location: ".APPDASHBOARD);
    }
    else{
        // Se comprueba si tiene todos los datos correctos y se procesa
		if(isset($_POST["submit"]) && isset($_POST["email"]) && isset($_POST["pwd"])) {
            
            // Se recogen los datos del formulario
            $usuario= $_POST["email"];
            $pwd= $_POST["pwd"];

            // Se consulta a la api si el usuario existe 
            $result= apiQuery('exist_usuario', ["usuario", "pwd"],[$usuario, $pwd])['result'];
            
            // Result == 1 ==> existe usuario
            // Result == 0 ==> no existe usuario

            // Se guardan los datos en la sesión
            if ($result){
                $result= apiQuery('get_usuario', ["usuario"],[$_POST["email"]])['result'];
                $_SESSION["usuario"]= $_POST["email"];
                $_SESSION["telefono"]= $result[0];
                $_SESSION["nombre"]= $result[1];
                $_SESSION["apellidos"]= $result[2];
                if($result[3]!=null) {
                    $_SESSION["profile_photo"] = "data:image;base64,".$result[3];
                } else {
                    $_SESSION["profile_photo"] = null;
                }
				
                header("Location: ".APPDASHBOARD);
            } 
            else $validate = 1;                    
        } 
        else $validate = 2;
    }
    $email= $_POST["email"];
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo APPNAME; ?> | Iniciar sesión</title>
    

    <?php 
        // Si el correo es incorrecto entra
        require_once('../config/publicImports.php');
        if ($validate == 1) echo mensaje('error', 'Las credenciales son incorrectas por favor intentelo de nuevo.');
	?>

</head>

<body class="hold-transition login-page" onload="bloquearReenvioFormulario();">

    <div class="login-box">
        <div class="login-logo">
            <!-- Imprime el logo desde context -->
            <img src="<?php echo LOGOPATH ?>" style="max-width:300px;" alt="Logo APP" />
        </div>
        <div class="card" style="margin-top: 2em;">
            <div class="card-body login-card-body">
                <p class="login-box-msg">Ingrese usufario y contraseña</p>

                <!-- Formulario Login -->
                <form action="login.php" method="post">
                    <div class="input-group mb-3">
                        <input type="email" name="email" class="form-control" placeholder="Email"
                            value="<?php echo $email?>" required />
                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-envelope"></span>
                            </div>
                        </div>
                    </div>
                    <div class="input-group mb-3">
                        <input type="password" name="pwd" class="form-control" placeholder="Contraseña" required />
                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-lock"></span>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-8">
                            <p class="mb-0">
                                <a href="registro.php" class="text-center">Registrarse</a>
                            </p>
                        </div>
                        <div class="col-4">
                            <button type="submit" name="submit" class="btn btn-primary btn-block"
                                value="submit">Acceder</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>

</html>