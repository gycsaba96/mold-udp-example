SHELL := /bin/bash
P4RROT_CODE := codegen.py
P4RROT_TEMPLATE := P4RROT/templates/p4_template.p4app

create-venv:
	python3 -m venv .venv

install-p4rrot-in-venv:
	source .venv/bin/activate && python3 -m pip install ./P4RROT

submodule-update:
	git submodule update --remote --merge

update-p4rrot: submodule-update install-p4rrot-in-venv

dev-setup: create-venv install-p4rrot-in-venv

code-gen:
	rm -r -f output_code
	cp -r $(P4RROT_TEMPLATE) output_code
	source .venv/bin/activate && python3 $(P4RROT_CODE)

stats:
	bash stats.sh $(P4RROT_TEMPLATE) $(P4RROT_CODE)

clean:
	rm -r -f output_code
	rm -r -f .venv

