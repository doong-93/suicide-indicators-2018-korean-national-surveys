# suicide-indicators-2018-korean-national-surveys (KNHANES)

Analysis code for **Suicide Related Indicators and Trends in Korea in 2018**.

**Publication:** Health Policy and Management, 2020. [Published article](https://doi.org/10.4332/KJHPA.2020.30.1.112).

## Data and analyses

**Data source:** KNHANES, KoWePS, and Statistics Korea mortality statistics; the article also summarizes KCHS and Korea Health Panel trends.

Annual suicidal ideation and suicide attempt indicators, income-stratified estimates, and annual percentage change.

Participant-level data are obtained separately from the relevant data provider and are not distributed in this repository.

## Contents

- `run_all.sas`: entry point and output management.
- `config/paths.example.sas`: input path settings.
- `sas/00_helpers.sas`: input, cohort, and duplicate-key checks.
- `sas/01_analysis.sas`: data preparation, descriptive analyses, and statistical models.
- `outputs/`: local results; each run writes to a separate folder.

## Use

1. Use SAS 9.4M5 or later with SAS/STAT. Excel and Stata imports also require the corresponding SAS/ACCESS support.
2. Copy `config/paths.example.sas` to `config/paths.local.sas` and enter the paths to the study data.
3. Set `PROJECT_ROOT` in `run_all.sas` to the absolute path of this repository.
4. Submit `run_all.sas`. Results are written under `outputs/`.

Input libraries are read-only. Intermediate datasets are created in SAS WORK.

## Citation

Lee DW et al. Suicide Related Indicators and Trends in Korea in 2018. *Health Policy and Management*. 2020. https://doi.org/10.4332/KJHPA.2020.30.1.112
