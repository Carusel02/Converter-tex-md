%{
#include <stdio.h>
#include <stdlib.h>
FILE *out;
int quotation_word_count = 0;
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

\\texttt\{[^}]*\} {     char *text = yytext + 8;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "`%s`", text); }

\\textbf\{[^}]*\} {     char *text = yytext + 8;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "**%s**", text); }

\\textit\{[^}]*\} {     char *text = yytext + 8;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "_%s_", text); }

\\emph\{[^}]*\} {       char *text = yytext + 6;
                        text[strlen(text) - 1] = '\0';
                        fprintf(out, "_%s_", text); }

([ \t]*)?\\begin\{itemize\}\n? {     tabs++;
                                     fprintf(out, "\n");
                                     yy_push_state(ITEMIZE); }



<ITEMIZE>(.*)?\\item {  for(int i = 0; i < tabs; i++) {
                            fprintf(out, "  ");
                        }
                        
                        fprintf(out, "-"); }

<ITEMIZE>([ \t]*)?\\end\{itemize\}\n? {  tabs--;
                                         yy_pop_state(); }


([ \t]*)?\\begin\{enumerate\}\n? {   tabs++;
                                     fprintf(out, "\n");
                                     yy_push_state(ENUMERATE); }

<ENUMERATE>(.*)?\\item {  for(int i = 0; i < tabs; i++) {
                            fprintf(out, "  ");
                          }
                        
                            fprintf(out, "1."); }

<ENUMERATE>([ \t]*)?\\end\{enumerate\}\n? { tabs--; 
                                            yy_pop_state();

                                        }


\\begin\{quotation\}\n? { 
                          BEGIN(QUOTATION);  
                        }


<QUOTATION>\\end\{quotation\}\n? {
    BEGIN(INITIAL);
}

<QUOTATION>[[:space:]]+ 

<QUOTATION>[^([:space:]\\)]+ {
                            
                                if (quotation_word_count == 0) {
                                    fprintf(out, "> ");
                                }

                                quotation_word_count++;

                                if(quotation_word_count == 10) {
                                    fprintf(out, "%s\n", yytext);
                                    quotation_word_count = 0;
                                } else {
                                    fprintf(out, "%s ", yytext);
                                }

                            }

\\begin\{verbatim\} { BEGIN(VERBATIM); }

<VERBATIM>\n { fprintf(out, "\n    "); }

<VERBATIM>\\end\{verbatim\}\n? { BEGIN(INITIAL); }

\\href { BEGIN(HREF); }

<HREF>\{([^}]*)\} { 
                    char *text = yytext + 1;
                    text[strlen(text) - 1] = '\0';
                    fprintf(out, "[%s]", text);
                    BEGIN(HREF_EXTRACT);
                  }

<HREF_EXTRACT>\{([^}]*)\} { 
                            char *text = yytext + 1;
                            text[strlen(text) - 1] = '\0';
                            fprintf(out, "(%s)", text);
                            BEGIN(INITIAL);
                    }   


\\[^ \t]*section { BEGIN(UNDERLINE_SECTION); }

<UNDERLINE_SECTION>\{([^}]*)\}\n { 
                           char *text = yytext + 1;
                           text[strlen(text) - 2] = '\0';
                           
                           fprintf(out, "%s\n", text);
                           fprintf(out, "----------\n");
                           BEGIN(INITIAL);
                         }

<UNDERLINE_SECTION>\{([^}]*)\} { 
                           char *text = yytext + 1;
                           text[strlen(text) - 1] = '\0';
                           
                           fprintf(out, "%s\n", text);
                           fprintf(out, "----------\n");
                           BEGIN(INITIAL);
                         }

\\title { BEGIN(UNDERLINE_TITLE); }

<UNDERLINE_TITLE>\{([^}]*)\}\n { 
                           char *text = yytext + 1;
                           text[strlen(text) - 1] = '\0';
                           
                           fprintf(out, "%s", text);
                           fprintf(out, "==========\n");
                           BEGIN(INITIAL);
                         }

<UNDERLINE_TITLE>\{([^}]*)\} { 
                           char *text = yytext + 1;
                           text[strlen(text) - 1] = '\0';
                           
                           fprintf(out, "%s\n", text);
                           fprintf(out, "==========\n");
                           BEGIN(INITIAL);
                         }



 
%.*\n { fprintf(out, "\n"); }
. { fprintf(out, "%s", yytext); }
\n { fprintf(out, "\n"); }
[ \t]+

%%

int main(int argc, char **argv) {

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        printf("Error opening file %s\n", argv[1]);
        return 1;
    }

    out = fopen("out.md", "w");
    if (out == NULL) {
        printf("Error opening file out.txt\n");
        return 1;
    }

    yylex();

    fclose(yyin);
    fclose(out);

    return 0;
}
