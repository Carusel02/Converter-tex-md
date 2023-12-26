%{
#include <stdio.h>
FILE *out;
int tabs = 0;
int level = 0;
%}

%s QUOTATION
%s ITEMIZE
%s ENUMERATE

%%
[\t] {};
\\documentclass.*\{.*\} ;
\\newcommand\{.*\}\{.*\} ;
\\usepackage\{.*\} ;
\\date\{.*\} ;
\\maketitle ;
\\label\{.*\} ;
\\LaTeX ;
\%.* ;
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

\\begin\{verbatim\}     {   fprintf(out, "\n");
                            tabs++;
                        }

\\end\{verbatim\}       {   
                            tabs--;
                            fprintf(out, "\n");
                        }

\\begin\{quotation\}               {    fprintf(out, "\n> ");
                                        BEGIN(QUOTATION); 
                                   }

<QUOTATION>\\end\{quotation\}      {    fprintf(out, "\n");
                                        BEGIN(INITIAL); 
                                   }


\\begin\{enumerate\}               {    tabs++;
                                        BEGIN(ENUMERATE); 
                                   }

<ENUMERATE>\\item                 {
                                        fprintf(out, "1.");
                                  }

<ENUMERATE>\\end\{enumerate\}      {    tabs--;
                                        if(tabs == 0)
                                            BEGIN(INITIAL);
                                   }


\\begin\{itemize\}                 {    tabs++;
                                        printf("%d", tabs);
                                        BEGIN(ITEMIZE); 
                                   }

<ITEMIZE>\\item                 {       
                                        fprintf(out, "-");
                                }


<ITEMIZE>\\end\{itemize\}          {    tabs--;
                                        if(tabs == 0)
                                            BEGIN(INITIAL); 
                                   }

[\n]         {  if(tabs > 0)
                    fprintf(out, "\n");
                // fprintf(out, "%d", tabs); 
                for(int i = 0; i < tabs; i++)
                    fprintf(out, "\t");
             }

.             { 
                fprintf(out, "%s", yytext); }
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
