SHELL := /bin/bash
P4RROT_CODE := codegen.py
P4RROT_TEMPLATE := P4RROT/templates/p4_template.p4app
SERVER := englewood.ct.univie.ac.at

submodule-setup:
	git submodule init
	git submodule update

create-venv:
	python3.8 -m venv .venv

install-p4rrot-in-venv:
	source .venv/bin/activate && python3.8 -m pip install --upgrade pip
	source .venv/bin/activate && python3.8 -m pip install --upgrade setuptools
	source .venv/bin/activate && python3.8 -m pip install ./P4RROT

submodule-update:
	git submodule update --remote --merge

update-p4rrot: submodule-update install-p4rrot-in-venv

dev-setup: submodule-setup create-venv install-p4rrot-in-venv

code-gen:
	rm -r -f output_code
	cp -r $(P4RROT_TEMPLATE) output_code
	source .venv/bin/activate && python3 $(P4RROT_CODE)

build: code-gen
	cp config.sh output_code/config.sh
	cd output_code && bash build.sh

deploy:
	cd output_code && /opt/netronome/p4/bin/rtecli -r $(SERVER) design-load -f simple_router.nffw -p out/pif_design.json
	python /opt/nfp_pif/thrift/client/sdk6_rte_cli.py -r $(SERVER) registers set -r r_next_id --values 1

stats:
	bash stats.sh $(P4RROT_TEMPLATE) $(P4RROT_CODE)

clean:
	rm -r -f output_code
	rm -r -f .venv

