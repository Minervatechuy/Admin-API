import mysql.connector

def connect():
    hostname = 'mariadb'
    username = 'minervatech'
    password = 'MinervallTech'
    database = 'minervatech'

    return mysql.connector.connect( host=hostname, user=username, passwd=password, db=database)
