from datetime import datetime
import smtplib, ssl, model.functionsDB as functionsDB

# Función para guardar en el log los eventos de la API
def log(message):
    with open("logs/stdout.log", "a") as logfile:
        now = datetime.now()
        logfile.write(f"[{now}] ---> {message}\n")

def writeLog(function, entrada, salida, pagina, usuario, debug):
    if debug:
        with open("logs/stdout.log", "a") as logfile:
                now = datetime.now()
                logfile.write(f"[{now}] - /{function} \n  |--> Entrada {entrada} \n  |--> Llamado desde {pagina} \n  |--> Llamado por {usuario} \n  |--> Salida {salida} \n")

