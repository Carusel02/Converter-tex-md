# MARIN MARIUS DANIEL 332CC
## Tema FLEX Varianta A

### Probleme aparute:
- diversitatea in care pot veni comenzile:
    - uneori au `\{}`, uneori au `\[]{}`, uneori au `\{}{}`
    - astfel regulile trebuie sa fie mai generale, ca sa
    cuprinda toate cazurile posibile
- ce se intampla cu restul comenzilor:
    - ideea mea de baza sta la printarea fisierului in mod
    normal si transformarea anumitor sintaxe din el (astfel,
    se afiseaza tot si ce este afisat se modifica)
- indentarea, spatierea si noi randuri de linie
    - gestionarea acestora mi s-a parut foarte dificila
    -ca sa arate ok, am incercat in reguli sa fac match
    si cu whitespaces

### Implementare:
- am creat mai multe reguli care fac match pe comenzi care ar trebui
ignorate
- am creat mai multe reguli care transforma textul din format latex
in format md
- pentru aceste tranformari in variantele simple am extras folosind
limbajul C, pentru situatiile mai complexe am folosit `STARI` pentru a 
avea un numar rezonabil din acestea
- am folosit stiva de stari pentru listele `IMBRICATE`, reusind astfel 
sa creez logica de indentare a acestora folosind taburi
- pentru mediul quotation, am folosit un word count si reguli care
impart linia in cuvinte, reusind astfel sa le numerotez pentru a putea
fi 10 pe linie

Am folosit `Visual Studio Code` in mediul linux.