from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = socket.gethostname()
    return f"""
    <html>
        <head>
            <title>Kubernetes Python App</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    max-width: 800px;
                    margin: 50px auto;
                    padding: 20px;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                }}
                .container {{
                    background: rgba(255, 255, 255, 0.1);
                    padding: 30px;
                    border-radius: 10px;
                    box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
                }}
                h1 {{ color: #fff; }}
                .info {{ 
                    background: rgba(255, 255, 255, 0.2);
                    padding: 15px;
                    border-radius: 5px;
                    margin: 10px 0;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🚀 Hello from Kubernetes!</h1>
                <p>This is a simple Python Flask application running in a Kubernetes pod.</p>
                <div class="info">
                    <strong>Pod Hostname:</strong> {hostname}
                </div>
                <div class="info">
                    <strong>Project:</strong> 2 of 7 - Kubernetes Certification Training
                </div>
                <p>Refresh the page multiple times to see different pod hostnames (if multiple replicas are running)!</p>
            </div>
        </body>
    </html>
    """

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
