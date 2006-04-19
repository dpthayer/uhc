# location of ruler2 src
RULER2_SRC_PREFIX	:= $(TOP_PREFIX)ruler2/
RULER2_DEMO_PREFIX	:= $(RULER2_SRC_PREFIX)demo/

# location of shuffle build
RULER2_BLD_PREFIX	:= $(BLD_PREFIX)ruler/

# this file
RULER2_MKF			:= $(RULER2_SRC_PREFIX)files.mk

# sources + dpds, for .rul
RULER2_RULES_SRC_RL2					:= $(RULER2_SRC_PREFIX)RulerRules.rul

# main + sources + dpds
RULER2_MAIN			:= Ruler

RULER2_HS_MAIN_SRC_HS					:= $(addprefix $(RULER2_SRC_PREFIX),$(RULER2_MAIN).hs)
RULER2_HS_MAIN_DRV_HS					:= $(patsubst $(RULER2_SRC_PREFIX)%.hs,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_HS_MAIN_SRC_HS))
RULER2_HS_DPDS_SRC_HS					:= $(patsubst %,$(RULER2_SRC_PREFIX)%.hs,\
											Version Common Err Opts DpdGr AttrProps \
											NmParser ViewSelParser SelParser KeywParser RulerParser \
											ARuleUtils ExprUtils TyUtils LaTeXFmtUtils RulerUtils ViewSelUtils \
											Gam FmGam ECnstrGam RwExprGam WrKindGam JdShpGam \
											RulerAdmin RulerMkAdmin \
											ExprToAEqn \
											RulerScanner RulerScannerMachine \
											)
RULER2_HS_DPDS_DRV_HS					:= $(patsubst $(RULER2_SRC_PREFIX)%.hs,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_HS_DPDS_SRC_HS))

RULER2_CHS_UTIL_SRC_CHS					:= $(patsubst %,$(RULER2_SRC_PREFIX)%.chs,RulerConfig)
RULER2_CHS_UTIL_DRV_HS					:= $(patsubst $(RULER2_SRC_PREFIX)%.chs,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_CHS_UTIL_SRC_CHS))

RULER2_AGMAIN1_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,Main1AG)
RULER2_AGMAIN1_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag, \
											RulerAbsSynCommonAG RulerAbsSyn1AG RulerAS1Misc RulerAS1Pretty RulerAS1RlSel \
											RulerAS1SchemeDpd RulerAS1ViewDpd \
											RulerAS1GenAS2 \
											ExprAbsSynAG ExprIsRwAG ExprNmSAG ExprFmGamAG ExprPrettyPrintAG ExprSelfAG \
											TyAbsSynAG TySelfAG \
											)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGMAIN1_MAIN_SRC_AG)) \
										: $(RULER2_AGMAIN1_DPDS_SRC_AG)

RULER2_AS1IMPS_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,RulerAS1Imports)
RULER2_AS1IMPS_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag, \
											RulerAbsSyn1AG RulerAbsSynCommonAG \
											ExprAbsSynAG \
											TyAbsSynAG \
											)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AS1IMPS_MAIN_SRC_AG)) \
										: $(RULER2_AS1IMPS_DPDS_SRC_AG)

RULER2_AGMAIN2_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,Main2AG)
RULER2_AGMAIN2_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag, \
											RulerAbsSynCommonAG RulerAbsSyn2AG RulerAS2Opts RulerAS2Pretty \
											ExprAbsSynAG ExprSelfAG ExprPrettyPrintAG \
											ARuleAbsSynAG ARuleSelfAG ARulePrettyPrintAG \
											)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGMAIN2_MAIN_SRC_AG)) \
										: $(RULER2_AGMAIN2_DPDS_SRC_AG)

RULER2_TRF2ARULE_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,TrfAS2GenARule)
RULER2_TRF2ARULE_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag, \
											RulerAbsSynCommonAG RulerAbsSyn2AG RulerAS2Opts \
											TrfAS2CommonAG \
											ExprAbsSynAG ExprSelfAG \
											ARuleAbsSynAG ARuleSelfAG \
											)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_TRF2ARULE_MAIN_SRC_AG)) \
										: $(RULER2_TRF2ARULE_DPDS_SRC_AG)

RULER2_TRF2LATEX_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,TrfAS2GenLaTeX)
RULER2_TRF2LATEX_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag, \
											RulerAbsSynCommonAG RulerAbsSyn2AG RulerAS2Opts \
											TrfAS2CommonAG \
											ExprAbsSynAG ExprSelfAG \
											ARuleAbsSynAG ARuleSelfAG \
											)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_TRF2LATEX_MAIN_SRC_AG)) \
										: $(RULER2_TRF2LATEX_DPDS_SRC_AG)

RULER2_AGRLAST1_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,RulerAbsSyn1)
RULER2_AGRLAST1_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,RulerAbsSyn1AG RulerAbsSynCommonAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGRLAST1_MAIN_SRC_AG)) \
										: $(RULER2_AGRLAST1_DPDS_SRC_AG)

RULER2_AGRLAST2_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,RulerAbsSyn2)
RULER2_AGRLAST2_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,RulerAbsSyn2AG RulerAbsSynCommonAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGRLAST2_MAIN_SRC_AG)) \
										: $(RULER2_AGRLAST2_DPDS_SRC_AG)

RULER2_AGEXPR_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,Expr)
RULER2_AGEXPR_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGEXPR_MAIN_SRC_AG)) \
										: $(RULER2_AGEXPR_DPDS_SRC_AG)

RULER2_AGTY_MAIN_SRC_AG					:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,Ty)
RULER2_AGTY_DPDS_SRC_AG					:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,TyAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGTY_MAIN_SRC_AG)) \
										: $(RULER2_AGTY_DPDS_SRC_AG)

RULER2_TYPRETTY_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,TyPrettyPrint)
RULER2_TYPRETTY_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,TyAbsSynAG TyPrettyPrintAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_TYPRETTY_MAIN_SRC_AG)) \
										: $(RULER2_TYPRETTY_DPDS_SRC_AG)

RULER2_EXISRW_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprIsRw)
RULER2_EXISRW_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprAbsSynAG ExprIsRwAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_EXISRW_MAIN_SRC_AG)) \
										: $(RULER2_EXISRW_DPDS_SRC_AG)

RULER2_EXNMS_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprNmS)
RULER2_EXNMS_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprAbsSynAG ExprNmSAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_EXNMS_MAIN_SRC_AG)) \
										: $(RULER2_EXNMS_DPDS_SRC_AG)

RULER2_EXLTX_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprLaTeX)
RULER2_EXLTX_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprAbsSynAG ExprOptsAG ExprLaTeXAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_EXLTX_MAIN_SRC_AG)) \
										: $(RULER2_EXLTX_DPDS_SRC_AG)

RULER2_EXCOGAM_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprCoGam)
RULER2_EXCOGAM_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_EXCOGAM_MAIN_SRC_AG)) \
										: $(RULER2_EXCOGAM_DPDS_SRC_AG)

#RULER2_EXREGAM_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprReGamExprFmGam)
#RULER2_EXREGAM_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ExprAbsSynAG ExprSelfAG)
#$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_EXREGAM_MAIN_SRC_AG)) \
#										: $(RULER2_EXREGAM_DPDS_SRC_AG)

RULER2_AGVWSL_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSel)
RULER2_AGVWSL_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGVWSL_MAIN_SRC_AG)) \
										: $(RULER2_AGVWSL_DPDS_SRC_AG)

RULER2_VWSLSELF_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelSelf)
RULER2_VWSLSELF_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_VWSLSELF_MAIN_SRC_AG)) \
										: $(RULER2_VWSLSELF_DPDS_SRC_AG)

RULER2_VWSLNMS_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelNmS)
RULER2_VWSLNMS_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelAbsSynAG ViewSelDpdGrAG ViewSelNmSAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_VWSLNMS_MAIN_SRC_AG)) \
										: $(RULER2_VWSLNMS_DPDS_SRC_AG)

RULER2_RLSLRNM_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelRlRnm)
RULER2_RLSLRNM_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_RLSLRNM_MAIN_SRC_AG)) \
										: $(RULER2_RLSLRNM_DPDS_SRC_AG)

RULER2_RLSLISSL_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelRlIsSel)
RULER2_RLSLISSL_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelAbsSynAG ViewSelNmSAG ViewSelDpdGrAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_RLSLISSL_MAIN_SRC_AG)) \
										: $(RULER2_RLSLISSL_DPDS_SRC_AG)

RULER2_VWSLPP_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelPrettyPrint)
RULER2_VWSLPP_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ViewSelAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_VWSLPP_MAIN_SRC_AG)) \
										: $(RULER2_VWSLPP_DPDS_SRC_AG)

RULER2_AGARULE_MAIN_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARule)
RULER2_AGARULE_DPDS_SRC_AG				:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AGARULE_MAIN_SRC_AG)) \
										: $(RULER2_AGARULE_DPDS_SRC_AG)

RULER2_ARLPATUNQ_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARulePatternUniq)
RULER2_ARLPATUNQ_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAbsSynAG ARuleOptsAG ExprAbsSynAG ARuleCopyRuleNmAG ARuleFmGamAG ExprFmGamAG ExprOptsAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_ARLPATUNQ_MAIN_SRC_AG)) \
										: $(RULER2_ARLPATUNQ_DPDS_SRC_AG)

RULER2_ARLRWSUBS_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleRwSubst)
RULER2_ARLRWSUBS_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAbsSynAG ARuleOptsAG ExprAbsSynAG ARuleCopyRuleNmAG ARuleFmGamAG ExprFmGamAG ExprOptsAG ExprRwExprGamAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_ARLRWSUBS_MAIN_SRC_AG)) \
										: $(RULER2_ARLRWSUBS_DPDS_SRC_AG)

RULER2_ARLAVARSUBS_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAVarRename)
RULER2_ARLAVARSUBS_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAbsSynAG ExprAbsSynAG ExprSelfAG ARuleSelfAG ARuleEqnDest1NmAG ARuleInCompDestAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_ARLAVARSUBS_MAIN_SRC_AG)) \
										: $(RULER2_ARLAVARSUBS_DPDS_SRC_AG)

RULER2_ARLELIMCR_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleElimCopyRule)
RULER2_ARLELIMCR_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAbsSynAG ExprAbsSynAG ARuleCopyRuleNmAG ARuleEqnDest1NmAG ARuleInCompDestAG ExprSelfAG ARuleSelfAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_ARLELIMCR_MAIN_SRC_AG)) \
										: $(RULER2_ARLELIMCR_DPDS_SRC_AG)

RULER2_ARLELIMWLDC_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleElimWildcAssign)
RULER2_ARLELIMWLDC_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAbsSynAG ExprAbsSynAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_ARLELIMWLDC_MAIN_SRC_AG)) \
										: $(RULER2_ARLELIMWLDC_DPDS_SRC_AG)

RULER2_ARLPRETTY_MAIN_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARulePrettyPrint)
RULER2_ARLPRETTY_DPDS_SRC_AG			:= $(patsubst %,$(RULER2_SRC_PREFIX)%.ag,ARuleAbsSynAG ExprAbsSynAG ExprPrettyPrintAG ARulePrettyPrintAG ExprSelfAG ARuleSelfAG)
$(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_ARLPRETTY_MAIN_SRC_AG)) \
										: $(RULER2_ARLPRETTY_DPDS_SRC_AG)

RULER2_AG_D_MAIN_SRC_AG					:= $(RULER2_AGEXPR_MAIN_SRC_AG) $(RULER2_AGTY_MAIN_SRC_AG) $(RULER2_AGRLAST1_MAIN_SRC_AG) $(RULER2_AGRLAST2_MAIN_SRC_AG) $(RULER2_AGVWSL_MAIN_SRC_AG) $(RULER2_AGARULE_MAIN_SRC_AG)
RULER2_AG_S_MAIN_SRC_AG					:= $(RULER2_EXISRW_MAIN_SRC_AG) $(RULER2_EXNMS_MAIN_SRC_AG) $(RULER2_EXLTX_MAIN_SRC_AG) \
											$(RULER2_EXCOGAM_MAIN_SRC_AG) $(RULER2_EXREGAM_MAIN_SRC_AG) \
											$(RULER2_VWSLSELF_MAIN_SRC_AG) $(RULER2_VWSLNMS_MAIN_SRC_AG) $(RULER2_RLSLRNM_MAIN_SRC_AG) \
											$(RULER2_RLSLISSL_MAIN_SRC_AG) $(RULER2_VWSLPP_MAIN_SRC_AG) $(RULER2_ARLPATUNQ_MAIN_SRC_AG) \
											$(RULER2_ARLRWSUBS_MAIN_SRC_AG) $(RULER2_ARLAVARSUBS_MAIN_SRC_AG) $(RULER2_ARLELIMCR_MAIN_SRC_AG) $(RULER2_ARLELIMWLDC_MAIN_SRC_AG) \
											$(RULER2_ARLPRETTY_MAIN_SRC_AG) \
											$(RULER2_TYPRETTY_MAIN_SRC_AG) \
											$(RULER2_AGMAIN1_MAIN_SRC_AG) $(RULER2_AGMAIN2_MAIN_SRC_AG) \
											$(RULER2_AS1IMPS_MAIN_SRC_AG) \
											$(RULER2_TRF2ARULE_MAIN_SRC_AG) $(RULER2_TRF2LATEX_MAIN_SRC_AG)
RULER2_AG_DS_MAIN_SRC_AG				:=

RULER2_AG_ALL_DPDS_SRC_AG				:= $(sort \
											$(RULER2_AGMAIN1_DPDS_SRC_AG) \
											$(RULER2_AS1IMPS_DPDS_SRC_AG) \
											$(RULER2_AGMAIN2_DPDS_SRC_AG) \
											$(RULER2_TRF2ARULE_DPDS_SRC_AG) \
											$(RULER2_TRF2LATEX_DPDS_SRC_AG) \
											$(RULER2_AGEXPR_DPDS_SRC_AG) \
											$(RULER2_AGTY_DPDS_SRC_AG) \
											$(RULER2_AGRLAST1_DPDS_SRC_AG) \
											$(RULER2_AGRLAST2_DPDS_SRC_AG) \
											$(RULER2_AGVWSL_DPDS_SRC_AG) \
											$(RULER2_AGARULE_DPDS_SRC_AG) \
											$(RULER2_EXISRW_DPDS_SRC_AG) \
											$(RULER2_EXNMS_DPDS_SRC_AG) \
											$(RULER2_EXLTX_DPDS_SRC_AG) \
											$(RULER2_EXCOGAM_DPDS_SRC_AG) \
											$(RULER2_EXREGAM_DPDS_SRC_AG) \
											$(RULER2_VWSLSELF_DPDS_SRC_AG) \
											$(RULER2_VWSLNMS_DPDS_SRC_AG) \
											$(RULER2_RLSLRNM_DPDS_SRC_AG) \
											$(RULER2_RLSLISSL_DPDS_SRC_AG) \
											$(RULER2_VWSLPP_DPDS_SRC_AG) \
											$(RULER2_ARLPATUNQ_DPDS_SRC_AG) \
											$(RULER2_ARLRWSUBS_DPDS_SRC_AG) \
											$(RULER2_ARLAVARSUBS_DPDS_SRC_AG) \
											$(RULER2_ARLELIMCR_DPDS_SRC_AG) \
											$(RULER2_ARLELIMWLDC_DPDS_SRC_AG) \
											$(RULER2_ARLPRETTY_DPDS_SRC_AG) \
											$(RULER2_TYPRETTY_DPDS_SRC_AG) \
											)

RULER2_AG_ALL_MAIN_SRC_AG				:= $(RULER2_AG_D_MAIN_SRC_AG) $(RULER2_AG_S_MAIN_SRC_AG) $(RULER2_AG_DS_MAIN_SRC_AG)

# all src
RULER2_ALL_SRC							:= $(RULER2_AG_ALL_MAIN_SRC_AG) $(RULER2_AG_ALL_DPDS_SRC_AG) $(RULER2_HS_MAIN_SRC_HS) \
											$(RULER2_CHS_UTIL_SRC_CHS) $(RULER2_HS_DPDS_SRC_HS) $(RULER2_MKF) $(RULER2_RULES_SRC_RL2)


# derived
RULER2_AG_D_MAIN_DRV_HS					:= $(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AG_D_MAIN_SRC_AG))
RULER2_AG_S_MAIN_DRV_HS					:= $(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AG_S_MAIN_SRC_AG))
RULER2_AG_DS_MAIN_DRV_HS				:= $(patsubst $(RULER2_SRC_PREFIX)%.ag,$(RULER2_BLD_PREFIX)%.hs,$(RULER2_AG_DS_MAIN_SRC_AG))
RULER2_AG_ALL_MAIN_DRV_HS				:= $(RULER2_AG_D_MAIN_DRV_HS) $(RULER2_AG_S_MAIN_DRV_HS) $(RULER2_AG_DS_MAIN_DRV_HS)

RULER2_HS_ALL_DRV_HS					:= $(RULER2_HS_MAIN_DRV_HS) $(RULER2_HS_DPDS_DRV_HS)

# binary/executable
RULER2_BLD_EXEC							:= $(BIN_PREFIX)ruler$(EXEC_SUFFIX)
RULER2									:= $(RULER2_BLD_EXEC)

# make rules
$(RULER2_BLD_EXEC): $(RULER2_AG_ALL_MAIN_DRV_HS) $(RULER2_HS_ALL_DRV_HS) $(RULER2_CHS_UTIL_DRV_HS) $(LIB_SRC_HS)
	$(GHC) --make $(GHC_OPTS) $(GHC_OPTS_OPTIM) -i$(LIB_SRC_PREFIX) -i$(RULER2_BLD_PREFIX) $(RULER2_BLD_PREFIX)$(RULER2_MAIN).hs -o $@
	strip $@

$(RULER2_AG_D_MAIN_DRV_HS): $(RULER2_BLD_PREFIX)%.hs: $(RULER2_SRC_PREFIX)%.ag
	mkdir -p $(@D) ; \
	$(AGC) -dr -P$(RULER2_SRC_PREFIX) -o $@ $<

$(RULER2_AG_S_MAIN_DRV_HS): $(RULER2_BLD_PREFIX)%.hs: $(RULER2_SRC_PREFIX)%.ag
	mkdir -p $(@D) ; \
	$(AGC) -cfspr -P$(RULER2_SRC_PREFIX) -o $@ $<

$(RULER2_AG_DS_MAIN_DRV_HS): $(RULER2_BLD_PREFIX)%.hs: $(RULER2_SRC_PREFIX)%.ag
	mkdir -p $(@D) ; \
	$(AGC) --module=$(*F) -dcfspr -P$(RULER2_SRC_PREFIX) -o $@ $<

$(RULER2_HS_ALL_DRV_HS): $(RULER2_BLD_PREFIX)%.hs: $(RULER2_SRC_PREFIX)%.hs
	mkdir -p $(@D) ; \
	cp $< $@

$(RULER2_CHS_UTIL_DRV_HS): $(RULER2_BLD_PREFIX)%.hs: $(RULER2_SRC_PREFIX)%.chs $(SHUFFLE)
	mkdir -p $(@D) ; \
	$(SHUFFLE) --gen=1 --base=$(*F) --hs --preamble=no --lhs2tex=no --order="1" $< > $@


### demo stuff
RULER2_DEMO_AG_MAIN				:= RulerDemoMain
RULER2_DEMO_SRC_CAG_MAIN		:= $(RULER2_DEMO_PREFIX)$(RULER2_DEMO_AG_MAIN).cag
RULER2_DEMO_DRV_AG_MAIN			:= $(RULER2_DEMO_SRC_CAG_MAIN:.cag=.ag)
RULER2_DEMO_DRV_AG_MAIN_TEX		:= $(RULER2_DEMO_SRC_CAG_MAIN:.cag=.tex)
RULER2_DEMO_DRV_HS_MAIN			:= $(RULER2_DEMO_DRV_AG_MAIN:.ag=.hs)

RULER2_DEMO_SRC_CHS_UTILS		:= $(RULER2_DEMO_PREFIX)RulerDemoUtils.chs
RULER2_DEMO_DRV_HS_UTILS		:= $(RULER2_DEMO_SRC_CHS_UTILS:.chs=.hs)
RULER2_DEMO_DRV_HS_UTILS_TEX	:= $(RULER2_DEMO_SRC_CHS_UTILS:.chs=.tex)

RULER2_DEMO_EXEC				:= $(BLD_BIN_PREFIX)rulerdemo$(EXEC_SUFFIX)

RULER2_DEMO_RUL_BASE		:= rulerDemoRL
RULER2_DEMO_AG_BASE			:= rulerDemoAG
RULER2_DEMO_AGWCOPY_BASE	:= rulerDemoAGWithCopy
RULER2_DEMO_SRC_CRL			:= $(RULER2_DEMO_PREFIX)$(RULER2_DEMO_RUL_BASE).crl2
RULER2_DEMO_DRV_CAG			:= $(RULER2_DEMO_PREFIX)$(RULER2_DEMO_AG_BASE).cag
RULER2_DEMO_DRV_WCOPY_CAG	:= $(RULER2_DEMO_PREFIX)$(RULER2_DEMO_AGWCOPY_BASE).cag
RULER2_DEMO_DRV_LCTEX		:= $(RULER2_DEMO_PREFIX)demo.lctex
RULER2_DEMO_DRV_CTEX		:= $(RULER2_DEMO_DRV_LCTEX:.lctex=.ctex)
RULER2_DEMO_DRV_RL2			:= $(RULER2_DEMO_DRV_LCTEX:.lctex=.rl2)
RULER2_DEMO_DRV_LRTEX		:= $(RULER2_DEMO_DRV_LCTEX:.lctex=.lrtex)
RULER2_DEMO_DRV_RTEX		:= $(RULER2_DEMO_DRV_LCTEX:.lctex=.rtex)
RULER2_DEMO_DRV_LATEX		:= $(RULER2_DEMO_DRV_LCTEX:.lctex=.latex)
RULER2_DEMO_DRV_ATEX		:= $(RULER2_DEMO_DRV_LCTEX:.lctex=.atex)
RULER2_DEMO_DRV_AG			:= $(RULER2_DEMO_DRV_LCTEX:.lctex=.ag)

RULER2_DEMO_ALL_DRV_TEX		:= $(RULER2_DEMO_DRV_HS_UTILS_TEX) $(RULER2_DEMO_DRV_AG_MAIN_TEX)

RULER2_DEMO_ALL_SRC			:= $(RULER2_DEMO_SRC_CRL) $(RULER2_DEMO_SRC_CAG_MAIN) $(RULER2_DEMO_SRC_CHS_UTILS) 

# chunks for inclusion in main text by shuffle
RULER2_ALL_CHUNK_SRC		:= $(RULER2_DEMO_SRC_CRL) $(RULER2_DEMO_DRV_CAG) $(RULER2_DEMO_DRV_WCOPY_CAG) $(RULER2_DEMO_SRC_CAG_MAIN) $(RULER2_DEMO_SRC_CHS_UTILS) \
								$(RULER2_CHS_UTIL_SRC_CHS)

# chunk view order for demo src
RULER2_DEMO_RULER2_ORDER	:= 1 < 2 < 3
RULER2_DEMO_RULER2_FINAL	:= 3

# configuration of ruler, to be done on top level
RULER2_DEMO_MARK_CHANGES_CFG	:= --markchanges="E - AG"

# distribution
RULER2_DIST_FILES			:= $(RULER2_ALL_SRC) $(RULER2_DEMO_ALL_SRC) \
								$(addprefix $(RULER2_SRC_PREFIX),Makefile README) \
								$(wildcard $(RULER2_DEMO_PREFIX)tst*)

# make rules
$(RULER2_DEMO_DRV_LCTEX): $(RULER2_DEMO_SRC_CRL) $(SHUFFLE)
	$(SHUFFLE) --gen=all --latex --order="$(RULER2_DEMO_RULER2_ORDER)" --base=$(RULER2_DEMO_RUL_BASE) --lhs2tex=yes $< > $@

$(RULER2_DEMO_DRV_CTEX): $(RULER2_DEMO_DRV_LCTEX)
	$(LHS2TEX) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER2_DEMO_DRV_RL2): $(RULER2_DEMO_SRC_CRL) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_RULER2_FINAL) --plain --order="$(RULER2_DEMO_RULER2_ORDER)"  --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_LRTEX): $(RULER2_DEMO_DRV_RL2) $(RULER2)
	$(RULER2) $(RULER2_OPTS) --lhs2tex --selrule="(E - *).(*).(*)" $(RULER2_DEMO_MARK_CHANGES_CFG) --base=rulerDemo $< > $@

$(RULER2_DEMO_DRV_RTEX): $(RULER2_DEMO_DRV_LRTEX)
	$(LHS2TEX) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER2_DEMO_DRV_CAG): $(RULER2_DEMO_DRV_RL2) $(RULER2)
	$(RULER2) $(RULER2_OPTS) --ag --ATTR --selrule="(3).(*).(*)" --wrapshuffle  --base=$(RULER2_DEMO_AG_BASE) $< > $@

$(RULER2_DEMO_DRV_WCOPY_CAG): $(RULER2_DEMO_DRV_RL2) $(RULER2)
	$(RULER2) $(RULER2_OPTS) --ag --ATTR --selrule="(3).(*).(*)" --wrapshuffle --copyelim=no --base=$(RULER2_DEMO_AGWCOPY_BASE) $< > $@

$(RULER2_DEMO_DRV_AG): $(RULER2_DEMO_DRV_CAG) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_RULER2_FINAL) --plain --order="$(RULER2_DEMO_RULER2_ORDER)"  --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_LATEX): $(RULER2_DEMO_DRV_CAG) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_RULER2_FINAL) --latex --order="$(RULER2_DEMO_RULER2_ORDER)" --base=$(RULER2_DEMO_AG_BASE) --lhs2tex=yes $< > $@

$(RULER2_DEMO_DRV_ATEX): $(RULER2_DEMO_DRV_LATEX)
	$(LHS2TEX) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER2_DEMO_DRV_HS_UTILS): $(RULER2_DEMO_SRC_CHS_UTILS) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_RULER2_FINAL) --hs --order="$(RULER2_DEMO_RULER2_ORDER)" --preamble=no --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_HS_UTILS_TEX): $(RULER2_DEMO_SRC_CHS_UTILS) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_RULER2_FINAL) --latex --order="$(RULER2_DEMO_RULER2_ORDER)" --base=rulerDemoUtils --lhs2tex=yes $< | $(LHS2TEX) $(LHS2TEX_OPTS_POLY) > $@

$(RULER2_DEMO_DRV_AG_MAIN): $(RULER2_DEMO_SRC_CAG_MAIN) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_RULER2_FINAL) --ag --order="$(RULER2_DEMO_RULER2_ORDER)" --base=Main --preamble=no --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_AG_MAIN_TEX): $(RULER2_DEMO_SRC_CAG_MAIN) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_RULER2_FINAL) --latex --order="$(RULER2_DEMO_RULER2_ORDER)" --base=rulerDemoMain --lhs2tex=yes $< | $(LHS2TEX) $(LHS2TEX_OPTS_POLY) > $@

$(RULER2_DEMO_DRV_HS_MAIN): $(RULER2_DEMO_DRV_AG_MAIN) $(RULER2_DEMO_DRV_AG)
	$(AGC) -csdfr -P$(RULER2_DEMO_PREFIX) $<

$(RULER2_DEMO_EXEC): $(RULER2_DEMO_DRV_HS_MAIN) $(RULER2_DEMO_DRV_HS_UTILS) $(LIB_SRC_HS)
	mkdir -p $(@D)
	$(GHC) --make $(GHC_OPTS) -i$(LIB_SRC_PREFIX) -i$(RULER2_DEMO_PREFIX) $(RULER2_DEMO_DRV_HS_MAIN) -o $@

