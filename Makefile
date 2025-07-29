# Define variables
CXX := g++
STRIP := strip
CXXFLAGS += -Wall -g
TARGET = tsid
LDFLAGS += -lSDL3 -lGL -lGLU
SRCS := $(shell find -name '*.cpp')
OBJS = $(SRCS:.cpp=.o)

ifeq ($(RELEASE),1)
CXXFLAGS += -DNDEBUG -Oz -flto -fno-rtti
endif

# Default target: builds the executable
all: $(TARGET) squish

squish:
ifeq ($(RELEASE),1)
	$(STRIP) $(TARGET)
	upx --ultra-brute $(TARGET)
endif

resource/shaders.h:
	bash resource/glsl2h.sh

# Rule to link object files into the executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^

$(OBJS): resource/shaders.h

# Rule to compile C++ source files into object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Phony target for cleaning up generated files
.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJS) resource/shaders.h
