import platform
from bottle import route, run, template, request

@route('/hello/:name')
def index(name='World'):
    return template('Hello {{name}} ({{remote_addr}}), I\'m {{hostname}} !\n', name=name, remote_addr=request.remote_addr, hostname=platform.node())

run(host='0.0.0.0', port=8080)
