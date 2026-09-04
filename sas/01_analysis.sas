/* Suicide Related Indicators and Trends in Korea in 2018 */

libname KHANES "&KHANES_DIR" access=readonly;
libname KOWEPS "&KOWEPS_DIR" access=readonly;
%require_data(KHANES.HN07_ALL);
%require_data(KHANES.HN08_ALL);
%require_data(KHANES.HN09_ALL);
%require_data(KHANES.HN10_ALL);
%require_data(KHANES.HN11_ALL);
%require_data(KHANES.HN12_ALL);
%require_data(KHANES.HN13_ALL);
%require_data(KHANES.HN14_ALL);
%require_data(KHANES.HN15_ALL);
%require_data(KHANES.HN16_ALL);
%require_data(KHANES.HN17_ALL);
%require_data(KHANES.HN18_ALL);
%require_data(KOWEPS.koweps_hp01_13_long_beta1);
%if not %sysfunc(fileexist(%superq(MORTALITY_FILE))) %then %do;
    %put ERROR: Input file &MORTALITY_FILE is missing.;
    %abort cancel;
%end;
proc contents data=KHANES.HN07_ALL varnum; run;
proc contents data=KHANES.HN08_ALL varnum; run;
proc contents data=KHANES.HN09_ALL varnum; run;
proc contents data=KHANES.HN10_ALL varnum; run;
proc contents data=KHANES.HN11_ALL varnum; run;
proc contents data=KHANES.HN12_ALL varnum; run;
proc contents data=KHANES.HN13_ALL varnum; run;
proc contents data=KHANES.HN14_ALL varnum; run;
proc contents data=KHANES.HN15_ALL varnum; run;
proc contents data=KHANES.HN16_ALL varnum; run;
proc contents data=KHANES.HN17_ALL varnum; run;
proc contents data=KHANES.HN18_ALL varnum; run;
proc contents data=KOWEPS.koweps_hp01_13_long_beta1 varnum; run;

/* KNHANES */
    RUN;
/* Combine KNHANES annual survey files */
DATA KHANES_1;
SET KHANES.HN07_ALL KHANES.HN08_ALL KHANES.HN09_ALL KHANES.HN10_ALL KHANES.HN11_ALL KHANES.HN12_ALL
    KHANES.HN13_ALL KHANES.HN14_ALL KHANES.HN15_ALL KHANES.HN16_ALL KHANES.HN17_ALL KHANES.HN18_ALL;
RUN;

/* Adult suicidal ideation was not collected in 2014, 2016, or 2018; adult attempts were not collected in 2014 */
DATA KHANES_2;
SET KHANES_1;
IF MISSING(AGE) OR AGE<19 OR MISSING(INCM) THEN DELETE;
IF BP6_10=8 THEN BP6_10=2;
IF BP6_31=8 THEN BP6_31=2;
IF BP6_10 NOT IN (1,2) THEN BP6_10=.;
IF BP6_31 NOT IN (1,2) THEN BP6_31=.;
/* Adult ideation was not asked in these waves. */
IF YEAR IN (2014,2016,2018) THEN BP6_10=.;
IF YEAR=2014 THEN BP6_31=.;
RUN;

/* Annual KNHANES suicidal ideation and attempt estimates */				/* Survey item availability varies by year */
/* Unweighted suicidal ideation */
PROC SURVEYFREQ DATA=KHANES_2;
TABLE YEAR*BP6_10;
RUN;

/* Weighted suicidal ideation */
PROC SURVEYFREQ DATA=KHANES_2;
STRATA KSTRATA;
CLUSTER PSU;
WEIGHT WT_ITVEX;
TABLE YEAR*BP6_10;
RUN;

/* Unweighted suicide attempts */
PROC SURVEYFREQ DATA=KHANES_2;
WHERE YEAR=2018;
TABLE BP6_31*YEAR;
RUN;

/* Weighted suicide attempts */
PROC SURVEYFREQ DATA=KHANES_2;
WHERE YEAR=2018;
STRATA KSTRATA;
CLUSTER PSU;
WEIGHT WT_ITVEX;
TABLE BP6_31*YEAR;
RUN;

/* KNHANES estimates by year and income quartile */
PROC SORT DATA=KHANES_2;
BY INCM YEAR;
RUN;

/* Unweighted suicidal ideation */
proc sort data=KHANES_2 out=work._by_input; by INCM; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2017;
TABLE BP6_10*YEAR;
BY INCM;
RUN;

/* Weighted suicidal ideation */
proc sort data=KHANES_2 out=work._by_input; by INCM; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2017;
STRATA KSTRATA;
CLUSTER PSU;
WEIGHT WT_ITVEX;
TABLE BP6_10*YEAR;
BY INCM;
RUN;

/* Unweighted suicide attempts */
proc sort data=KHANES_2 out=work._by_input; by INCM; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2018;
TABLE BP6_31*YEAR;
BY INCM;
RUN;

/* Weighted suicide attempts */
proc sort data=KHANES_2 out=work._by_input; by INCM; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2018;
STRATA KSTRATA;
CLUSTER PSU;
WEIGHT WT_ITVEX;
TABLE BP6_31*YEAR;
BY INCM;
RUN;

/* Annual percentage change in KNHANES */
/* Suicidal ideation */
PROC GENMOD DATA=KHANES_2;
WHERE YEAR IN (2007,2008,2009,2010,2011,2012,2013,2015,2017,2018);
/* BY INCM; */
WEIGHT WT_ITVEX;
MODEL BP6_10(EVENT="1")=YEAR/LINK=LOG DIST=BIN;
ESTIMATE "Annual rate ratio" YEAR 1 / EXP;
RUN;

/* Suicide attempts */
PROC GENMOD DATA=KHANES_2;
WHERE YEAR IN (2007,2008,2009,2010,2011,2012,2013,2015,2016,2017,2018);
/* BY INCM; */
WEIGHT WT_ITVEX;
MODEL BP6_31(EVENT="1")=YEAR/LINK=LOG DIST=BIN;
ESTIMATE "Annual rate ratio" YEAR 1 / EXP;
RUN;

/* Korea Community Health Survey */	/* No additional annual wave in this script */
/* Korea Health Panel */	/* No additional annual wave in this script */
/* Korean Welfare Panel Study */
/* Combine KoWePS data, survey years 2012-2018 */
DATA KOWEPS_1;
SET KOWEPS.koweps_hp01_13_long_beta1;
RUN;

DATA KOWEPS_2;
SET KOWEPS_1;
YEAR=YEAR+1;				/* Survey year equals reference year plus one */
AGE=year-h_g4+1;		/* Age */
INCM=h_cin;					/* Current household income */
MEMBER=h01_1;			/* Household size */
INCM1=INCM/SQRT(MEMBER);
IF p05_7aq1=1 THEN S_IDEATION=1;		/* Past-year suicidal ideation: p05_7aq1 */
ELSE IF p05_7aq1=2 THEN S_IDEATION=2;
IF p05_7aq3=1 THEN S_ATTEMPT=1;		/* Past-year suicide attempt: p05_7aq3 */
ELSE IF p05_7aq3=2 THEN S_ATTEMPT=2;
RUN;

/* Annual equivalized income quartiles */
/* 2012 equivalized income quartiles */
    PROC UNIVARIATE DATA=KOWEPS_2 NOPRINT;
    WHERE YEAR=2012;
    VAR INCM1;
    OUTPUT OUT=P_2012 PCTLPRE=P_ PCTLPTS=25 50 75;
    WEIGHT p_wsc;
    RUN;
    /* 2013 equivalized income quartiles */
    PROC UNIVARIATE DATA=KOWEPS_2 NOPRINT;
    WHERE YEAR=2013;
    VAR INCM1;
    OUTPUT OUT=P_2013 PCTLPRE=P_ PCTLPTS=25 50 75;
    WEIGHT p_wsc;
    RUN;
    /* 2014 equivalized income quartiles */
    PROC UNIVARIATE DATA=KOWEPS_2 NOPRINT;
    WHERE YEAR=2014;
    VAR INCM1;
    OUTPUT OUT=P_2014 PCTLPRE=P_ PCTLPTS=25 50 75;
    WEIGHT p_wsc;
    RUN;
    /* 2015 equivalized income quartiles */
    PROC UNIVARIATE DATA=KOWEPS_2 NOPRINT;
    WHERE YEAR=2015;
    VAR INCM1;
    OUTPUT OUT=P_2015 PCTLPRE=P_ PCTLPTS=25 50 75;
    WEIGHT p_wsc;
    RUN;
    /* 2016 equivalized income quartiles */
    PROC UNIVARIATE DATA=KOWEPS_2 NOPRINT;
    WHERE YEAR=2016;
    VAR INCM1;
    OUTPUT OUT=P_2016 PCTLPRE=P_ PCTLPTS=25 50 75;
    WEIGHT p_wsc;
    RUN;
    /* 2017 equivalized income quartiles */
    PROC UNIVARIATE DATA=KOWEPS_2 NOPRINT;
    WHERE YEAR=2017;
    VAR INCM1;
    OUTPUT OUT=P_2017 PCTLPRE=P_ PCTLPTS=25 50 75;
    WEIGHT p_wsc;
    RUN;
    /* 2018 equivalized income quartiles */
    PROC UNIVARIATE DATA=KOWEPS_2 NOPRINT;
    WHERE YEAR=2018;
    VAR INCM1;
    OUTPUT OUT=P_2018 PCTLPRE=P_ PCTLPTS=25 50 75;
    WEIGHT p_wsc;
    RUN;
PROC UNIVARIATE DATA=KOWEPS_2;
VAR INCM1;
RUN;

    /* Assign annual equivalized income quartiles */
DATA KOWEPS_3;
SET KOWEPS_2;
IF YEAR<2012 THEN DELETE;
IF MISSING(INCM1) THEN DO; Q4=.; OUTPUT; RETURN; END;
IF YEAR=2012 THEN DO;
IF 0<INCM1<=1689.3268876 THEN Q4=1;
ELSE IF INCM1<=2518.4018742 THEN Q4=2;
ELSE IF INCM1<=3569.7567144 THEN Q4=3;
ELSE IF INCM1>3569.7567144 THEN Q4=4;
END;
IF YEAR=2013 THEN DO;
IF 0<INCM1<=1835.973856 THEN Q4=1;
ELSE IF INCM1<=2708.2189719 THEN Q4=2;
ELSE IF INCM1<=3836.339401 THEN Q4=3;
ELSE IF INCM1>3836.339401 THEN Q4=4;
END;
IF YEAR=2014 THEN DO;
IF 0<INCM1<=1833.6644549 THEN Q4=1;
ELSE IF INCM1<=2798.1260243 THEN Q4=2;
ELSE IF INCM1<=3994.5 THEN Q4=3;
ELSE IF INCM1>3994.5 THEN Q4=4;
END;
IF YEAR=2015 THEN DO;
IF 0<INCM1<=1883.7324651 THEN Q4=1;
ELSE IF INCM1<=2796.5 THEN Q4=2;
ELSE IF INCM1<=3993 THEN Q4=3;
ELSE IF INCM1>3993 THEN Q4=4;
END;
IF YEAR=2016 THEN DO;
IF 0<INCM1<=2044.213345 THEN Q4=1;
ELSE IF INCM1<=2980.4550827 THEN Q4=2;
ELSE IF INCM1<=4227.9573319 THEN Q4=3;
ELSE IF INCM1>4227.9573319 THEN Q4=4;
END;
IF YEAR=2017 THEN DO;
IF 0<INCM1<=2143 THEN Q4=1;
ELSE IF INCM1<=3123.2906525 THEN Q4=2;
ELSE IF INCM1<=4366.5 THEN Q4=3;
ELSE IF INCM1>4366.5 THEN Q4=4;
END;
IF YEAR=2018 THEN DO;
IF 0<INCM1<=2261.4810044 THEN Q4=1;
ELSE IF INCM1<=3303.56683 THEN Q4=2;
ELSE IF INCM1<=4636 THEN Q4=3;
ELSE IF INCM1>4636 THEN Q4=4;
END;
RUN;

DATA KOWEPS_4;
SET KOWEPS_3;
IF S_IDEATION=. THEN DELETE;
IF S_ATTEMPT=. THEN DELETE;
IF AGE<19 THEN DELETE;
RUN;

/* Annual KoWePS suicidal ideation and attempt estimates */
/* Unweighted suicidal ideation */
PROC SURVEYFREQ DATA=KOWEPS_4;
WHERE YEAR=2018;
TABLE S_IDEATION*YEAR;
RUN;

/* Weighted suicidal ideation */
PROC SURVEYFREQ DATA=KOWEPS_4;
WHERE YEAR=2018;
WEIGHT p_wsc;
TABLE S_IDEATION*YEAR;
RUN;

/* Unweighted suicide attempts */
PROC SURVEYFREQ DATA=KOWEPS_4;
WHERE YEAR=2018;
TABLE S_ATTEMPT*YEAR;
RUN;

/* Weighted suicide attempts */
PROC SURVEYFREQ DATA=KOWEPS_4;
WHERE YEAR=2018;
WEIGHT p_wsc;
TABLE S_ATTEMPT*YEAR;
RUN;

/* KoWePS estimates by year and income quartile */
PROC SORT DATA=KOWEPS_4;
BY Q4 YEAR;
RUN;

/* Unweighted suicidal ideation */
proc sort data=KOWEPS_4 out=work._by_input; by Q4; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2018;
TABLE S_IDEATION*YEAR;
BY Q4;
RUN;

/* Weighted suicidal ideation */
proc sort data=KOWEPS_4 out=work._by_input; by Q4; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2018;
WEIGHT p_wsc;
TABLE S_IDEATION*YEAR;
BY Q4;
RUN;

/* Unweighted suicide attempts */
proc sort data=KOWEPS_4 out=work._by_input; by Q4; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2018;
TABLE S_ATTEMPT*YEAR;
BY Q4;
RUN;

/* Weighted suicide attempts */
proc sort data=KOWEPS_4 out=work._by_input; by Q4; run;
PROC SURVEYFREQ DATA=work._by_input;
WHERE YEAR=2018;
WEIGHT p_wsc;
TABLE S_ATTEMPT*YEAR;
BY Q4;
RUN;

/* Annual percentage change in KoWePS */
/* Suicidal ideation */
PROC GENMOD DATA=KOWEPS_4;
MODEL S_IDEATION(EVENT="1")=YEAR/LINK=LOG DIST=BIN;
ESTIMATE "Annual rate ratio" YEAR 1 / EXP;
RUN;

/* Suicide attempts */
PROC GENMOD DATA=KOWEPS_4;
MODEL S_ATTEMPT(EVENT="1")=YEAR/LINK=LOG DIST=BIN;
ESTIMATE "Annual rate ratio" YEAR 1 / EXP;
RUN;

/* Statistics Korea mortality: annual percentage change */
/* 2007~2018 */
PROC IMPORT OUT=STAT_DEATH
DATAFILE="&MORTALITY_FILE"
DBMS=XLSX REPLACE;
GETNAMES=YES;


RUN;

PROC GENMOD DATA=STAT_DEATH;
WHERE YEAR>=2011;
MODEL RATE=YEAR / LINK=LOG;
ESTIMATE "Annual rate ratio" YEAR 1 / EXP;
RUN;

%cohort_summary(KOWEPS_4,vars=S_IDEATION S_ATTEMPT);
