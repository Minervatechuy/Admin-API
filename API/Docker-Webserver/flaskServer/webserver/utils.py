from datetime import datetime
import smtplib, ssl, model.functionsDB as functionsDB

# Función para guardar en el log los eventos de la API
def log(message):
    with open("logs/stdout.log", "a") as logfile:
        now = datetime.now()
        logfile.write(f"[{now}] ---> {message}\n")

def writeLog(function, entrada, salida, pagina, usuario, debug, **kwargs):
    with open("logs/stdout.log", "a") as logfile:
        now = datetime.now()
        logfile.write(f"[{now}] - /{function}\n")
        logfile.write(f"  |--> Entrada: {entrada}\n")
        logfile.write(f"  |--> Llamado desde: {pagina}\n")
        logfile.write(f"  |--> Llamado por: {usuario}\n")
        logfile.write(f"  |--> Salida: {salida}\n")

        if debug and 'exception' in kwargs:
            logfile.write(f"  |--> Exception: {str(kwargs['exception'])}\n")