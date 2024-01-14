%{
#include <stdio.h>
#include <stdlib.h>
// output file
FILE *out;
// for quotation mode
int quotation_word_count = 0;
// for indentation
int tabs = 0;
%}

%option stack
%s UNDERLINE_SECTION
%s UNDERLINE_TITLE
%s HREF
%s HREF_EXTRACT
%s VERBATIM
%s ITEMIZE
%s ENUMERATE
%s QUOTATION
%s SPECIAL_TYPE

%%

\\documentclass(\[[^\]]*\])?\{[^\}]*\}\n?

\\usepackage(\[[^\]]*\])?\{[^\}]*\}\n?

\\newcommand((\{[^}]*\})*)?\n?

\\maketitle((\{[^}]*\})*)?\n?

\\label((\{[^}]*\})*)?\n?

\\date\{[^}]*\}\n?

\\LaTeX\n?

\\author\{[^}]*\}\n?

\\begin\{document\}\n?
\\end\{document\}\n?

\\begin\{abstract\}\n?
\\end\{abstract\}\n?

\\begin\{center\}\n?
\\end\{center\}\n?

\\begin\{tabular\}((\{[^}]*\})*)?
\\end\{tabular\}\n?

\\hline\n?

\\texttt\{[^}]*\} {     // extract text and put under `[text]`
                        char *text = yytext + 8;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "`%s`", text);   }

\\textbf\{[^}]*\} {     // extract text and put under **[text]**
                        char *text = yytext + 8;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "**%s**", text); }

\\textit\{[^}]*\} {     // extract text and put under _[text]_
                        char *text = yytext + 8;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "_%s_", text);   }

\\emph\{[^}]*\}   {     // extract text and put under _[text]_
                        char *text = yytext + 6;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "_%s_", text);   }


([ \t]*)?\\begin\{itemize\}\n {     
    // increase number of tabs
    tabs++;
    // add ITEMIZE on stack
    yy_push_state(ITEMIZE);    }

([ \t]*)?\\begin\{itemize\} {     
    // increase number of tabs
    tabs++;
    // print new line
    fprintf(out, "\n");
    // add ITEMIZE on stack
    yy_push_state(ITEMIZE);    }

<ITEMIZE>(.*)?\\item   {  
    // print tabs
    for(int i = 0; i < tabs; i++) {
        fprintf(out, "  ");
    }
    // print bullet               
    fprintf(out, "-"); }

<ITEMIZE>([ \t]*)?\\end\{itemize\}\n? {  
    // decrease number of tabs
    tabs--;
    // remove ITEMIZE from stack
    yy_pop_state(); }


([ \t]*)?\\begin\{enumerate\}\n {
    // increase number of tabs
    tabs++;
    // add ENUMERATE on stack
    yy_push_state(ENUMERATE); }

([ \t]*)?\\begin\{enumerate\} {
    // increase number of tabs
    tabs++;
    // print new line
    fprintf(out, "\n");
    // add ENUMERATE on stack
    yy_push_state(ENUMERATE); }

<ENUMERATE>(.*)?\\item {  
    // print tabs
    for(int i = 0; i < tabs; i++) {
        fprintf(out, "  ");
    }
    // print bullet       
    fprintf(out, "1."); }

<ENUMERATE>([ \t]*)?\\end\{enumerate\}\n? { 
    // decrease number of tabs
    tabs--; 
    // remove ENUMERATE from stack
    yy_pop_state(); }

\\begin\{quotation\}\n? {   BEGIN(QUOTATION);   }

<QUOTATION>\\end\{quotation\}\n? {   BEGIN(INITIAL);    }

<QUOTATION>[[:space:]]+ 

<QUOTATION>[^([:space:]\\)]+ {

    // verify if it is the first word of the quotation                  
    if (quotation_word_count == 0) {
        fprintf(out, "> ");
    }
    // increase word count
    quotation_word_count++;
    // print word and verify if it is the last word of the quotation
    if(quotation_word_count == 10) {
        fprintf(out, "%s\n", yytext);
        // reset word count
        quotation_word_count = 0;
    } else {
        // print word
        fprintf(out, "%s ", yytext);
    }
                            }

\\begin\{verbatim\} {   BEGIN(VERBATIM);   }

<VERBATIM>\n { 
    // print indent with 4 spaces
    fprintf(out, "\n    "); }

<VERBATIM>\\end\{verbatim\}\n? {   BEGIN(INITIAL);   }

\\href {   BEGIN(HREF);   }

<HREF>\{([^}]*)\} {
    // extract text and put under [text] 
    char *text = yytext + 1;
    text[strlen(text) - 1] = '\0';
    fprintf(out, "[%s]", text);
    BEGIN(HREF_EXTRACT); }

<HREF_EXTRACT>\{([^}]*)\} {
    // extract text and put under (text)
    char *text = yytext + 1;
    text[strlen(text) - 1] = '\0';
    fprintf(out, "(%s)", text);
    BEGIN(INITIAL);        }   

\\[^ \t]*section {   BEGIN(UNDERLINE_SECTION);   }

<UNDERLINE_SECTION>\{([^}]*)\}\n { 
    // extract text and print underlined with '-'
    char *text = yytext + 1;
    text[strlen(text) - 2] = '\0';
    
    fprintf(out, "%s\n", text);
    fprintf(out, "----------\n");
    BEGIN(INITIAL); }

<UNDERLINE_SECTION>\{([^}]*)\} {
    // extract text and print underlined with '-'
    char *text = yytext + 1;
    text[strlen(text) - 1] = '\0';
    
    fprintf(out, "%s\n", text);
    fprintf(out, "----------\n");
    BEGIN(INITIAL); }

\\title {   BEGIN(UNDERLINE_TITLE);   }

<UNDERLINE_TITLE>\{([^}]*)\}\n { 
    // extract text and print underlined with '='
    char *text = yytext + 1;
    text[strlen(text) - 1] = '\0';
    
    fprintf(out, "%s", text);
    fprintf(out, "==========\n");
    BEGIN(INITIAL); }

<UNDERLINE_TITLE>\{([^}]*)\} {
    // extract text and print underlined with '='
    char *text = yytext + 1;
    text[strlen(text) - 1] = '\0';
    
    fprintf(out, "%s\n", text);
    fprintf(out, "==========\n");
    BEGIN(INITIAL);
                         }

%.*\n   { fprintf(out, "\n"); }
.       { fprintf(out, "%s", yytext); }
\n      { fprintf(out, "\n"); }
[ \t]+

%%

int main(int argc, char **argv) {

    // open input file
    yyin = fopen(argv[1], "r");
    // verify for errors
    if (yyin == NULL) {
        printf("Error opening file %s\n", argv[1]);
        return 1;
    }

    // open output file
    out = fopen("out.md", "w");
    // verify for errors
    if (out == NULL) {
        printf("Error opening file out.txt\n");
        return 1;
    }

    // start analysis
    yylex();

    // close files
    fclose(yyin);
    fclose(out);

    return 0;
}
