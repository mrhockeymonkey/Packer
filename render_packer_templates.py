"""
This script renders packer files using jinja2

This allows different flavours of packer builds without code duplication
"""

import os
import jinja2
import subprocess

#Define some variables
script_path = os.path.dirname(os.path.abspath(__file__))
template_folder = os.path.join(script_path, 'templates')
template_files = ['win_10_standard.json', 'win_10_developer.json']

#Create jinja2 environment
env = jinja2.Environment(
	loader = jinja2.FileSystemLoader(template_folder),
	#Becuase we are templating json we need to pick different variable start/end strings
	variable_start_string = '{{{',
	variable_end_string = '}}}'
)

for file in template_files:
	#Resolve template
	print(file, ": Rendering from templates...")
	template = env.get_template(file)
	packer_config = template.render()

	#Write to file
	print(file, ": Writing to disk...")
	base, ext = os.path.splitext(file)
	rendered_file = base + ".rendered" + ext
	f = open(os.path.join(script_path, rendered_file), 'w')
	f.write(packer_config)
	f.close()

	#Validate resultant file
	print(file, ": Validating...")
	subprocess.check_call(["packer.exe", "validate", rendered_file])
	print("")