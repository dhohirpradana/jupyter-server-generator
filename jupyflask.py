from flask import Flask, jsonify
import subprocess

app = Flask(__name__)

@app.route('/jupyserv-create/<service_name>', methods=['GET'])
def generate_token(service_name):
    unused_port = subprocess.run([
        '/bin/bash',
        '-c',
        f'./unused_port.sh'
    ], capture_output=True, text=True).stdout.strip()
    
    if unused_port == "404":
        return jsonify({"message": f"Not found unused port between 38000 and 65535."}), 400
    
    port = unused_port
    
    jupyter = subprocess.run([
        '/bin/bash',
        '-c',
        f'./jupyter.sh {service_name} {port}'
    ], capture_output=True, text=True).stdout.strip()
    
    if jupyter == "400":
        return jsonify({"message": f"Usage: {service_name} {port}"}), 400
    elif jupyter == "409":
        return jsonify({"message": f"Service {service_name} already exists. Please use a different service name."}), 409
    elif jupyter == "406":
        return jsonify({"message": f"Port {port} already in use."}), 406

    return jsonify({"token": jupyter, "port": port})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
