from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_login import login_required, LoginManager, UserMixin, login_user, logout_user, current_user
from tqdm import tqdm
import sqlite3
import subprocess, sys
from subprocess import STDOUT
from datetime import timedelta
import logging
import os
import waitress

pingpath="C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\PingTest.ps1"
vncpath="C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\UVNCTestV2.ps1"
aioMOPpath= "C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\MOPAllinoneSetup.ps1"
DefualtWebsitePath= "C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\SetDefualtWebsiteV2.ps1"
alPath= "C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\autologinV2.ps1"
scoreboardpath="C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\ScoreboardConfigV3.ps1"
teguarPath="C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\TegAIO.ps1"
bypassWSUSPath="C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\bypassWSUS.ps1"
RemoveALpath="C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\RemoveAutoLogin.ps1"
output= ' '
path='C:\\Users\\bfire\\OneDrive\\Desktop\\EmersonTool\\exampleSQL.db'

def RemoveALOpt(computername): #ping computer name Option

    try:
        output=subprocess.run(["powershell.exe", RemoveALpath, computername],
                                stdout=subprocess.PIPE, stderr=STDOUT)

        output=output.stdout.decode('utf-8')
        #errors=output.stderr.decode('utf-8')

    except Exception as err:
        output=err
    return (output)

def vncOpt(computername):#Add VNC to computer name Option
    try:
        print("Testing "+computername)
        output = subprocess.run(["powershell.exe", vncpath, computername],
                                stdout=subprocess.PIPE, stderr=STDOUT)
        output = output.stdout.decode('utf-8')
    except Exception as err:
        output = err
    return (output)

def mopSetupOpt(computername, cUname, cPwd):#sets chrome page, adds it to the appropriate AD groups, and install VNC
    try:
        output = subprocess.run(["powershell.exe", aioMOPpath, computername, cUname, cPwd],
                                stdout=subprocess.PIPE, stderr=STDOUT)
        output = output.stdout.decode('utf-8')
    except Exception as err:
        output = err
    return (output)

def alOpt(computername, cUname, cPwd): #sets up autologin option
    try:
        output = subprocess.run(["powershell.exe", alPath, computername, cUname, cPwd], stdout=subprocess.PIPE, stderr=STDOUT)
        output = output.stdout.decode('utf-8')
    except Exception as err:
        output = err
    return (output)

def sbOpt(computername, cUname, cPwd, url): #setup for scoreboards, installs chrome, sets defualt webpage, and autologin
    try:

        output = subprocess.run(["powershell.exe", scoreboardpath, computername, cUname, url, cPwd],
                                stdout=subprocess.PIPE, stderr=STDOUT)
        output = output.stdout.decode('utf-8')
    except Exception as err:
        output = err
    return (output)

def WebsiteSetup(ComputerName,Url): #Add Heijunka as default page to computer Option
    try:
        print("Setting up "+ComputerName+" with "+Url)
        output = subprocess.run(["powershell.exe", DefualtWebsitePath, ComputerName, Url], stdout=subprocess.PIPE)
        output = output.stdout.decode('utf-8')
    except Exception as err:
        output = err
    return (output)

def TeguarSetup(ComputerName, cUname, cPwd, url):
    try:
        output = subprocess.run(["powershell.exe", teguarPath, ComputerName, cUname, url, cPwd],
                                stdout=subprocess.PIPE, stderr=STDOUT)
        output = output.stdout.decode('utf-8')
    except Exception as err:
        output = err
    return (output)

def BypassWSUS(ComputerName):
    try:
        output = subprocess.run(["powershell.exe", bypassWSUSPath, ComputerName],
                                stdout=subprocess.PIPE, stderr=STDOUT)
    except Exception as err:
        output = err
    return (output)

logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

app = Flask(__name__, template_folder=("."))#Pull the html files from current directory
login_manager = LoginManager(app)
login_manager.login_view = "login"
app.config['SECRET_KEY'] ='abcd'
#Set logout time
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=500)
enctype="multipart/form-data"

class User(UserMixin):
    def __init__(self, user, password, enable, admin):
         self.id = user
         self.password = password
         self.enable = enable
         self.admin = admin
         self.authenticated = False


    def is_active(self):
         return self.is_active()


    def is_anonymous(self):
         return False


    def is_authenticated(self):
         return self.authenticated


#    def is_active(self):
#        return True

    def get_id(self):
         return self.id


@login_manager.user_loader
def load_user(user_id):
    path = (r'C:\Users\bfire\OneDrive\Desktop\EmersonTool')
    conn = sqlite3.connect(path + r"\exampleSQL.db")
    curs = conn.cursor()
    curs.execute("SELECT * from accounts where Account = ?",[user_id])
    lu = curs.fetchone()
#    print("DEBUG : LOGIN ACCOUNT @login manager: " + str(lu))
    if lu is None:
        curs.close()
        return None
    else:
        curs.close()
        #set session time to start countdown at login
        session.permanent = True
        return User(lu[0], lu[1], lu[2],lu[3])






@app.route('/')
@login_required
def index():
    return render_template('index.html') #defualt webpage

@app.route('/subIndex')
@login_required
def subIndex():
    output = session.get('output')
    return render_template('subIndex.html', output=output, progress=0) #defualt webpage

@app.route('/UVNCSetup', methods=['POST', 'GET'])
@login_required
def UVNCSetup():
    compName = request.form['ComputerName']  # request computer name from html
    print("compName: "+compName)
    output=vncOpt(compName) #send computername to vncOpt
    session["output"] = output
    print(output)
    return render_template('index.html', compName=compName, output=output)

@app.route('/RemoveAutoLogin', methods=['POST', 'GET'])
@login_required
def RemoveAutoLogin():
    compName = request.form['ComputerName'] #request computer name from html
    output=RemoveALOpt(compName) #send computername to pingOpt
    session["output"] = output
    print(output)
    return render_template('index.html',compName=compName, output=output)


@app.route('/mopSetup', methods=['POST', 'GET'])
@login_required
def mopSetup(): #request computer, username, and password from html and passes it to mopSetupOpt
    compName=request.form["ComputerName"]
    userName=request.form["Username"]
    pwd = request.form["Password"]
    pwd = ("'" + pwd + "'")
    output=mopSetupOpt(compName, userName, pwd)
    session["output"] = output
    print(output)
    return render_template('index.html',compName=compName, output=output)


@app.route('/autologin', methods=['POST', 'GET'])
@login_required
def autologin():
    compName=request.form["ComputerName"]
    userName=request.form["Username"]
    pwd = request.form["Password"]
    pwd = ("'" + pwd + "'")
    output=alOpt(compName, userName, pwd)
    session["output"] = output
    print(output)
    return render_template('index.html',compName=compName, output=output)

@app.route('/setupSB', methods=['POST', 'GET'])
@login_required
def setupSB():
    compName=request.form["ComputerName"]
    userName=request.form["Username"]
    pwd = request.form["Password"]
    url = request.form["URL"]
    print(compName, userName, pwd, url)
    pwd = ('"' + pwd + '"')
    output=sbOpt(compName, userName, pwd, url)
    session["output"] = output
    print(output)
    return render_template('index.html',compName=compName, output=output)

@app.route('/addWebsite', methods=['POST', 'GET'])
@login_required
def addWebsite():
    compName=request.form["ComputerName"]
    url = request.form["URL"]
    output= WebsiteSetup(compName,url)
    session["output"] = output
    print(output)
    return render_template('index.html',compName=compName, output=output)

@app.route('/TEGSetup', methods=['POST', 'GET'])
@login_required
def TEGSetup():
    compName = request.form["ComputerName"]
    userName = request.form["Username"]
    pwd = request.form["Password"]
    url = request.form["URL"]
    print(compName, userName, pwd, url)
    pwd = ('"' + pwd + '"')
    output = TeguarSetup(compName, userName, pwd, url)
    session["output"] = output
    print(output)
    return render_template('index.html',compName=compName, output=output)

@app.route('/WSUSbypass', methods=['POST', 'GET'])
@login_required
def WSUSbypass():
    compName = request.form["ComputerName"]
    print(compName)
    output = BypassWSUS(compName)
    session["output"] = output
    print(output)
    return render_template('index.html',compName=compName, output=output)

@app.route('/login', methods =['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))

    path = (r'C:\Users\bfire\OneDrive\Desktop\EmersonTool')
    conn = sqlite3.connect(path + r"\exampleSQL.db")
    cursor = conn.cursor()
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        username = request.form['username']
        password = request.form['password']
        params = (username, password)
        table = cursor.execute('SELECT * FROM Accounts WHERE Account=? AND Password = ?', params)
        account = table.fetchone()
#        print("DEBUG : ACCOUNT FETCH RETURNED : " + str(account))
        if account is None:
#            print("DEBUG : LOGIN ACCOUNT: FALSE")
            flash('Incorrect username / password',"error")
        elif account[3] != 1:
#            print("DEBUG : LOGIN ACCOUNT: DISABLED")
            flash('Account not Enabled',"error")
        else:
#            print("DEBUG : LOGIN ACCOUNT: TRUE")
#            print("DEBUG : ACCOUNT : " + account[0])
            Us = load_user(account[0])
            session['loggedin'] = True
            session['password'] = account[1]
            login_user(Us)
            table.close()
            return redirect(url_for('index'))
    return render_template('login1.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    if session.get('was_once_logged_in'):
        # prevent flashing automatically logged out message
        del session['was_once_logged_in']
    flash('You have successfully logged yourself out.')
    return redirect('/login')

if __name__ == '__main__':
    waitress.serve(app, host='0.0.0.0', port=5004)
    #app.run(debug=True)