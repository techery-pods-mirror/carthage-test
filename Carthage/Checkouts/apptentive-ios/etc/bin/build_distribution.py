#!/usr/bin/env python
from contextlib import contextmanager
import os
import biplist
import json
import re
import shutil
import subprocess
import sys

HELP_MESSAGE = """
./build_distribution.py
"""

class Usage(Exception):
	def __init__(self, msg):
		super(Usage, self).__init__(msg)
		self.msg = msg

def log(msg):
	print >> sys.stderr, msg

def get_dirname():
	return os.path.dirname(globals()["__file__"])

@contextmanager
def chdir(path):
	curdir = os.getcwd()
	os.chdir(path)
	try:
		yield
	finally:
		os.chdir(curdir)

def escape_arg(argument):
	"""Escapes an argument to a command line utility."""
	argument = argument.replace('\\', "\\\\").replace("'", "\'").replace('"', '\\"').replace("!", "\\!").replace("`", "\\`")
	return "\"%s\"" % argument

def run_command(command, verbose=False):
	if verbose:
		sys.stderr.write("Running: %s\n" % command)
	p = subprocess.Popen(command, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	stdin, stdout = (p.stdin, p.stdout)
	output = stdout.read()
	output = output.strip("\n")
	status = stdin.close()
	stdout.close()
	p.wait()
	return (p.returncode, output)

class Builder(object):
	COCOAPODS_DIST = "COCOAPODS_DIST"
	BINARY_DIST = "BINARY_DIST"
	build_root = "/tmp/apptentive_connect_build"
	dist_type = None
	def __init__(self, verbose=False, dist_type=None):
		if not dist_type:
			dist_type = self.BINARY_DIST
		self.verbose = verbose
		self.dist_type = dist_type
		if dist_type not in [self.COCOAPODS_DIST, self.BINARY_DIST]:
			log("Unknown dist_type: %s" % dist_type)
			sys.exit(1)
	
	def build(self):
		with chdir(self._project_dir()):
			# Build for simulator and device, each 64bit and not.
			for is_simulator in [True, False]:
				for is_64bit in [True, False]:
					build_command = self._build_command(is_simulator=is_simulator, is_64bit=is_64bit)
					(status, output) = run_command(build_command, verbose=self.verbose)
					if status != 0:
						target_type = "simulator" if is_simulator else "device"
						arch_type = "64bit" if is_64bit else "not 64bit"
						log("Building for %s %s failed with code: %d" % (target_type, arch_type, status))
						log(output)
						return False
			library_dir = self._output_dir()
			try:
				if os.path.exists(library_dir):
					shutil.rmtree(library_dir)
				os.makedirs(library_dir)
				os.makedirs(os.path.join(library_dir, 'include'))
			except Exception as e:
				log("Exception %s" % e)
				pass
			if not os.path.exists(library_dir):
				log("Unable to create output directory at: %s" % library_dir)
				return False
			(status, output) = run_command(self._lipo_command(), verbose=self.verbose)
			if status != 0:
				log("Unable to lipo static libraries")
				log(output)
				return False
			paths_to_copy = [("source/ATConnect.h", "include/ATConnect.h"), ("../LICENSE.txt", "LICENSE.txt"), ("../README.md", "README.md"), ("../CHANGELOG.md", "CHANGELOG.md")]
			for (project_path, destination_path) in paths_to_copy:
				full_project_path = project_path
				full_destination_path = os.path.join(self._output_dir(), destination_path)
				(status, output) = self._ditto_file(full_project_path, full_destination_path)
				if status != 0:
					log("Unable to ditto project path: %s" % full_project_path)
					log(output)
					return False
			# Copy the ApptentiveResources.bundle.
			bundle_source = os.path.join(self._products_dir(), "ApptentiveResources.bundle")
			bundle_dest = os.path.join(self._output_dir(), "ApptentiveResources.bundle")
			(status, output) = self._ditto_file(bundle_source, bundle_dest)
			# Update the Info.plist in the ApptentiveResources.bundle.
			bundle_plist_path = os.path.join(bundle_dest, "Info.plist")
			if not os.path.exists(bundle_plist_path):
				log("Unable to find bundle Info.plist at %s" % bundle_plist_path)
				return False
			plist = biplist.readPlist(bundle_plist_path)
			plist_key = "ATInfoDistributionKey"
			if self.dist_type == self.COCOAPODS_DIST:
				plist[plist_key] = "CocoaPods"
			elif self.dist_type == self.BINARY_DIST:
				plist[plist_key] = "binary"
			else:
				log("Unknown dist_type")
				return False
			biplist.writePlist(plist, bundle_plist_path)
		
		# Try to get the version.
		version = None
		header_contents = open(os.path.join(self._project_dir(), "source", "ATConnect.h")).read()
		match = re.search(r"#define kATConnectVersionString @\"(?P<version>.+)\"", header_contents, re.MULTILINE)
		if match and match.group('version'):
			version = match.group('version')
		with chdir(self._output_dir()):
			filename = 'apptentive_ios_sdk.tar.gz'
			if version:
				if self.dist_type == self.BINARY_DIST:
					filename = 'apptentive_ios_sdk-%s.tar.gz' % version
				elif self.dist_type == self.COCOAPODS_DIST:
					filename = 'apptentive_ios_sdk-cocoapods-%s.tar.gz' % version
			tar_command = "tar -zcvf ../%s ." % filename
			(status, output) = run_command(tar_command, verbose=self.verbose)
			if status != 0:
				log("Unable to create library archive")
				log("output")
				return False
			run_command("open .")
		return True
	
	def _project_dir(self):
		return os.path.realpath(os.path.join(get_dirname(), "..", "..", "ApptentiveConnect"))
	
	def _output_dir(self):
		return os.path.join(self.build_root, "library_dir")
	
	def _products_dir(self, is_simulator=False, is_64bit=False):
		products_dir = os.path.join(self.build_root, "device_product")
		if is_simulator:
			products_dir = os.path.join(self.build_root, "simulator_product")
		if is_64bit:
			products_dir += "_64bit"
		return products_dir
	
	def _xcode_options(self, is_simulator=False, is_64bit=False):
		products_dir = self._products_dir(is_simulator=is_simulator, is_64bit=is_64bit)
		symroot = os.path.join(self.build_root, "symroot")
		temp_dir = os.path.join(self.build_root, "target_temp_dir")
		return "CONFIGURATION_BUILD_DIR=%s SYMROOT=%s TARGET_TEMP_DIR=%s" % (escape_arg(products_dir), escape_arg(symroot), escape_arg(temp_dir))
	
	def _lipo_command(self):
		output_dir = self._output_dir()
		lib = "libApptentiveConnect.a"
		output_library = os.path.join(output_dir, lib)
		input_a = os.path.join(self._products_dir(is_simulator=True), lib)
		input_b = os.path.join(self._products_dir(is_simulator=False), lib)
		input_c = os.path.join(self._products_dir(is_simulator=True, is_64bit=True), lib)
		input_d = os.path.join(self._products_dir(is_simulator=False, is_64bit=True), lib)
		return """xcrun lipo -create -output %s %s %s %s %s""" % (escape_arg(output_library), escape_arg(input_a), escape_arg(input_b), escape_arg(input_c), escape_arg(input_d))
	
	def _build_command(self, is_simulator=False, is_64bit=False):
		sdk = 'iphoneos'
		if is_simulator:
			sdk = 'iphonesimulator'
		command = """xcrun xcodebuild -target ApptentiveConnect -configuration Release -sdk %s %s""" % (sdk, self._xcode_options(is_simulator=is_simulator, is_64bit=is_64bit))
		if is_64bit and is_simulator:
			command += " ARCHS='x86_64' VALID_ARCHS='x86_64'"
		elif is_simulator and not is_64bit:
			command += " ARCHS='i386' VALID_ARCHS='i386'"
		elif is_64bit:
			command += " ARCHS='arm64' VALID_ARCHS='arm64'"
		elif not is_simulator and not is_64bit:
			command += " ARCHS='armv7 armv7s' VALID_ARCHS='armv7 armv7s'"
		return command
	
	def _project_path(self, filename):
		"""Returns the file within the project directory for the given filename."""
		return os.path.join(self._project_dir(), filename)
	
	def _ditto_file(self, path_from, path_to):
		command = """xcrun ditto %s %s""" % (escape_arg(path_from), escape_arg(path_to))
		return run_command(command, verbose=self.verbose)

if __name__ == "__main__":
	for dist_type in [Builder.BINARY_DIST, Builder.COCOAPODS_DIST]:
		builder = Builder(dist_type=dist_type)
		result = builder.build()
		if result == True:
			log("Build succeeded")
		else:
			log("Build failed!")
			break
