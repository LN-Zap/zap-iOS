from subprocess import Popen, PIPE
import shutil
import time

btcd = None
lnd = None

def test():
	print("test")

def start():
	global btcd, lnd

	shutil.copytree("fixtures", "temp")

	print("starting btcd")

	btcd = Popen(["btcd",
		"--txindex",
		"--simnet",
		"--rpcuser=kek",
		"--rpcpass=kek"], stdout=PIPE, stderr=PIPE)


	print("starting lnd")

	lnd = Popen([
		"lnd",
		"--noseedbackup",
		"--bitcoin.active",
		"--bitcoin.simnet",
		"--bitcoin.node=btcd",
		"--debuglevel=info",
		"--btcd.rpcuser=kek",
		"--btcd.rpcpass=kek",
		"--rpclisten=localhost:10001",
		"--listen=localhost:10011",
		"--tlscertpath=temp/tls.cert",
		"--tlskeypath=temp/tls.key",
		"--datadir=temp/data",
		"--logdir=temp/log"], stdout=PIPE, stderr=PIPE)

def stop():
	global btcd, lnd
	btcd.kill()
	lnd.kill()
	shutil.rmtree('temp')
