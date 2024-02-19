CC = gcc
FLEX = flex

all: main

main: lex.yy.c
	$(CC) lex.yy.c -o main -lfl

lex.yy.c: main.l
	$(FLEX) main.l

clean:
	rm -f main lex.yy.c
