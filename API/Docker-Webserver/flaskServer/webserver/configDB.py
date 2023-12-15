import mysql.connector

def connect():
    hostname = 'prod-db.cyimwtghazuk.us-east-1.rds.amazonaws.com'
    username = 'minervatech'
    password = 'MinervallTech'
    database = 'minervatech'

    return mysql.connector.connect( host=hostname, user=username, passwd=password, db=database)
