import socket
import threading
import json

class MinimalRESTFramework:
    def __init__(self, host='127.0.0.1', port=5000):
        self.host = host
        self.port = port
        self.routes = {}

    def route(self, path, method='GET'):
        def wrapper(func):
            self.routes[(path, method)] = func
            return func
        return wrapper

    def handle_request(self, conn, addr):
        try:
            data = conn.recv(1024).decode('utf-8')
            if not data:
                return

            headers = data.split('\r\n')
            request_line = headers[0].split()
            method, path = request_line[0], request_line[1]

            response_body = {}
            if (path, method) in self.routes:
                response_body = self.routes[(path, method)]()
                response_status = '200 OK'
            else:
                response_body = {"error": "Not Found"}
                response_status = '404 Not Found'

            response = (
                f"HTTP/1.1 {response_status}\r\n"
                "Content-Type: application/json\r\n"
                "\r\n"
                f"{json.dumps(response_body)}"
            )
            conn.sendall(response.encode('utf-8'))
        finally:
            conn.close()

    def run(self):
        print(f"Starting server at {self.host}:{self.port}")
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
            server.bind((self.host, self.port))
            server.listen()
            print("Server is running...")

            while True:
                conn, addr = server.accept()
                threading.Thread(target=self.handle_request, args=(conn, addr)).start()

# Example usage
app = MinimalRESTFramework()

@app.route("/", method="GET")
def home():
    return {"message": "Welcome to the Minimal REST Framework!"}

@app.route("/data", method="GET")
def get_data():
    return {"data": [1, 2, 3, 4, 5]}

@app.route("/info", method="POST")
def post_info():
    return {"status": "Information saved successfully!"}

if __name__ == "__main__":
    app.run()