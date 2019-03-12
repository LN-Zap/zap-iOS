import os
import re
import sys

def pprint_labels(labels):
	for item in labels:
		print("\t" + item)

def labels_in_file(filename):
	result = set()
	file = open(filename, "r")
	for line in file:
		match = re.match(r"^\"([^\"]*)", line)
		if match:
			result.add(match.group(1))
	return result

root_folder = "../Library"
subfolders = [f.path + "/Localizable.strings" for f in os.scandir(root_folder) if f.is_dir() and f.path.endswith(".lproj") and not f.path.endswith("en.lproj")]

en_file = f"{root_folder}/en.lproj/Localizable.strings"
en_labels = labels_in_file(en_file)

exit_code = 0

for folder in subfolders:
	lang_labels = labels_in_file(folder)
	missing = en_labels.difference(lang_labels)
	additional = lang_labels.difference(en_labels)

	if missing or additional:
		print(f"\n{folder}\n------------------------------------")
		exit_code = 1

	if missing:
		print("⚠️  Missing Labels:")
		pprint_labels(missing)

	if additional:
		print("⚠️  Additional Labels:")
		pprint_labels(additional)

sys.exit(exit_code)
