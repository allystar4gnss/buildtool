################################################################################
#
# GNSS application configuration file
#
################################################################################

#
# Type of project
#
PROJ_MOD_APP      :=  gnssapp

#
# Suffix to be added to this configuration
#
PROJ_MOD_EXTRA    :=  dr

#
# Package can be:
# - SOC for STA80xxEX and its derivatives
# - SAL for STA80xxF and STA80xxG and their derivatives
PROJ_PACKAGE      :=  SOC

#
# Load region is the region of memory where the binary produced will be loaded
# It can be:
# - SQI
# - NOR
# - RAM
PROJ_LOAD_REGION  :=  SQI

#
# NVM region is the region of memory where the GNSS NVM data  will be saved
# It can be:
# - SQI
# - NOR
# - RAM
PROJ_NVM_REGION   :=  SQI

#$(warning Warning! If you enable SBAS + DRAW + STAGNSS then you need to increase DTCM size (DATA_TCM_SIZE := 0x2C000 in /build/core_defs.mk))
#
# Optional settings.
# Some settings are defined by default in specific makefiles. If you want to
# apply specific settings, use this section to uncomment and define them.
# Check documentation for explanation of each setting and allowed values.
#
PROJ_OPT_FEATURES     :=  SBAS DRAW TCXO_48 FWUPG STBIN HDBIN
PROJ_FAST_ENABLE      :=  GNSSLIB DRAW
# PROJ_ENTRY_POINT      :=
# DATA_TCM_START        :=
# DATA_TCM_SIZE         :=
# OS_HEAP_BASE          :=
# OS_HEAP_SIZE          :=
# PROJ_SCFFILE_BASENAME :=
#

################################################################################
#
# This part should not be modified
#
################################################################################

#
# Operating system used in this project
#
PROJ_MOD_OS       :=  FREERTOS

#
# Toolchain used in this project
#
PROJ_TC           :=  gae
