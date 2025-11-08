#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Filename : app.R
# Use      : Shiny application for PK-platelet simulation
# Author   : Tomas Sou
# Created  : 2025-10-17
# Updated  : 2025-11-08
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Notes
# - na
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Updates
# - na
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Setup

# Clear
rm(list=ls())

# Today
td = format(Sys.Date(), "%y%m%d")

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Import

# library(mrgsolve)
# library(shiny)
# library(shinydashboard)
# library(dplyr)
# library(ggplot2)
# library(ggpubr)
# library(xgxr)
# library(scales)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Options

# Page title
pgtitle = "PK-PLT-GDF"

# Plot
ptwid = 1200  # width
pthgt = 600  # height

# PNG settings
pngname = "PLT"

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Model

param_CGM =
  "
$PARAM
@annotated
//Ref: Bauer et al. (2021). Br J Cancer. PMID: 34140638
//PK CGM097
KA          : 2.05  : First-order absorption rate constant (1/h)
TLAG        : 0.383 : Absorption lag time (h)
V1          : 92.6  : Apparent central Vd (V1/F; L)
beta_WT_V1  : 1.12  : Body weight effect on central Vd; assumed normalised to 70 kg as not stated in the paper
CL          : 1.62  : Apparent clearance (CL/F; L/h)
Q           : 2.81  : Apparent inter-comparmental clearance (Q/F; L/h)
V2          : 7.11  : Apparent peripheral Vd (V2/F; L)
//dummy
Ktr         : 0     : Transit compartment rate constant (1/h)
MTT         : 0     : Mean transit time (h)
//added
DRUG  : 1 : 1=CGM

$OMEGA
@annotated
//0 0 // No IIV
IIVKA   : 0.9740 : 1 Ka CV = 98.7%
IIVTLAG : 0.0480 : 2 Tlag CV = 21.9%
IIVV1   : 0.1140 : 3 V1 CV = 33.7%
IIVCL   : 0.4490 : 4 CL CV = 67.0%
IIVQ    : 0.2500 : 5 Q CV = 50.0%
IIVV2   : 4.0000 : 6 V2 CV = 200%
//dummy
IIVKtr  : 0.628  : Ktr
IIVMTT  : 0.321  : MTT

$PARAM
@annotated
//Platelet and GDF15 PD model from Bauer paper
//Ref: Bauer et al. (2021). Br J Cancer. PMID: 34140638
//Platelet
PLTZ        : 276      : Baseline platelet (G/L)
MMT         : 264      : Mean maturation time of drug affected cells (h)
ALP         : 27.8     : Platelet transfusion dose (G/L)
KE0         : 3.29e-8  : Effect compartment rate (1/h)
SLPD        : 3.93e-5  : Drug direct thrombocytopaenia potency (mL/ng)
SLPI        : 0.0176   : Drug indirect thrombocytopaenia potency through effect compartment (mL/ng)
SEP         : 0.74     : Indirect effect thrombocytopenia potency power; No IIV
SPW         : 0.595    : Systemic regulation
CFR         : -1.62    : Drug effect potency on systemic regulation (mL/ng)
LPW         : 0.146    : Local regulation
//GDF-15
EMAXG       : 0.00078  : Drug potency (mL/ng)
KOUT        : 0.08     : Turnover rate (1/h)
GDFZ        : 2.78e3   : Baseline concentration (pg/mL)
KIN         : 175      : Production rate (pg/h)
//added
KPRO        : -1    : First-order prolifeation rate constant of P1 platelet (1/h)
KP5         : -1    : First-order elimination rate constant of P5 platelet (1/h)
KP1         : 0     : First-order elimination rate constant of P1 platelet (1/h)
TRTPLT      : 0     : 1=treat platelet
TRTGDF      : 0     : 1=treat GDF-15
//Covariates
WT          : 70    : Body weight (kg)
//dummy
SLP_PLTZ    : 0     : dummy
kSR         : 0     : dummy
EC50G       : 0     : EC50 for GDF15 (ng/mL)
GAMG        : 0     : gamma for GDF15
FU          : 1     : dummy
EMAX_PLT    : 0     : dummy
EC50_PLT    : 0     : dummy
HEM         : 0     : dummy
MMTsolid    : 0     : dummy

$OMEGA
@annotated
IIVPLTZ  : 0.1670 : 7 PLTZ CV = 40.9%
IIVMMT   : 0.1225 : 8 MMT CV = 35.0%
IIVALP   : 0.4900 : 9 ALP CV = 70.0%
IIVKE0   : 0.0900 : 10 Ke0 CV = 30.0%
IIVSLPD  : 0.0900 : 11 SLPD CV = 30.0%
IIVSLPI  : 0.0986 : 12 SLPI CV = 314%
IIVSPW   : 0.0400 : 13 SPW CV = 20.0%
IIVCFR   : 1.0000 : 14 CFR CV = 100%
IIVLPW   : 0.0400 : 15 LPW CV = 20.0%
IIVEMAXG : 0.1120 : 16 SG CV = 33.4%
IIVKOUT  : 0.8230 : 17 Kout CV = 90.7%
IIVGDFZ  : 1.4600 : 18 GDFZ CV = 121%
IIVKIN   : 0.4080 : 19 KIN CV = 63.9%
//dummy
IIVEMAX  : 0  : dummy
IIVEC50  : 0  : dummy
IIVKPRO  : 0  : dummy
IIVKP5   : 0  : dummy
IIVMMTsolid  : 0 : dummy
IIVkSR       : 0 : dummy
IIVSLP_PLTZ  : 0 : dummy
"

param_HDM_PLTv35 =
  "
$PARAM
@annotated
//Ref: 	V19_10no_occ_QC; Modelling Memo on 06-Jul-2022
//PK HDM
Ktr         : 6.28  : Transit compartment rate constant (1/h)
MTT         : 0.812 : Mean transit time (h)
KA          : 3.89  : First-order absorption rate constant (1/h)
V1          : 116.0 : Apparent central Vd (V1/F; L)
beta_WT_V1  : 0.888 : Body weight effect on central Vd, normalised to 70 kg
CL          : 5.90  : Apparent clearance (CL/F; L/h)
//dummy
Q           : 0     : Apparent inter-comparmental clearance (Q/F; L/h)
V2          : 1     : Apparent peripheral Vd (V2/F; L)
TLAG        : 0     : Absorption lag time (h)
//added
DRUG : 2 : 2=HDM

$OMEGA
@annotated
//0 0 // No IIV
IIVKtr  : 0.382  : Ktr CV = 61.8%
IIVMTT  : 0.108  : MTT CV = 32.8%
IIVKA   : 2.016  : Ka CV = 142.0%
//dummy
IIVTLAG : 0      : Tlag
IIVQ    : 0      : Q
IIVV2   : 0      : V2

$OMEGA @block @correlation
@annotated
IIVV1      : 0.0992       : V1 CV = 31.5%
IIVCL      : 0.650 0.308  : CL CV = 55.5%; corr_V_Cl = 0.650

$PARAM
@annotated
//Platelet model from v35_v34_propERR on 30-Nov-2022
PLTZ        : 28.0     : Baseline platelet (G/L)
MMT         : 177      : Mean maturation time of drug affected cells (h)
SPW         : 0.145    : Systemic regulation (gamma)
EMAX_PLT    : 0.000808 : Emax; or SLP for linear model
EC50_PLT    : 0        : EC50 (ng/mL); set to 0 for linear model
//GDF-15 model by Sebastien Lorenzo Mar2023
EMAXG       : 61162.45 : SLP or EMAX for GDF15
EC50G       : 388.86   : EC50 for GDF15 (ng/mL)
GAMG        : 1.08     : gamma for GDF15
GDFZ        : 2477.51  : Baseline concentration (pg/mL)
//added
kSR         : 0.0000964 : Added from v97 for testing R-comp
KPRO        : -1       : First-order prolifeation rate constant of P1 platelet (1/h)
KP5         : -1       : First-order elimination rate constant of P5 platelet (1/h)
KP1         : 0        : First-order elimination rate constant of P1 platelet (1/h)
TRTPLT      : 0        : 1=treat platelet
TRTGDF      : 0        : 1=treat GDF-15
//Covariates
WT          : 70       : Body weight (kg)
//dummy
KOUT        : 0        : Turnover rate (1/h)
KIN         : 0        : Production rate (pg/h)
SLPD        : 0        : Drug direct thrombocytopaenia potency (mL/ng)
SLPI        : 0        : Drug indirect thrombocytopaenia potency through effect compartment (mL/ng)
ALP         : 0        : Platelet transfusion dose (G/L)
KE0         : 0        : Effect compartment rate (1/h)
SEP         : 0        : Indirect effect thrombocytopenia potency power; No IIV
CFR         : 0        : Drug effect potency on systemic regulation (mL/ng)
LPW         : 0        : Local regulation
FU          : 1        : dummy
HEM         : 0        : dummy
MMTsolid    : 0        : dummy

$OMEGA
@annotated
//Platelet model from v35_v34_propERR on 30-Nov-2022
IIVPLTZ : 0.7465  : PLTZ CV = 86.4%
IIVMMT  : 0.4529  : MMT CV = 67.3%
IIVSPW  : 0.7797  : SPW CV = 88.3% (gamma)
IIVEMAX : 0.5098  : EMAX_PLT or SLP CV = 71.4%
//GDF-15 model by Sebastien Lorenzo Mar2023
IIVEMAXG : 0.7396 : EMAXG CV = 86.0%
IIVGDFZ  : 0.4761 : GDFZ CV = 69.0%
//dummy
IIVALP  : 0 : ALP
IIVKE0  : 0 : Ke0
IIVSLPD : 0 : SLPD
IIVSLPI : 0 : SLPI
IIVCFR  : 0 : CFR
IIVLPW  : 0 : LPW
IIVEC50 : 0 : EC50_PLT
IIVKPRO : 0 : KPRO
IIVKP5  : 0 : KP5
IIVKOUT : 0 : Kout
IIVKIN  : 0 : KIN
IIVMMTsolid  : 0 : dummy
IIVkSR       : 0 : dummy
"

param_HDM_PLTv97 =
  "
$PARAM
@annotated
//Ref: 	V19_10no_occ_QC; Modelling Memo on 06-Jul-2022
//PK HDM
Ktr         : 6.28  : Transit compartment rate constant (1/h)
MTT         : 0.812 : Mean transit time (h)
KA          : 3.89  : First-order absorption rate constant (1/h)
V1          : 116.0 : Apparent central Vd (V1/F; L)
beta_WT_V1  : 0.888 : Body weight effect on central Vd, normalised to 70 kg
CL          : 5.90  : Apparent clearance (CL/F; L/h)
//dummy
Q           : 0     : Apparent inter-comparmental clearance (Q/F; L/h)
V2          : 1     : Apparent peripheral Vd (V2/F; L)
TLAG        : 0     : Absorption lag time (h)
//added
DRUG : 2 : 2=HDM

$OMEGA
@annotated
//0 0 // No IIV
IIVKtr  : 0.382  : Ktr CV = 61.8%
IIVMTT  : 0.108  : MTT CV = 32.8%
IIVKA   : 2.016  : Ka CV = 142.0%
//dummy
IIVTLAG : 0      : Tlag
IIVQ    : 0      : Q
IIVV2   : 0      : V2

$OMEGA @block @correlation
@annotated
IIVV1      : 0.0992       : V1 CV = 31.5%
IIVCL      : 0.650 0.308  : CL CV = 55.5%; corr_V_Cl = 0.650

$PARAM
@annotated
//Platelet model from v97_v95_kSR on 10May2023
PLTZ        : 1         : Baseline platelet (G/L)
MMT         : 170       : Mean maturation time of drug affected cells (h)
MMTsolid    : 518       : Mean maturation time of drug affected cells (h)
SPW         : 0.0624    : Systemic regulation (gamma)
EMAX_PLT    : 0.00192   : Emax; or SLP for linear model
EC50_PLT    : 0         : EC50 (ng/mL); set to 0 for linear model
kSR         : 0.0000964 : kSR resistance transition rate constant (1/h)
//GDF-15 model by Sebastien Lorenzo Mar2023
EMAXG       : 61162.45 : SLP or EMAX for GDF15
EC50G       : 388.86   : EC50 for GDF15 (ng/mL)
GAMG        : 1.08     : gamma for GDF15
GDFZ        : 2477.51  : Baseline concentration (pg/mL)
//added
KPRO        : -1       : First-order prolifeation rate constant of P1 platelet (1/h)
KP5         : -1       : First-order elimination rate constant of P5 platelet (1/h)
KP1         : 0        : First-order elimination rate constant of P1 platelet (1/h)
TRTPLT      : 0        : 1=treat platelet
TRTGDF      : 0        : 1=treat GDF-15
//Covariates
WT          : 70       : Body weight (kg)
HEM         : 1        : Population type: 1=HEM; 0=SOL
//dummy
KOUT        : 0        : Turnover rate (1/h)
KIN         : 0        : Production rate (pg/h)
SLPD        : 0        : Drug direct thrombocytopaenia potency (mL/ng)
SLPI        : 0        : Drug indirect thrombocytopaenia potency through effect compartment (mL/ng)
ALP         : 0        : Platelet transfusion dose (G/L)
KE0         : 0        : Effect compartment rate (1/h)
SEP         : 0        : Indirect effect thrombocytopenia potency power; No IIV
CFR         : 0        : Drug effect potency on systemic regulation (mL/ng)
LPW         : 0        : Local regulation
FU          : 1        : dummy

$OMEGA
@annotated
//Platelet model from v97_v95_kSR on 10May2023
IIVPLTZ      : 0.0790  : PLTZ CV = 28.1%
IIVMMT       : 0.6440  : MMT CV = 80.3%
IIVMMTsolid  : 0.6839  : MMTsolid CV = 82.7%
IIVSPW       : 2.1316  : SPW CV = 146% (gamma)
IIVEMAX      : 1.5129  : EMAX_PLT or SLP CV = 123%
IIVkSR       : 20.160  : kSR CV = 449%
//GDF-15 model by Sebastien Lorenzo Mar2023
IIVEMAXG : 0.7396 : EMAXG CV = 86.0%
IIVGDFZ  : 0.4761 : GDFZ CV = 69.0%
//dummy
IIVALP  : 0 : ALP
IIVKE0  : 0 : Ke0
IIVSLPD : 0 : SLPD
IIVSLPI : 0 : SLPI
IIVCFR  : 0 : CFR
IIVLPW  : 0 : LPW
IIVEC50 : 0 : EC50_PLT
IIVKPRO : 0 : KPRO
IIVKP5  : 0 : KP5
IIVKOUT : 0 : Kout
IIVKIN  : 0 : KIN
"

# Platelet model v125
param_HDM =
  "
$PARAM
@annotated
//Ref: 	V19_10no_occ_QC; Modelling Memo on 06-Jul-2022
//PK HDM
Ktr         : 6.28  : Transit compartment rate constant (1/h)
MTT         : 0.812 : Mean transit time (h)
KA          : 3.89  : First-order absorption rate constant (1/h)
V1          : 116.0 : Apparent central Vd (V1/F; L)
beta_WT_V1  : 0.888 : Body weight effect on central Vd, normalised to 70 kg
CL          : 5.90  : Apparent clearance (CL/F; L/h)
//dummy
Q           : 0     : Apparent inter-comparmental clearance (Q/F; L/h)
V2          : 1     : Apparent peripheral Vd (V2/F; L)
TLAG        : 0     : Absorption lag time (h)
//added
DRUG : 2 : 2=HDM

$OMEGA
@annotated
//0 0 // No IIV
IIVKtr  : 0.382  : Ktr CV = 61.8%
IIVMTT  : 0.108  : MTT CV = 32.8%
IIVKA   : 2.016  : Ka CV = 142.0%
//dummy
IIVTLAG : 0      : Tlag
IIVQ    : 0      : Q
IIVV2   : 0      : V2

$OMEGA @block @correlation
@annotated
IIVV1      : 0.0992       : V1 CV = 31.5%
IIVCL      : 0.650 0.308  : CL CV = 55.5%; corr_V_Cl = 0.650

$PARAM
@annotated
//Platelet model from v125_v119_kPLTZsol_fix0 on 12Jun2023
PLTZ        : 1         : Baseline platelet (G/L)
MMT         : 162       : Mean maturation time of drug affected cells (h)
MMTsolid    : 591       : Mean maturation time of drug affected cells (h)
SPW         : 0.0688    : Systemic regulation (gamma)
EMAX_PLT    : 0.00157   : Emax; or SLP for linear model
EC50_PLT    : 0         : EC50 (ng/mL); set to 0 for linear model
kSR         : 0.0000507 : kSR resistance transition rate constant (1/h)
KE0         : 0.000129 : Effect compartment rate (1/h); value from v125
SLP_PLTZ    : 0.004180 : Effect on PLTZ; value from v125
//GDF-15 model by Sebastien Lorenzo Mar2023
EMAXG       : 61162.45 : SLP or EMAX for GDF15
EC50G       : 388.86   : EC50 for GDF15 (ng/mL)
GAMG        : 1.08     : gamma for GDF15
GDFZ        : 2477.51  : Baseline concentration (pg/mL)
//added
KPRO        : -1       : First-order prolifeation rate constant of P1 platelet (1/h)
KP5         : -1       : First-order elimination rate constant of P5 platelet (1/h)
KP1         : 0        : First-order elimination rate constant of P1 platelet (1/h)
TRTPLT      : 0        : 1=treat platelet
TRTGDF      : 0        : 1=treat GDF-15
//Covariates
WT          : 70       : Body weight (kg)
HEM         : 1        : Population type: 1=HEM; 0=SOL
//dummy
KOUT        : 0        : Turnover rate (1/h)
KIN         : 0        : Production rate (pg/h)
SLPD        : 0        : Drug direct thrombocytopaenia potency (mL/ng)
SLPI        : 0        : Drug indirect thrombocytopaenia potency through effect compartment (mL/ng)
ALP         : 0        : Platelet transfusion dose (G/L)
SEP         : 0        : Indirect effect thrombocytopenia potency power; No IIV
CFR         : 0        : Drug effect potency on systemic regulation (mL/ng)
LPW         : 0        : Local regulation
FU          : 1        : dummy

$OMEGA
@annotated
//Platelet model from v125_v119_kPLTZsol_fix0 on 12Jun2023
IIVPLTZ      : 0.0724  : PLTZ CV = 26.9%
IIVMMT       : 0.6690  : MMT CV = 81.8%
IIVMMTsolid  : 0.4340  : MMTsolid CV = 65.9%
IIVSPW       : 1.7200  : SPW CV = 131% (gamma)
IIVEMAX      : 0.7590  : EMAX_PLT or SLP CV = 87.1%
IIVkSR       : 11.800  : kSR CV = 344%
IIVKE0       : 24.400  : Ke0 CV = 494%
IIVSLP_PLTZ  : 9.3030  : SLP_PLTZ CV = 305%
//GDF-15 model by Sebastien Lorenzo Mar2023
IIVEMAXG : 0.7396 : EMAXG CV = 86.0%
IIVGDFZ  : 0.4761 : GDFZ CV = 69.0%
//dummy
IIVALP  : 0 : ALP
IIVSLPD : 0 : SLPD
IIVSLPI : 0 : SLPI
IIVCFR  : 0 : CFR
IIVLPW  : 0 : LPW
IIVEC50 : 0 : EC50_PLT
IIVKPRO : 0 : KPRO
IIVKP5  : 0 : KP5
IIVKOUT : 0 : Kout
IIVKIN  : 0 : KIN
"

main =
  "

$SIGMA @labels ERR
0 //dummy

$SET delta=1, end=24

$CMT
A1 A2 A3 EFF
AUC
P1S P1R P2 P3 P4 P5
GDFT

$MAIN

//PK ------

double iCL = CL*exp(IIVCL) ;
double iV1 = V1*pow(WT/70,beta_WT_V1)*exp(IIVV1) ;
double iQ = Q*exp(IIVQ) ;
double iV2 = V2*exp(IIVV2) ;

double iKe = iCL/iV1 ;
double iK12 = iQ/iV1 ;
if(DRUG==2) iK12 = 0 ;
double iK21 = iQ/iV2 ;
if(DRUG==2) iK21 = 0 ;

double iKA = KA*exp(IIVKA) ;
double iTLAG = TLAG*exp(IIVTLAG) ;
ALAG_A1 = iTLAG ;

double iKtr = Ktr*exp(IIVKtr) ;
double iMTT = MTT*exp(IIVMTT) ;
double n = (iKtr*iMTT)-1 ;

double dose = 0 ;
if(self.amt>0 && self.cmt==1) dose = self.amt ;
if(self.amt>0 && self.cmt!=1) dose = 0 ;

//Platelet ------

double iPLTZ = PLTZ*exp(IIVPLTZ) ;
double iMMT = MMT*exp(IIVMMT) ;
if(HEM==0) iMMT = MMTsolid*exp(IIVMMTsolid) ;
double iKtrP = (3+1)/iMMT ;
double iKpro = iKtrP ;
if(KPRO>=0) iKpro = KPRO*exp(IIVKPRO) ;
double iPhiP = iKtrP ;
if(KP5>=0) iPhiP = KP5*exp(IIVKP5) ;
double icP  = iPLTZ*iPhiP/iKtrP ;

//================================
// Added kSR to R-comp
double ikSR = kSR*exp(IIVkSR) ;
//================================

//================================
// Added kE0 and SLP_PLTZ
double iKE0 = KE0*exp(IIVKE0) ;
double iSLP_PLTZ = SLP_PLTZ*exp(IIVSLP_PLTZ) ;
//================================


double iCFR = CFR*exp(IIVCFR) ;
double iSLPD = SLPD*exp(IIVSLPD) ;
double iSLPI = SLPI*exp(IIVSLPI) ;
double iSPW = SPW*exp(IIVSPW) ;
double iLPW = LPW*exp(IIVLPW) ;

double iEMAX = EMAX_PLT*exp(IIVEMAX) ;
double iEC50 = EC50_PLT*exp(IIVEC50) ;

//GDF-15 ------
double iGDFZ = GDFZ*exp(IIVGDFZ) ;
double iEMAXG = EMAXG*exp(IIVEMAXG) ;
double iEC50G = EC50G ;
double iGAMG = GAMG ;
double iKIN = KIN*exp(IIVKIN) ;
double iKOUT = KOUT*exp(IIVKOUT) ;

//Initial condition ------
//P1_0 = icP ;
P1S_0 = icP ;
P1R_0 = 0 ;
P2_0 = icP ;
P3_0 = icP ;
P4_0 = icP ;
P5_0 = iPLTZ ;
GDFT_0 = iGDFZ ;

$ODE

//PK
double transit_in = 0 ;
if(DRUG==2) transit_in = exp(log(dose)+log(iKtr)+n*log(iKtr*SOLVERTIME)-iKtr*SOLVERTIME-lgamma(n+1)) ;

double CP = A2/iV1 ;
dxdt_A1 = -iKA*A1 +transit_in ;
dxdt_A2 =  iKA*A1 -iK12*A2 +iK21*A3 -iKe*A2 ;
dxdt_A3 =          iK12*A2 -iK21*A3 ;
dxdt_AUC = CP ;

//Effect compartment
dxdt_EFF = iKE0*CP -iKE0*EFF ;

//Platelet
double DrugCGM = 0 ;
if(TRTPLT==1 & DRUG==1) DrugCGM = iSLPI*pow(EFF,SEP) +iSLPD*CP ;

double DrugHDM = 0 ;
if(TRTPLT==1 & DRUG==2 & EC50_PLT==0) DrugHDM = iEMAX*CP ;
if(TRTPLT==1 & DRUG==2 & EC50_PLT>0)  DrugHDM = iEMAX*CP/(iEC50+CP) ;

double DrugHDM_PLTZ = 0 ;
if(TRTPLT==1 & DRUG==2)  DrugHDM_PLTZ = iSLP_PLTZ*EFF ;

double DrugsFBK = 1 ;
if(TRTPLT==1 & DRUG==1) DrugsFBK = exp(iCFR*EFF) ; //effect on sFBK for CGM only

double sFBK = pow((iPLTZ*(1+DrugHDM_PLTZ)/P5),iSPW*DrugsFBK) ; //systemic feedback

double lFBK = 1 ;
if(DRUG==1) lFBK = pow((iPLTZ*(iPhiP/iKtrP)/(P1S+P1R)),iLPW) ; //local feedback for CGM only

dxdt_P1S = iKpro*(sFBK-DrugCGM)*P1S -iKtrP*(1+DrugHDM)*P1S -KP1*P1S -kSR*P1S ;
dxdt_P1R = iKpro*(sFBK-DrugCGM)*P1R -iKtrP*P1R             -KP1*P1R +kSR*P1S ;
dxdt_P2 = iKtrP*(lFBK)*(P1S+P1R) -iKtrP*P2 ;
dxdt_P3 = iKtrP*(lFBK)*P2 -iKtrP*P3 ;
dxdt_P4 = iKtrP*(lFBK)*P3 -iKtrP*P4 ;
dxdt_P5 = iKtrP*(lFBK)*P4 -iPhiP*P5 ; //Platelet count

//GDF-15
double DrugGDF = 0 ;
if(TRTGDF==1 & DRUG==1) DrugGDF = iEMAXG*CP ;
if(TRTGDF==1 & DRUG==2) DrugGDF = iEMAXG*pow(CP,iGAMG)/(pow(iEC50G,iGAMG)+pow(CP,iGAMG)) ;

if(DRUG==1) dxdt_GDFT = iKIN*(1+DrugGDF) -iKOUT*GDF ;
double GDF = 0 ;
if(DRUG==1) GDF = GDFT ;
if(DRUG==2) GDF = GDFZ + DrugGDF ;

$TABLE
capture Ptot = P1S+P1R ;
capture CPu = CP*FU ;
//capture Y = exp(log(CP)+ERR) ;

$CAPTURE
CP GDF transit_in
"

mcode_CGM = paste0(param_CGM,main)
mod_CGM = mcode_cache("m1",mcode_CGM)
mcode_HDM = paste0(param_HDM,main)
mod_HDM = mcode_cache("m2",mcode_HDM)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Function

# PI function
# lims = c(0.025, 0.975)  # 95% PI
lims = c(0.05, 0.95)  # 90% PI
PIpc = (lims[2]-lims[1])*100  # PI%
PIs = function(sim,dv){
  sim$DV = sim[[dv]]
  out = sim |>
    group_by(time) |>
    summarise(
      PImd = median(DV, na.rm=TRUE),
      PIlo = quantile(DV, lims[1], na.rm=TRUE),
      PIup = quantile(DV, lims[2], na.rm=TRUE)
    )
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
utils::globalVariables(c(
  "CP","CPu","DV","GDF","ID","P1R","P1S","P5","PIlo","PImd","PIup","Ptot","evarm","y"
))
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#' Run Shiny application for PK-platelet-GDF15 simulation
#'
#' Run Shiny application for interactive PKPD simulation using a PK-platelet-GDF15 model.
#' The simulation is powered by the [mrgsolve] package.
#'
#' @return Run the app.
#' @export
#' @examples
#' \dontrun{
#' app()
#' }
app = function(){

  # Define UI
  ui <- dashboardPage(  #2

    skin = "black",

    dashboardHeader(
      # titleWidth = 300,
      title = pgtitle
    ),

    dashboardSidebar( #4

      # width = 300,
      collapsed = TRUE,

      sidebarMenu(
        menuItem(h5("Sample"), tabName="sample"),
        menuItem(h5("Body"), tabName="body")
      )

    ),

    dashboardBody(

      tabItems(

        tabItem(

          tabName = "sample",

          # h4(tags$b("PK parameters of animals:")),

          #Scrollbar

          fluidRow(

            column(width = 2,

                   box(

                     width = NULL,
                     background = "black",
                     title = "Subject",
                     status = "primary",
                     solidHeader = TRUE,
                     collapsible = TRUE,
                     collapsed = TRUE,

                     tags$div(
                       column(width = 6, textInput(inputId="WT", label="WT [kg]", value = 70))
                       ,column(width = 6, selectInput(inputId="HEM", label="HEM/SOL", choices=list("HEM"=1, "SOL"=0), selected=1))
                       # ,column(width = 6, checkboxInput(inputId = "HEM", label = "HEM", value = TRUE))
                       ,column(width = 12, checkboxInput(inputId="SHCOV", label="Show Covs", value=TRUE))
                     )
                   ),

                   box(
                     title = "PK",
                     width = NULL,
                     background = "black",
                     status = "primary",
                     solidHeader = TRUE,
                     collapsible = TRUE,
                     collapsed = TRUE,
                     tags$div(
                       column(width = 6, selectInput(inputId = "DRUG",label = "Drug",choices = list("CGM"=1, "HDM"=2), selected=1))
                       # ,column(width = 12, checkboxInput(inputId = "KGD", label = "Dose per kg?", value = FALSE))
                       ,column(width = 6, selectInput(inputId = "ADM",label = "Admin",choices = list("Oral"=1, "IV"=2), selected=1))
                       ,column(width = 4, textInput(inputId = "DOSE",label = "Dose[mg]", value = 20))
                       ,column(width = 4, textInput(inputId = "NDOSE",label = "NDoses", value = 5))
                       ,column(width = 4, textInput(inputId = "TAU",label = "Tau[day]", value = 1))
                       ,column(width = 12, textInput(inputId = "TDOSE", label = "Times [day] (add times by `,`)", value = "0,1,2,3,4,28,29,30,31,32,56,57,58,59,60,c(0,1,2,3,4,28,29,30,31,32,56,57,58,59,60)+28*3"))
                       ,column(width = 6, textInput(inputId = "KA",label = "Ka [1/h]", value = ""))
                       ,column(width = 6, textInput(inputId = "TLAG",label = "Tlag [h]", value = ""))
                       ,column(width = 6, textInput(inputId = "Ktr",label = "Ktr [1/h]", value = ""))
                       ,column(width = 6, textInput(inputId = "MTT",label = "MTT [h]", value = ""))
                       ,column(width = 6, textInput(inputId = "V1",label = "V1/F [L]", value = ""))
                       ,column(width = 6, textInput(inputId = "CL",label = "CL/F [L/h]", value = ""))
                       # ,column(width = 12, numericInput(inputId = "INFH",label = "Infuion duration (h), NA=bolus",value = NA))
                       ,column(width = 6, checkboxInput(inputId = "SHCMAX", label = "Cmax", value = FALSE))
                       ,column(width = 6, checkboxInput(inputId = "SS", label = "Steady-state", value = FALSE))
                       ,column(width = 6, numericInput(inputId = "FU", label = "fu", value = 0.2))
                       ,column(width = 6, numericInput(inputId = "MIC", label = "Ct [ng/mL]", value = 100))
                       ,column(width = 3, h5("Show"))
                       # ,column(width = 3, checkboxInput(inputId = "SHCP", label = "Cp", value = TRUE))
                       ,column(width = 3, checkboxInput(inputId = "SHCPU", label = "Cpu", value = FALSE))
                       ,column(width = 3, checkboxInput(inputId = "SHFU", label = "fu", value = FALSE))
                       ,column(width = 3, checkboxInput(inputId = "SHMIC", label = "Ct", value = FALSE))
                       ,column(width = 6, h5("Y-axis"))
                       ,column(width = 6, checkboxInput(inputId = "LOGPK", label = "Log-scale", value = FALSE))
                       ,column(width = 4, numericInput(inputId = "LOWY", label = "Lower", value = NA))
                       ,column(width = 4, numericInput(inputId = "UPPY", label = "Upper" , value = NA))
                       ,column(width = 4, numericInput(inputId = "ACC", label = "Accuracy" , value = NA))
                       ,column(width = 12, checkboxInput(inputId = "OBSPK", label = "Show OBS (add by `,`)", value = FALSE))
                       ,column(width = 6, textInput(inputId = "PKX", label = "X", value = ""))
                       ,column(width = 6, textInput(inputId = "PKY", label = "Y", value = ""))
                     )
                   ),

                   box(
                     title = "Platelet",
                     width = NULL,
                     background = "black",
                     status = "primary",
                     solidHeader = TRUE,
                     collapsible = TRUE,
                     collapsed = TRUE,
                     tags$div(
                       # ,column(width = 6, checkboxInput(inputId = "SHOBS", label = "Show growth", value = FALSE))
                       column(width = 6, checkboxInput(inputId = "TRTPLT", label = "Drug effect", value = TRUE))
                       ,column(width = 6, checkboxInput(inputId = "TPG", label = "TP grades", value = FALSE))
                       ,column(width = 6, textInput(inputId = "PLTZ", label = "Baseline [G/L]", value = "28.0"))
                       ,column(width = 6, textInput(inputId = "MMT", label = "MMT [h]", value = ""))
                       ,column(width = 12, h5("Resistant clones"))
                       ,column(width = 12, textInput(inputId = "kSR", label = "kSR [1/h]", value = ""))
                       ,column(width = 12, h5("Effect on PLTZ"))
                       ,column(width = 6, textInput(inputId = "KE0", label = "KE0 [1/h]", value = ""))
                       ,column(width = 6, textInput(inputId = "SLP_PLTZ", label = "SLP_PLTZ", value = "0.05"))
                       ,column(width = 12, h5("P1 prolifeation"))
                       ,column(width = 12, textInput(inputId = "KPRO", label = "kpro [1/h] (ktrP = 4/MMT)", value = ""))
                       ,column(width = 12, h5("PLT elimination effect"))
                       ,column(width = 6, textInput(inputId = "KP1", label = "kP1 [1/h]", value = 0))
                       ,column(width = 6, textInput(inputId = "KP5", label = "kP5 [1/h]", value = ""))
                       ,column(width = 12, h5("Feedback"))
                       ,column(width = 6, textInput(inputId = "SPW", label = "gamma", value = param(mod_HDM)$SLP))
                       ,column(width = 6, textInput(inputId = "LPW", label = "Local PW", value = ""))
                       ,column(width = 12, h5("HDM"))
                       ,column(width = 12, textInput(inputId = "EMAX_PLT", label = "SLP (linear) or Emax", value = param(mod_HDM)$SLP))
                       ,column(width = 12, textInput(inputId = "EC50_PLT", label = "EC50 [ng/mL] (0=linear)", value = ""))
                       ,column(width = 12, h5("CGM"))
                       ,column(width = 6, textInput(inputId = "SLPD", label = "Direct [mL/ng]", value = ""))
                       ,column(width = 6, textInput(inputId = "SLPI", label = "Indirect [mL/ng]", value = ""))
                       ,column(width = 12, checkboxInput(inputId = "PINF", label = "PLT transfusion (add times by `,`)", value = FALSE))
                       ,column(width = 6, textInput(inputId = "ALP", label = "PLT dose [G/L]", value = 30))
                       ,column(width = 6, textInput(inputId = "TALP", label = "Times [day]", value = 14))
                       ,column(width = 6, h5("Y-axis"))
                       ,column(width = 6, checkboxInput(inputId = "LOGPLT", label = "Log-scale", value = FALSE))
                       ,column(width = 4, numericInput(inputId = "PLTLOWY",label = "Lower", value = 0))
                       ,column(width = 4, numericInput(inputId = "PLTUPPY",label = "Upper" , value = 40))
                       ,column(width = 4, numericInput(inputId = "PLTACC",label = "Accuracy" , value = NA))
                       ,column(width = 12, checkboxInput(inputId = "OBSPLT", label = "Show OBS (add by `,`)", value = FALSE))
                       ,column(width = 6, textInput(inputId = "PLTX", label = "X", value = "0,50,100,150"))
                       ,column(width = 6, textInput(inputId = "PLTY", label = "Y", value = "276,277,275.5,274.5"))
                     )
                   ),

                   box(
                     title = "GDF-15",
                     width = NULL,
                     background = "black",
                     status = "primary",
                     solidHeader = TRUE,
                     collapsible = TRUE,
                     collapsed = TRUE,
                     tags$div(
                       column(width = 12, textInput(inputId = "GDFZ", label = "Baseline [pg/mL]", value = NA))
                       ,column(width = 6, textInput(inputId = "KIN", label = "Kin [pg/h]", value = NA))
                       ,column(width = 6, textInput(inputId = "KOUT", label = "Kout [1/h]", value = NA))
                       ,column(width = 12, checkboxInput(inputId = "TRTGDF", label = "Drug effect", value = TRUE))
                       ,column(width = 12, textInput(inputId = "EMAXG", label = "SLP or Emax (for HDM)", value = NA))
                       ,column(width = 6, textInput(inputId = "EC50G", label = "EC50 [mL/ng]", value = NA))
                       ,column(width = 6, textInput(inputId = "GAMG", label = "gamma", value = NA))
                       ,column(width = 6, h5("Y-axis"))
                       ,column(width = 6, checkboxInput(inputId = "LOGGDF", label = "Log-scale", value = FALSE))
                       ,column(width = 4, numericInput(inputId = "GDFLOWY",label = "Lower", value = NA))
                       ,column(width = 4, numericInput(inputId = "GDFUPPY",label = "Upper" , value = NA))
                       ,column(width = 4, numericInput(inputId = "GDFACC",label = "Accuracy" , value = NA))
                       ,column(width = 12, checkboxInput(inputId = "OBSGDF", label = "Show OBS (add by `,`)", value = FALSE))
                       ,column(width = 6, textInput(inputId = "GDFX", label = "X", value = ""))
                       ,column(width = 6, textInput(inputId = "GDFY", label = "Y", value = ""))
                     )
                   ),

                   #  box(
                   # title = "Dose prediction",
                   #      width = NULL,
                   #      background = "black",
                   #      status = "primary",
                   #      solidHeader = TRUE,
                   #      collapsible = TRUE,
                   #      collapsed = TRUE,
                   #   tags$div(
                   #     column(width = 12, h4("EBL-1463:"))
                   #     ,column(width = 12, numericInput(inputId = "TGFMIC", label = "Target %fT>Ct", value = NA))
                   #     ,column(width = 12, actionButton(inputId = "GETDOSE", label = "Predict dose"))
                   #     ,column(width = 12, textOutput(outputId = "PFTAM"))
                   #   )
                   # ),

                   box(

                     title = "Options",
                     width = NULL,
                     background = "black",
                     status = "primary",
                     solidHeader = TRUE,
                     collapsible = TRUE,
                     collapsed = TRUE,

                     # Simulation options
                     textInput(inputId = "DELTA", label = "Delta [h]", value = 1),
                     textInput(inputId = "DURA", label = "Duration [day]", value = 7),
                     textInput(inputId = "NSUB", label = "Number of subjects", value = 1),

                     # Plot options
                     checkboxInput(inputId = "SHIPRED", label = "Show IPRED", value = FALSE),
                     checkboxInput(inputId = "SHLGD", label = "Show legend", value = FALSE),
                     checkboxInput(inputId = "SUBTL", label = "Show subtitle", value = TRUE),
                     checkboxInput(inputId = "SHOWCAP", label = "Show caption", value = TRUE),
                     textInput(inputId = "CUSCAP", label = "Caption", value = ""),
                     textInput(inputId = "NOTES", label = "Notes", value = ""),

                     # PNG file name
                     textInput(inputId = "pfname",label="File name", value=""),

                     # Button to download plot
                     h5("Save:"),
                     # downloadButton(outputId="plotDL1", label="PK"),
                     # br(),br(),
                     # downloadButton(outputId="plotDL2", label="PK-PLT"),
                     # downloadButton(outputId="plotDL3", label="PK-PLT-BM"),
                     # downloadButton(outputId="plotDL4", label="PK-GDF"),
                     # br(),br(),
                     downloadButton(outputId="csvPK", label="CSV"),
                     # Help text
                     h6("Hint: Refresh browser to reset values"),
                     h6("Developed by",tags$a(href="https://github.com/soutomas","Tomas Sou",target="_blank"))
                     # tags$a(href="https://github.com/soutomas","Tomas Sou",target="_blank")
                   )

            ), # close column

            column(width = 10,

                   tabsetPanel(
                     type = "tabs"
                     ,tabPanel(
                       title = "PK",
                       box(
                         width = NULL,
                         background = "black",
                         title = "Plots",
                         status = NULL,
                         solidHeader = TRUE,
                         collapsible = TRUE,
                         align = "center",
                         plotOutput(outputId="plotPK", width=ptwid, height=pthgt),
                         downloadButton(outputId="plotDL1", label="PK")
                       )
                     )
                     ,tabPanel(
                       title = "PLT",
                       box(
                         width = NULL,
                         background = "black",
                         title = "Plots",
                         status = NULL,
                         solidHeader = TRUE,
                         collapsible = TRUE,
                         align = "center",
                         plotOutput(outputId="plotPLT", width=ptwid, height=pthgt)
                       )
                     )
                     ,tabPanel(
                       title = "GDF",
                       box(
                         width = NULL,
                         background = "black",
                         title = "Plots",
                         status = NULL,
                         solidHeader = TRUE,
                         collapsible = TRUE,
                         align = "center",
                         plotOutput(outputId="plotGDF", width=ptwid, height=pthgt)
                       )
                     )
                     ,tabPanel(
                       title = "PK-PLT",
                       box(
                         width = NULL,
                         background = "black",
                         title = "Plots",
                         status = NULL,
                         solidHeader = TRUE,
                         collapsible = TRUE,
                         align = "center",
                         plotOutput(outputId="plotPKPLT", width=ptwid, height=pthgt),
                         downloadButton(outputId="plotDL2", label="PK-PLT"),
                         downloadButton(outputId="plotDL3", label="PK-PLT-BM")
                       )
                     )
                     ,tabPanel(
                       title = "PK-GDF",
                       box(
                         width = NULL,
                         background = "black",
                         title = "Plots",
                         status = NULL,
                         solidHeader = TRUE,
                         collapsible = TRUE,
                         align = "center",
                         plotOutput(outputId="plotPKGDF", width=ptwid, height=pthgt),
                         downloadButton(outputId="plotDL4", label="PK-GDF"),
                       )
                     )
                     ,tabPanel(
                       title = "Ref",
                       box(
                         width = NULL,
                         background = "black",
                         title = "Reference",
                         status = NULL,
                         solidHeader = TRUE,
                         collapsible = TRUE,
                         align = "center",
                         h4("For CGM097:"),
                         h5("Bauer et al. (2021). Br J Cancer. 2021 Aug;125(5):687-98. PMID: 34140638"),
                         h5("`Pharmacokinetic-pharmacodynamic guided optimisation of dose and schedule of CGM097, an HDM2 inhibitor, in preclinical and clinical studies`"),
                         tags$a(href="https://pubmed.ncbi.nlm.nih.gov/34140638/","https://pubmed.ncbi.nlm.nih.gov/34140638/",target="_blank")
                       )
                     )
                   )
            ) # close column
          ) # close fluidRow
        ), # close tabItem

        tabItem(
          tabName = "body",

          column(width = 2,

                 box(
                   width = NULL,
                   background = "black",
                   title = "Plots",
                   status = "primary",
                   solidHeader = TRUE,
                   collapsible = TRUE,
                   collapsed = FALSE,

                   #Checkbox for log scale
                   checkboxInput("LOGY2", label = "Log-y?", value = TRUE),

                   #PNG file name
                   textInput(inputId="pfname2",label="File name", value=""),

                   #Button to download plot
                   # downloadButton(outputId="plotDL2",label="Save"),

                   #Help text
                   h6("Hint: refresh browser to reset values")
                 )
          ),

          column(width = 10,

                 box(
                   width = NULL,
                   background="black",
                   title = "Body",
                   status = NULL,
                   solidHeader = TRUE,
                   collapsible = TRUE,
                   align = "center",
                   plotOutput(outputId="plot.tab2",width=800,height=700)
                 )
          ) # close column
        ) # close tabItem
      ) # close tabItems
    )	# closing "dashboardBody"
  )  # closing "ui"

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #Define Server

  #Server
  server <-(function(input, output) {  #5

    # Reactive parameters
    # Spec = reactive({input$SPEC})  # 1=mouse; 2=human
    Strn = reactive({input$STRN})  # 1=Eco; 2=Kpn
    Mod = reactive({
      if(input$DRUG==1) mod = mod_CGM
      if(input$DRUG==2) mod = mod_HDM
      return(mod)
    })
    Wt = reactive({
      x = input$WT
      return(x)
    })
    Subn = reactive({eval(parse(text=input$NSUB))})
    Dura = reactive({eval(parse(text=input$DURA))})

    # Individual parameters and covariates
    Idata = reactive({
      subn = Subn()
      idata = data.frame(
        ID = 1:subn,
        evarm = 1)
    })

    # IPRED simulation function
    # delta = 0.01  # time-step for sim and fT>MIC
    fn.sim = function(amt = NULL){

      # Dose calculation
      Dose = reactive({
        dose = amt
        if(is.null(amt)) dose = eval(parse(text=input$DOSE))  # mg
        # if(input$KGD) dose = dose * Wt()  # convert mg/kg to mg
        return(dose)
      })

      # Dosing event dataset
      # Evdata.mt1 = reactive({
      #   wt = Wt()
      #   tau = input$TAU
      #   dura = Dura()
      #   dose = Dose()
      #   adm = as.numeric(input$ADM)
      #   ndose = ceiling(dura/tau)
      #   idata = Idata()
      # if(input$SS) ss = 1 else ss = 0
      #   ev1 = ev(amt=dose, addl=ndose-1, ii=tau, cmt=adm, tinf=input$INFH, ss=ss)  # cmt: 1=SC, 2=IV
      #   # ev1 = ev(amt=dose,addl=ndose-1,ii=tau,cmt=adm)  # cmt: 1=IV
      #   evall = seq(ev1)
      #   evdata = assign_ev(list(evall),idata,evgroup="evarm")
      # })

      # Simulation
      set.seed(12345)
      out = reactive({
        # evdata.all = Evdata.mt1()
        # evdata.all = rbind(evdata2,evdata1)
        # evdata = evdata.all %>% arrange(ID,time)
        # idata = Idata()
        tau = eval(parse(text=input$TAU))*24 # day => hr
        dose = Dose()*1000 # mg => mcg
        adm = ifelse(input$ADM==1,"A1","A2")
        # ndose = ceiling(dura/tau)
        ndose = eval(parse(text=input$NDOSE))
        idata = Idata()
        ss = 0
        if(input$SS) ss = 1
        evall = ev(amt=dose, addl=ndose-1, ii=tau, cmt=adm, ss=ss) # cmt: 1=oral, 2=IV
        tdose = eval(parse(text=paste0("c(",input$TDOSE,")")))*24 # day => hr
        if(length(tdose)>0) evall = ev(amt=dose, time=tdose, cmt=adm, ss=ss) # cmt: 1=oral, 2=IV
        if(input$PINF) talp = eval(parse(text=paste0("c(",input$TALP,")")))*24 # day => hr
        if(input$PINF) alp = eval(parse(text=input$ALP))
        if(input$PINF) evall = evall + ev(amt=alp, cmt="P5", time=talp, tinf=0.5) # 0.5 h transfusion
        delta = eval(parse(text=input$DELTA))
        dura = eval(parse(text=input$DURA))*24 # day => hr
        mod = Mod()
        if(input$NSUB==1) mod =  mod %>% zero_re() # omit IIV
        sim =
          mod %>%
          # data_set(evdata) %>%
          idata_set(idata) %>%
          carry_out(evarm) %>%
          param(
            DRUG = as.numeric(input$DRUG),
            WT = eval(parse(text=input$WT)),
            # HEM = ifelse(input$HEM, 1, 0),
            HEM = as.numeric(input$HEM),
            KA = ifelse(input$KA=="", param(mod)$KA, eval(parse(text=input$KA))),
            TLAG = ifelse(input$TLAG=="", param(mod)$TLAG, eval(parse(text=input$TLAG))),
            Ktr = ifelse(input$Ktr=="", param(mod)$Ktr, eval(parse(text=input$Ktr))),
            MTT = ifelse(input$MTT=="", param(mod)$MTT, eval(parse(text=input$MTT))),
            CL = ifelse(input$CL=="", param(mod)$CL, eval(parse(text=input$CL))),
            V1 = ifelse(input$V1=="", param(mod)$V1, eval(parse(text=input$V1))),
            FU = input$FU,
            PLTZ = ifelse(input$PLTZ=="", param(mod)$PLTZ, eval(parse(text=input$PLTZ))),
            MMT = ifelse(input$MMT=="", param(mod)$MMT, eval(parse(text=input$MMT))),
            MMTsolid = ifelse(input$MMT=="", param(mod)$MMTsolid, eval(parse(text=input$MMT))),
            LPW = ifelse(input$LPW=="", param(mod)$LPW, eval(parse(text=input$LPW))),
            SPW = ifelse(input$SPW=="", param(mod)$SPW, eval(parse(text=input$SPW))),
            KPRO = ifelse(input$KPRO=="", param(mod)$KPRO, ifelse(input$KPRO=="ktrP", -1, eval(parse(text=input$KPRO)))),
            KP5 = ifelse(input$KP5=="", param(mod)$KP5, ifelse(input$KP5=="ktrP", -1, eval(parse(text=input$KP5)))),
            KP1 = ifelse(input$KP1=="", param(mod)$KP1, eval(parse(text=input$KP1))),
            kSR = ifelse(input$kSR=="", param(mod)$kSR, eval(parse(text=input$kSR))),
            TRTPLT = ifelse(input$TRTPLT, 1, 0),
            KE0 = ifelse(input$KE0=="", param(mod)$KE0, eval(parse(text=input$KE0))),
            SLP_PLTZ = ifelse(input$SLP_PLTZ=="", param(mod)$SLP_PLTZ, eval(parse(text=input$SLP_PLTZ))),
            SLPD = ifelse(input$SLPD=="", param(mod)$SLPD, eval(parse(text=input$SLPD))),
            SLPI = ifelse(input$SLPI=="", param(mod)$SLPI, eval(parse(text=input$SLPI))),
            EMAX_PLT = ifelse(input$EMAX_PLT=="", param(mod)$EMAX_PLT, eval(parse(text=input$EMAX_PLT))),
            EC50_PLT = ifelse(input$EC50_PLT=="", param(mod)$EC50_PLT, eval(parse(text=input$EC50_PLT))),
            TRTGDF = ifelse(input$TRTGDF, 1, 0),
            GDFZ = ifelse(input$GDFZ=="", param(mod)$GDFZ, eval(parse(text=input$GDFZ))),
            KIN = ifelse(input$KIN=="", param(mod)$KIN, eval(parse(text=input$KIN))),
            KOUT = ifelse(input$KOUT=="", param(mod)$KOUT, eval(parse(text=input$KOUT))),
            EMAXG = ifelse(input$EMAXG=="", param(mod)$EMAXG, eval(parse(text=input$EMAXG))),
            EC50G = ifelse(input$EC50G=="", param(mod)$EC50G, eval(parse(text=input$EC50G))),
            GAMG = ifelse(input$GAMG=="", param(mod)$GAMG, eval(parse(text=input$GAMG))),
          ) %>%
          mrgsim_df(delta=delta, end=dura, events=evall, obsonly=TRUE, tad=TRUE, hmax=0.1, atol=1e-10)
      })

    }
    Sim = fn.sim()

    # Auto fT>MIC matching for dose prediction
    # observeEvent(input$GETDOSE, {
    # 	sim = Sim()
    #  tfTAM = input$TGFMIC
    #  pdose = idose = input$DOSE
    #   ftam = round(sum(sim$CPu>input$MIC)/(24/delta)*100,4)  # fT>MIC
    #   if(!is.na(tfTAM)){
    #   	dif = ftam - tfTAM
    #   	dose = idose
    #   	while(abs(dif)>0.1){
    # 	  	if (dif > 0) dose = dose * 0.9
    # 	  	if (dif <= -5) dose = dose * 1.1
    # 	  	if (dif < 0 & dif > -5) dose = dose * 1.01
    #    	Sim2 = fn.sim(amt = dose)
    #    	sim2 = Sim2()
    # 		ftam = round(sum(sim2$CPu>input$MIC)/(24/delta)*100,4)  # fT>MIC
    # 		dif = ftam - tfTAM
    #   	}
    #  	pdose = round(dose)
    #   }
    #   unit = "mg"
    #   if(input$KGD) unit = "mg/kg"
    #   output$PFTAM = renderText({paste0("fT>",input$MIC, " mg/L = ", round(ftam,1), "%; dose = ", pdose, " ", unit," q",input$TAU ,"h")})  # fT>MIC
    # })

    # PIs
    CP.PI = reactive({out = PIs(Sim(),"CP")})
    CPu.PI = reactive({out = PIs(Sim(),"CPu")})
    P5.PI = reactive({out = PIs(Sim(),"P5")})
    P1S.PI = reactive({out = PIs(Sim(),"P1S")})
    P1R.PI = reactive({out = PIs(Sim(),"P1R")})
    Ptot.PI = reactive({out = PIs(Sim(),"Ptot")})
    GDF.PI = reactive({out = PIs(Sim(),"GDF")})

    # Plot - PK
    rplotPK = function(){
      if(input$LOGPK) logy = "log10" else logy = "identity"
      if(input$ADM==2) adm = " IV" else if (input$ADM==1) adm = " oral" else adm = NULL
      ndose = input$NDOSE
      tdose = as.numeric(unlist(strsplit(input$TDOSE,split=",")))*24  # day => hr
      if(length(tdose)>0) ndose = length(tdose)
      stitle = paste0(input$DOSE," mg",adm)
      if(length(tdose)==0) stitle = paste0(stitle," q",input$TAU,"d x",ndose)
      hem = "SOL"
      if(input$HEM==1) hem = "HEM"
      if(input$SHCOV) stitle = paste0(stitle,"; ",input$WT," kg; ",hem)
      if(input$SHFU)  stitle = paste0(stitle,"; fu = ",input$FU)
      cap = paste0("n=",input$NSUB)
      if(!input$CUSCAP=="") cap = bquote(.(input$CUSCAP))
      if(!input$SHOWCAP) cap = NULL
      if(!is.na(input$ACC)) accu = input$ACC else accu = 0.1
      mic = input$MIC
      shmic = input$SHMIC
      if(shmic) {  # MIC
        mic.hline = geom_hline(yintercept=mic,linetype="dashed",col="red")
        mic.anno = annotate(geom="text", x=0, y=mic, label=paste0("Ct = ",mic), hjust=0, vjust=-0.5, col="grey50")
      } else {
        mic.hline = NULL
        mic.anno = NULL
      }
      dura = Dura()
      sim = Sim()
      dd = CP.PI()
      fdd = CPu.PI()
      # ftam = round(sum(fdd %>% filter(time<=24) %>% extract2("PImd") >mic)/(24/input$DELTA)*100,1)  # fT>MIC
      # if(input$SHMIC) stitle = paste0(stitle,"; MIC: ",input$MIC," ng/mL")
      if(!input$SUBTL) stitle = NULL
      # tm  = unique(sim$time)
      shcmax = input$SHCMAX
      cmax = round(max(dd[[2]]),1)
      if(input$SHCPU) cmax = round(max(fdd[[2]]),1)
      if(shcmax) {  # Cmin
        cmax.hline = geom_hline(yintercept=cmax, linetype="dashed", col="blue")
        cmax.anno = annotate(geom="text", x=0, y=cmax, label=paste0("Cmax = ",cmax), hjust=0, vjust=-0.5, col="grey50")
      }
      else {
        cmax.hline = NULL
        cmax.anno = NULL
      }
      if(input$SHCPU) dd = fdd
      if(input$OBSPK) dobs = tibble::tibble(
        x = eval(parse(text=paste0("c(",input$PKX,")"))),
        y = eval(parse(text=paste0("c(",input$PKY,")"))),
      )
      plt =
        ggplot(data=dd, aes(x=time/24))+
        {if(!input$SHCPU) geom_line(aes(y=PImd, linetype="CP"))}+
        {if(!input$SHCPU && input$SHIPRED) geom_line(data=sim, aes(y=CP, group=ID, linetype="CP"), alpha=0.3, col="navy")}+
        {if(input$SHCPU) geom_line(data=fdd, aes(y=PImd, linetype="CPU"))}+
        {if(input$SHCPU && input$SHIPRED) geom_line(data=sim, aes(y=CPu, group=ID, alpha=0.5, col="blue", linetype="CPU"))}+
        {if(input$OBSPK) geom_point(data=dobs, aes(x=x,y=y), col="red", size=2)}+
        geom_ribbon(aes(ymin=PIlo, ymax=PIup, fill="PI"), alpha=0.5)+
        cmax.hline + cmax.anno +  # Cmin line
        mic.hline + mic.anno + # MIC line
        scale_x_continuous(
          # breaks = seq(0, dura, 4),
          limits = c(NA,NA)
        )+
        scale_y_continuous(
          trans = logy,
          # breaks=c(0,2,4,6,8,10,12),
          limits = c(input$LOWY, input$UPPY),
          oob = squish,
          labels = comma_format(accuracy=accu)
        )+
        # {if(input$LOGPK) xgx_scale_y_log10(
        #   limits = c(input$LOWY, input$UPPY),
        #   oob = squish,
        # )}+
        labs(
          title = ifelse(input$DRUG==1,"CGM097","Drug")
          ,subtitle = stitle
          ,caption = cap
          ,x = "Time [day]"
          ,y = "Drug concentration [ng/mL]" #ylab
        )+
        guides(
          linetype = ifelse(input$SHLGD, "legend", "none"),
          fill = ifelse(input$SHLGD, "legend", "none"),
          colour = "none", # legd
          alpha = "none"
        )+
        scale_linetype_manual(
          name = NULL,
          labels = c("CP"="Median","CPU"="Median (free)"),
          values = c("CP"=1,"CPU"=2)
        )+
        scale_fill_manual(
          name = NULL,
          labels = c(paste0(PIpc,"%PI")),
          values = c("grey")
        )+
        xgxr::xgx_annotate_status()+
        theme_bw()+
        theme(
          plot.title = element_text(hjust=0.5,size=18,face="bold"),
          plot.subtitle = element_text(hjust=0.5,size=12),  # align subtitle
          # plot.caption=element_text(hjust=0.5,size=14),
          axis.text.x = element_text(size=11),
          axis.text.y = element_text(size=11),
          axis.title = element_text(size=12),
          strip.text = element_text(size=12),
          # legend.title=element_blank(),
          legend.position = "bottom",
          aspect.ratio = 1
        )
    }

    # Plot - Platelet
    rplotPLT = function(){
      if(input$LOGPLT) logy = "log10" else logy = "identity"
      cap = paste0("n=",input$NSUB)
      if(!input$CUSCAP=="") cap = bquote(.(input$CUSCAP))
      if(!input$SHOWCAP) cap = NULL
      if(!is.na(input$PLTACC)) accu = input$PLTACC else accu = 0.1
      mod = Mod()
      trt = "; Drug = no"
      if(input$TRTPLT && input$DRUG==1) trt = "; Drug = CGM"
      if(input$TRTPLT && input$DRUG==2) trt = "; Drug = HDM"
      ke0 = ifelse(input$KE0=="", param(mod)$KE0, input$KE0)
      slp_pltz = ifelse(input$SLP_PLTZ=="", param(mod)$SLP_PLTZ, input$SLP_PLTZ)
      stitle = paste0("kE0=",ke0,"; SLPpltz=",slp_pltz,trt)
      if(!input$SUBTL) stitle = NULL
      dura = Dura()
      sim = Sim()
      dd = P5.PI()
      ylab = "Platelet count [10^9/L]"
      if(input$OBSPLT) dobs = tibble::tibble(
        x = eval(parse(text=paste0("c(",input$PLTX,")"))),
        y = eval(parse(text=paste0("c(",input$PLTY,")"))),
      )
      plt =
        ggplot(data=dd, aes(x=time/24))+
        geom_line(aes(y=PImd, linetype="Median"))+
        geom_ribbon(aes(ymin=PIlo, ymax=PIup, fill="PI"), alpha=0.5)+
        {if(input$SHIPRED) geom_line(data=sim, aes(y=P5, group=ID), alpha=0.3, col="navy")}+
        {if(input$TPG) geom_hline(yintercept=100, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=100, label=paste0("Grade 1: 100"), hjust=0, vjust=1, col=1)}+
        {if(input$TPG) geom_hline(yintercept=75, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=75, label=paste0("Grade 2: 75"), hjust=0, vjust=1, col=1)}+
        {if(input$TPG) geom_hline(yintercept=50, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=50, label=paste0("Grade 3: 50"), hjust=0, vjust=1, col=1)}+
        {if(input$TPG) geom_hline(yintercept=25, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=25, label=paste0("Grade 4: 25"), hjust=0, vjust=1, col=1)}+
        {if(input$OBSPLT) geom_point(data=dobs, aes(x=x,y=y), col="red", size=2)}+
        scale_x_continuous(
          # breaks = seq(0, dura, 4),
          limits = c(NA,NA)
        )+
        scale_y_continuous(
          trans = logy,
          # breaks=c(0,2,4,6,8,10,12),
          # breaks = trans_breaks("log10", function(x) 10^x),
          # labels = trans_format("log10", math_format(10^.x)) ,
          # labels = comma_format(accuracy=accu),
          limits = c(input$PLTLOWY, input$PLTUPPY),
          oob = squish,
        )+
        # {if(input$LOGPLT) xgx_scale_y_log10(
        #   limits = c(input$PLTLOWY, input$PLTUPPY),
        #   oob = squish,
        # )}+
        labs(
          title = paste0("Platelet")
          ,subtitle = stitle
          ,caption = cap
          ,x = "Time [day]"
          ,y = ylab
          ,shape = NULL
        )+
        guides(
          linetype = ifelse(input$SHLGD, "legend", "none"),
          fill = ifelse(input$SHLGD, "legend", "none"),
          col = "none",
          alpha = "none"
        )+
        scale_linetype_manual(
          name = NULL,
          labels = c("Median"),
          values = c("solid")
        )+
        scale_fill_manual(
          name = NULL,
          labels = c(paste0(PIpc,"%PI")),
          values = c("grey")
        )+
        scale_shape_manual(
          name = NULL,
          values = c(0,1,2,5)
        )+
        xgxr::xgx_annotate_status()+
        theme_bw()+
        theme(
          plot.title = element_text(hjust=0.5, size=18, face="bold"),
          plot.subtitle = element_text(hjust=0.5, size=12),  # align subtitle
          # plot.caption=element_text(hjust=0.5,size=14),
          axis.text.x = element_text(size=11),
          axis.text.y = element_text(size=11),
          axis.title = element_text(size=12),
          strip.text = element_text(size=12),
          # legend.title=element_blank(),
          legend.position = "bottom",
          aspect.ratio = 1
        )
    }

    # Plot - BM cells
    rplotP1 = function(){
      if(input$LOGPLT) logy = "log10" else logy = "identity"
      cap = paste0("n=",input$NSUB)
      if(!input$CUSCAP=="") cap = bquote(.(input$CUSCAP))
      if(!input$SHOWCAP) cap = NULL
      if(!is.na(input$PLTACC)) accu = input$PLTACC else accu = 0.1
      mod = Mod()
      trt = "; Drug = no"
      if(input$TRTPLT && input$DRUG==1) trt = "; Drug = CGM"
      if(input$TRTPLT && input$DRUG==2) trt = "; Drug = HDM"
      ksr = ifelse(input$kSR=="", param(mod)$kSR, input$kSR)
      stitle = paste0("kSR=",ksr,trt)
      if(!input$SUBTL) stitle = NULL
      dura = Dura()
      sim = Sim()
      ddS = P1S.PI()
      ddR = P1R.PI()
      ddPtot = Ptot.PI()
      ylab = "Cell count [10^9/L]"
      if(input$OBSPLT) dobs = tibble::tibble(
        x = eval(parse(text=paste0("c(",input$PLTX,")"))),
        y = eval(parse(text=paste0("c(",input$PLTY,")"))),
      )
      plt =
        ddS %>%
        ggplot(aes(x=time/24))+
        geom_line(data=ddS, aes(y=PImd, linetype="Median", col="P1S"))+
        geom_line(data=ddR, aes(y=PImd, linetype="Median", col="P1R"))+
        geom_line(data=ddPtot, aes(y=PImd, linetype="Median", col="Ptot"))+
        geom_ribbon(data=ddS, aes(ymin=PIlo, ymax=PIup, fill="P1S"), alpha=0.2)+
        geom_ribbon(data=ddR, aes(ymin=PIlo, ymax=PIup, fill="P1R"), alpha=0.2)+
        geom_ribbon(data=ddPtot, aes(ymin=PIlo, ymax=PIup, fill="Ptot"), alpha=0.2)+
        {if(input$SHIPRED) geom_line(data=sim, aes(y=Ptot, group=ID, col="Ptot"), alpha=0.2)}+
        {if(input$SHIPRED) geom_line(data=sim, aes(y=P1R, group=ID, col="P1R"), alpha=0.2)}+
        {if(input$SHIPRED) geom_line(data=sim, aes(y=P1S, group=ID, col="P1S"), alpha=0.2)}+
        {if(input$TPG) geom_hline(yintercept=100, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=100, label=paste0("Grade 1: 100"), hjust=0, vjust=1, col=1)}+
        {if(input$TPG) geom_hline(yintercept=75, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=75, label=paste0("Grade 2: 75"), hjust=0, vjust=1, col=1)}+
        {if(input$TPG) geom_hline(yintercept=50, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=50, label=paste0("Grade 3: 50"), hjust=0, vjust=1, col=1)}+
        {if(input$TPG) geom_hline(yintercept=25, linetype="dashed", col=1)}+
        {if(input$TPG) annotate(geom="text", x=0, y=25, label=paste0("Grade 4: 25"), hjust=0, vjust=1, col=1)}+
        {if(input$OBSPLT) geom_point(data=dobs, aes(x=x,y=y), col="red", size=2)}+
        scale_x_continuous(
          # breaks = seq(0, dura, 4),
          limits = c(NA,NA)
        )+
        scale_y_continuous(
          trans = logy,
          # breaks=c(0,2,4,6,8,10,12),
          # breaks = trans_breaks("log10", function(x) 10^x),
          # labels = trans_format("log10", math_format(10^.x)) ,
          # labels = comma_format(accuracy=accu),
          limits = c(input$PLTLOWY, input$PLTUPPY),
          oob = squish,
        )+
        # {if(input$LOGPLT) xgx_scale_y_log10(
        #   limits = c(input$PLTLOWY, input$PLTUPPY),
        #   oob = squish,
        # )}+
        labs(
          title = paste0("BM")
          ,subtitle = stitle
          ,caption = cap
          ,x = "Time [day]"
          ,y = ylab
          ,shape = NULL
        )+
        guides(
          linetype = ifelse(input$SHLGD, "legend", "none"),
          fill = ifelse(input$SHLGD, "legend", "none"),
          col = "none",
          alpha = "none"
        )+
        scale_linetype_manual(
          name = NULL,
          labels = c("Median"),
          values = c("solid")
        )+
        scale_colour_manual(
          name = NULL,
          values=c("P1S"="blue","P1R"="red","Ptot"="grey80")
        )+
        scale_fill_manual(
          name = NULL,
          values=c("P1S"="blue","P1R"="red","Ptot"="grey80")
        )+
        scale_shape_manual(
          name = NULL,
          values = c(0,1,2,5)
        )+
        xgx_annotate_status()+
        theme_bw()+
        theme(
          plot.title = element_text(hjust=0.5, size=18, face="bold"),
          plot.subtitle = element_text(hjust=0.5, size=12),  # align subtitle
          # plot.caption=element_text(hjust=0.5,size=14),
          axis.text.x = element_text(size=11),
          axis.text.y = element_text(size=11),
          axis.title = element_text(size=12),
          strip.text = element_text(size=12),
          # legend.title=element_blank(),
          legend.position = "bottom",
          aspect.ratio = 1
        )
    }

    # Plot - GDF-15
    rplotGDF = function(){
      if(input$LOGGDF) logy = "log10" else logy = "identity"
      cap = paste0("n=",input$NSUB)
      if(!input$CUSCAP=="") cap = bquote(.(input$CUSCAP))
      if(!input$SHOWCAP) cap = NULL
      if(!is.na(input$GDFACC)) accu = input$GDFACC else accu = 0.1
      mod = Mod()
      trt = "Drug = no"
      if(input$TRTGDF && input$DRUG==1) trt = "Drug = CGM"
      if(input$TRTGDF && input$DRUG==2) trt = "Drug = HDM"
      stitle = trt
      if(!input$SUBTL) stitle = NULL
      sim = Sim()
      dd = GDF.PI()
      ylab = "Serum GDF-15 level [pg/mL]"
      if(input$OBSGDF) dobs = tibble::tibble(
        x = eval(parse(text=paste0("c(",input$GDFX,")"))),
        y = eval(parse(text=paste0("c(",input$GDFY,")"))),
      )
      plt =
        ggplot(data=dd, aes(x=time/24))+
        geom_line(aes(y=PImd, linetype="Median"))+
        geom_ribbon(aes(ymin=PIlo, ymax=PIup, fill="PI"), alpha=0.5)+
        {if(input$SHIPRED) geom_line(data=sim, aes(y=GDF, group=ID), alpha=0.3, col="navy")}+
        {if(input$OBSGDF) geom_point(data=dobs, aes(x=x,y=y), col="red", size=2)}+
        scale_x_continuous(
          # breaks = seq(0, dura, 4),
          limits = c(NA,NA)
        )+
        scale_y_continuous(
          trans = logy,
          # breaks=c(0,2,4,6,8,10,12),
          # breaks = trans_breaks("log10", function(x) 10^x),
          # labels = trans_format("log10", math_format(10^.x)) ,
          limits = c(input$GDFLOWY, input$GDFUPPY),
          oob = squish,
          # labels = comma_format(accuracy=accu)
        )+
        # {if(input$LOGGDF)
        # xgx_scale_y_log10(
        #   limits = c(input$GDFLOWY, input$GDFUPPY),
        #   oob = squish,
        # )
        # }+
        labs(
          title = paste0("GDF-15")
          ,subtitle = stitle
          ,caption = cap
          ,x = "Time [day]"
          ,y = ylab
          ,shape = NULL
        )+
        guides(
          linetype = ifelse(input$SHLGD, "legend", "none"),
          fill = ifelse(input$SHLGD, "legend", "none"),
          col = "none",
          alpha = "none"
        )+
        scale_linetype_manual(
          name = NULL,
          labels = c("Median"),
          values = c("solid")
        )+
        scale_fill_manual(
          name = NULL,
          labels = c(paste0(PIpc,"%PI")),
          values = c("grey")
        )+
        scale_shape_manual(
          name = NULL,
          values = c(0,1,2,5)
        )+
        xgx_annotate_status()+
        theme_bw()+
        theme(
          plot.title = element_text(hjust=0.5, size=18, face="bold"),
          plot.subtitle = element_text(hjust=0.5, size=12),  # align subtitle
          # plot.caption=element_text(hjust=0.5,size=14),
          axis.text.x = element_text(size=11),
          axis.text.y = element_text(size=11),
          axis.title = element_text(size=12),
          strip.text = element_text(size=12),
          # legend.title=element_blank(),
          legend.position = "bottom",
          aspect.ratio = 1
        )
    }

    # Combine all plots for layout
    rplot11 = reactive({
      p2 = rplotPK()
      pall = ggarrange(p2, ncol=1, nrow=1, align="hv", legend="bottom", common.legend=FALSE)
      pall = annotate_figure(
        p = pall
        ,bottom = text_grob(paste0("v",td), hjust=1.1, x=1, size=10)
      )
      return(pall)
    })
    output$plotPK = renderPlot({rplot11()})

    rplot1 = reactive({
      p1 = rplotPLT()
      # p2 = rplotP1()
      pall = ggarrange(p1, ncol=1, nrow=1, align="hv", legend="bottom", common.legend=FALSE)
      pall = annotate_figure(
        p = pall
        ,bottom = text_grob(paste0("v",td), hjust=1.1, x=1, size=10)
      )
      return(pall)
    })
    output$plotPLT = renderPlot({rplot1()})

    rplot2 = reactive({
      p1 = rplotPK()
      p2 = rplotPLT()
      pall = ggarrange(p1,p2, ncol=2, nrow=1, align="hv", legend="bottom", common.legend=FALSE)
      pall = annotate_figure(
        p = pall
        ,bottom = text_grob(paste0("v",td), hjust=1.1, x=1, size=10)
      )
      return(pall)
    })

    rplot3 = reactive({
      p1 = rplotPK()
      p2 = rplotPLT()
      p3 = rplotP1()
      pall = ggarrange(p1,p2, p3, ncol=3, nrow=1, align="hv", legend="bottom", common.legend=FALSE)
      pall = annotate_figure(
        p = pall
        ,bottom = text_grob(paste0("v",td), hjust=1.1, x=1, size=10)
      )
      return(pall)
    })
    output$plotPKPLT = renderPlot({rplot3()})

    rplot4 = reactive({
      p1 = rplotPK()
      p2 = rplotGDF()
      pall = ggarrange(p1,p2, ncol=2, nrow=1, align="hv", legend="bottom", common.legend=FALSE)
      pall = annotate_figure(
        p = pall
        ,bottom = text_grob(paste0("v",td), hjust=1.1, x=1, size=10)
      )
      return(pall)
    })
    output$plotPKGDF = renderPlot({rplot4()})

    rplot5 = reactive({
      # p1 = rplotPK()
      p2 = rplotGDF()
      pall = ggarrange(p2, ncol=1, nrow=1, align="hv", legend="bottom", common.legend=FALSE)
      pall = annotate_figure(
        p = pall
        ,bottom = text_grob(paste0("v",td), hjust=1.1, x=1, size=10)
      )
      return(pall)
    })
    output$plotGDF = renderPlot({rplot5()})

    # Save plots
    output$plotDL1 = downloadHandler(
      filename = function(){
        paste0("PK_",input$pfname,"_",td,".png")
      },
      content = function(file){
        ggsave(file, plot=rplotPK(), width=7, height=7, scale=)
      }
    )
    output$plotDL2 = downloadHandler(
      filename = function(){
        paste0("PKPLT_",input$pfname,"_",td,".png")
      },
      content = function(file){
        ggsave(file, plot=rplot2(), width=12, height=7, scale=1)
      }
    )
    output$plotDL3 = downloadHandler(
      filename = function(){
        paste0("PKPLTBM_",input$pfname,"_",td,".png")
      },
      content = function(file){
        ggsave(file, plot=rplot3(), width=15, height=6, scale=1)
      }
    )
    output$plotDL4 = downloadHandler(
      filename = function(){
        paste0("PKGDF_",input$pfname,"_",td,".png")
      },
      content = function(file){
        ggsave(file, plot=rplot4(), width=12, height=7, scale=1)
      }
    )

    # Save CSV
    CsvPK = reactive({
      tau = input$TAU
      adm0 = input$ADM
      adm = ifelse(adm0==1, "Oral", ifelse(adm0==2, "IV", NA))
      sim = Sim()
      out = tibble::tibble(
        TIME = sim$time,
        CPtotal = sim$CP,
        CPunit = "ng/mL",
        DRUG = ifelse(input$DRUG==1,"CGM","HDM"),
        TAU = tau,
        ADM = adm,
      )
    })
    output$csvPK = downloadHandler(
      filename = function(){paste0(pngname,"_",input$pfname,".csv")},
      content = function(file){
        write.csv(CsvPK(), file, row.names=FALSE)
      }
    )

  })  #5 closing server

  shinyApp(ui=ui, server=server, options=list(launch.browser=TRUE))

}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Run app
# print(shinyApp(ui=ui, server=server))
# Launch from shortcut
# print(shinyApp(ui=ui, server=server,options=list(launch.browser=TRUE)))

