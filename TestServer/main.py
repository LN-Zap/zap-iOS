#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
from methods import *

class Server(BaseHTTPRequestHandler):
	def handle_http(self, status_code, path):
		self.send_response(status_code)
		self.send_header('Content-type', 'text/html')
		self.end_headers()
		content = path
		return bytes(content, 'UTF-8')

	def do_GET(self):
		print(self.path)

		globals()[self.path[1:]]()

		response = self.handle_http(200, self.path)
		self.wfile.write(response)

HOST_NAME = 'localhost'
PORT_NUMBER = 8080

if __name__ == '__main__':
	httpd = HTTPServer((HOST_NAME, PORT_NUMBER), Server)
	print(time.asctime(), 'Server UP - %s:%s' % (HOST_NAME, PORT_NUMBER))
	try:
		httpd.serve_forever()
	except KeyboardInterrupt:
		pass
	httpd.server_close()
	print(time.asctime(), 'Server DOWN - %s:%s' % (HOST_NAME, PORT_NUMBER))
