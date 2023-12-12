
from flask import Flask, jsonify, render_template, request, json
from flask_cors import CORS  # Para que se permita la política CORS
from datetime import datetime
import smtplib, ssl, model.functionsDB as functionsDB
from utils import *
from mails import send_mail
from cryptography.fernet import Fernet
import base64


app = Flask(__name__, template_folder="./templates", static_folder='./static')
CORS(app, resources={r"/*": {"origins": "https://www.cloud.minervatech.uy", "supports_credentials": True}})

# Add the route for handling preflight requests
@app.route('/', methods=['OPTIONS'])
def handle_preflight():
    response = jsonify()
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    return response


# USUARIO 
# --------------------------------------------------------------------------
# Verifica que el user existe en la base de datos


@app.route('/stripe_webhook', methods=['POST'])
def stripe_webhook():
    info = json.loads(request.data)
    event = info['type']
    datos_de_pago = info['data']['object']
    
    if event == 'checkout.session.completed':
        try:
            requestId = info['id']
            timestamp = datos_de_pago['created']
            amount = datos_de_pago['amount_total']/100
            nombre = datos_de_pago['customer_details']['name']
            email = datos_de_pago['customer_details']['email']
            new_token = functionsDB.doStoredProcedure("comprar_token", [])[0][0][0]
            send_mail(f"Gracias {nombre}!<br/>Compra correcta. A continuación el token de activación:<br/><br/><b><i>{new_token}</i></b><br/><br/>"
          f"Equipo MinervaTech<br/>"
          f"Para cualquier consulta, no dudes en ponerte en contacto con nuestro equipo de soporte:<br/>"
          f"Soporte técnico: soporte@minervatech.uy<br/>"
          f"WhatsApp: +59895738995", "Licencia Simulador", email)
        except Exception as e:
            log(e)

    if event == 'invoice.finalized':
        log(f"{info}") 

    if event == 'invoice.paid':
        log(f"{info}") 

    return "200"

@app.route('/insert_logs', methods=['POST'])
def insert_logs():
    try:
        data = json.loads(request.data)
        date = datetime.now().strftime('%Y-%m-%d')
        time = datetime.now().strftime('%H:%M:%S')
        procedure = data.get('procedure')
        presupuesto_id = data.get('presupuesto_id')
        log_in = data.get('in')
        log_out = data.get('out')

        functionsDB.doStoredProcedure("insert_log", [date, time, procedure, presupuesto_id, log_in, log_out])
        
        return "200"
    except Exception as e:
        log(e)

@app.route('/exist_usuario', methods=['POST'], endpoint='exist_usuario')
def exist_usuario():
    # Se recogen los datos recibidos mediante JSON
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el datos del campo user y contraseña
    usuario = info['usuario']
    pwd = info['pwd']

    arg_pass = [usuario]
    password = functionsDB.doStoredProcedure("get_usuario_pass", arg_pass)[0][0]
   
    hashed_password = decrypt(password[0])

    # Se monta el array de entradas
    args = [usuario, hashed_password]

    # Se ejecuta el procedimiento almacenado accediendo ademas a su resultado
    result = 1 if hashed_password == pwd else 0

    # Se realizan los logs 
    writeLog('exist_usuario', args, hashed_password, url_context, usuario_context, debug_context)

    # Se devuelve el resultado en formato JSON
    return jsonify({'result': result}) 


# --------------------------------------------------------------------------
# Busca y devuelve la imagen de perfil del user

@app.route('/get_usuario', methods=['POST'], endpoint='get_usuario')
def get_usuario():
    
    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    # Se toma el usuario del json anterior de cara a la búsqueda
    usuario = info["usuario"]

    # Se crea la lista de entrada
    args= [usuario]

    # Se ejecuta el procedimiento almacenado
    try:
        result= functionsDB.doStoredProcedure("get_usuario", args)[0][0]
    except Exception as e:
        log(f"{e}")
        result= []
    
    # Se devuelve el resultado a la vista
    return jsonify({'result': result})


# --------------------------------------------------------------------------
# Busca y devuelve el número de calculadoras disponibles

@app.route('/getCalcsOfUser', methods=['POST'], endpoint='getCalcsOfUser')
def getNumCalcsOfUser():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    user = info['user']

    # Parámetros para el procedimiento, IN OUT OUT
    args = [user, 0]

    # Llamada al procedimiento para obtener las calculadoras del cliente
    # Como se devuelve una lista con una lista de tuplas, se toma el primer elemento de ambas listas y tupla
    result = functionsDB.doStoredProcedure("getCalcsOfUser", args)[0][0][0]
    
    if result != None:
        # Se separa la cadena que llega desde la base de datos
        calcs = result.split(',')
    else:
        calcs = []
    # Registro en el log del movimiento
    writeLog('getCalcsOfUser', args, calcs, url_context, usuario_context, debug_context)

    # Se devuelv el resultado a la vista
    return jsonify({'result': calcs})


# --------------------------------------------------------------------------
# Busca y devuelve el número de consultas en todas las calculadoras del user

@app.route('/getQueriesCount', methods=['POST'], endpoint='getQueriesCount')
def getQueriesCount():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    user = info['user']

    # Parámetros para el procedimiento, IN OUT OUT
    args = [user, 0]

    # Llamada al procedimiento para obtener las consultas en las calculadoras del cliente
    # Como se devuelve una lista con una lista de tuplas, se toma el primer elemento de ambas listas y tupla
    result = functionsDB.doStoredProcedure("getQueriesCount", args)[0][0][0]

    # Registro en el log del movimiento
    writeLog('getQueriesCount', args, result, url_context, usuario_context, debug_context)

    # Se devuelv el resultado a la vista
    return jsonify({'result': result})


# --------------------------------------------------------------------------
# Busca y devuelve el número de clientes en todas las calculadoras del user

@app.route('/getClientsCount', methods=['POST'], endpoint='getClientsCount')
def getClientsCount():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    user = info['user']

    # Parámetros para el procedimiento, IN OUT OUT
    args = [user, 0]

    # Llamada al procedimiento para obtener las consultas en las calculadoras del cliente
    # Como se devuelve una lista con una lista de tuplas, se toma el primer elemento de ambas listas y tupla
    result = functionsDB.doStoredProcedure("getClientsCount", args)[0][0][0]

    # Registro en el log del movimiento
    writeLog('getClientsCount', args, result, url_context, usuario_context, debug_context)

    # Se devuelv el resultado a la vista
    return jsonify({'result': result})


# --------------------------------------------------------------------------
# Busca y devuelve el número de users asociados a las calculadoras del cliente

@app.route('/getTeamMates', methods=['POST'], endpoint='getTeamMates')
def getTeamMates():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    user = info['user']

    # Parámetros para el procedimiento, IN OUT OUT
    args = [user, 0]

    # Llamada al procedimiento para obtener las consultas en las calculadoras del cliente
    # Como se devuelve una lista con una lista de tuplas, se toma el primer elemento de ambas listas y tupla
    result = functionsDB.doStoredProcedure("getTeamMates", args)[0][0][0]

    # Registro en el log del movimiento
    writeLog('getTeamMates', args, result, url_context, usuario_context, debug_context)

    # Se devuelv el resultado a la vista
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Busca y devuelve el número de users asociados a las calculadoras del cliente

@app.route('/getUserEntities', methods=['POST'], endpoint='getUserEntities')
def getUserEntities():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    user = info['usuario']

    # Parámetros para el procedimiento, IN 
    args = [user]
      
    # Llamada al procedimiento para obtener las calculadoras del cliente
    # Como se devuelve una lista con una lista de tuplas, se toma el primer elemento de ambas listas y tupla
    result = functionsDB.doStoredProcedure("getUserEntities", args)[0]

    # Se separa la cadena que llega desde la base de datos
    #calcs = result.split(',')

    # Registro en el log del movimiento
    writeLog('getUserEntities', args, result, url_context, usuario_context, debug_context)

    # Se devuelv el resultado a la vista
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Crea una calculadora actualizando todas las tablas necesarias para ello
@app.route('/createCalculator', methods=['POST'], endpoint='createCalculator')
def createCalculator():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    token = info['token']
    url = info["url"]

    ip = info['ip']
    entidad = info['entidad']
    nombre = info['nombre']
    email = info['email']

    # Parámetros para el procedimientno, IN 
    args = [token]
    result = functionsDB.doStoredProcedure("token_disponible", args)[0][0][0]
    n_dominio = functionsDB.doStoredProcedure("n_dominio_cal", [url])[0][0][0]
    writeLog('token_disponible', args, result, url_context, usuario_context, debug_context)
    writeLog('n_dominio', url, n_dominio, url_context, usuario_context, debug_context)
    if result!=1:
        return jsonify({'tipo': "error", "mensaje":"Token inválido"}) 
    elif n_dominio!=0:
        return jsonify({'tipo': "error", "mensaje":"Ya existe un simulador para esa pagina, por favor intentelo con otra direcci"}) 
    else:
        args = [token, url, ip, entidad, nombre, email]
        # Llamada al procedimiento para obtener las calculadoras del cliente
        # Como se devuelve una lista con una lista de tuplas, se toma el primer elemento de ambas listas y tupla
        result = functionsDB.doStoredProcedure("createCalculator", args)[0][0][0]

        # Registro en el log del movimieto
        writeLog('createCalculator', args, result, url_context, usuario_context, debug_context)

        # Se devuelv el resultado a la vista
        return jsonify({'tipo': "success", "mensaje":"Simulador creado"}) 


# ---------------------------------------------------------------------------------
# Comprueba si el email de un user ya existe
@app.route('/existEmail', methods=['POST'], endpoint='existEmail')
def existEmail():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    args = [info['email']]

    result = functionsDB.doStoredProcedure("existEmail", args)[0][0][0]
    if result == 1:
        # Registro en el log del movimieto
        writeLog('existEmail', args, 'user ya registrado', url_context, usuario_context, debug_context)
        return jsonify({'result': True})


    # Se devuelv el resultado a la vista
    #return jsonify({'result': 'Correcto'})
    writeLog('existEmail', args, 'user no registrado', url_context, usuario_context, debug_context)
    return jsonify({'result': False})
    

# ---------------------------------------------------------------------------------
# Registra un user en la base de datos
@app.route('/insert_usuario', methods=['POST'], endpoint='insert_usuario')
def insert_usuario():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)
    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    args=[info["email"]]
    c= functionsDB.doStoredProcedure('existEmail', args)[0][0][0]
    if (c!=0): 
        writeLog('insert_usuario', args, "USUARIO NO LOGGEADO", url_context, usuario_context, debug_context)
        return jsonify({'result': False})


    # Se recoge el dato del nombre 
    nombreCompleto= info["nombre"]

    # Se le aplica un proceso al nombre para dividirlo en nombre y apellidos
    nombreCompleto= nombreCompleto.split(' ')
    apellidos= ''

    if len(nombreCompleto)>=1:
        nombre= nombreCompleto[0]
        if len(nombreCompleto)>=2:
            apellidos= nombreCompleto[1]
            if len(nombreCompleto)==3:
                apellidos= apellidos +' '+nombreCompleto[2]
    if len(apellidos)==0: apellidos=''

    # Se recogen los datos del email, la contraseña, la direccion IP del cliente, la 
    # fecha actual y la imagen para la foto de perfil
    email= info["email"]
    password= info["password"]
    ip= info["dir_ip"]
    now= now = datetime.now()
    imagen= info["imagen"]

    hashed_password = encrypt(password)

    # Se crea la lista de argumentos
    args= [email, hashed_password, nombre, now, ip, apellidos, imagen]
    
    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("insert_usuario", args)

    # Se escriben los logs
    writeLog('insert_usuario', args, "PROCESS PASSED", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})


@app.route('/getCalcsInfo', methods=['POST'], endpoint='getCalcsInfo')
def getCalcsInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    user = info["user"]

    # Se crea la lista de entrada
    args= [user]

    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getCalcsInfo", args)[0]
    
    # Registro en el log del movimiento
    writeLog('getCalcsInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelv el resultado a la vista
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Edita un user en la base de datos
@app.route('/editProfile', methods=['POST'], endpoint='editProfile')
def editProfile():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del nombre 
    nombreCompleto= info["nombre_completo"]

    # Se le aplica un proceso al nombre para dividirlo en nombre y apellidos
    nombreCompleto= nombreCompleto.split(' ')
    apellidos= ''

    if len(nombreCompleto)>=1:
        nombre= nombreCompleto[0]
        if len(nombreCompleto)>=2:
            apellidos= nombreCompleto[1]
            if len(nombreCompleto)==3:
                apellidos= apellidos +' '+nombreCompleto[2]
    if len(apellidos)==0: apellidos=''

    # Se recogen los datos del email, la contraseña, la direccion IP del cliente, la 
    # fecha actual y la imagen para la foto de perfil
    email= info["user"]
    password= info["contrasena"]
    #imagen= info["imagen"]
    telefono= info["telefono"]

    hashed_password = encrypt(password)

    # Se crea la lista de argumentos
    args= [email, hashed_password, nombre, telefono, apellidos]
    
    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("editProfile", args)

    # Se escriben los logs
    writeLog('editProfile', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Busca en la base de datos la informacion de las etapas de la calculadora
@app.route('/getStagesGeneralInfo', methods=['POST'], endpoint='getStagesGeneralInfo')
def getStagesGeneralInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del nombre 
    token= info["token"]

    # Se crea la lista de argumentos
    args= [token]
    
    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getStagesGeneralInfo", args)[0]

    # Se escriben los logs
    writeLog('getStagesGeneralInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Se edita la posicion de una etapa dada una id
@app.route('/editStagePos', methods=['POST'], endpoint='editStagePos')
def editStagePos():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del del id y de la posicion
    stage_id= info["stage_id"]
    pos= info["pos"]

    # Se crea la lista de argumentos
    args= [stage_id, pos]
    
    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("editStagePos", args)

    # Se escriben los logs
    writeLog('editStagePos', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Busca en la base de datos el tipo del id de la etapa pasada por parametro
@app.route('/getStageType', methods=['POST'], endpoint='getStageType')
def getStageType():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del del id
    identificador= info["identificador"]

    # Se crea la lista de argumentos
    args= [identificador]
    
    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getStageType", args)[0][0][0]

    # Se escriben los logs
    writeLog('getStageType', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Trae la informacion de la etapa discreta mediante su id
@app.route('/getDiscreteStageInfo', methods=['POST'], endpoint='getDiscreteStageInfo')
def getDiscreteStageInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del del id
    identificador= info["identificador"]

    # Se crea la lista de argumentos
    args= [identificador]
    
    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getDiscreteStageInfo", args)[0][0]
    rangos_json= result[6]

    # Se escriben los logs
    writeLog('getDiscreteStageInfo', "Rangos", rangos_json, url_context, usuario_context, debug_context)
    writeLog('getDiscreteStageInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Trae la informacion de la etapa geografica mediante su id
@app.route('/getGeographicStageInfo', methods=['POST'], endpoint='getGeographicStageInfo')
def getGeographicStageInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del del id
    identificador= info["identifier"]

    # Se crea la lista de argumentos
    args= [identificador]
    
    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getGeographicStageInfo", args)[0][0]

    # Se escriben los logs
    writeLog('getGeographicStageInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Trae la informacion de la etapa continua mediante su id
@app.route('/getCountinousStageInfo', methods=['POST'], endpoint='getCountinousStageInfo')
def getCountinousStageInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del del id
    identificador= info["identificador"]

    # Se crea la lista de argumentos
    args= [identificador]
    
    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getCountinousStageInfo", args)[0][0]


    # Se escriben los logs
    writeLog('getCountinousStageInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Trae la informacion de la etapa cualificada mediante su id
@app.route('/getCualifiedStageInfo', methods=['POST'], endpoint='getCualifiedStageInfo')
def getCualifiedStageInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se recoge el dato del del id
    identificador= info["identifier"]

    # Se crea la lista de argumentos
    args= [identificador]
    
    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getCualifiedStageInfo", args)[0][0]

    # Se escriben los logs
    writeLog('getCualifiedStageInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la etapa discreta con la informacion mandada por parametro
@app.route('/updateDiscrete', methods=['POST'], endpoint='updateDiscrete')
def updateDiscrete():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    identifier= info["identifier"]
    title = info["title"]
    features='{"features": "0"}'
    minumum= info["minimum"]
    maximum= info["maximum"]
    valor_inicial= info["value"]
    ranges= info["ranges"]
    ranges= ranges.split(',')
    json_ranges= "{"
    i=0
    for r in ranges:
        nombre_rango= "rango"+str(i)
        json_ranges= json_ranges + "\"" + nombre_rango + "\" : \"" + r + "\", "
        i=i+1
    
    json_ranges= json_ranges[:-2]
    json_ranges= json_ranges+ "}"
    
    args= [identifier, title, valor_inicial, minumum, maximum, json_ranges, features]

    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("updateDiscrete", args)

    # Se escriben los logs
    writeLog('updateDiscrete', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Actualiza la etapa geografica con la informacion mandada por parametro
@app.route('/updateCountinous', methods=['POST'], endpoint='updateCountinous')
def updateCountinous():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    identifier= info["identifier"]
    title = info["title"]
    features='{"features": "0"}'
    minumum= info["minimum"]
    maximum= info["maximum"]
    valor_inicial= info["value"]
    
    args= [identifier, title, valor_inicial, minumum, maximum, features]

    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("updateCountinous", args)

    # Se escriben los logs
    writeLog('updateCountinous', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Actualiza la etapa cualificada con la informacion mandada por parametro
@app.route('/updateCualified', methods=['POST'], endpoint='updateCualified')
def updateCualified():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    identifier= info["identifier"]
    title = info["title"]
    features='{"features": "0"}'
    valor_inicial= info["value"]
    
    args= [identifier, title, valor_inicial, features]

    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("updateCualified", args)

    # Se escriben los logs
    writeLog('updateCualified', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})


# ---------------------------------------------------------------------------------
# Actualiza la etapa geografica con la informacion mandada por parametro
@app.route('/updateGeographic', methods=['POST'], endpoint='updateGeographic')
def updateGeographic():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el user del json anterior de cara a la búsqueda
    identifier= info["identifier"]
    title = info["title"]
    direction = info["direction"]
    latitude = info["latitude"]
    longitude = info["longitude"]
    zoom= info["zoom"]
    features='{"features": "0"}'
    
    args= [identifier, title, direction, latitude, longitude, zoom, features]

    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("updateGeographic", args)

    # Se escriben los logs
    writeLog('updateGeographic', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})


@app.route('/getSpecificCalculatorInfo', methods=['POST'], endpoint='getSpecificCalculatorInfo')
def getSpecificCalculatorInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token del json anterior de cara a la búsqueda
    token = info["token"]

    # Se crea la lista de entrada
    args= [token]

    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getSpecificCalculatorInfo", args)[0][0]
    
    # Registro en el log del movimiento
    writeLog('getSpecificCalculatorInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/updateFormula', methods=['POST'], endpoint='updateFormula')
def updateFormula():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    token= info["token"]
    formula = info["formula"]
    
    args= [token, formula]

    # Se ejecuta el procedimiento almacenado
    functionsDB.doStoredProcedure("updateFormula", args)

    # Se escriben los logs
    writeLog('updateFormula', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})


@app.route('/createStage', methods=['POST'], endpoint='createStage')
def createStage():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

        
    # Convierto las claves del JSON en una lista
    keys_arr = list()
    for i in info.keys():
        keys_arr.append(i)
    

    
    # Se toma el user del json anterior de cara a la búsqueda
    usuario= info[keys_arr[0]]
    token= info[keys_arr[1]]
    tipo= info[keys_arr[2]]
    titulo= info[keys_arr[3]]
    subtitulo= info[keys_arr[4]]
    
    args= [token, tipo, titulo, subtitulo]
    etapa_id =functionsDB.doStoredProcedure("insert_etapa", args)[0][0][0]

    
    # CREAR LA ETAPA Y GUARDAR ID-ETAPA

    for k in range (5,len(info)):
        clave= keys_arr[k]
        valor= info[keys_arr[k]]
        args= [etapa_id, clave, valor]
        # PARA CADA KEY, INSERTAR SU ATRIBUTO ( id-AI, etapa_id, meta_key, mneta_value ))
        writeLog('createDataStage', args, "OK", url_context, usuario_context, debug_context)
        functionsDB.doStoredProcedure("insert_etapa_data", args) #- ( ID-ETAPA, keys_arr[k] info[keys_arr[k]] )

    writeLog('createStage', info, etapa_id, url_context, usuario_context, debug_context)

    return jsonify({'result':True, 'id_etapa': etapa_id})
    

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/getCalcFormula', methods=['POST'], endpoint='getCalcFormula')
def getCalcFormula():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    token= info["token"]
    
    args= [token]

    try:
        # Se ejecuta el procedimiento almacenado
        result= functionsDB.doStoredProcedure("getCalcFormula", args)[0][0][0]
    except:
        result=None
    # Se escriben los logs
    writeLog('getCalcFormula', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})


# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/getStageGeneralInfo', methods=['POST'], endpoint='getStageGeneralInfo')
def getStageGeneralInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    identificador= info["identificador"]
    
    args= [identificador]

    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getStageGeneralInfo", args)[0][0]

    # Se escriben los logs
    writeLog('getStageGeneralInfo', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/getStageInfo', methods=['POST'], endpoint='getStageInfo')
def getStageInfo():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    identificador = info["identificador"]
    
    args = [identificador]

    # Se ejecuta el procedimiento almacenado
    result = functionsDB.doStoredProcedure("getStageInfo", args)[0]

    # Se escriben los logs
    writeLog('getStageInfo', args, result, url_context, usuario_context, debug_context)

    # Obtener información específica de la etapa
    stage_specific_info = functionsDB.doStoredProcedure("getStageInfo", args)[0]

    # Mapear las claves meta a nombres de variables
    meta_key_mapping = {
        'maximo': 'maximo',
        'minimo': 'minimo',
        'valor_inicial': 'valor_inicial',
        'rangos': 'rangos'
    }

    # Inicializar un diccionario para almacenar los valores
    meta_values = {}

    # Iterar sobre las filas de stage_specific_info y mapear las claves meta a nombres de variables
    for row in stage_specific_info:
        meta_key = row[2]
        if meta_key in meta_key_mapping:
            variable_name = meta_key_mapping[meta_key]
            meta_values[variable_name] = row[3]

    # Devolver el resultado y los valores específicos
    return jsonify({
        'result': result,
        **meta_values
    })

@app.route('/editEtapa', methods=['POST'], endpoint='editEtapa')
def editEtapa():
    #try:
        # Se trae la información que viene de la vista en json
        info = json.loads(request.data)

        try:
            usuario_context = info['usuario_context']
            url_context = info['url_context']
            debug_context = info['debug_context']
        except:
            usuario_context = "[Sin informacion]"
            url_context = "[Sin informacion]"
            debug_context = "[Sin informacion]"

        
        # Convierto las claves del JSON en una lista
        keys_arr = list()
        for i in info.keys():
            keys_arr.append(i)
        

        
        # Se toma el user del json anterior de cara a la búsqueda
        usuario= info[keys_arr[0]]
        etapa_id= info[keys_arr[1]]
        titulo= info[keys_arr[2]]
        subtitulo= info[keys_arr[3]]
        
        writeLog('editEtapa', info, "OK", url_context, usuario_context, debug_context)
        
        # Se guarda la informacion en etapas
        args= [etapa_id, titulo, subtitulo]
        functionsDB.doStoredProcedure("edit_etapa", args)
        writeLog('editEtapa', etapa_id, "OK", url_context, usuario_context, debug_context)

        # Se guardan los datos de las etapas
        for clave, valor in info.items():
            if clave not in ['usuario_context', 'url_context', 'debug_context', 'usuario', 'etapa_id', 'titulo', 'subtitulo']:
                args = [etapa_id, clave, valor]
                writeLog('editEtapaData', args, "OK", url_context, usuario_context, debug_context)
                functionsDB.doStoredProcedure("edit_etapa_data", args)

        return jsonify({'result':True})
    
    #except:
     #   return jsonify({'result':False})

@app.route('/insertOpcion', methods=['POST'], endpoint='insertOpcion')
def insertOpcion():
    #try:
        # Se trae la información que viene de la vista en json
        info = json.loads(request.data)

        # Se recoge la informacion de contexto
        try:
            usuario_context = info['usuario_context']
            url_context = info['url_context']
            debug_context = info['debug_context']
        except:
            usuario_context = "[Sin informacion]"
            url_context = "[Sin informacion]"
            debug_context = "[Sin informacion]"
        
        writeLog('insertOpcion', info, "OK", url_context, usuario_context, debug_context)

        # Convierto las claves del JSON en una lista
        keys_arr = list()
        for i in info.keys():
            keys_arr.append(i)
        
        # Se toma el user del json anterior de cara a la búsqueda
        usuario= info[keys_arr[0]]
        etapa_id= info[keys_arr[4]]
        
        
        # CREAR LA ETAPA Y GUARDAR ID-ETAPA

        for k in range (5,len(info)):
            clave= keys_arr[k]
            valor= info[keys_arr[k]]
            '''if clave == 'imagen':
                args = [etapa_id, clave, 'None', valor]
            else:
                args= [etapa_id, clave, valor, None]'''
            if clave == 'imagen' and valor!='':
                args = [etapa_id, clave, 'imagen', valor]
            else:
                args= [etapa_id, clave, valor, None]
               
            writeLog(f'insertOpcion{k}', args, "OK", url_context, usuario_context, debug_context)
            functionsDB.doStoredProcedure("insert_etapa_opcion", args) #- ( ID-ETAPA, keys_arr[k] info[keys_arr[k]] )
    
        return jsonify({'result':True, 'id_etapa': etapa_id})
    
    #except:
     #   return jsonify({'result':False})


# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/getOpciones', methods=['POST'], endpoint='getOpciones')
def getOpciones():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    identificador= info["identificador"]
    
    args= [identificador]

    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getOpciones", args)[0]

    # Agrupo las opciones
    # Split a Python List into Chunks using For Loops
    our_list = result
    result = list()
    chunk_size = 3
    for i in range(0, len(our_list), chunk_size):
        result.append(our_list[i:i+chunk_size])

    # Casteo para cambiar tuplas invariantes por listas modificables
    for i in range(0,len(result)):
        for j in range(0,len(result[i])):
            result[i][j] = list(result[i][j])

    for i in range(0,len(result)):
        for j in range(0,len(result[i])):
            if j == 2:
                result[i][j][4] = result[i][j][4].decode('utf-8')

    # Se devuelve el resultado
    return jsonify({'result': result})



@app.route('/editOpcion', methods=['POST'], endpoint='editOpcion')
def editOpcion():
    try:
        # Se trae la información que viene de la vista en json
        info = json.loads(request.data)

        # Se recoge la informacion de contexto
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
        
        # Convierto las claves del JSON en una lista
        keys_arr = list()
        for i in info.keys():
            keys_arr.append(i)
        
        # Se toma el user del json anterior de cara a la búsqueda
        usuario= info[keys_arr[0]]
        data_id= info[keys_arr[1]]
        
        
        # CREAR LA ETAPA Y GUARDAR ID-ETAPA

        for k in range (2,len(info)):
            clave= keys_arr[k]
            valor= info[clave]
            if clave == 'imagen' and valor!='':
                argsOpt = [data_id, clave, 'imagen', valor]
            else:
                argsOpt= [data_id, clave, valor, None]
            
            functionsDB.doStoredProcedure("edit_etapa_opcion", argsOpt) #- ( ID-ETAPA, keys_arr[k] info[keys_arr[k]] )'''
            writeLog("Se edita "+clave, argsOpt, "OK", url_context, usuario_context, debug_context)

        return jsonify({'result':True, 'id_etapa': data_id})
    
    except:
        return jsonify({'result':False})


# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/getOpcion', methods=['POST'], endpoint='getOpcion')
def getOpcion():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    identificador= info["identificador"]
    
    args= [identificador]

    # Se ejecuta el procedimiento almacenado
    result= functionsDB.doStoredProcedure("getOpcion", args)[0]


    # Casteo para cambiar tuplas invariantes por listas modificables
    for i in range(0,len(result)):
        result[i] = list(result[i])

    for i in range(0,len(result)):
        if i == 2:
            result[i][4] = result[i][4].decode('utf-8')

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/deleteCalc', methods=['POST'], endpoint='deleteCalc')
def deleteCalc():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    token= info["token"]
    
    args= [token]

    listaEtapas= functionsDB.doStoredProcedure("getStagesGeneralInfo", args)[0]

    for etapa in listaEtapas:
        etapa_id= etapa[0]
        args= [etapa_id]
        writeLog('delete_data && delete_opcion', args, "OK", url_context, usuario_context, debug_context)
        functionsDB.doStoredProcedure("delete_dato_de_etapa", args)
        functionsDB.doStoredProcedure("delete_opcion_de_etapa", args)

    args= [token]
    
    writeLog('delete_etapa_de_calculadora', args, "OK", url_context, usuario_context, debug_context)
    functionsDB.doStoredProcedure("delete_etapa_de_calculadora", args)

    writeLog('deleteCalc', args, "OK", url_context, usuario_context, debug_context)
    functionsDB.doStoredProcedure("delete_calc", args)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/deleteEtapa', methods=['POST'], endpoint='deleteEtapa')
def deleteEtapa():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    etapa_id= info["etapa_id"]
    
    args= [etapa_id]
    writeLog('delete_data && delete_opcion', args, "OK", url_context, usuario_context, debug_context)
    functionsDB.doStoredProcedure("delete_dato_de_etapa", args)
    functionsDB.doStoredProcedure("delete_opcion_de_etapa", args)
    
    writeLog('delete_etapa_de_calculadora', args, "OK", url_context, usuario_context, debug_context)
    functionsDB.doStoredProcedure("delete_etapa", args)


    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/deleteOpcion', methods=['POST'], endpoint='deleteOpcion')
def deleteOpcion():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    etapa_id= info["opcion_id"]
    writeLog('delete_opcion', etapa_id, "OK", url_context, usuario_context, debug_context)
    functionsDB.doStoredProcedure("delete_opcion", [etapa_id])
    
    etapa_id= int(etapa_id)+1
    writeLog('delete_opcion', etapa_id, "OK", url_context, usuario_context, debug_context)
    functionsDB.doStoredProcedure("delete_opcion", [etapa_id])

    etapa_id= int(etapa_id)+1
    writeLog('delete_opcion', etapa_id, "OK", url_context, usuario_context, debug_context)
    functionsDB.doStoredProcedure("delete_opcion", [etapa_id])

    # Se devuelve el resultado
    return jsonify({'result': True})


# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/puedeAccederEtapa', methods=['POST'], endpoint='puedeAccederEtapa')
def puedeAccederEtapa():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    etapa_id= info["etapa_id"]
    user= info["user_id"]

    args= [user, etapa_id]
    result= functionsDB.doStoredProcedure("getAllStagesOfUser", args)
    
    writeLog('delete_opcion', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})


# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/createEntidad', methods=['POST'], endpoint='createEntidad')
def createEntidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    identificador= info["identificador"]
    nombre= info["nombre"]
    telefono= info["telefono"]
    direccion= info["direccion"]
    tipo= info["tipo"]
    descripcion= info["descripcion"]
    usuario= info["usuario"]

    args= [identificador]
    result= functionsDB.doStoredProcedure("get_entidad", args)[0]

    writeLog('get_entidad', info, result, url_context, usuario_context, debug_context)
    if len(result)!=0:
        return jsonify({'tipo': "error", "mensaje":"No se ha creado la entidad, porque existe una entidad registrada con ese RUT o CI"}) 

    args= [identificador, nombre, telefono, direccion, tipo, 1, descripcion, usuario]
    result= functionsDB.doStoredProcedure("create_entidad", args)
    
    writeLog('createEntidad', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'tipo': "success", "mensaje":"Entidad creada correctamente"}) 



    edit_entidad
# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/editEntidad', methods=['POST'], endpoint='editEntidad')
def editEntidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    identificador= info["identificador"]
    nombre= info["nombre"]
    telefono= info["telefono"]
    direccion= info["direccion"]
    tipo= info["tipo"]
    descripcion= info["descripcion"]
    usuario= info["usuario"]

    args= [identificador, nombre, telefono, direccion, tipo]
    result= functionsDB.doStoredProcedure("edit_entidad", args)
    
    writeLog('editEntidad', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/getEntidad', methods=['POST'], endpoint='getEntidad')
def getEntidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    entidad_id= info["entidad_id"]

    args= [entidad_id]
    result= functionsDB.doStoredProcedure("get_entidad", args)[0][0]
    
    writeLog('getEntidad', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/deleteEntidad', methods=['POST'], endpoint='deleteEntidad')
def deleteEntidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    entidad_id= info["entidad_id"]

    args= [entidad_id]
    functionsDB.doStoredProcedure("delete_entidad", args)
    
    writeLog('deleteEntidad', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/addUsuarioEntidad', methods=['POST'], endpoint='addUsuarioEntidad')
def addUsuarioEntidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"


     # Se toma el token y la formula del json anterior de cara a la búsqueda
    new_user_email= info["new_user_email"]
    entidad_id= info["entidad_id"]
    

    args= [new_user_email]
    result= functionsDB.doStoredProcedure("existEmail", args)[0][0][0]
    if result != 1: 
        writeLog('existEmail', info, "No existe el email por lo que no se añade", url_context, usuario_context, debug_context)
        return jsonify({'tipo': 'warning', 'mensaje':'No existe nigun usuario con ese email.'})

    args= [new_user_email, entidad_id]
    result= functionsDB.doStoredProcedure("exist_user_entidad", args)[0][0][0]
    if result != 0: 
        writeLog('exist_user_entidad', info, "No se ha guardado porque ya pertenece a la entidad", url_context, usuario_context, debug_context)
        return jsonify({'tipo': 'info', 'mensaje':'El usuario ya esta en la entidad'})

    args= [new_user_email, entidad_id]
    functionsDB.doStoredProcedure("add_usuario_entidad", args)

    writeLog('addUsuarioEntidad', info, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado'''
    return jsonify({'tipo': 'success', 'mensaje':'Usuario añadido a la entidad.'})


# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/getUsuariosEntidad', methods=['POST'], endpoint='getUsuariosEntidad')
def getUsuariosEntidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    entidad_id= info["entidad_id"]
    email= info["email"]

    args= [entidad_id, email]
    result= functionsDB.doStoredProcedure("get_usuarios_entidad", args)[0]
    
    writeLog('getUsuariosEntidad', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/deleteUsuarioEntidad', methods=['POST'], endpoint='deleteUsuarioEntidad')
def deleteUsuarioEntidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    entidad_id= info["entidad_id"]
    email= info["email"]

    args= [email, entidad_id]
    functionsDB.doStoredProcedure("delete_usuario_entidad", args)
    
    writeLog('deleteUsuarioEntidad', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': True})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/get_presupuestos_calculadora', methods=['POST'], endpoint='get_presupuestos_calculadora')
def get_presupuestos_calculadora():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    token= info["token"]

    args= [token]
    result= functionsDB.doStoredProcedure("get_presupuestos_calculadora", args)[0]
    
    writeLog('get_presupuestos_calculadora', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/get_presupuestos_calculadoras_nombre', methods=['POST'], endpoint='get_presupuestos_calculadoras_nombre')
def get_presupuestos_calculadoras_nombre():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    usuario= info["usuario"]

    args= [usuario]
    result= functionsDB.doStoredProcedure("get_presupuestos_calculadoras_nombre", args)[0]
    
    writeLog('get_presupuestos_calculadoras_nombre', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/get_presupuestos_email', methods=['POST'], endpoint='get_presupuestos_email')
def get_presupuestos_email():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    email= info["email"]

    args= [email]
    result= functionsDB.doStoredProcedure("get_presupuestos_email", args)[0]
    
    writeLog('get_presupuestos_email', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/get_presupuestos_entidad', methods=['POST'], endpoint='get_presupuestos_entidad')
def get_presupuestos_entidad():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    entidad_id= info["entidad_id"]

    args= [entidad_id]
    result= functionsDB.doStoredProcedure("get_presupuestos_entidad", args)[0]
    
    writeLog('get_presupuestos_entidad', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/edit_calulator', methods=['POST'], endpoint='edit_calulators')
def edit_calulators():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"

    # Se toma el token y la formula del json anterior de cara a la búsqueda
    token= info["token"]
    nombre= info["nombre"]
    url= info["url"]
    entidad= info["entidad_id"]
    
    n_url= functionsDB.doStoredProcedure("n_dominio_cal", [url])[0][0][0]
    if n_url!=1 and n_url!=0:
        return jsonify({'tipo': "error", "mensaje":"Este dominio ya esta siendo utilizado en otro simulador, por favor intentelo de nuevo con otro dominio."})

    args= [token, nombre, url,entidad]
    functionsDB.doStoredProcedure("edit_calulators", args)
    
    writeLog('edit_calulators', args, "OK", url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'tipo': "success", "mensaje":"El simulador ha sido editado correctamente."})

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
@app.route('/comprar_token', methods=['POST'], endpoint='comprar_token')
def comprar_token():

    # Se trae la información que viene de la vista en json
    info = json.loads(request.data)

    try:
        usuario_context = info['usuario_context']
        url_context = info['url_context']
        debug_context = info['debug_context']
    except:
        usuario_context = "[Sin informacion]"
        url_context = "[Sin informacion]"
        debug_context = "[Sin informacion]"


    args= []
    result= functionsDB.doStoredProcedure("comprar_token", args)[0][0][0]
    
    writeLog('comprar_token', args, result, url_context, usuario_context, debug_context)

    # Se devuelve el resultado
    return jsonify({'result': result})


# *******************************************************************************************************************
# *******************************************************************************************************************
# *******************************************************************************************************************
# *******************************************************************************************************************
# *******************************************************************************************************************
#                                       A PARTIR DE AQUI EMPIEZAN LAS VISTAS
# *******************************************************************************************************************
# *******************************************************************************************************************
# *******************************************************************************************************************
# *******************************************************************************************************************
# *******************************************************************************************************************

# ---------------------------------------------------------------------------------
# Actualiza la formula de una determinada calculadora
#@app.route('/prueba', methods=['POST'], endpoint='prueba')
@app.route('/show_etapa/<posicion>/<direccion_url>/<n_presupuesto>/<tipo_ant>/<valor_ant>/<area_ant>/<lonfgitud_ant>/latitud_ant>/<direccion_ant>/<tipo_sig>')
@app.route('/show_etapa/<posicion>/<direccion_url>/<n_presupuesto>/<tipo_ant>/<valor_ant>/<area_ant>/<lonfgitud_ant>/latitud_ant>/<direccion_ant>')
@app.route('/show_etapa/<posicion>/<direccion_url>/<n_presupuesto>/<tipo_ant>/<valor_ant>')
@app.route('/show_etapa/<posicion>/<direccion_url>/')

def show_etapa(posicion=None, direccion_url=None, n_presupuesto=None, tipo_ant=None, valor_ant=None, area_ant=None, longitud_ant=None, latitud_ant=None, direccion_ant=None, tipo_sig=None):
    #url= request.environ['HTTP_ORIGIN']
    url= direccion_url.replace("!", "/")
    writeLog("PRUEBA DE URL", url, "", "url_context", "usuario_context", "debug_context")
    pos_actual= int(posicion)-1
    
    funcion_sig= "APIrequest"

    '''if tipo_sig==None:
        if tipoSigEtapa(pos_actual+1)=="Geografica":
            funcion_sig= "APIrequest_geo"'''


    # Se verifica que unicamente existe una vista para esta calculadora
    verficar_vista= functionsDB.doStoredProcedure("verficar_vista", [url])[0][0][0]
    writeLog(verficar_vista, "", "", "url_context", "usuario_context", "debug_context")
    if verficar_vista!=1: 
        writeLog("FALLA 1875", "", "", "url_context", "usuario_context", "debug_context")
        return render_template("error.html")
    
    # Se verifica que la calculadora tiene etapas
    verficar_vista= functionsDB.doStoredProcedure("vista_calculadora_n_etapas", [url])[0][0][0]
    if verficar_vista==0: 
        writeLog("FALLA 1881", "", "", "url_context", "usuario_context", "debug_context")
        return render_template("error.html")

    posicion= int(posicion)

    # La posicion 0 no se contempla en el sistema por lo que de llegar se muestra la vista de error
    if posicion==0: 
        return render_template("inicio.html", funcion_sig=funcion_sig, posicion=posicion)
    
    # Si la posicion es 1 se crea un nuevo presupuesto y se almacena su id
    if posicion==1:
        tupla= functionsDB.doStoredProcedure("select_calc_by_url", [url])[0][0]
        token= tupla[0]
        formula= tupla[1]
        nombre= n_presupuesto
        email= tipo_ant
        telefono= valor_ant
        n_email= functionsDB.doStoredProcedure("getClientEmailOcurrences", [email])[0][0][0]
        if n_email==0:
            functionsDB.doStoredProcedure("insert_client", [email, nombre, telefono])
            
        n_presupuesto= functionsDB.doStoredProcedure("create_presupuesto", [token, formula, email, nombre, telefono])[0][0][0]
        writeLog("Nuevo presupuesto", [token, formula, email, telefono, nombre], n_presupuesto, "url_context", "usuario_context", "debug_context")
    else:
        # Insertar datos de la etapa anterior
        if tipo_ant=="intervalos" or tipo_ant=="opciones" or tipo_ant=="geografica":
            # insert_presupuesto_data (presupuesto_id, etapa_id, meta_key, meta_value)
            etapa_id= functionsDB.doStoredProcedure("get_id_de_posicion", [url, pos_actual-1])[0][0][0] # Saco el id de la etapa anterior
            meta_key= "valor-"+tipo_ant
            meta_value= valor_ant

            args= [n_presupuesto, etapa_id, meta_key, meta_value]
            functionsDB.doStoredProcedure("insert_presupuesto_data", args)

            writeLog('VALOR INSERTADO:', args, "", "url_context", "usuario_context", "debug_context")

    
    
    # Se comprueba si es la ultima etapa ya ha sido mostrada y de haberlo sido muestro el resultado del presupuesto
    last_stage_pos= functionsDB.doStoredProcedure("get_ultima_etapa_posicion", [url])[0][0][0]
    if pos_actual==last_stage_pos+1: 
        # Da el presupuesto por finalizado y calcula su resultado sumando los valores de todas sus etapas
        tupla= functionsDB.doStoredProcedure("select_calc_by_url", [url])[0][0]
        token= tupla[0]
        formula= tupla[1]
        email= tipo_ant
        telefono= valor_ant
        try:
            resultado_final= round(eval(generar_presupuesto(formula, token, n_presupuesto)))
            resultado_mes,promedio_mensual = get_monthly_average(formula, token, n_presupuesto, resultado_final)
            writeLog("resultado_mes", f"resultado_mes: {resultado_mes}", "", "", "", True)
            writeLog("promedio_mensual", f"promedio_mensual: {promedio_mensual}", "", "", "", True)
        except RuntimeError:
            return render_template("error.html")
        functionsDB.doStoredProcedure("update_presupuesto_resultado", [resultado_final, n_presupuesto])
        home_url= request.environ['HTTP_ORIGIN']
        return render_template("etapaFinal.html", resultado=resultado_final, resultado_mes=resultado_mes, promedio_mensual=promedio_mensual, url=home_url)

    # Se obtiene el id de la url y la posicion actual
    args=[url, pos_actual]
    id_etapa_actual= functionsDB.doStoredProcedure("get_id_de_posicion", args)[0][0][0]

    # Una vez obtenido el id se procede a recoger toda su información general
    args=[id_etapa_actual]
    stage_general_info= functionsDB.doStoredProcedure("getStageGeneralInfo", args)[0][0]   
    tipo= stage_general_info[2]
    
    titulo= stage_general_info[3]
    subtitulo= stage_general_info[4]
    posicion_etapa=stage_general_info[5]

    # Dependiendo el tipo de etapa se recogen unos datos u otos para crear las vistas renderizadas
    if tipo == "Discreta":  # Intervalos

        # Obtener información específica de la etapa
        stage_specific_info = functionsDB.doStoredProcedure("getStageInfo", args)[0]

        # Mapear las claves meta a nombres de variables
        meta_key_mapping = {
            'maximo': 'maximo',
            'minimo': 'minimo',
            'valor_inicial': 'valor_inicial',
            'intervalo': 'rangos'
        }

        # Inicializar un diccionario para almacenar los valores
        meta_values = {}

        # Iterar sobre las filas de stage_specific_info y mapear las claves meta a nombres de variables
        for row in stage_specific_info:
            meta_key = row[2]
            if meta_key in meta_key_mapping:
                variable_name = meta_key_mapping[meta_key]
                meta_values[variable_name] = row[3]

        writeLog('getStageInfo/Intevalos', args, stage_specific_info, "url_context", "usuario_context", "debug_context")

        return render_template("intervalos.html", funcion_sig=funcion_sig, posicion=posicion,
                            n_presupuesto=n_presupuesto, titulo=titulo, subtitulo=subtitulo, **meta_values)

    elif tipo== "Cualificada": #Opciones
        # Se verifica que la calculadora tiene opciones
        vista_etapa_opciones_n_opciones= functionsDB.doStoredProcedure("vista_etapa_opciones_n_opciones", args)[0][0][0]
        writeLog("vista_etapa_opciones_n_opciones", args, vista_etapa_opciones_n_opciones, "url_context", "usuario_context", "debug_context")

        if vista_etapa_opciones_n_opciones==0:
            writeLog("FALLA 1953", "", "", "url_context", "usuario_context", "debug_context")
            return render_template("error.html")

        stage_specific_info= functionsDB.doStoredProcedure("getOpciones", args)[0]

        new_options= []
        new_option= []
        for opt in stage_specific_info:
            new_option.append(opt)
            if len(new_option)==3: 
                new_options.append(new_option)
                new_option=[]

        #writeLog('vista_Opciones', args, new_options, "url_context", "usuario_context", "debug_context")
        return render_template("opciones.html", funcion_sig=funcion_sig, posicion=posicion, n_presupuesto=n_presupuesto, titulo=titulo, subtitulo=subtitulo, opciones=new_options)

    elif tipo== "Geografica":
        stage_specific_info = functionsDB.doStoredProcedure("getStageInfo", args)[0]
        info_dict = {row[2]: row[3] for row in stage_specific_info}
        direccion = info_dict.get('direccion', None)
        zoom = info_dict.get('zoom', None)
        latitud = info_dict.get('latitud', None)
        longitud = info_dict.get('longitud', None)

        writeLog('vista_Geografica', args, stage_specific_info, "url_context", "usuario_context", "debug_context")
        writeLog('posicion', posicion, "", "url_context", "usuario_context", "debug_context")
        return render_template("geografica.html", funcion_sig=funcion_sig, posicion=posicion, n_presupuesto=n_presupuesto, titulo=titulo, subtitulo=subtitulo, direccion=direccion, zoom=zoom, latitud=latitud, longitud=longitud)
    
    return render_template("etapaFinal.html",pos_actual=pos_actual)

def generar_presupuesto(formula, token, n_presupuesto):
    try:
        stages_id_list = functionsDB.doStoredProcedure("getCalcStagesId", [token])[0]
        id_list = [stage_id[0] for stage_id in stages_id_list]

        for id_stage in id_list:
            stage_values = functionsDB.doStoredProcedure("getStageInsertedValue", [id_stage, n_presupuesto])[0]
            
            if stage_values:
                stage_value = stage_values[0][0]
                writeLog(id_stage, "1", "", "url_context", "usuario_context", "debug_context")
                writeLog(stage_value, "2", "", "url_context", "usuario_context", "debug_context")
                writeLog("cambio", "[" + str(id_stage) + "]", str(stage_value), "url_context", "usuario_context", "debug_context")
                formula = formula.replace("[" + str(id_stage) + "]", str(stage_value))
                writeLog(stage_value, "3", "", "url_context", "usuario_context", "debug_context")
            else:
                writeLog("error", f"Stage values not found for id_stage: {id_stage}", "", "", "", True)

        writeLog("formula", [token], formula, "url_context", "usuario_context", "debug_context")
        return formula
    except Exception as e:
        writeLog("error", f"An error occurred in generar_presupuesto: {str(e)}", "", "", "", True, exception=e)
        raise RuntimeError("An error occurred in generar_presupuesto: " + str(e))
    
def get_monthly_average(formula, token, n_presupuesto, resultado_final):
    try:
        resultado_mes = 0
        promedio_mensual = 0

        stages_id_list = functionsDB.doStoredProcedure("getCalcStagesId", [token])[0]
        id_list = [stage_id[0] for stage_id in stages_id_list]

        for id_stage in id_list:
            result_list = functionsDB.doStoredProcedure("get_monthly_average", [id_stage, n_presupuesto])[0]

            if result_list and len(result_list) > 0:
                promedio_mensual_tuple = result_list[0]
                promedio_mensual_value = promedio_mensual_tuple[0]

                if promedio_mensual_value is not None:
                    promedio_mensual = promedio_mensual_value
                    break
                
        if promedio_mensual != 0:
            resultado_mes = max(0, int(resultado_final) // int(promedio_mensual))

        return resultado_mes, promedio_mensual

    except Exception as e:
        writeLog("error", f"An error occurred in get_monthly_average: {str(e)}", "", "", "", True, exception=e)
        return 0, 0

def tipoSigEtapa(pos):
    args=[pos]
    tipo= functionsDB.doStoredProcedure("getTipoEtapa", args)[0][0][0]
    writeLog("tipoSigEtapa", args , tipo, "url_context", "usuario_context", "debug_context")
    return tipo

def encrypt(value: str) -> str:
    key = "KWkPbFZPN3EU4IkmLPZKMSkseqwDotMQNyZ9IMkrmDA="
    f = Fernet(str.encode(key))
    return f.encrypt(str.encode(value)).decode()


def decrypt(value: str) -> str:
    key = "KWkPbFZPN3EU4IkmLPZKMSkseqwDotMQNyZ9IMkrmDA="
    f = Fernet(str.encode(key))
    decrypted = f.decrypt(str.encode(value))
    return decrypted.decode()
