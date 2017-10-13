################################################################################
#
# GNSS application configuration defaults section
#
################################################################################

include ../build/app_gnssapp_versions.mk

# FW upgrade configuration
MOD_FWUPG:=$(if $(findstring ram,${MOD_LOAD_RGN}),0,$(if $(findstring FWUPG,${PROJ_OPT_FEATURES}),1,0))
PROJ_OPT_FEATURES+=$(if $(findstring DRAW,${PROJ_OPT_FEATURES}),SENSORSMGR))

#
# Optional features. It is a list of optional features available in GNSS
# application.
# - SBAS
# - DTCM
# - STAGNSS
# - STBIN
# - SDLOG
# - USB
#PROJ_OPT_FEATURES     :=

#
# Optional optimization features
#
#PROJ_FAST_ENABLE      :=

#
# Code execution entry point
#
ifeq (${PROJ_ENTRY_POINT},)
PROJ_ENTRY_POINT      :=  reset_vector
endif

#
# Basename of template for scatter file
#
ifeq (${PROJ_SCFFILE_BASENAME},)
ifeq (${PROJ_MOD_OS},OS20)
PROJ_SCFFILE_BASENAME :=  ${MOD_CORE}_arm9gnssapp
endif
ifeq (${PROJ_MOD_OS},FREERTOS)
PROJ_SCFFILE_BASENAME :=  ${MOD_CORE}_arm9gnssapp_FR
endif
endif

################################################################################
#
# GNSS application toolchain section
#
################################################################################

#
# assembler defs for gnssapp projects
#

ifeq (${PROJ_TC},rvct)
PROJ_ASMDEFS:=\
  --pd \"TARGET_CORE_CONFIG SETS \\\"__GPS_SINGLE_CORE__\\\"\"
endif # PROJ_TC

#
# compiler defs for gnssapp projects
#

ifeq ($(findstring SENSORSMGR,${PROJ_OPT_FEATURES}),SENSORSMGR)
CSOURCES+=modules/sensors_lld/slld_pres.c
CSOURCES+=modules/sensors_lld/slld_3Dacc.c
CSOURCES+=modules/sensors_lld/slld_3Dgyro.c
CSOURCES+=modules/sensors_lld/slld_common.c
CSOURCES+=modules/sensors_lld/slld_magn.c
endif

ifeq ($(findstring STBIN,${PROJ_OPT_FEATURES}),STBIN)
CSOURCES+=modules/stbin/stbin_dr_plugin.c
CSOURCES+=modules/stbin/stbin_stagps_plugin.c
CSOURCES+=modules/stbin/stbin_waas_plugin.c
CSOURCES+=modules/stbin/stbin.c
endif

ifeq ($(findstring HDBIN,${PROJ_OPT_FEATURES}),HDBIN)
CSOURCES+=modules/stbin/hdbin.c
endif

PROJ_CDEFS:=\
  __MST__                                \
  __GPS_SINGLE_CORE__                    \
  __$(call MK_UPPER,${MOD_CORE})__       \
  UART_DEBUG                             \
  VERSION_SDK=${VERSION_SDK}             \
  VERSION_SUFFIX=${VERSION_SUFFIX}       \
  ${PROJ_MOD_OS}

ifneq (${VERSION_BINARY},)
PROJ_CDEFS+=VERSION_BINARY=${VERSION_BINARY}
endif

ifeq (${MOD_FWUPG},1)
PROJ_CDEFS+=FWUPG_SUPPORT
endif

PROJ_CDEFS+=\
  $(if $(findstring ${MOD_NVM_RGN},nor),NVM_NOR)   \
  $(if $(findstring ${MOD_NVM_RGN},ram),NVM_RAM)   \
  $(if $(findstring ${MOD_NVM_RGN},sqi),NVM_SQI $(if $(findstring ${PROJ_TC},gae),NVM_SQI_CACHED))

PROJ_CDEFS+=$(if $(findstring SBAS,${PROJ_OPT_FEATURES}),WAAS_LINKED)
PROJ_CDEFS+=$(if $(findstring RTCM,${PROJ_OPT_FEATURES}),RTCM_LINKED)
PROJ_CDEFS+=$(if $(findstring STAGNSS,${PROJ_OPT_FEATURES}),ST_AGPS)
PROJ_CDEFS+=$(if $(findstring STBIN,${PROJ_OPT_FEATURES}),STBIN_LINKED)
PROJ_CDEFS+=$(if $(findstring SDLOG,${PROJ_OPT_FEATURES}),SDLOG_LINKED)
PROJ_CDEFS+=$(if $(findstring USB,${PROJ_OPT_FEATURES}),USB_LINKED)
PROJ_CDEFS+=$(if $(findstring SENSORSMGR,${PROJ_OPT_FEATURES}),SW_CONFIG_PRIVATE_BLOCK)
PROJ_CDEFS+=$(if $(findstring DRAW,${PROJ_OPT_FEATURES}),DR_CODE_LINKED)
PROJ_CDEFS+=$(if $(findstring BINEXTRAS,${PROJ_OPT_FEATURES}),BINARY_EXTRA_LINKED)

PROJ_CINCDIRS:=\
  clibs                             \
  os_svc                            \
  os_svc/adc                        \
  os_svc/can                        \
  os_svc/fsmc                       \
  os_svc/fsw                        \
  os_svc/gpio                       \
  os_svc/i2c                        \
  os_svc/mcu                        \
  os_svc/msp                        \
  os_svc/mtu                        \
  os_svc/pwr                        \
  os_svc/sdi                        \
  os_svc/sqi                        \
  os_svc/ssp                        \
  os_svc/uart                       \
  os_svc/usb                        \
  modules/fat                       \
  modules/gnssapp_plugins           \
  modules/in_out                    \
  modules/nmea                      \
  modules/sdlog                     \
  modules/sensors_lld               \
  modules/shutdn                    \
  ${MOD_CORE}/platforms             \
  ${MOD_CORE}/frontend              \
  ${MOD_CORE}/gpsapp

#
# linker defs for gnssapp projects
#

# scatter template folder
SCF_FOLDER:=${PROJ_SDKROOTDIR}/${MOD_CORE}/gpsapp

# Scatter file defs
PROJ_SCF_DEFS:=\
  -DLR_CODE_BASE=$(if $(findstring ${MOD_FWUPG},1),${LR_CODE_BASE_FWUPG},${LR_CODE_BASE})   \
  -DLR_CODE_SIZE=$(if $(findstring ${MOD_FWUPG},1),${LR_CODE_SIZE_FWUPG},${LR_CODE_SIZE})   \
  -DLR_CODE_BLOCK_SIZE=${LR_CODE_BLOCK_SIZE}        \
  -DSW_CONFIG_NVM_BASE=${NVM_BASE_SWCFG}            \
  -DDATA_TCM_START=${DATA_TCM_START}    \
  -DDATA_TCM_SIZE=${DATA_TCM_SIZE}      \
  -DXR_NVM_DATA_REGION=${NVM_BASE}      \
  -DXR_NVM_DATA_SIZE=${NVM_SIZE}        \
  -DOS_HEAP_AREA_START=${OS_HEAP_BASE}  \
  -DOS_HEAP_AREA_SIZE=${OS_HEAP_SIZE}   \

PROJ_SCF_DEFS+=\
  -DDR_ON=$(if $(findstring DRAW,${PROJ_FAST_ENABLE}),1,0)           \
  -DBIN_IMAGE_FAST=$(if $(findstring BIN,${PROJ_FAST_ENABLE}),1,0)   \
  -DGNSSLIB_FAST=$(if $(findstring GNSSLIB,${PROJ_FAST_ENABLE}),1,0) \
  -DSTAGPS_FAST=$(if $(findstring STAGNSS,${PROJ_FAST_ENABLE}),1,0)  \

# Libraries to link
ifeq ($(findstring STBIN,${PROJ_OPT_FEATURES}),STBIN)
LIBNAMES:=stbin
endif # STBIN
ifeq ($(findstring BINEXTRAS,${PROJ_OPT_FEATURES}),BINEXTRAS)
LIBNAMES+=logger
LIBNAMES+=odometer
LIBNAMES+=geofencing
endif # RTCM
LIBNAMES+=lvd
LIBNAMES+=error_handler
LIBNAMES+=antenna_sensing
LIBNAMES+=nmea_ext
ifeq ($(findstring DRAW,${PROJ_OPT_FEATURES}),DRAW)
LIBNAMES+=dr
endif
ifeq ($(findstring SENSORSMGR,${PROJ_OPT_FEATURES}),SENSORSMGR)
LIBNAMES+=sensors_manager
LIBNAMES+=sw_config_dr
else
LIBNAMES+=sw_config
endif # DRAW
LIBNAMES+=nvm_${MOD_NVM_RGN}
LIBNAMES+=datum
LIBNAMES+=debug
ifeq ($(findstring RTCM,${PROJ_OPT_FEATURES}),RTCM)
LIBNAMES+=dgps
endif # RTCM
LIBNAMES+=rtc
ifeq ($(findstring STAGNSS,${PROJ_OPT_FEATURES}),STAGNSS)
LIBNAMES+=stagps
endif # STAGNSS
LIBNAMES+=pgps
LIBNAMES+=rxn_security
LIBNAMES+=navigate
LIBNAMES+=tracker
ifeq ($(findstring SBAS,${PROJ_OPT_FEATURES}),SBAS)
LIBNAMES+=waas
endif # SBAS
LIBNAMES+=compass
LIBNAMES+=galileo
LIBNAMES+=gnss_bsp
LIBNAMES+=gnss_events
LIBNAMES+=gnss_msg
LIBNAMES+=gpslib_common
LIBNAMES+=${OS_LIBNAMES}
LIBNAMES+=lld
LIBNAMES+=common

#
# Bootloader defs for GNSS based projects
#

# TCXO configuration
TCXOMHZ:=$(firstword $(strip\
    $(if $(findstring TCXO_26,${PROJ_OPT_FEATURES}),26)   \
    $(if $(findstring TCXO_48,${PROJ_OPT_FEATURES}),48)   \
    $(if $(findstring TCXO,${PROJ_OPT_FEATURES}),,26)     \
))

# configuration file used for TCXO configuration
FWCFGTCXO:=$(strip\
    $(if $(findstring ${TCXOMHZ},26),245 -^> 00)   \
    $(if $(findstring ${TCXOMHZ},48),245 -^> 0A)   \
)

# Project specific FW configuration file
PROJ_FWCFG_FILE           :=  $(PROJ_ROOTDIR)/fwcfg.txt

# folder containing support for binary generation
SECLOADER_SUPPORT_FOLDER  :=  ${PROJ_SDKROOTDIR}/build/binimgsupp

# definitions for secondary loader images
SECLOADER_IMAGE           :=  ${SECLOADER_SUPPORT_FOLDER}/${MOD_CORE}_boot_${MOD_LOAD_RGN}_${TCXOMHZ}MHz.${MOD_BINEXT}
SECLOADER_CODEVAL         :=  ${SECLOADER_SUPPORT_FOLDER}/${MOD_CORE}_code_validity.${MOD_BINEXT}

TARGET_EXTRA_RULES        :=  applydefcfg

ifeq (${MOD_FWUPG},1)
TARGET_DEST_FILENAME_BOOT :=  ${COMMON_BINDIR}/${TARGET_DEST_FILENAME}_${MOD_BOOTEXT}.${MOD_BINEXT}
TARGET_DEST_FILENAME_UPG  :=  ${COMMON_BINDIR}/${TARGET_DEST_FILENAME}_${MOD_UPGEXT}.${MOD_BINEXT}
TARGET_POSTBUILD          :=  ${TARGET_DEST_FILENAME_BOOT}
else
TARGET_POSTBUILD          :=  ${TARGET_DEST_FILENAME_BIN}
endif
