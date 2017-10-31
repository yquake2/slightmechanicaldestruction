# ----------------------------------------------------- #
# Makefile for the "Slight Mechanical Destruction       #
# by Musashi" (SMD) game module for Quake II            #
# Ported from the original SMD source code for Windows  #
# by Alkaline - See included Changelog for details      #
#                                                       #
# Just type "make" to compile the                       #
# SMD Game library (game.so / game.dylib / game.dll)    #
#                                                       #
# Build Dependencies:                                   #
# - None, but you need Quake II (and SMD) to play.      #
#   While in theory any engine should work,             #
#   Yamagi Quake II is recommended.                     #
#                                                       #
# Compatible Platforms:                                 #
# - Linux       (compiles, plays, and saves)            #
# - macOS       (compiles, plays, and saves)            #
# - Windows     (compiles w/MinGW; not play-tested)     #
# - Other?      (Should compile on most Unix-like OSes) #
# ----------------------------------------------------- #

# Detect the OS
ifdef SystemRoot
OSTYPE := Windows
else
OSTYPE := $(shell uname -s)
endif

# Special case for MinGW
ifneq (,$(findstring MINGW,$(OSTYPE)))
OSTYPE := Windows
endif

# Detect the architecture
ifeq ($(OSTYPE), Windows)
# At this time only i386 is supported on Windows
ARCH := i386
# seems like mingw doesn't set CC by default
CC := gcc
else
# Some platforms call it "amd64" and some "x86_64"
ARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/amd64/x86_64/)
endif

# Refuse all other platforms as a firewall against PEBKAC
# (You'll need some #ifdef for your unsupported  platform!)
ifeq ($(findstring $(ARCH), i386 x86_64 sparc64 ia64),)
$(error arch $(ARCH) is currently not supported)
endif

# ----------

# Base CFLAGS.
#
# -O2 are enough optimizations.
#
# -fno-strict-aliasing since the source doesn't comply
#  with strict aliasing rules and it's next to impossible
#  to get it there...
#
# -fomit-frame-pointer since the framepointer is mostly
#  useless for debugging Quake II and slows things down.
#
# -g to build allways with debug symbols. Please do not
#  change this, since it's our only chance to debug this
#  crap when random crashes happen!
#
# -fPIC for position independend code.
#
# -MMD to generate header dependencies.
ifeq ($(OSTYPE), Darwin)
CFLAGS := -O2 -fno-strict-aliasing -fomit-frame-pointer \
		  -Wall -pipe -g -fwrapv -arch i386 -arch x86_64
else
CFLAGS := -O0 -fno-strict-aliasing -fomit-frame-pointer \
		  -Wall -pipe -ggdb -MMD -fwrapv
endif

# ----------

# Base LDFLAGS.
ifeq ($(OSTYPE), Darwin)
LDFLAGS := -shared -arch i386 -arch x86_64
else
LDFLAGS := -shared
endif

# ----------

# Builds everything
all: smd

# ----------

# When make is invoked by "make VERBOSE=1" print
# the compiler and linker commands.

ifdef VERBOSE
Q :=
else
Q := @
endif

# ----------

# Phony targets
.PHONY : all clean smd

# ----------

# Cleanup
clean:
	@echo "===> CLEAN"
	${Q}rm -Rf build release

# ----------

# The SMD game
ifeq ($(OSTYPE), Windows)
FILESUFFIX := dll
smd:
	@echo "===> Building game.dll"
	${Q}mkdir -p release
	$(MAKE) release/game.dll

build/%.o: %.c
	@echo "===> CC $<"
	${Q}mkdir -p $(@D)
	${Q}$(CC) -c $(CFLAGS) -o $@ $<
else
 ifeq ($(OSTYPE), Darwin)
 FILESUFFIX := dylib
 else
 FILESUFFIX := so
 endif
  
smd:
	@echo "===> Building game.${FILESUFFIX}"
	${Q}mkdir -p release
	$(MAKE) release/game.${FILESUFFIX}

build/%.o: %.c
	@echo "===> CC $<"
	${Q}mkdir -p $(@D)
	${Q}$(CC) -c $(CFLAGS) -o $@ $<

release/game.${FILESUFFIX} : CFLAGS += -fPIC
endif 

# ----------

SMD_OBJS_ = \
	src/g_ai.o \
	src/g_camera.o \
	src/g_chase.o \
	src/g_cmds.o \
	src/g_combat.o \
	src/g_crane.o \
	src/g_fog.o \
	src/g_func.o \
	src/g_items.o \
	src/g_jetpack.o \
	src/g_lights.o \
	src/g_lock.o \
	src/g_main.o \
	src/g_misc.o \
	src/g_model.o \
	src/g_monster.o \
	src/g_mtrain.o \
	src/g_newai.o \
	src/g_patchplayermodels.o \
	src/g_pendulum.o \
	src/g_phys.o \
	src/g_reflect.o \
	src/g_save.o \
	src/g_sound.o \
	src/g_spawn.o \
	src/g_svcmds.o \
	src/g_target.o \
	src/g_thing.o \
	src/g_tracktrain.o \
	src/g_trigger.o \
	src/g_turret.o \
	src/g_utils.o \
	src/g_vehicle.o \
	src/g_weapon.o \
	src/m_actor_weap.o \
	src/m_actor.o \
	src/m_berserk.o \
	src/m_boss2.o \
	src/m_boss3.o \
	src/m_boss31.o \
	src/m_boss32.o \
	src/m_brain.o \
	src/m_chick.o \
	src/m_flash.o \
	src/m_flipper.o \
	src/m_float.o \
	src/m_flyer.o \
	src/m_gladiator.o \
	src/m_gunner.o \
	src/m_hover.o \
	src/m_infantry.o \
	src/m_insane.o \
	src/m_medic.o \
	src/m_move.o \
	src/m_mutant.o \
	src/m_parasite.o \
	src/m_sentrybot.o \
	src/m_soldier.o \
	src/m_supertank.o \
	src/m_tank.o \
	src/p_client.o \
	src/p_chase.o \
	src/p_hud.o \
	src/p_menu.o \
	src/p_text.o \
	src/p_trail.o \
	src/p_view.o \
	src/p_weapon.o \
	src/q_shared.o

# ----------

# Rewrite paths to our object directory
SMD_OBJS = $(patsubst %,build/%,$(SMD_OBJS_))

# ----------

# Generate header dependencies
SMD_DEPS= $(SMD_OBJS:.o=.d)

# ----------

# Suck header dependencies in
-include $(SMD_DEPS)

# ----------

release/game.${FILESUFFIX} : $(SMD_OBJS)
	@echo "===> LD $@"
	${Q}$(CC) $(LDFLAGS) -o $@ $(SMD_OBJS)

# ----------
