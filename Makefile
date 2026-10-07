RSCRIPT := Rscript
PYTHON  := renv/python/virtualenvs/renv-python-3.13/Scripts/python.exe

SRC  := src
DATA := ../data_LAND
OUT  := out
CONFIG := config.yaml

LISTINGS := $(wildcard $(DATA)/listings_20*.csv)
$(if $(LISTINGS),,$(error No listings CSVs found in $(DATA)))

.PHONY: all clean
.DELETE_ON_ERROR:

all: $(OUT)/joined_airbnb_tenancy.rds

$(OUT):
	mkdir -p $(OUT)

$(OUT)/listings_chch.rds $(OUT)/listings_chch_cleaned.parquet &: $(SRC)/1_cleaning_airbnb_chch.R $(LISTINGS) $(CONFIG) | $(OUT)
	$(RSCRIPT) $(SRC)/1_cleaning_airbnb_chch.R

$(OUT)/tenancy_cleaned.rds: $(SRC)/2_cleaning_tenancy.R $(DATA)/Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv $(CONFIG) | $(OUT)
	$(RSCRIPT) $(SRC)/2_cleaning_tenancy.R

$(OUT)/airbnb_chch_codes.parquet: $(SRC)/3_enriching_airbnb_areacodes_nonapi.py $(OUT)/listings_chch_cleaned.parquet $(DATA)/statistical-area-2-2019-generalised.gpkg $(CONFIG) | $(OUT)
	$(PYTHON) $(SRC)/3_enriching_airbnb_areacodes_nonapi.py

$(OUT)/joined_airbnb_tenancy.rds: $(SRC)/4_join_airbnb_tenancy.R $(OUT)/airbnb_chch_codes.parquet $(OUT)/tenancy_cleaned.rds $(CONFIG) | $(OUT)
	$(RSCRIPT) $(SRC)/4_join_airbnb_tenancy.R

clean:
	rm -f $(OUT)/*.rds $(OUT)/*.parquet