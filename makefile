FLAGS+=-Istk-4.5.0/include

# chugin name
CHUGIN_NAME=BirlPhysicalModel

# all of the c/cpp files that compose this chugin
C_MODULES=
CXX_MODULES=BirlPhysicalModel.cpp stk-4.5.0/src/Noise.cpp \
stk-4.5.0/src/OneZero.cpp stk-4.5.0/src/PoleZero.cpp \
stk-4.5.0/src/Stk.cpp stk-4.5.0/src/BiQuad.cpp

# where the chuck headers are
CK_SRC_PATH?=../chuck/include/


# ---------------------------------------------------------------------------- #
# you won't generally need to change anything below this line for a new chugin #
# ---------------------------------------------------------------------------- #

# default target: print usage message and quit
current: 
	@echo "[chuck build]: please use one of the following configurations:"
	@echo "   make linux, make osx, or make win32"

ifneq ($(CK_TARGET),)
.DEFAULT_GOAL:=$(CK_TARGET)
ifeq ($(MAKECMDGOALS),)
MAKECMDGOALS:=$(.DEFAULT_GOAL)
endif
endif

.PHONY: osx linux linux-oss linux-jack linux-alsa win32
osx linux linux-oss linux-jack linux-alsa win32: all

CC=gcc
CXX=gcc
LD=g++

CHUGIN_PATH=/usr/lib/chuck

ifneq (,$(strip $(filter osx bin-dist-osx,$(MAKECMDGOALS))))
include makefile.osx
endif

ifneq (,$(strip $(filter linux,$(MAKECMDGOALS))))
include makefile.linux
endif

ifneq (,$(strip $(filter linux-oss,$(MAKECMDGOALS))))
include makefile.linux
endif

ifneq (,$(strip $(filter linux-jack,$(MAKECMDGOALS))))
include makefile.linux
endif

ifneq (,$(strip $(filter linux-alsa,$(MAKECMDGOALS))))
include makefile.linux
endif

ifneq (,$(strip $(filter win32,$(MAKECMDGOALS))))
include makefile.win32
endif

ifneq ($(CHUCK_DEBUG),)
FLAGS+= -g
else
FLAGS+= -O3
endif

ifneq ($(CHUCK_STRICT),)
FLAGS+= -Wall
endif

# default: build a dynamic chugin
CK_CHUGIN_STATIC?=0

ifeq ($(CK_CHUGIN_STATIC),0)
SUFFIX=.chug
else
SUFFIX=.schug
FLAGS+= -D__CK_DLL_STATIC__
endif

C_OBJECTS=$(addsuffix .o,$(basename $(C_MODULES)))
CXX_OBJECTS=$(addsuffix .o,$(basename $(CXX_MODULES)))

CHUG=$(addsuffix $(SUFFIX),$(CHUGIN_NAME))

all: $(CHUG)

$(CHUG): $(C_OBJECTS) $(CXX_OBJECTS)
ifeq ($(CK_CHUGIN_STATIC),0)
	g++ $(LDFLAGS) -o $@ $^
else
	ar rv $@ $^
	ranlib $@
endif

$(C_OBJECTS): %.o: %.c
	$(CC) $(FLAGS) -c -o $@ $<

$(CXX_OBJECTS): %.o: %.cpp $(CK_SRC_PATH)/chuck_dl.h
	$(CXX) $(FLAGS) -c -o $@ $<

install: $(CHUG)
	mkdir -p $(CHUGIN_PATH)
	cp $^ $(CHUGIN_PATH)
	chmod 755 $(CHUGIN_PATH)/$(CHUG)

clean: 
	rm -rf $(C_OBJECTS) $(CXX_OBJECTS) $(CHUG)

