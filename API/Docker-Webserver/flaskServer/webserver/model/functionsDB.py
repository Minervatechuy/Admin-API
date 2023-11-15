from __future__ import print_function
import configDB as configDB
from utils import log
     

def doQuerySQL(SQL):
    conexion = configDB.connect()
    cur = conexion.cursor()
    cur.execute(SQL)
    result = cur.fetchall()
    cur.close()
    conexion.close()
    return result

def doStoredProcedure(name, args):
    conexion = configDB.connect()
    cur = conexion.cursor()
    result = cur.callproc(name, args)
    x=[]
    for result in cur.stored_results():
            x.append(result.fetchall())
    cur.close()
    conexion.commit()
    conexion.close()
    return x