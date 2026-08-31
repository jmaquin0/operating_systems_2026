mkdir -p descargas/textos
mkdir -p copias/respaldo-2026
mkdir -p organizados/{quijote,alicia,poe}
touch notas.txt
touch registro.log inventario.csv
touch descargas/textos/.gitkeep
wget -O descargas/textos/quijote.txt https://www.gutenberg.org/cache/epub/2000/pg2000.txt
wget -O descargas/textos/alicia.txt https://www.gutenberg.org/cache/epub/11/pg11.txt
wget -O descargas/textos/poe.txt https://www.gutenberg.org/cache/epub/2148/pg2148.txt
cp descargas/textos/quijote.txt copias/
cp descargas/textos/alicia.txt copias/alicia-copia.txt
cp descargas/textos/*.txt copias/respaldo-2026/
cp -r descargas/textos copias/textos-respaldo
cp -iv descargas/textos/poe.txt copias/

