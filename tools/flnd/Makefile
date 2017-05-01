CC = gcc
CCFLAGS = -std=c99 -Wall -Werror

LD = gcc
LDFLAGS = -std=c99

SOURCES = flnd.c
OBJECTS = $(SOURCES:.c=.o)

TARGET = flnd

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CCFLAGS) -c -o $@ $<

clean:
	rm -rf *.o $(TARGET)

.PHONY: all clean