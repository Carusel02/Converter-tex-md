CC = cc
FLEX = flex

TARGET = main
SOURCE = main.l
OBJECT = lex.yy.c

all: $(TARGET)

$(TARGET): $(OBJECT)
	$(CC) $^ -o $@ -ll

$(OBJECT): $(SOURCE)
	$(FLEX) $<

clean:
	rm -f $(TARGET) $(OBJECT)
