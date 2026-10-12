RSCRIPT := Rscript
PYTHON  := renv/python/virtualenvs/renv-python-3.13/Scripts/python.exe

SRC    := src
DATA   := ../data_LAND
OUT    := out
CONFIG := config.yaml

LISTINGS := $(wildcard $(DATA)/listings_20*.csv)
$(if $(LISTINGS),,$(error No listings CSVs found in $(DATA)))

PLOTS := $(OUT)/d3_highest_reviews.png \
         $(OUT)/d3_last_review_days.png \
         $(OUT)/d3_price_distribution.png \
         $(OUT)/d5_airbnb_rentals_location_comparison.png

GAPS := $(OUT)/gap_sa2.rds \
        $(OUT)/gap_sa3.rds

REPORT := $(OUT)/report.html

.PHONY: all plots tables report clean
.DELETE_ON_ERROR:

all: $(OUT)/joined_airbnb_tenancy.rds $(PLOTS) $(GAPS) $(REPORT)

plots: $(PLOTS)

tables: $(GAPS)

report: $(REPORT)

$(OUT):
	mkdir -p $(OUT)

# Step 1: clean Airbnb listings (two outputs from one run)
$(OUT)/listings_chch.rds $(OUT)/listings_chch_cleaned.parquet &: $(SRC)/1_cleaning_airbnb_chch.R $(LISTINGS) $(CONFIG) | $(OUT)
	$(RSCRIPT) $<

# Step 2: clean tenancy data
$(OUT)/tenancy_cleaned.rds: $(SRC)/2_cleaning_tenancy.R $(DATA)/Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv $(CONFIG) | $(OUT)
	$(RSCRIPT) $<

# Step 3: add area codes (slow)
$(OUT)/airbnb_chch_codes.parquet: $(SRC)/3_enriching_airbnb_areacodes.py $(OUT)/listings_chch_cleaned.parquet $(CONFIG) | $(OUT)
	$(PYTHON) $<

# Step 4: join Airbnb and tenancy
$(OUT)/joined_airbnb_tenancy.rds: $(SRC)/4_join_airbnb_tenancy.R $(OUT)/airbnb_chch_codes.parquet $(OUT)/tenancy_cleaned.rds $(CONFIG) | $(OUT)
	$(RSCRIPT) $<

# d3 plots: depend on cleaned listings
$(OUT)/d3_%.png: $(SRC)/d3_%.R $(OUT)/listings_chch.rds $(CONFIG) | $(OUT)
	$(RSCRIPT) $<

# d5 plots: depend on the joined data
$(OUT)/d5_%.png: $(SRC)/d5_%.R $(OUT)/joined_airbnb_tenancy.rds $(CONFIG) | $(OUT)
	$(RSCRIPT) $<

# d5 gap tables (two outputs from one run)
$(OUT)/gap_sa2.rds $(OUT)/gap_sa3.rds &: $(SRC)/d5_rental_price_gap.R $(OUT)/joined_airbnb_tenancy.rds $(CONFIG) | $(OUT)
	$(RSCRIPT) $<

# Report: rebuilds when the Rmd, any plot or any table changes
$(REPORT): report.Rmd $(PLOTS) $(GAPS) | $(OUT)
	$(RSCRIPT) -e "rmarkdown::render('$<', output_file = 'report.html', output_dir = '$(OUT)')"

clean:
	rm -f $(OUT)/*.rds $(OUT)/*.parquet $(OUT)/*.png $(OUT)/*.html