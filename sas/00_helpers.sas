/* Shared input and cohort checks. */
%macro require_data(ds);
  %if not %sysfunc(exist(&ds)) %then %do;
    %put ERROR: Required dataset &ds does not exist.;
    %abort cancel;
  %end;
%mend;

%macro cohort_summary(ds,vars=);
  %require_data(&ds);
  title "Cohort summary: &ds";
  proc sql; select count(*) as Observations from &ds; quit;
  %if %length(%superq(vars)) %then %do;
    proc means data=&ds n nmiss min max; var &vars; run;
  %end;
  title;
%mend;

%macro require_unique(ds,keys);
  %local duplicates;
  proc sql noprint;
    select count(*) into :duplicates trimmed from
      (select &keys, count(*) as records from &ds
       group by &keys having calculated records>1);
  quit;
  %if &duplicates>0 %then %do;
    %put ERROR: &ds has &duplicates duplicated keys (&keys).;
    %abort cancel;
  %end;
%mend;
