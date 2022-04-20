# from http import server
# from sqlite3 import Cursor
from flask import Flask, request, make_response
import pyodbc

app = Flask(__name__)

@app.route('/')
def index():
    return 'This is index page of members'

@app.route('/users', methods=['GET', 'POST'])
def add():
    userid = request.args.get('userid')
    
    rows = get_user_info(userid)
    
    response = make_response(
        f'{userid}: {rows}',
        200
    )
    return response

def get_user_info(qid):
    server = 'memserver.database.windows.net'
    database = 'memDB'
    driver = '{ODBC Driver 17 for SQL Server}'
    username = 'nadeemkhalid'
    password = 'Young22.Sleep.Put'
    
    try:
        # conn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';DATABASE='+database+';Trusted_Connection=yes;')
        conn= pyodbc.connect('DRIVER='+driver+';SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+password)
        print(f'conn: {conn}')
        cursor = conn.cursor()
        print(cursor)
        sql_str = 'SELECT AddressID, City FROM SalesLT.Address where AddressID>=? AND AddressID<?'
        print(sql_str)
        # select table and fields
        cursor.execute(sql_str, 499, 1000)
        rows = cursor.fetchall()

        for row in rows:
            print(row)

        cursor.close()
        conn.close()

        return rows
    except Exception as error:
    
        return error

# to run on localhost
if __name__ == '__main__':
    app.run()