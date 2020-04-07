from flask import Flask, Response, request, json, redirect
app = Flask(__name__)


@app.route('/', methods=['GET'])
def openapp():
    return redirect('intent://login/?state=qU9b4zCSFuyHIFXCCltr&mobile=true&scope=%7B"doubleName"%3Atrue%2C"email"%3Afalse%2C"keys"%3Afalse%7D&appId=example.staging.jimber.org&appPublicKey=xKHlaIyza5dSxswOmvuYV7MDreIbLllK9T0n3c1tu0g%3D&state=qU9b4zCSFuyHIFXCCltr#Intent;scheme=threebot;package=org.jimber.threebotlogin;S.browser_fallback_url=http://www.jimber.org;end', code=302)

@app.route('/normal', methods=['GET'])
def normal():
    return redirect('threebot://login/?state=qU9b4zCSFuyHIFXCCltr&mobile=true&scope=%7B"doubleName"%3Atrue%2C"email"%3Afalse%2C"keys"%3Afalse%7D&appId=example.staging.jimber.org&appPublicKey=xKHlaIyza5dSxswOmvuYV7MDreIbLllK9T0n3c1tu0g%3D&state=qU9b4zCSFuyHIFXCCltr', code=302)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)