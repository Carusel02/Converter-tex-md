%{
#include <stdio.h>
FILE *out;
int tabs = 0;
%}

%s QUOTATION
%s ITEMIZE


%%
[\t] {}
\\documentclass.*\{.*\} ;
\\newcommand\{.*\}\{.*\} ;
\\usepackage\{.*\} ;
\\date\{.*\} ;
\\maketitle ;
\\label\{.*\} ;
\\begin\{document\} ;
\\end\{document\} ;

\\title\{[^}]*\}        {   char *title = yytext + 7;
                            title[strlen(title) - 1] = '\0';
                            fprintf(out, "%s\n===========\n", title); 
                        }


\\section\{[^}]*\}      {   char *section = yytext + 9;
                            section[strlen(section) - 1] = '\0';
                            fprintf(out, "%s\n-----------\n", section); 
                           }

\\href\{[^}]*\}\{[^}]*\} {   char *link = yytext + 6;
                             link[strlen(link) - 1] = '\0';
                             char *text = strchr(link, '}');
                             *text = '\0';
                             text = text + 2;
                             fprintf(out, "[%s](%s)", link, text); 
                         }

\\textbf\{[^}]*\}       {   char *text = yytext + 8;
                            text[strlen(text) - 1] = '\0';
                            fprintf(out, "**%s**", text); 
                        }

\\texttt\{[^}]*\}       {   char *text = yytext + 8;
                            text[strlen(text) - 1] = '\0';
                            fprintf(out, "`%s`", text); 
                        }

\\textit\{[^}]*\}       {   char *text = yytext + 8;
                            text[strlen(text) - 1] = '\0';
                            fprintf(out, "_%s_", text);
                        }

\\emph\{[^}]*\}         {   char *text = yytext + 6;
                            text[strlen(text) - 1] = '\0';
                            fprintf(out, "_%s_", text);
                        }

\\begin\{verbatim\}     {   
                            tabs++;
                        }

\\end\{verbatim\}       {   
                            tabs--;
                        }

\\begin\{quotation\}               {    fprintf(out, "\n> ");
                                        BEGIN(QUOTATION); 
                                   }

<QUOTATION>\\end\{quotation\}      {    fprintf(out, "\n");
                                        BEGIN(INITIAL); 
                                   }

\\begin\{itemize\}                 {    
                                        BEGIN(ITEMIZE); 
                                   }

<ITEMIZE>\\item                 {    fprintf(out, "\n\t -");
                                     // fprintf(out, "%s\n", yytext + 5);
                                }


<ITEMIZE>\\end\{itemize\}          {    
                                        BEGIN(INITIAL); 
                                   }

[\n]         {   
                fprintf(out, "\n"); 
                for(int i = 0; i < tabs; i++)
                    fprintf(out, "\t");
            }

.             { fprintf(out, "%s", yytext); }
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
    return 0;
}
