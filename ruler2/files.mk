# location of ruler2 src
RULER2_SRC_PREFIX	:= $(TOP_PREFIX)ruler2/
RULER2_DEMO_PREFIX	:= $(RULER2_SRC_PREFIX)demo/

# this file
RULER2_MKF			:= $(RULER2_SRC_PREFIX)files.mk

# main + sources
RULER2_MAIN			:= Ruler

RULER2_AG_MAIN_SRC	:= $(addprefix $(RULER2_SRC_PREFIX),RulerPretty.ag RulerAST.ag RulerGen.ag RulerParser.ag RulerExprMatchSubst.ag RulerWrap.ag \
						RulerViewDpd.ag RulerMisc.ag RulerARule.ag \
						RulerARuleOptim.ag RulerARuleOptim2.ag RulerARuleOptim3.ag \
						RulerRlSel.ag RulerPatternUniq.ag \
						$(RULER2_MAIN).ag \
						)

RULER2_HS_SRC		:= $(addprefix $(RULER2_SRC_PREFIX),RulerUtils.hs RulerAdmin.hs RulerMkAdmin.hs)
RULER2_HS_DRV		:= $(addprefix $(RULER2_SRC_PREFIX),$(RULER2_MAIN).hs)

# all src
RULER2_ALL_SRC		:= $(RULER2_AG_MAIN_SRC) $(RULER2_HS_SRC)

# binary/executable
RULER2_BLD_EXEC		:= $(BIN_PREFIX)ruler2
RULER2				:= $(RULER2_BLD_EXEC)

# make rules
$(RULER2_BLD_EXEC): $(RULER2_HS_DRV) $(RULER2_HS_SRC) $(LIB_SRC_HS)
	mkdir -p $(@D)
	$(GHC) --make $(GHC_OPTS) -i$(LIB_SRC_PREFIX) -i$(RULER2_SRC_PREFIX) $(RULER2_SRC_PREFIX)$(RULER2_MAIN).hs -o $@

$(RULER2_SRC_PREFIX)$(RULER2_MAIN).hs: $(RULER2_AG_MAIN_SRC)
	$(AGC) -csdfr --module=Main -P$(RULER2_SRC_PREFIX) $(RULER2_SRC_PREFIX)$(RULER2_MAIN).ag

### demo stuff
RULER2_DEMO_AG_MAIN				:= RulerDemoMain
RULER2_DEMO_SRC_CAG_MAIN		:= $(RULER2_DEMO_PREFIX)$(RULER2_DEMO_AG_MAIN).cag
RULER2_DEMO_DRV_AG_MAIN			:= $(RULER2_DEMO_SRC_CAG_MAIN:.cag=.ag)
RULER2_DEMO_DRV_AG_MAIN_TEX		:= $(RULER2_DEMO_SRC_CAG_MAIN:.cag=.tex)
RULER2_DEMO_DRV_HS_MAIN			:= $(RULER2_DEMO_DRV_AG_MAIN:.ag=.hs)

RULER2_DEMO_SRC_CHS_UTILS		:= $(RULER2_DEMO_PREFIX)RulerDemoUtils.chs
RULER2_DEMO_DRV_HS_UTILS		:= $(RULER2_DEMO_SRC_CHS_UTILS:.chs=.hs)
RULER2_DEMO_DRV_HS_UTILS_TEX	:= $(RULER2_DEMO_SRC_CHS_UTILS:.chs=.tex)

RULER2_DEMO_EXEC				:= $(BLD_BIN_PREFIX)rulerdemo

RULER2_DEMO_RUL_BASE		:= rulerDemoRL
RULER2_DEMO_AG_BASE			:= rulerDemoAG
RULER2_DEMO_SRC_CRL			:= $(RULER2_DEMO_PREFIX)$(RULER2_DEMO_RUL_BASE).crl2
RULER2_DEMO_DRV_CAG			:= $(RULER2_DEMO_PREFIX)$(RULER2_DEMO_AG_BASE).cag
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
RULER2_ALL_CHUNK_SRC		:= $(RULER2_DEMO_SRC_CRL) $(RULER2_DEMO_DRV_CAG) $(RULER2_DEMO_SRC_CAG_MAIN) $(RULER2_DEMO_SRC_CHS_UTILS)

# chunk view order for demo src
RULER2_DEMO_SHUFFLE_ORDER	:= 1 < 2 < 3
RULER2_DEMO_SHUFFLE_FINAL	:= 3

# configuration of ruler, to be done on top level
RULER2_DEMO_MARK_CHANGES_CFG	:= --markchanges="E - AG"

# distribution
RULER2_DIST_FILES			:= $(RULER2_ALL_SRC) $(RULER2_DEMO_ALL_SRC) \
								$(addprefix $(RULER2_SRC_PREFIX),Makefile README) \
								$(RULER2_MKF) \
								$(wildcard $(RULER2_DEMO_PREFIX)tst*)

# make rules
$(RULER2_DEMO_DRV_LCTEX): $(RULER2_DEMO_SRC_CRL) $(SHUFFLE)
	$(SHUFFLE) --gen=all --latex --order="$(RULER2_DEMO_SHUFFLE_ORDER)" --base=$(RULER2_DEMO_RUL_BASE) --lhs2tex=yes $< > $@

$(RULER2_DEMO_DRV_CTEX): $(RULER2_DEMO_DRV_LCTEX)
	$(LHS2TEX) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER2_DEMO_DRV_RL2): $(RULER2_DEMO_SRC_CRL) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_SHUFFLE_FINAL) --plain --order="$(RULER2_DEMO_SHUFFLE_ORDER)"  --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_LRTEX): $(RULER2_DEMO_DRV_RL2) $(RULER2)
	$(RULER2) --lhs2tex --selrule="(E - *).(*).(*)" $(RULER2_DEMO_MARK_CHANGES_CFG) --base=rulerDemo $< > $@

$(RULER2_DEMO_DRV_RTEX): $(RULER2_DEMO_DRV_LRTEX)
	$(LHS2TEX) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER2_DEMO_DRV_CAG): $(RULER2_DEMO_DRV_RL2) $(RULER2)
	$(RULER2) --ag --ATTR --selrule="(3).(*).(*)" --wrapshuffle  --base=$(RULER2_DEMO_AG_BASE) $< > $@

$(RULER2_DEMO_DRV_AG): $(RULER2_DEMO_DRV_CAG) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_SHUFFLE_FINAL) --plain --order="$(RULER2_DEMO_SHUFFLE_ORDER)"  --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_LATEX): $(RULER2_DEMO_DRV_CAG) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_SHUFFLE_FINAL) --latex --order="$(RULER2_DEMO_SHUFFLE_ORDER)" --base=$(RULER2_DEMO_AG_BASE) --lhs2tex=yes $< > $@

$(RULER2_DEMO_DRV_ATEX): $(RULER2_DEMO_DRV_LATEX)
	$(LHS2TEX) $(LHS2TEX_OPTS_POLY) $< > $@

$(RULER2_DEMO_DRV_HS_UTILS): $(RULER2_DEMO_SRC_CHS_UTILS) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_SHUFFLE_FINAL) --hs --order="$(RULER2_DEMO_SHUFFLE_ORDER)" --preamble=no --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_HS_UTILS_TEX): $(RULER2_DEMO_SRC_CHS_UTILS) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_SHUFFLE_FINAL) --latex --order="$(RULER2_DEMO_SHUFFLE_ORDER)" --base=rulerDemoUtils --lhs2tex=yes $< | $(LHS2TEX) $(LHS2TEX_OPTS_POLY) > $@

$(RULER2_DEMO_DRV_AG_MAIN): $(RULER2_DEMO_SRC_CAG_MAIN) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_SHUFFLE_FINAL) --ag --order="$(RULER2_DEMO_SHUFFLE_ORDER)" --base=Main --preamble=no --lhs2tex=no $< > $@

$(RULER2_DEMO_DRV_AG_MAIN_TEX): $(RULER2_DEMO_SRC_CAG_MAIN) $(SHUFFLE)
	$(SHUFFLE) --gen=$(RULER2_DEMO_SHUFFLE_FINAL) --latex --order="$(RULER2_DEMO_SHUFFLE_ORDER)" --base=rulerDemoMain --lhs2tex=yes $< | $(LHS2TEX) $(LHS2TEX_OPTS_POLY) > $@

$(RULER2_DEMO_DRV_HS_MAIN): $(RULER2_DEMO_DRV_AG_MAIN) $(RULER2_DEMO_DRV_AG)
	$(AGC) -csdfr -P$(RULER2_DEMO_PREFIX) $<

$(RULER2_DEMO_EXEC): $(RULER2_DEMO_DRV_HS_MAIN) $(RULER2_DEMO_DRV_HS_UTILS) $(LIB_SRC_HS)
	mkdir -p $(@D)
	$(GHC) --make $(GHC_OPTS) -i$(LIB_SRC_PREFIX) -i$(RULER2_DEMO_PREFIX) $(RULER2_DEMO_DRV_HS_MAIN) -o $@

