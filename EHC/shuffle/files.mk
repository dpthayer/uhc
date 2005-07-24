# location of shuffle src
SHUFFLE_SRC_PREFIX	:= $(TOP_PREFIX)shuffle/

# this file
SHUFFLE_MKF			:= $(SHUFFLE_SRC_PREFIX)files.mk

# main + sources
SHUFFLE_MAIN		:= Shuffle

SHUFFLE_AG_MAIN_SRC	:= $(addprefix $(SHUFFLE_SRC_PREFIX),$(SHUFFLE_MAIN).ag)

SHUFFLE_HS_SRC		:= 
SHUFFLE_HS_DRV		:= $(addprefix $(SHUFFLE_SRC_PREFIX),$(SHUFFLE_MAIN).hs)

# all src
SHUFFLE_ALL_SRC		:= $(SHUFFLE_AG_MAIN_SRC) $(SHUFFLE_HS_SRC)

# binary/executable
SHUFFLE_BLD_EXEC	:= $(BIN_PREFIX)shuffle
SHUFFLE				:= $(SHUFFLE_BLD_EXEC)

# distribution
SHUFFLE_DIST_FILES			:= $(SHUFFLE_ALL_SRC) $(SHUFFLE_MKF)

# make rules
$(SHUFFLE_BLD_EXEC): $(SHUFFLE_HS_DRV) $(SHUFFLE_HS_SRC) $(LIB_SRC_HS)
	mkdir -p $(@D)
	$(GHC) --make $(GHC_OPTS) $(GHC_OPTS_OPTIM) -i$(LIB_SRC_PREFIX) -i$(SHUFFLE_SRC_PREFIX) $(SHUFFLE_SRC_PREFIX)$(SHUFFLE_MAIN).hs -o $@
	strip $@

$(SHUFFLE_SRC_PREFIX)$(SHUFFLE_MAIN).hs: $(SHUFFLE_AG_MAIN_SRC)
	$(AGC) -csdfr --module=Main -P$(SHUFFLE_SRC_PREFIX) $(SHUFFLE_SRC_PREFIX)$(SHUFFLE_MAIN).ag

