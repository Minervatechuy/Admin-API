<?php
    $url= APIURL.'getOpciones';
    $identificador= $_POST["etapa_id"];
    $data= '{"identificador": '.$identificador.'}';
    $result_stage_info= apiQuery($data, $url)['result'];

    if (count($result_stage_info) > 0){
        echo '
        <div class="card card-row card-secondary">
            <div class="card-header">
                <h3 class="card-title">
                    Editar Opciones
                </h3>
            </div>
            <div class="card-body">
                <div class="container">
                    <div class="box">
                        <div class="card_stage card-body">
        ';
        foreach ($result_stage_info as $opcion) {
            echo            '<div class="card card-primary card-outline">
                                <div class="card-header">
                                    <h5 class="card-title">'.$opcion[0][3].'</h5>
                                    <form action="editarOpcion.php" method="POST">
                                        <div class="card-tools" style="">
                                            <div class="btn btn-tool btn-link" style="position: absolute; right: 6em; top: 1.5em;">
                                                #'.$opcion[0][0].'
                                            </div>
                                            <input type="hidden" value="'.$opcion[0][0].'" name="opcion_id"/>
                                            <button type="submit" class="btn btn-tool" style="position: absolute; right: 4em; top: 1.5em;">
                                                <i class="fas fa-pen"></i>
                                            </button>
                                        </div>
                                    </form>

                                    <form action= "eliminarOpcion.php" method="POST">
                                        <input type="hidden" value="'.$opcion[0][0].'" name="opcion_id"/>
                                        <input type="hidden" value="'.$_POST["etapa_id"].'" name="etapa_id"/>
                                        <button type="submit" class="btn btn-tool" style="position: absolute; right: 1em; top: 1.5em;">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </form>

                                </div>
                            </div>';
            }
        echo '          </div>
                    </div>
                </div>
            </div>
        </div>
        ';
    }
?>

