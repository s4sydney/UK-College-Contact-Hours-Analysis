/********************************************************************************/
/*	Author:  Sydney Ndabai (P2929107)						Date: 25 March 2026		*/
/*	Title:	Contact Learning Hours Analysis - P2929107.sas			*/
/*	Version: 1.0																*/
/*	Course: CSIP5302 Data Mining - Report on Contact Learning Hours in FE and SixthForm*/
/*  Module  : CSIP5302 Data Mining and Application
/********************************************************************************/



                /* =====================IMPORTING ALL 3 FILES==============================*/;

filename cwd 'H:/P2929107 DATA MINING/P2929107'; 
libname P2929107 'H:/P2929107 DATA MINING/P2929107';



              /* =====================IMPORTING  CSIP5302-6FORM.CSV FILE==============================*/;
                
/* From Lab Week 3 lines 574-575  using infile with quoted filename */
data sixthform_raw;
infile cwd ('CSIP5302-6form.csv') dsd dlm=',' firstobs=2 missover;
input
    TotalCHYear1  /*was mislabelled in the raw data set as TotalCHlearners*/
    Learners1
    TotalCHYear2
    Learners2
    TotalCHYear3
    Learners3
    GradPR
    VAF
    Institution : $ 40.
    Region : $ 40.
    GPercentFemale
    ;
    
   /*  From Lab Week 1B worksheet in lines 874-896 using the Label function*/
     label
        TotalCHYear1   = 'Total Contact Hours Year 1'
        Learners1      = 'Number of Learners Year 1'
        TotalCHYear2   = 'Total Contact Hours Year 2'
        Learners2      = 'Number of Learners Year 2'
        TotalCHYear3   = 'Total Contact Hours Year 3'
        Learners3      = 'Number of Learners Year 3'
        GradPR         = 'Graduation Pass Rate (average 3 years)'
        VAF            = 'Value Add Factor (average 3 years)'
        Institution    = 'Institution Type'
        Region         = 'Geographic Region'
        GPercentFemale = 'Percentage Female Students';
    run;
    
     /* From Lab Week 1B line 911-912 using the  proc print to verify the file imported            */
proc print data=sixthform_raw (obs=10) label;
title 'Sixthform Raw Data';
run; 
title;
    
     /* From Lab Week 1B line 908-908 using the proc contents print to check the data structure             */
proc contents data=sixthform_raw order=varnum;
title 'SixthForm_raw Structure';
run;
ods select all;
title;

  /* =====================IMPORTING  CSIP5302-FE.CSV FILE==============================*/; 

data fe_raw;
/* From Lab Week 3 lines 574-575 using infile with quoted filename */
infile cwd ('CSIP5302-FE.csv') dsd dlm=',' firstobs=2 missover;

/* From Lab2 worksheet lines 327-332 using the  INFILE/INPUT statement */;

input
    ID
    Institution : $ 40.
    Region : $ 40. 
    TotalCHYear1
    Learners1
    TotalCHYear2
    Learners2
    TotalCHYear3
    Learners3
    GPercentMale
     ;
     
     label
		ID='Institution ID'
		Institution='Institution Type'
		Region='Region'
		TotalCHYear1='Total Contact Hours Year 1'
		Learners1='Number of Learners Year 1'
		TotalCHYear2='Total Contact Hours Year 2'
		Learners2='Number of Learners Year 2'
		TotalCHYear3='Total Contact Hours Year 3'
		Learners3='Number of Learners Year 3'
		GPercentMale='Percentage Of Male'
		;
		
		  /* From Lab Week 1B line 911-912 using the  proc print to verify the file import             */
proc print data=fe_raw (obs=10) label;
title 'FE Raw Data';
run;
title;
		    /* From Lab Week 1B line 908-908 using the proc contents print to check the data structure             */
proc contents data=fe_raw order=varnum;
title 'fe_raw Structure';
run;
ods select all;
title;

     run;
     
   /* =====================IMPORTING  CSIP5302-FEMETRIC01.TAB FILE==============================*/;
    

data femetric01_raw;
infile cwd ('CSIP5302-FEmetric01.tab') dsd dlm='09'x firstobs=2 missover ;

input 
ID	
GradPR2	 
VAF2     
;

    label
        ID     = 'College ID (Primary Key)'
        GradPR2 = 'Graduation Pass Rate (FE)'
        VAF2    = 'Value Add Factor (FE)'
    ;

run;
proc print data=femetric01_raw (obs=10) label;
title'femetric01 Raw Data';
run ;
title;
 
 		    /* From Lab Week 1B line 908-908 using the proc contents print to check the data structure             */
proc contents data=femetric01_raw order=varnum;
title 'femetric01_raw Structure';
run;
ods select all;
title;
           /* Checking how many rows imported and how many missing values exist in the file               */
proc means data=femetric01_raw n nmiss min max maxdec=4;
title 'Summary of FEmetrics_raw [check for missing values]';
run;
title;

              /*======================= DATA CLEANING=============================*/
             
 /* ==========  Cleaning CSIP5302-6form.CSV data ==========   */
    data sixthform_clean;
    set sixthform_raw;

    /* Removing sub-total rows: Institution contains "Sub Total" or "Grand Total"     */
    /* from Lab Week 3 lines 776-778 using the if condition then delete           */
    
    if index(Institution, 'Sub Total')   > 0 then delete;
    if index(Institution, 'Grand Total') > 0 then delete;

    /* Removing the rows where institution is blank (incomplete rows from file end)        */
    if Institution = '' then delete;

    /* Flag rows with any missing Contact hours or Learner values for report commentary    */
    /* from Lab Week 3 lines 685-69 using the if/else derived variable          */
   length MissingFlag $15.;
    if TotalCHYear1 = . or Learners1 = . then MissingFlag = 'Year1_Missing';
    else if TotalCHYear2 = . or Learners2 = . then MissingFlag = 'Year2_Missing';
    else if TotalCHYear3 = . or Learners3 = . then MissingFlag = 'Year3_Missing';
    else MissingFlag = 'Complete';

    /* Adding an ID variable for sixth Form colleges because no ID in original the csv file        */
    /*  using a counter: ID starts at 1001 so it won't clash with FE file IDs 1-255  */
   

    /* from Lab Week 7 labsheet lines 492-494 using the ID + 1 counter pattern   */
    format SFid 6.;
    SFid + 1;
    ID = 1000 + SFid;  /* ID starts at 1001, 1002, 1003... no clash with FE IDs */

    label MissingFlag = 'Data Completeness Flag';

run;
proc print data=sixthform_clean label;
title 'sixth form clean data';
run;
title;



 /* ==========  Cleaning CSIP5302-FE.CSV data ==========   */

data fe_clean
     fe_anomalies;  /* separating dataset to hold rows flagged as anomalies */

    set fe_raw;

    /* Remove the one sub-total row: Institution = 'Sub Total East Midlands...'     */
    /* From Lab Week 3 worksheet lines 776-778 using the if - then delete statement               */
    if Institution ne 'FE College' then delete;
    
    /* from Lab Week 3 lines 685-692 using the if/else derived variable          */
    length MissingFlag $15.;
    if TotalCHYear1 = . or Learners1 = . then MissingFlag = 'Year1_Missing';
    else if TotalCHYear2 = . or Learners2 = . then MissingFlag = 'Year2_Missing';
    else if TotalCHYear3 = . or Learners3 = . then MissingFlag = 'Year3_Missing';
    else MissingFlag = 'Complete';

    label MissingFlag = 'Data Completeness Flag';

    /* ANOMALY: ID=79 its labelled FE College but Region is blank and            */
    /* CH values are approx 78 million which is incredibly large (grand total level) */
    /* Decision: route to anomalies dataset; exclude from main analysis         */
   
   
    /* From Lab Week 5 worksheet lines 308-312 using output to named dataset           */
    if ID = 79 then output fe_anomalies;
    else output fe_clean;

run;

proc print data=fe_anomalies ;
run;

proc print data=fe_clean ;
run;

 /* ==========  Cleaning CSIP5302-FEmetric01.tab data ==========   */

data femetric01_clean;
    set femetric01_raw;

    /* Removing the blank row line 22 in the file because ID is missing            */
    /*  From Lab Week 5 worksheet lines 252-255 using if missing then delete             */
    if ID = . then delete;

    /* from the file , IDs 79 and 243 have missing GradPR and VAF.                       */
    /* We keep them here ,so after the merge will produce missing values naturally,     */
    /* which will be documented as a data quality issue in the report.                 */

run;
proc print data=femetric01_clean label;
title 'femetric01_clean data';
run;
title; 

/* ===== Quality Control check for all three cleaned files=====    */

/* ======= From Lab Week 3 worksheet lines 806-810 using the proc freq for Quality Control========  */;
proc freq data=sixthform_clean noprint;
    table Institution * Region / out=qc_sf;
run;

proc print data=qc_sf;
    title 'Sixth Form colleges by Region (should be only Sixth Form College)';
run;
title;

proc freq data=fe_clean noprint;
    table Institution * Region / out=qc_fe;
run;

proc print data=qc_fe;
    title 'Quality control FE colleges by Region (should be only FE College)';
run;
title;

/* Checking for  MissingFlag distribution across both files                             */
proc freq data=sixthform_clean;
    table MissingFlag;
    title 'Sixth Form  Data completeness by row';
run;

proc freq data=fe_clean;
    table MissingFlag;
    title 'FE Data completeness by row';
run;
title;

/* Checking anomalies dataset because we need to confirm what was removed                           */
proc print data=fe_anomalies label;
    title 'Anomalous rows removed from FE dataset (ID=79)';
run;
title;

/********************************************************************************/
/*        =========MERGING FE DATA WITH METRICS=====                            */
/*   Firstly joining fe_clean with femetric01_clean on ID which is the primary key */
/*   Using the  'in=' flags to identify and log non-matching rows for Quality Control */
/*                                                                              */
/********************************************************************************/

/* starting by sorting both datasets by ID before merging                              */
/* from Lab Week 5 worksheet lines 989-991 using the proc sort before merging                */
proc sort data=fe_clean;
    by ID;
run;

proc sort data=femetric01_clean;
    by ID;
run;

/* The raw femetric01_tab file uses column headers GradPR2 and VAF2.       */
/* However, sixthform_clean uses GradPR and VAF for the same metrics.          */
/* Without renaming here, fe_merged gets GradPR2/VAF2 columns while           */
/* AllColleges analysis expects GradPR/VAF -- FE colleges would have missing   */
/* values throughout every analysis,so renaming on the merge using dataset    */
/* option rename= so both sides land in the same GradPR and VAF columns.      */

/* from Lab Week 5 lines 821-826 using DATA merge with in= flags              */
data fe_merged;

    merge
        fe_clean     (in=inFE)
        femetric01_clean (in=inMet
                          rename=(GradPR2=GradPR VAF2=VAF));
                          /* RENAME: GradPR2->GradPR and VAF2->VAF             */
                          /* The femetric01_tab file named them GradPR2/VAF2 but they     */
                          /* represent the same metric as sixthform GradPR/VAF */
    by ID;

    /* Capture the 'in= flag values so we can Quality Control the match                      */
    /* from Lab Week 5 line 757 using the  cin=CAFEIN pattern                     */
    FEin  = inFE;
    Metin = inMet;

run;

/* running quality control , checking how many rows matched on both sides                       */
/* from Lab Week 5 lines 1009-1011 using the proc freq on merge in= flags        */
proc freq data=fe_merged;
    table FEin * Metin / nocum nopercent missing;
    title 'Quality Control Merge match check -- FE (rows) x femetric01 (cols)';
    /* FEin=1 Metin=1 = matched rows (good)                                    */
    /* FEin=1 Metin=0 = FE row with NO matching metric (data gap)              */
    /* FEin=0 Metin=1 = Metric with no matching FE row (orphan metric)         */
run;
title;

/* Now printing unmatched rows for report commentary                           */
/* From Lab Week 5 lines 763-764 using where cin=0 to find mismatches        */
proc print data=fe_merged label;
    where Metin=0;
    title 'Quality Control for FE rows with no matching metric record';
run;
title;

/* Dropping the in= helper flags from the final merged dataset              */
/* From Lab Week 5 lines 152-153 using the drop statement                        */
data fe_merged;
    set fe_merged;
    drop FEin Metin;
run;

proc print data=fe_merged (obs=max) label;
    title ' Rows of merged FE + femetric01 dataset';
run;
title;

/********************************************************************************/
/*                                                                              */
/*    STACKING SIXTH FORM AND FE INTO ONE COMBINED DATASET             */
/*                                                                              */
/*   Both datasets now have the same variable names                     */
/*   We stack them vertically using SET.                                        */
/*   Sixthform has GradPR and VAF already included in its file.                    */
/*   FE colleges get GradPR and VAF from the metrics merge                 */
/*                                                                              */
/*   Also the sixthorm uses GPercentFemale, while the FE uses GPercentMale.                    */
/*   creating a unified GPercentFemale for both using 100 - GPercentMale.     */
/********************************************************************************/

data AllColleges;

    /*From Lab Week 5 worksheet using the SET stacks datasets vertically           */
    set
        sixthform_clean  /* 100 sixth form colleges                      */
        fe_merged;       /* 254 FE colleges (ID=79 removed)              */

    /* FE file has GPercentMale; sixth form has GPercentFemale.                  */
    /* Deriving a consistent GPercentFemale for all rows.                        */
   
    /* From Lab Week 1B line 47 using calculated variable in data step       */
   
    if  GPercentFemale = . and GPercentMale ne . then
        GPercentFemale = 100 - GPercentMale;

    /* Droping GPercentMale now that we have a unified female percentage column   */
   
    /* from Lab Week 5 lines 152-153 using drop statement                   */
    drop GPercentMale SFid;

    label GPercentFemale = 'Percentage Female Students (unified)';

run;

/* Verifying total record count after stacking                                    */
proc freq data=AllColleges;
    table Institution / nocum;
    title 'Record count by institution type after stacking';
run;
title;
proc print data=AllColleges label;
title'All Colleges';
run;
title;


/********************************************************************************/
/* NOTE: We have to calculate the CHperLearner derived variables first         */
data AllColleges;
length SizeCategory  $15.;
    set AllColleges;

    /* CHperLearner per year */
    /* Guard against division by zero using IF check                            */
    /* From Lab Week 1B line 47 using calculated derived variables           */
    if Learners1 > 0 then CHperLearner_Yr1 = TotalCHYear1 / Learners1;
    if Learners2 > 0 then CHperLearner_Yr2 = TotalCHYear2 / Learners2;
    if Learners3 > 0 then CHperLearner_Yr3 = TotalCHYear3 / Learners3;

    /* Average CHperLearner across all three years                              */
    /* Using the mean() function it handles missing years                    */
   
    CHperLearner = mean(CHperLearner_Yr1, CHperLearner_Yr2, CHperLearner_Yr3);

    /* ==============SizeCategory based on average CHperLearner ==================== */
    /* From Lab Week 3 worksheet line 685 using format statement before conditionals   */

    if      CHperLearner >= 350              then SizeCategory = 'Large';
    else if CHperLearner >= 225              then SizeCategory = 'Large-Medium';
    else if CHperLearner >= 175              then SizeCategory = 'Medium';
    else if CHperLearner >= 125              then SizeCategory = 'Small-Medium';
    else if CHperLearner >  0               then SizeCategory = 'Small';
    else                                         SizeCategory = 'Unknown';
    /*The 'Unknown' column catches rows where CHperLearner could not be calculated */

    /* Labels for all new variables                                             */
    
    label
        CHperLearner_Yr1 = 'Contact Hours per Learner Year 1'
        CHperLearner_Yr2 = 'Contact Hours per Learner Year 2'
        CHperLearner_Yr3 = 'Contact Hours per Learner Year 3'
        CHperLearner     = 'Average Contact Hours per Learner'
        SizeCategory     = 'Institution Size Category'
    ;

run;

/*   OUTLIER DETECTION AND FILTERING                                           */
/*   KNOWN ANOMALIES DOCUMENTED:                                               */
/*     ID=79  : Removed  blank Region, CH~78 million                        */
/*              (Confirmed in both FE CSV and FEmetric01.tab -- consistent gap*/
/*     ID=243 : Kept but flagged -- missing Year2/3 CH data and missing        */
/*              GradPR/VAF in metrics file. Both files agree this record is    */
/*              incomplete. Included in dataset but noted in report.           */
/*     Line 22 (tab file): Completely blank row -- removed by if ID=. delete   */

/*   STATISTICAL OUTLIERS: Use IQR rule on CHperLearner                        */
/*   Any value below Q1 - 1.5*IQR or above Q3 + 1.5*IQR is an outlier          */
/*   Outliers are flagged and routed to a separate dataset, not deleted,       */
/*   so  it can be documented in the report appendix.                          */

/*******************************************************************************/
/*  Step 1: Calculating Q1, Q3 and IQR for CHperLearner                        */

/* From Lab Week 7 lines 148-156 using proc means with stackodsoutput          */
proc means data=AllColleges noprint;
    var CHperLearner;
    output out=CHstats q1=Q1 q3=Q3;
run;

/* Step 2: Pull Q1 and Q3 into macro variables so we can use in data step      */
/* From Lab Week 10 lines 26-28 using %let macro variables                     */
data _null_;
    set CHstats;
    IQR = Q3 - Q1;
    LowerFence = Q1 - 1.5 * IQR;
    UpperFence = Q3 + 1.5 * IQR;
    call symputx('LowerFence', LowerFence);
    call symputx('UpperFence', UpperFence);
    call symputx('Q1val', Q1);
    call symputx('Q3val', Q3);
    call symputx('IQRval', IQR);
run;

/* Print the fence values for the report                                       */
%put NOTE: CHperLearner Lower Fence = &LowerFence;
%put NOTE: CHperLearner Upper Fence = &UpperFence;
%put NOTE: Q1=&Q1val  Q3=&Q3val  IQR=&IQRval;

/* Step 3: Flag and separate outlier rows                                       */

/* From Lab Week 5 lines 308-312 using output to separate named datasets          */
data AllColleges_flagged
     AllColleges_clean    /* dataset used for all statistical analysis          */
     AllColleges_outliers; /* outlier rows documented for report appendix      */

    set AllColleges;

    /* Flag each row as outlier or normal                                       */
    /* From Lab Week 3 lines 685-692 using if/else derived variable               */
    length OutlierFlag $40.;

    if CHperLearner = . then OutlierFlag = 'Missing_CH';
    else if CHperLearner < &LowerFence then OutlierFlag = 'Low_Outlier';
    else if CHperLearner > &UpperFence then OutlierFlag = 'High_Outlier';
    else OutlierFlag = 'Normal';

    label OutlierFlag = 'Outlier Status (IQR method)';
    output AllColleges_flagged;

    /* Route to appropriate output dataset                                     */
    if OutlierFlag in ('Low_Outlier', 'High_Outlier') then
        output AllColleges_outliers;
    else
        output AllColleges_clean;

run;

/* Step 4: Reporting how many outliers were found and what they are               */
proc freq data=AllColleges_flagged;
    table OutlierFlag / nocum;
    title 'Outlier detection results [CHperLearner (IQR method)]';
run;
title;

proc print data=AllColleges_outliers label;
    var Institution Region CHperLearner SizeCategory GradPR VAF;
    title 'Outlier rows removed from analysis [documented for report appendix]';
run;
title;

/* Step 5: Confirming final clean record count ready for EDA and modelling        */
proc means data=AllColleges_clean n nmiss min max mean median maxdec=2;
    class Institution;
    var CHperLearner;
    title 'AllColleges_clean  [record count and CHperLearner summary after outliers has been removed]';
run;
title;

/* NOTE: All EDA, ANOVA and Regression below uses AllColleges_clean            */


/********************************************************************************/
/*                                                                              */
/*                   DERIVED VARIABLES                                             */
/*                                                                              */
/*    CHperLearner  [Contact Hours per Learner for each year + average]      */
/*    SizeCategory  [classify college by average CHperLearner]               */
/*                                                                              */
/*   SizeCategory boundary values below are based on the EDA     */

/********************************************************************************/

/* Quick print to verify derived variables                                      */
proc print data=AllColleges_clean (obs=10) label;
    var Institution Region CHperLearner_Yr1 CHperLearner_Yr2 CHperLearner_Yr3
        CHperLearner SizeCategory;
    title 'Derived variables [CHperLearner and SizeCategory]';
run;
title;

/* Frequency check on SizeCategory  to check if the 5 groups populated?       */
/* From Lab Week 3 lines 806-810 using proc freq                             */
proc freq data=AllColleges_clean;
    table SizeCategory * Institution / nocum nopercent;
    title ' SizeCategory by institution type ';
run;
title;


/********************************************************************************/
/*                                                                              */
/*                EXPLORATORY DATA ANALYSIS (EDA)                               */
/*                                                                              */
/*    Proc Means  [descriptive stats for key numeric variables]               */
/*    Proc Freq   [frequency tables for categorical variables]               */
/*    Proc Tabulate  [summary table by Region and Institution type]            */
/*    Metadata summary table for the report appendix                        */
/********************************************************************************/

/* ======Descriptive statistics for CHperLearner by Institution and Region ----  */

/* From Lab Week 3 lines 828-833 using the proc means with class                 */
proc means data=AllColleges_clean
    n nmiss min q1 median mean q3 max std maxdec=2;
    class Institution;
    var CHperLearner CHperLearner_Yr1 CHperLearner_Yr2 CHperLearner_Yr3;
    title 'CHperLearner descriptive statistics by Institution Type';
run;
title;

proc means data=AllColleges_clean
    n nmiss min q1 median mean q3 max std maxdec=2;
    class Region;
    var CHperLearner;
    title ' Average CHperLearner by Region';
run;
title;

proc means data=AllColleges_clean
    n nmiss min q1 median mean q3 max std maxdec=2;
    class Institution SizeCategory;
    var CHperLearner GradPR VAF GPercentFemale;
    title ' Key metrics by Institution Type and Size Category';
run;
title;

/* =====Checking Frequency tables======   */

/* From Lab Week 3 lines 806-810 using the proc freq                             */
proc freq data=AllColleges_clean;
    table Region * Institution / nocum nopercent;
    title 'College count by Region and Institution Type';
run;

proc freq data=AllColleges_clean;
    table SizeCategory / nocum;
    title 'College count by Size Category';
run;

proc freq data=AllColleges_clean;
    table MissingFlag * Institution / nocum nopercent;
    title 'Data completeness by Institution Type';
run;
title;

/* ======== Proc Tabulate cross-tabulation of CHperLearner ==================== */

/* From Nitrofen.sas lines 134-146 using proc tabulate with class and var    */

proc tabulate data=AllColleges_clean format=8.1;
    class  Institution Region SizeCategory;
    var    CHperLearner GradPR VAF;
    table  Institution * Region,
           CHperLearner * (n mean median std)
           GradPR * mean
           VAF * mean
    ;
    title 'CHperLearner, GradPR and VAF summary by Type and Region';
run;
title;

/* =====Metadata summary ,we have the number of obs, variables, missing values =====*/
/* From Lab Week 1B lines 268-270 using proc contents with ods exclude       */

ods exclude enginehost;
proc contents data=AllColleges_clean order=varnum;
    title 'Metadata [AllColleges compiled dataset]';
run;
ods select all;
title;

/* Count observations in final dataset                                          */
proc means data=AllColleges_clean n nmiss maxdec=0;
    var CHperLearner TotalCHYear1 TotalCHYear2 TotalCHYear3
        GradPR VAF GPercentFemale;
    title 'Missing value count per variable in AllColleges';
run;
title;

/* ======== CORRELATION ANALYSIS =============================================*/
/* Adding proc corr to examine relationships between all key numeric variables */

/* From Lab Week 9 lines 62-65 using proc means/corr for variable relationships  */

proc corr data=AllColleges_clean pearson;
    var CHperLearner GradPR VAF GPercentFemale;
    title 'Correlation matrix [CHperLearner, GradPR, VAF and GPercentFemale]';
run;
title;

/* Correlation broken down by Institution type to see if relationships differ  */
/* Correlation broken down by Institution type                                 */
/* From Lab Week 5 worksheet lines 763-764 using where statement to find       */
/* mismatches -- same WHERE= pattern applied here to filter by group           */

proc corr data=AllColleges_clean (where=(Institution='FE College'))
    pearson nosimple;
    var CHperLearner GradPR VAF GPercentFemale;
    title 'Correlation matrix -- FE Colleges only';
run;
title;

proc corr data=AllColleges_clean (where=(Institution='Sixth Form College'))
    pearson nosimple;
    var CHperLearner GradPR VAF GPercentFemale;
    title 'Correlation matrix -- Sixth Form Colleges only';
run;
title;
/* ======== GENDER ANALYSIS ==================================================*/
/* Examining effect of gender on CHperLearner and GradPR       */
/* GPercentFemale is the unified gender variable created in the stacking step  */
/* From Lab Week 3 lines 828-833 using teh proc means with class                      */

proc means data=AllColleges_clean
    n nmiss min q1 median mean q3 max std maxdec=2;
    class Institution;
    var GPercentFemale;
    title 'Gender composition (Percentage of Female) by Institution Type';
run;
title;

proc means data=AllColleges_clean
    n nmiss min q1 median mean q3 max std maxdec=2;
    class Region;
    var GPercentFemale;
    title 'Gender composition (% Female) by Region';
run;
title;

/* GPercentFemale distribution by Institution and Region             */
/* From Lab Week 7 lines 181-185 using proc sgplot vbox                          */
ods graphics on;

title 'Gender Composition (Percentage of Female) by Institution Type';
proc sgplot data=AllColleges_clean;
    vbox GPercentFemale / category=Institution;
    xaxis label='Institution Type';
    yaxis label='Percentage Female Students';
run;
title;

ods graphics off;

/********************************************************************************/
/*                                                                              */
/*                 DATA VISUALISATIONS                                         */
/*                                                                              */
/*   Boxplots [CHperLearner by Institution, Region, SizeCategory]               */
/*   Histograms [distribution of CHperLearner, GradPR, VAF]                */
/*   Scatter matrix [correlations between key variables]                    */
/*   Time trend [CHperLearner across Year 1, 2, 3]                         */
/********************************************************************************/

/* ========================Boxplots ==========================================   */

/* CHperLearner by Institution Type                                             */
/* From Lab Week 7 lines 181-185 using proc sgplot vbox                      */
proc sgplot data=AllColleges_clean;
    vbox CHperLearner / category=Institution;
    xaxis label='Institution Type';
    yaxis label='Average Contact Hours per Learner';
    title 'Distribution of CHperLearner by Institution Type';
run;
title;

/* CHperLearner by Region, separated by Institution                                 */
proc sgplot data=AllColleges_clean;
    vbox CHperLearner / category=Region group=Institution;
    xaxis label='Region' fitpolicy=rotate;
    yaxis label='Average Contact Hours per Learner';
    keylegend / title='Institution Type';
    title 'CHperLearner by Region and Institution Type';
run;
title;

/* GradPR by SizeCategory and Institution                                           */
proc sgplot data=AllColleges_clean (where=(Institution='FE College'));
    vbox GradPR / category=SizeCategory;
    xaxis label='Size Category';
    yaxis label='Graduation Pass Rate';
    title 'Graduation Pass Rate by Size Category -- FE Colleges';
run;
title;

/* VAF by Region                                                                */
proc sgplot data=AllColleges_clean;
    vbox VAF / category=Region;
    xaxis label='Region' fitpolicy=rotate;
    yaxis label='Value Add Factor';
    title 'Value Add Factor by Region';
run;
title;

/* ==============Histograms of key variables===========    */

/* From Nitrofen.sas workshet lines 115-126 using the proc sgplot histogram with density  */
proc sgplot data=AllColleges_clean;
    histogram CHperLearner;
    density CHperLearner;
    density CHperLearner / type=kernel;
    keylegend / location=inside position=topright;
    xaxis label='Average Contact Hours per Learner';
    title 'Distribution of CHperLearner (all colleges)';
run;
title;

proc sgplot data=AllColleges_clean;
    histogram GradPR;
    density GradPR;
    xaxis label='Graduation Pass Rate';
    title 'Distribution of Graduation Pass Rate';
run;
title;

proc sgplot data=AllColleges_clean;
    histogram VAF;
    density VAF;
    xaxis label='Value Add Factor';
    title 'Distribution of Value Add Factor';
run;
title;

                  /*===========SCATTER MATRIX PAIRWISE CORRELATIONS=====  */
                 
/* From Lab Week 7 lines 344-346 using the proc sgscatter matrix               */

proc sgscatter data=AllColleges_clean;
    matrix CHperLearner GradPR VAF GPercentFemale
        / group=Institution diagonal=(histogram kernel);
    title 'Scatter matrix pairwise relationships between key variables';
run;
title;

/* --- Working on Year trend -- CHperLearner Yr1 vs Yr2 vs Yr3 -------------------    */
/* Reshaping wide to long using multiple output statements                        */
/* From Nitrofen.sas worksheet lines 158-175 using multiple output to reshape wide to long    */
/* Each college produces exactly 3 rows, one per year                            */


data CHlong;
    set AllColleges_clean;

    /* Year 1 row -- From Nitrofen.sas worksheet lines 161-163 -- assign value then output */
    Year            = 1;
    CHperLearner_Yr = CHperLearner_Yr1;
    output;

    /* Year 2 row */
    Year            = 2;
    CHperLearner_Yr = CHperLearner_Yr2;
    output;

    /* Year 3 row */
    Year            = 3;
    CHperLearner_Yr = CHperLearner_Yr3;
    output;

    /* Keep only columns needed for the year trend plot                        */
    /* from Lab Week 5 lines 152-153 using keep statement                      */
    keep Institution Region SizeCategory Year CHperLearner_Yr;

    label
        Year            = 'Year (1=earliest, 3=latest)'
        CHperLearner_Yr = 'Contact Hours per Learner'
    ;

run;


/* Verify reshape -- each Year group should have the same n as AllColleges_clean */

proc means data=CHlong n nmiss min max mean maxdec=2;
    class Year;
    var CHperLearner_Yr;
    title 'CHlong reshape check [n per year confirms 3 rows per college]';
run;
title;

/* Year trend boxplot                                                           */
/* From Lab Week 7 lines 181-185 using proc sgplot vbox                           */

ods graphics on;
title 'CHperLearner by Year [Trend across 3 years]';

proc sgplot data=CHlong (where=(CHperLearner_Yr ne .)) noautolegend;
    /* WHERE= removes missing rows before plotting -- no incomplete boxes      */
    /* From Lab Week 5 lines 763-764 using where statement to filter rows      */
    vbox CHperLearner_Yr / category=Year group=Institution;
    xaxis label='Year (1=earliest, 3=latest)';
    yaxis label='Contact Hours per Learner';
    keylegend / title='Institution Type';
run;

ods graphics off;
title;


/*Examining effect of year on  CHperLearner using CHlong (long format) so Year is a proper class variable               */
/* From Lab Week 9 lines 423-428 using proc GLM with model and means              */

proc GLM data=CHlong;
    class Year;
    model CHperLearner_Yr = Year;
    means Year / lsd hovtest=levene;
    output out=Resid_Year p=Predicted r=Residual;
    title 'One-way ANOVA [CHperLearner by Year (does year significantly affect CH?)]';
quit;
title;

/* Residual diagnostics for year ANOVA                                         */
/* From Lab Week 9 lines 430-436 using proc univariate on residuals               */

proc univariate data=Resid_Year normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual diagnostics -- ANOVA CHperLearner ~ Year';
run;
title;

/********************************************************************************/
/*                                                                              */
/*              ANOVA ANALYSIS                                                */
/*                                                                              */
/*   TASK: Does Region, Institution, and/or SizeCategory affect CHperLearner?  */    
/*    One-way ANOVA -- CHperLearner ~ Region                                */
/*    One-way ANOVA -- CHperLearner ~ SizeCategory                          */
/*    Two-way ANOVA -- CHperLearner ~ ColType Region                        */
/*    ANOVA -- GradPR ~ InstitutionType                                             */
/*   Residual diagnostics included to validate normality assumption.           */
/********************************************************************************/

/* --- One-way ANOVA CHperLearner  Region -------------------------   */

/* From Lab Week 9 lines 423-428 using proc GLM with hovtest Levene          */

proc GLM data=AllColleges_clean;
    class Region;
    model CHperLearner = Region;
    means Region / lsd hovtest=levene;
    output out=Resid_Region p=Predicted r=Residual;
    title 'One-way ANOVA  CHperLearner by Region';
quit;
title;

/* Residual diagnostics , checking normality of residuals                          */
/* From Lab Week 9 lines 430-436 using proc univariate on residuals          */

proc univariate data=Resid_Region normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual diagnostics -- ANOVA CHperLearner ~ Region';
run;
title;

/* ==============One-way ANOVA -- CHperLearner ~ SizeCategory ==============   */

proc GLM data=AllColleges_clean;
    class SizeCategory;
    model CHperLearner = SizeCategory;
    means SizeCategory / lsd hovtest=levene;
    output out=Resid_Size p=Predicted r=Residual;
    title 'One-way ANOVA [CHperLearner by Size Category]';
quit;
title;

proc univariate data=Resid_Size normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual diagnostics [ANOVA CHperLearner ~ SizeCategory]';
run;
title;

/* ========Two-way ANOVA -- CHperLearner ~ InstitutionType Region========   */

proc GLM data=AllColleges_clean;
    class Institution Region;
    model CHperLearner = Institution Region Institution*Region;
    means Institution Region ;
    output out=Resid_2way p=Predicted r=Residual;
    title 'Two-way ANOVA [CHperLearner by Institution and Region]';
quit;
title;

proc univariate data=Resid_2way normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual diagnostics  Two-way ANOVA';
run;
title;

/* ============== ANOVA -- GradPR ~ Institution (do types differ in pass rates?) =====   */

proc GLM data=AllColleges_clean;
    class Institution;
    model GradPR = Institution;
    means Institution / lsd hovtest=levene;
    output out=Resid_GradPR p=Predicted r=Residual;
    title 'One-way ANOVA [GradPR by Institution Type]';
quit;
title;

proc univariate data=Resid_GradPR normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual diagnostics  [ANOVA GradPR ~ Institution]';
run;
title;

/********************************************************************************/
/*                                                                              */
/*                 REGRESSION ANALYSIS                                          */
/*                                                                              */
/*   Question: Can GradPR, VAF and GPercentFemale predict CHperLearner?        */
/*   Also: Does CHperLearner predict GradPR?                                   */
/*                                                                              */
/*    Simple regression   -- CHperLearner ~ GradPR                             */
/*    Simple regression   -- CHperLearner ~ VAF                                */
/*    Multiple regression -- CHperLearner ~ GradPR + VAF + GPercentFemale      */
/*    Regression          -- GradPR ~ CHperLearner + VAF                       */
/*   Full residual diagnostics and Cook's D influence checks included.         */
/********************************************************************************/

/*============Simple regression -- CHperLearner ~ GradPR====================== */

/* From Lab Week 9 lines 1437-1440 using proc reg                            */
ods graphics on;
proc reg data=AllColleges_clean;
    model CHperLearner = GradPR / p r cli clm;
    output out=Reg_CHL_GradPR
        p=Predicted
        r=Residual
        cookd=CooksD;
    title 'Simple Regression -- CHperLearner ~ GradPR';
quit;
ods graphics off;
title;

/* ====================Residual plot======================================== */
/* From Lab Week 9 lines 1467-1470 using sgplot loess residual vs predicted  */

proc sgplot data=Reg_CHL_GradPR;
    loess x=Predicted y=Residual;
    refline 0 / axis=y;
    title 'Residuals vs Predicted -- CHperLearner ~ GradPR';
run;
title;

/* Normality of residuals                                                       */
/* From Lab Week 9 lines 1445-1450 using proc univariate on residuals        */

proc univariate data=Reg_CHL_GradPR normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual normality check -- CHperLearner ~ GradPR';
run;
title;

/* Cook's D -- identify influential observations                                 */
/* From Lab Week 9 lines 1515-1522 using CooksD diagnostics                  */

ods graphics on;
proc reg data=AllColleges_clean
    plots(only label)=(RStudentByLeverage CooksD);
    model CHperLearner = GradPR;
    output out=Reg_CHL_GradPR p=Predicted r=Residual cookd=CooksD;
    title 'Influence diagnostics -- Cook''s D (>0.5 = investigate)';
quit;
ods graphics off;
title;

/*============Simple regression -- CHperLearner ~ VAF =========   */

ods graphics on;
proc reg data=AllColleges_clean;
    model CHperLearner = VAF / p r;
    output out=Reg_CHL_VAF
        p=Predicted
        r=Residual
        cookd=CooksD;
    title 'Simple Regression -- CHperLearner ~ VAF';
quit;
ods graphics off;
title;

proc sgplot data=AllColleges_clean;
    reg x=VAF y=CHperLearner / clm cli;
    loess x=VAF y=CHperLearner;
    title 'Scatter plot with regression line [CHperLearner vs VAF]';
run;
title;

/* ===========Multiple regression -- CHperLearner ~ GradPR + VAF + GPercentFemale========*/

ods graphics on;
proc reg data=AllColleges_clean
    plots(only label)=(RStudentByLeverage CooksD);
    model CHperLearner = GradPR VAF GPercentFemale / p r cli clm vif;
    /* vif = Variance Inflation Factor -- checks for multicollinearity           */
    output out=Reg_CHL_multi
        p=Predicted
        r=Residual
        cookd=CooksD;
    title 'Multiple Regression -- CHperLearner ~ GradPR + VAF + GPercentFemale';
quit;
ods graphics off;
title;

proc univariate data=Reg_CHL_multi normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual diagnostics -- Multiple Regression';
run;
title;

proc sgplot data=Reg_CHL_multi;
    loess x=Predicted y=Residual;
    refline 0 / axis=y;
    title 'Residuals vs Predicted -- Multiple Regression';
run;
title;

/* Print observations ( Cook's D)                 */
/* From Lab Week 9 lines 1661-1667 using proc SQL outobs CooksD desc         */

proc sql outobs=max;
    select CHperLearner, GradPR, VAF, GPercentFemale, Predicted, Residual, CooksD
    from Reg_CHL_multi
    order by CooksD desc;
    title 'Observations (Cook''s D)';
quit;
title;

/* ==========Regression -- GradPR ~ CHperLearner + VAF =====================  */

ods graphics on;
proc reg data=AllColleges_clean;
    model GradPR = CHperLearner VAF / p r vif;
    output out=Reg_GradPR
        p=Predicted
        r=Residual
        cookd=CooksD;
    title 'Regression  [GradPR predicted by CHperLearner and VAF]';
quit;
ods graphics off;
title;

proc univariate data=Reg_GradPR normal;
    var Residual;
    histogram / normal(mu=est sigma=est) kernel(color=red);
    qqplot   / normal(mu=est sigma=est);
    inset n nmiss min q1 median q3 max skew kurt / position=SE;
    title 'Residual diagnostics [GradPR regression]';
run;
ods graphics off;
title;


    
     
     
   



