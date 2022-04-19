#!/usr/bin/python3
from __future__ import print_function
from flask import Flask, redirect, url_for, request, jsonify
app = Flask(__name__)

import mysql.connector
from mysql.connector import errorcode

cnx = mysql.connector.connect(
  host="34.83.139.11",
  user="admin",
  password="aaAA11!!",
)

DB_NAME = 'fintax_mysql_db'
TABLE_NAME = 'hostname_count'

def create_database(cursor):
    try:
        cursor.execute(
            f"CREATE DATABASE {DB_NAME} DEFAULT CHARACTER SET 'utf8'")
    except mysql.connector.Error as err:
        print("Failed creating database: {}".format(err))
        exit(1)

##########

@app.route('/hostname_count',methods = ['POST', 'GET'])
def hostname_count():
  cnx = mysql.connector.connect(
    host="34.83.139.11",
    user="admin",
    password="aaAA11!!",
    database = DB_NAME
  )
  if request.method == 'POST':
    json = request.json
    if 'hostname' not in json:
      res = {"error":"Body must contains 'hostname' field"}
      return res, 400
    print(f"""{json["hostname"]}""")
    try:
      print("a")
      cursor = cnx.cursor()
      print("b")
      query = f"""
      INSERT INTO {TABLE_NAME} (hostname, count)
      VALUES ("{json["hostname"]}",1)
      ON DUPLICATE KEY UPDATE count = VALUES(count)+1
      """
      cursor.execute(query)
      cnx.commit()
      cursor.close()
      return {'status':'ok'}
    except Exception as e:
      return {'error':e}, 500
  else:
    cursor = cnx.cursor()
    query = f'SELECT hostname, count FROM {TABLE_NAME};'
    cursor.execute(query)
    res_tmp = {}
    for hostname, count in cursor:
      res_tmp[hostname] = count
    return jsonify(res_tmp)




if __name__ == '__main__':
  cursor = cnx.cursor()
  try:
      cursor.execute(f"USE {DB_NAME}")
  except mysql.connector.Error as err:
      print(f"Database {DB_NAME} does not exists.")
      if err.errno == errorcode.ER_BAD_DB_ERROR:
          create_database(cursor)
          print(f"Database {DB_NAME} created successfully.")
          cnx.database = DB_NAME
      else:
          print(err)
          exit(1)

  try:
      print(f"Creating table {TABLE_NAME}: ", end='')
      cursor.execute(
        f"""
        CREATE TABLE {TABLE_NAME}
        (hostname VARCHAR(255), PRIMARY KEY(hostname), count INT);
        """
      )
  except mysql.connector.Error as err:
      if err.errno == errorcode.ER_TABLE_EXISTS_ERROR:
          print("already exists.")
      else:
          print(err.msg)
  else:
      print("OK")

  cursor.close()
  cnx.close()
  app.run(debug=True, host='0.0.0.0', port=80)
