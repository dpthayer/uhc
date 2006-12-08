# location of RULER3 src
SRC_RULER3_PREFIX	:= $(SRC_PREFIX)ruler3/
RULER3_DEMO_PREFIX	:= $(SRC_RULER3_PREFIX)demo/

# location of shuffle build
RULER3_BLD_PREFIX	:= $(BLD_PREFIX)ruler3/

# this file
RULER3_MKF			:= $(SRC_RULER3_PREFIX)files.mk

# sources + dpds, for .rul
RULER3_RULES_SRC_RL2					:= $(SRC_RULER3_PREFIX)RulerRules.crul

# main + sources + dpds
RULER3_MAIN			:= Ruler

RULER3_HS_MAIN_SRC_HS					:= $(addprefix $(SRC_RULER3_PREFIX),$(RULER3_MAIN).chs)
RULER3_HS_MAIN_DRV_HS					:= $(patsubst $(SRC_RULER3_PREFIX)%.chs,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_HS_MAIN_SRC_HS))
RULER3_HS_DPDS_SRC_HS					:= $(patsubst %,$(SRC_RULER3_PREFIX)%.chs,\
											Version Common Err Opts AttrProps \
											NmParser ViewSel/Parser SelParser KeywParser Parser \
											ARule/Utils Expr/Utils Ty/Utils LaTeXFmtUtils Utils ViewSel/Utils \
											Gam FmGam ECnstrGam RwExprGam WrKindGam JdShpGam \
											Admin MkAdmin \
											Expr/ToAEqn \
											Scanner ScannerMachine \
											)
RULER3_HS_DPDS_DRV_HS					:= $(patsubst $(SRC_RULER3_PREFIX)%.chs,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_HS_DPDS_SRC_HS))

RULER3_CHS_UTIL_SRC_CHS					:= $(patsubst %,$(SRC_RULER3_PREFIX)%.chs,Config)
RULER3_CHS_UTIL_DRV_HS					:= $(patsubst $(SRC_RULER3_PREFIX)%.chs,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_CHS_UTIL_SRC_CHS))

RULER3_AGMAIN1_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Main1AG)
RULER3_AGMAIN1_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag, \
											AbsSyn/CommonAG AbsSyn/1 AS1/Misc AS1/Pretty AS1/RlSel FmGamAG \
											AS1/SchemeDpd AS1/ViewDpd \
											AS1/GenAS2 \
											Expr/AbsSynAG Expr/IsRwAG Expr/NmSAG Expr/FmGamAG Expr/PrettyPrintAG Expr/SelfAG \
											Ty/AbsSynAG Ty/SelfAG \
											)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGMAIN1_MAIN_SRC_AG)) \
										: $(RULER3_AGMAIN1_DPDS_SRC_AG)

RULER3_AS1IMPS_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,AS1/Imports)
RULER3_AS1IMPS_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag, \
											AbsSyn/1AG AbsSyn/CommonAG \
											Expr/AbsSynAG \
											Ty/AbsSynAG \
											)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AS1IMPS_MAIN_SRC_AG)) \
										: $(RULER3_AS1IMPS_DPDS_SRC_AG)

RULER3_AGMAIN2_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Main2AG)
RULER3_AGMAIN2_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag, \
											AbsSyn/CommonAG AbsSyn/2AG AS2/Opts AS2/Pretty FmGamAG \
											Expr/AbsSynAG Expr/SelfAG Expr/PrettyPrintAG Expr/FmGamAG \
											ARule/AbsSynAG ARule/SelfAG ARule/PrettyPrintAG \
											)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGMAIN2_MAIN_SRC_AG)) \
										: $(RULER3_AGMAIN2_DPDS_SRC_AG)

RULER3_TRF2ARULE_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,TrfAS2/GenARule)
RULER3_TRF2ARULE_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag, \
											AbsSyn/CommonAG AbsSyn/2AG AS2/Opts \
											TrfAS2/CommonAG \
											Expr/AbsSynAG Expr/SelfAG \
											ARule/AbsSynAG ARule/SelfAG \
											)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_TRF2ARULE_MAIN_SRC_AG)) \
										: $(RULER3_TRF2ARULE_DPDS_SRC_AG)

RULER3_TRF2LATEX_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,TrfAS2/GenLaTeX)
RULER3_TRF2LATEX_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag, \
											AbsSyn/CommonAG AbsSyn/2AG AS2/Opts \
											TrfAS2/CommonAG \
											Expr/AbsSynAG Expr/SelfAG \
											ARule/AbsSynAG ARule/SelfAG \
											)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_TRF2LATEX_MAIN_SRC_AG)) \
										: $(RULER3_TRF2LATEX_DPDS_SRC_AG)

RULER3_AGRLAST1_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,AbsSyn/1)
RULER3_AGRLAST1_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,AbsSyn/1AG AbsSyn/CommonAG)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGRLAST1_MAIN_SRC_AG)) \
										: $(RULER3_AGRLAST1_DPDS_SRC_AG)

RULER3_AGRLAST2_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,AbsSyn/2)
RULER3_AGRLAST2_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,AbsSyn/2AG AbsSyn/CommonAG)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGRLAST2_MAIN_SRC_AG)) \
										: $(RULER3_AGRLAST2_DPDS_SRC_AG)

RULER3_AGEXPR_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/Expr)
RULER3_AGEXPR_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGEXPR_MAIN_SRC_AG)) \
										: $(RULER3_AGEXPR_DPDS_SRC_AG)

RULER3_AGTY_MAIN_SRC_AG					:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Ty/Ty)
RULER3_AGTY_DPDS_SRC_AG					:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Ty/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGTY_MAIN_SRC_AG)) \
										: $(RULER3_AGTY_DPDS_SRC_AG)

RULER3_TYPRETTY_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Ty/PrettyPrint)
RULER3_TYPRETTY_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Ty/AbsSynAG Ty/PrettyPrintAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_TYPRETTY_MAIN_SRC_AG)) \
										: $(RULER3_TYPRETTY_DPDS_SRC_AG)

RULER3_EXISRW_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/IsRw)
RULER3_EXISRW_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/AbsSynAG Expr/IsRwAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_EXISRW_MAIN_SRC_AG)) \
										: $(RULER3_EXISRW_DPDS_SRC_AG)

RULER3_EXNMS_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/NmS)
RULER3_EXNMS_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/AbsSynAG Expr/NmSAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_EXNMS_MAIN_SRC_AG)) \
										: $(RULER3_EXNMS_DPDS_SRC_AG)

RULER3_EXLTX_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/LaTeX)
RULER3_EXLTX_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/AbsSynAG Expr/OptsAG Expr/LaTeXAG Expr/FmGamAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_EXLTX_MAIN_SRC_AG)) \
										: $(RULER3_EXLTX_DPDS_SRC_AG)

RULER3_EXCOGAM_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/CoGam)
RULER3_EXCOGAM_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,Expr/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_EXCOGAM_MAIN_SRC_AG)) \
										: $(RULER3_EXCOGAM_DPDS_SRC_AG)

RULER3_AGVWSL_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/ViewSel)
RULER3_AGVWSL_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGVWSL_MAIN_SRC_AG)) \
										: $(RULER3_AGVWSL_DPDS_SRC_AG)

RULER3_VWSLSELF_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/Self)
RULER3_VWSLSELF_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_VWSLSELF_MAIN_SRC_AG)) \
										: $(RULER3_VWSLSELF_DPDS_SRC_AG)

RULER3_VWSLNMS_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/NmS)
RULER3_VWSLNMS_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/AbsSynAG ViewSel/DpdGrAG ViewSel/NmSAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_VWSLNMS_MAIN_SRC_AG)) \
										: $(RULER3_VWSLNMS_DPDS_SRC_AG)

RULER3_RLSLRNM_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/RlRnm)
RULER3_RLSLRNM_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_RLSLRNM_MAIN_SRC_AG)) \
										: $(RULER3_RLSLRNM_DPDS_SRC_AG)

RULER3_RLSLISSL_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/RlIsSel)
RULER3_RLSLISSL_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/AbsSynAG ViewSel/NmSAG ViewSel/DpdGrAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_RLSLISSL_MAIN_SRC_AG)) \
										: $(RULER3_RLSLISSL_DPDS_SRC_AG)

RULER3_VWSLPP_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/PrettyPrint)
RULER3_VWSLPP_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ViewSel/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_VWSLPP_MAIN_SRC_AG)) \
										: $(RULER3_VWSLPP_DPDS_SRC_AG)

RULER3_AGARULE_MAIN_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/ARule)
RULER3_AGARULE_DPDS_SRC_AG				:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AGARULE_MAIN_SRC_AG)) \
										: $(RULER3_AGARULE_DPDS_SRC_AG)

RULER3_ARLPATUNQ_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/PatternUniq)
RULER3_ARLPATUNQ_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AbsSynAG ARule/OptsAG Expr/AbsSynAG ARule/CopyRuleNmAG ARule/FmGamAG Expr/FmGamAG Expr/OptsAG)
$(patsubst $(SRC_RULER3_PREFIX)%.ag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_ARLPATUNQ_MAIN_SRC_AG)) \
										: $(RULER3_ARLPATUNQ_DPDS_SRC_AG)

RULER3_ARLRWSUBS_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/RwSubst)
RULER3_ARLRWSUBS_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AbsSynAG ARule/OptsAG Expr/AbsSynAG ARule/CopyRuleNmAG ARule/FmGamAG Expr/FmGamAG Expr/OptsAG Expr/RwExprGamAG)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_ARLRWSUBS_MAIN_SRC_AG)) \
										: $(RULER3_ARLRWSUBS_DPDS_SRC_AG)

RULER3_ARLAVARSUBS_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AVarRename)
RULER3_ARLAVARSUBS_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AbsSynAG Expr/AbsSynAG Expr/SelfAG ARule/SelfAG ARule/EqnDest1NmAG ARule/InCompDestAG)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_ARLAVARSUBS_MAIN_SRC_AG)) \
										: $(RULER3_ARLAVARSUBS_DPDS_SRC_AG)

RULER3_ARLELIMCR_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/ElimCopyRule)
RULER3_ARLELIMCR_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AbsSynAG Expr/AbsSynAG ARule/CopyRuleNmAG ARule/EqnDest1NmAG ARule/InCompDestAG Expr/SelfAG ARule/SelfAG)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_ARLELIMCR_MAIN_SRC_AG)) \
										: $(RULER3_ARLELIMCR_DPDS_SRC_AG)

RULER3_ARLELIMWLDC_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/ElimWildcAssign)
RULER3_ARLELIMWLDC_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AbsSynAG Expr/AbsSynAG)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_ARLELIMWLDC_MAIN_SRC_AG)) \
										: $(RULER3_ARLELIMWLDC_DPDS_SRC_AG)

RULER3_ARLPRETTY_MAIN_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/PrettyPrint)
RULER3_ARLPRETTY_DPDS_SRC_AG			:= $(patsubst %,$(SRC_RULER3_PREFIX)%.cag,ARule/AbsSynAG Expr/AbsSynAG Expr/PrettyPrintAG ARule/PrettyPrintAG Expr/SelfAG ARule/SelfAG)
$(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_ARLPRETTY_MAIN_SRC_AG)) \
										: $(RULER3_ARLPRETTY_DPDS_SRC_AG)

RULER3_AG_D_MAIN_SRC_AG					:= $(RULER3_AGEXPR_MAIN_SRC_AG) $(RULER3_AGTY_MAIN_SRC_AG) $(RULER3_AGRLAST1_MAIN_SRC_AG) $(RULER3_AGRLAST2_MAIN_SRC_AG) $(RULER3_AGVWSL_MAIN_SRC_AG) $(RULER3_AGARULE_MAIN_SRC_AG)
RULER3_AG_S_MAIN_SRC_AG					:= $(RULER3_EXISRW_MAIN_SRC_AG) $(RULER3_EXNMS_MAIN_SRC_AG) $(RULER3_EXLTX_MAIN_SRC_AG) \
											$(RULER3_EXCOGAM_MAIN_SRC_AG) $(RULER3_EXREGAM_MAIN_SRC_AG) \
											$(RULER3_VWSLSELF_MAIN_SRC_AG) $(RULER3_VWSLNMS_MAIN_SRC_AG) $(RULER3_RLSLRNM_MAIN_SRC_AG) \
											$(RULER3_RLSLISSL_MAIN_SRC_AG) $(RULER3_VWSLPP_MAIN_SRC_AG) $(RULER3_ARLPATUNQ_MAIN_SRC_AG) \
											$(RULER3_ARLRWSUBS_MAIN_SRC_AG) $(RULER3_ARLAVARSUBS_MAIN_SRC_AG) $(RULER3_ARLELIMCR_MAIN_SRC_AG) $(RULER3_ARLELIMWLDC_MAIN_SRC_AG) \
											$(RULER3_ARLPRETTY_MAIN_SRC_AG) \
											$(RULER3_TYPRETTY_MAIN_SRC_AG) \
											$(RULER3_AGMAIN1_MAIN_SRC_AG) $(RULER3_AGMAIN2_MAIN_SRC_AG) \
											$(RULER3_AS1IMPS_MAIN_SRC_AG) \
											$(RULER3_TRF2ARULE_MAIN_SRC_AG) $(RULER3_TRF2LATEX_MAIN_SRC_AG)
RULER3_AG_DS_MAIN_SRC_AG				:=

RULER3_AG_ALL_DPDS_SRC_AG				:= $(sort \
											$(RULER3_AGMAIN1_DPDS_SRC_AG) \
											$(RULER3_AS1IMPS_DPDS_SRC_AG) \
											$(RULER3_AGMAIN2_DPDS_SRC_AG) \
											$(RULER3_TRF2ARULE_DPDS_SRC_AG) \
											$(RULER3_TRF2LATEX_DPDS_SRC_AG) \
											$(RULER3_AGEXPR_DPDS_SRC_AG) \
											$(RULER3_AGTY_DPDS_SRC_AG) \
											$(RULER3_AGRLAST1_DPDS_SRC_AG) \
											$(RULER3_AGRLAST2_DPDS_SRC_AG) \
											$(RULER3_AGVWSL_DPDS_SRC_AG) \
											$(RULER3_AGARULE_DPDS_SRC_AG) \
											$(RULER3_EXISRW_DPDS_SRC_AG) \
											$(RULER3_EXNMS_DPDS_SRC_AG) \
											$(RULER3_EXLTX_DPDS_SRC_AG) \
											$(RULER3_EXCOGAM_DPDS_SRC_AG) \
											$(RULER3_EXREGAM_DPDS_SRC_AG) \
											$(RULER3_VWSLSELF_DPDS_SRC_AG) \
											$(RULER3_VWSLNMS_DPDS_SRC_AG) \
											$(RULER3_RLSLRNM_DPDS_SRC_AG) \
											$(RULER3_RLSLISSL_DPDS_SRC_AG) \
											$(RULER3_VWSLPP_DPDS_SRC_AG) \
											$(RULER3_ARLPATUNQ_DPDS_SRC_AG) \
											$(RULER3_ARLRWSUBS_DPDS_SRC_AG) \
											$(RULER3_ARLAVARSUBS_DPDS_SRC_AG) \
											$(RULER3_ARLELIMCR_DPDS_SRC_AG) \
											$(RULER3_ARLELIMWLDC_DPDS_SRC_AG) \
											$(RULER3_ARLPRETTY_DPDS_SRC_AG) \
											$(RULER3_TYPRETTY_DPDS_SRC_AG) \
											)

RULER3_AG_ALL_MAIN_SRC_AG				:= $(RULER3_AG_D_MAIN_SRC_AG) $(RULER3_AG_S_MAIN_SRC_AG) $(RULER3_AG_DS_MAIN_SRC_AG)

# all src
RULER3_ALL_SRC							:= $(RULER3_AG_ALL_MAIN_SRC_AG) $(RULER3_AG_ALL_DPDS_SRC_AG) $(RULER3_HS_MAIN_SRC_HS) \
											$(RULER3_CHS_UTIL_SRC_CHS) $(RULER3_HS_DPDS_SRC_HS) $(RULER3_MKF) $(RULER3_RULES_SRC_RL2)


# derived
RULER3_AG_D_MAIN_DRV_HS					:= $(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AG_D_MAIN_SRC_AG))
RULER3_AG_S_MAIN_DRV_HS					:= $(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AG_S_MAIN_SRC_AG))
RULER3_AG_DS_MAIN_DRV_HS				:= $(patsubst $(SRC_RULER3_PREFIX)%.cag,$(RULER3_BLD_PREFIX)%.hs,$(RULER3_AG_DS_MAIN_SRC_AG))
RULER3_AG_ALL_MAIN_DRV_HS				:= $(RULER3_AG_D_MAIN_DRV_HS) $(RULER3_AG_S_MAIN_DRV_HS) $(RULER3_AG_DS_MAIN_DRV_HS)

RULER3_HS_ALL_DRV_HS					:= $(RULER3_HS_MAIN_DRV_HS) $(RULER3_HS_DPDS_DRV_HS)

# binary/executable
RULER3_NAME								:= ruler3
RULER3_BLD_EXEC							:= $(BIN_PREFIX)$(RULER3_NAME)$(EXEC_SUFFIX)
RULER3									:= $(RULER3_BLD_EXEC)

# make rules

$(RULER3_NAME): $(RULER3_BLD_EXEC)

$(RULER3_BLD_EXEC): $(RULER3_AG_ALL_MAIN_DRV_HS) $(RULER3_HS_ALL_DRV_HS) $(RULER3_CHS_UTIL_DRV_HS) $(LIB_EH_UTIL_INS_FLAG)
	$(GHC) --make $(GHC_OPTS) -package $(LIB_EH_UTIL_PKG_NAME) -i$(RULER3_BLD_PREFIX) $(RULER3_BLD_PREFIX)$(RULER3_MAIN).hs -o $@
	$(STRIP) $@

# fake a shuffle
$(RULER3_BLD_PREFIX)%.ag: $(SRC_RULER3_PREFIX)%.cag
	mkdir -p $(@D); \
	cp $< $@

# fake a shuffle
$(RULER3_BLD_PREFIX)%.ag: $(SRC_RULER3_PREFIX)%.cag
	mkdir -p $(@D); \
	cp $< $@

$(RULER3_AG_D_MAIN_DRV_HS): $(RULER3_BLD_PREFIX)%.hs: $(RULER3_BLD_PREFIX)%.ag
	mkdir -p $(@D) ; \
	$(AGC) -dr -P$(SRC_RULER3_PREFIX) -o $@ $<

$(RULER3_AG_S_MAIN_DRV_HS): $(RULER3_BLD_PREFIX)%.hs: $(RULER3_BLD_PREFIX)%.ag
	mkdir -p $(@D) ; \
	$(AGC) -cfspr -P$(SRC_RULER3_PREFIX) -o $@ $<

$(RULER3_AG_DS_MAIN_DRV_HS): $(RULER3_BLD_PREFIX)%.hs: $(RULER3_BLD_PREFIX)%.ag
	mkdir -p $(@D) ; \
	$(AGC) --module=$(*F) -dcfspr -P$(SRC_RULER3_PREFIX) -o $@ $<

$(RULER3_HS_ALL_DRV_HS): $(RULER3_BLD_PREFIX)%.hs: $(SRC_RULER3_PREFIX)%.chs
	mkdir -p $(@D) ; \
	cp $< $@

$(RULER3_CHS_UTIL_DRV_HS): $(RULER3_BLD_PREFIX)%.hs: $(SRC_RULER3_PREFIX)%.chs $(SHUFFLE)
	mkdir -p $(@D) ; \
	$(SHUFFLE) --gen=1 --base=$(*F) --hs --preamble=no --lhs2tex=no --order="1" $< > $@


### demo stuff
RULER3_DEMO_AG_MAIN				:= RulerDemoMain
RULER3_DEMO_SRC_CAG_MAIN		:= $(RULER3_DEMO_PREFIX)$(RULER3_DEMO_AG_MAIN).cag
RULER3_DEMO_DRV_AG_MAIN			:= $(RULER3_DEMO_SRC_CAG_MAIN:.cag=.ag)
RULER3_DEMO_DRV_AG_MAIN_TEX		:= $(RULER3_DEMO_SRC_CAG_MAIN:.cag=.tex)
RULER3_DEMO_DRV_HS_MAIN			:= $(RULER3_DEMO_DRV_AG_MAIN:.ag=.hs)

RULER3_DEMO_SRC_CHS_UTILS		:= $(RULER3_DEMO_PREFIX)RulerDemoUtils.chs
RULER3_DEMO_DRV_HS_UTILS		:= $(RULER3_DEMO_SRC_CHS_UTILS:.chs=.hs)
RULER3_DEMO_DRV_HS_UTILS_TEX	:= $(RULER3_DEMO_SRC_CHS_UTILS:.chs=.tex)

RULER3_DEMO_EXEC				:= $(BLD_BIN_PREFIX)rulerdemo3$(EXEC_SUFFIX)

RULER3_DEMO_RUL_BASE		:= rulerDemoRL
RULER3_DEMO_AG_BASE			:= rulerDemoAG
RULER3_DEMO_AGWCOPY_BASE	:= rulerDemoAGWithCopy
RULER3_DEMO_SRC_CRL			:= $(RULER3_DEMO_PREFIX)$(RULER3_DEMO_RUL_BASE).crl2
RULER3_DEMO_DRV_CAG			:= $(RULER3_DEMO_PREFIX)$(RULER3_DEMO_AG_BASE).cag
RULER3_DEMO_DRV_WCOPY_CAG	:= $(RULER3_DEMO_PREFIX)$(RULER3_DEMO_AGWCOPY_BASE).cag
RULER3_DEMO_DRV_LCTEX		:= $(RULER3_DEMO_PREFIX)demo.lctex
RULER3_DEMO_DRV_CTEX		:= $(RULER3_DEMO_DRV_LCTEX:.lctex=.ctex)
RULER3_DEMO_DRV_RL2			:= $(RULER3_DEMO_DRV_LCTEX:.lctex=.rl2)
RULER3_DEMO_DRV_LRTEX		:= $(RULER3_DEMO_DRV_LCTEX:.lctex=.lrtex)
RULER3_DEMO_DRV_RTEX		:= $(RULER3_DEMO_DRV_LCTEX:.lctex=.rtex)
RULER3_DEMO_DRV_LATEX		:= $(RULER3_DEMO_DRV_LCTEX:.lctex=.latex)
RULER3_DEMO_DRV_ATEX		:= $(RULER3_DEMO_DRV_LCTEX:.lctex=.atex)
RULER3_DEMO_DRV_AG			:= $(RULER3_DEMO_DRV_LCTEX:.lctex=.ag)

RULER3_DEMO_ALL_DRV_TEX		:= $(RULER3_DEMO_DRV_HS_UTILS_TEX) $(RULER3_DEMO_DRV_AG_MAIN_TEX)

RULER3_DEMO_ALL_SRC			:= $(RULER3_DEMO_SRC_CRL) $(RULER3_DEMO_SRC_CAG_MAIN) $(RULER3_DEMO_SRC_CHS_UTILS) 

# chunks for inclusion in main text by shuffle
RULER3_ALL_CHUNK_SRC		:= $(RULER3_DEMO_SRC_CRL) $(RULER3_DEMO_DRV_CAG) $(RULER3_DEMO_DRV_WCOPY_CAG) $(RULER3_DEMO_SRC_CAG_MAIN) $(RULER3_DEMO_SRC_CHS_UTILS) \
								$(RULER3_CHS_UTIL_SRC_CHS)

# chunk view order for demo src
RULER3_DEMO_RULER3_ORDER	:= 1 < 2 < 3
RULER3_DEMO_RULER3_FINAL	:= 3

# configuration of ruler, to be done on top level
RULER3_DEMO_MARK_CHANGES_CFG	:= --markchanges="E - AG"

# distribution
RULER3_DIST_FILES			:= $(RULER3_ALL_SRC) $(RULER3_DEMO_ALL_SRC) \
								$(addprefix $(SRC_RULER3_PREFIX),Makefile README) \
								$(wildcard $(RULER3_DEMO_PREFIX)tst*)

# make rules
$(RULER3_DEMO_DRV_LCTEX): $(RULER3_DEMO_SRC_CRL) $(SHUFFLE)
	$(SHUFFLE) --gen=all --latex --order="$(RULER3_DEMO_RULER3_ORDER)" --base=$(RULER3_DEMO_RUL_BASE) --lhs2tex=yes $< > $@

$(RULER3_DEMO_DRV_CTEX): $(RULER3_DEMO_DRV_LCTEX)
	$(LHS2TEX_CMD) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER3_DEMO_DRV_RL2): $(RULER3_DEMO_SRC_CRL) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER3_DEMO_RULER3_FINAL) --plain --order="$(RULER3_DEMO_RULER3_ORDER)"  --lhs2tex=no $< > $@

$(RULER3_DEMO_DRV_LRTEX): $(RULER3_DEMO_DRV_RL2) $(RULER3)
	$(RULER3) $(RULER3_OPTS) --lhs2tex --selrule="(E - *).(*).(*)" $(RULER3_DEMO_MARK_CHANGES_CFG) --base=rulerDemo $< > $@

$(RULER3_DEMO_DRV_RTEX): $(RULER3_DEMO_DRV_LRTEX)
	$(LHS2TEX_CMD) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER3_DEMO_DRV_CAG): $(RULER3_DEMO_DRV_RL2) $(RULER3)
	$(RULER3) $(RULER3_OPTS) --ag --ATTR --DATA --selrule="(3).(*).(*)" --wrapshuffle  --base=$(RULER3_DEMO_AG_BASE) $< > $@

$(RULER3_DEMO_DRV_WCOPY_CAG): $(RULER3_DEMO_DRV_RL2) $(RULER3)
	$(RULER3) $(RULER3_OPTS) --ag --ATTR --DATA --selrule="(3).(*).(*)" --wrapshuffle --copyelim=no --base=$(RULER3_DEMO_AGWCOPY_BASE) $< > $@

$(RULER3_DEMO_DRV_AG): $(RULER3_DEMO_DRV_CAG) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER3_DEMO_RULER3_FINAL) --plain --order="$(RULER3_DEMO_RULER3_ORDER)"  --lhs2tex=no $< > $@

$(RULER3_DEMO_DRV_LATEX): $(RULER3_DEMO_DRV_CAG) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER3_DEMO_RULER3_FINAL) --latex --order="$(RULER3_DEMO_RULER3_ORDER)" --base=$(RULER3_DEMO_AG_BASE) --lhs2tex=yes $< > $@

$(RULER3_DEMO_DRV_ATEX): $(RULER3_DEMO_DRV_LATEX)
	$(LHS2TEX_CMD) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER3_DEMO_DRV_HS_UTILS): $(RULER3_DEMO_SRC_CHS_UTILS) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER3_DEMO_RULER3_FINAL) --hs --order="$(RULER3_DEMO_RULER3_ORDER)" --preamble=no --lhs2tex=no $< > $@

$(RULER3_DEMO_DRV_HS_UTILS_TEX): $(RULER3_DEMO_SRC_CHS_UTILS) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER3_DEMO_RULER3_FINAL) --latex --order="$(RULER3_DEMO_RULER3_ORDER)" --base=rulerDemoUtils --lhs2tex=yes $< | $(LHS2TEX_CMD) $(LHS2TEX_OPTS_POLY) > $@

$(RULER3_DEMO_DRV_AG_MAIN): $(RULER3_DEMO_SRC_CAG_MAIN) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER3_DEMO_RULER3_FINAL) --ag --order="$(RULER3_DEMO_RULER3_ORDER)" --base=Main --preamble=no --lhs2tex=no $< > $@

$(RULER3_DEMO_DRV_AG_MAIN_TEX): $(RULER3_DEMO_SRC_CAG_MAIN) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER3_DEMO_RULER3_FINAL) --latex --order="$(RULER3_DEMO_RULER3_ORDER)" --base=rulerDemoMain --lhs2tex=yes $< | $(LHS2TEX_CMD) $(LHS2TEX_OPTS_POLY) > $@

$(RULER3_DEMO_DRV_HS_MAIN): $(RULER3_DEMO_DRV_AG_MAIN) $(RULER3_DEMO_DRV_AG)
	$(AGC) -csdfr -P$(RULER3_DEMO_PREFIX) $<

$(RULER3_DEMO_EXEC): $(RULER3_DEMO_DRV_HS_MAIN) $(RULER3_DEMO_DRV_HS_UTILS) $(LIB_EH_UTIL_INS_FLAG)
	mkdir -p $(@D)
	$(GHC) --make $(GHC_OPTS) -package $(LIB_EH_UTIL_PKG_NAME) -i$(RULER3_DEMO_PREFIX) $(RULER3_DEMO_DRV_HS_MAIN) -o $@

