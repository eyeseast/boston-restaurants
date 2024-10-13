# data

DATA = data/licenses.csv data/inspections.csv data/alcohol.csv
DB = restaurants.db

data/licenses.csv: data
	wget -O $@ https://data.boston.gov/dataset/5e4182e3-ba1e-4511-88f8-08a70383e1b6/resource/f1e13724-284d-478c-b8bc-ef042aa5b70b/download/tmpbica0ls2.csv
	touch $@

data/inspections.csv: data
	wget -O $@ https://data.boston.gov/dataset/03693648-2c62-4a2c-a4ec-48de2ee14e18/resource/4582bec6-2b4f-4f9e-bc55-cbaa73117f4c/download/tmphg12hdsp.csv
	touch $@

data/alcohol.csv: data
	wget -O $@ https://data.boston.gov/dataset/47d501bf-8bfa-4076-944f-da0aedb60c8a/resource/aab353c1-c797-4053-a3fc-e893f5ccf547/download/tmp_qwzoue3.csv
	touch $@

data:
	mkdir -p data

$(DB):
	uv run sqlite-utils create-database $(DB) --enable-wal --init-spatialite

licenses: $(DB) data/licenses.csv
	uv run sqlite-utils insert $(DB) $@ data/licenses.csv --csv --truncate
	uv run sqlite-utils transform $(DB) $@ --type latitude FLOAT
	uv run sqlite-utils transform $(DB) $@ --type longitude FLOAT
	uv run sqlite-utils transform $(DB) $@ --type property_id INTEGER

inspections: $(DB) data/inspections.csv
	uv run sqlite-utils insert $(DB) $@ data/inspections.csv --csv --truncate

alcohol: $(DB) data/alcohol.csv
	uv run sqlite-utils insert $(DB) $@ data/alcohol.csv --csv --truncate
	uv run sqlite-utils transform $(DB) $@ --type latitude FLOAT
	uv run sqlite-utils transform $(DB) $@ --type longitude FLOAT

# workflow

install:
	uv sync

update: $(DATA)

run:
	# https://docs.datasette.io/en/stable/settings.html#configuration-directory-mode
	uv run datasette serve . --load-extension spatialite
