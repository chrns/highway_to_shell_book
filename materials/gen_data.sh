#!/usr/bin/env bash
set -euo pipefail

echo "Preparing the system"
sudo apt update
sudo apt install mc htop tmux git build-essential

echo "Creating a folder for test, ~/highway"
mkdir -p highway/data highway/chsm/src

cat > highway/data/commands.txt <<'EOF'
date
uptime
EOF

for i in {1..7}; do
  touch "highway/data/file_${i}.txt"
done

for i in {1,11,12,16}; do
  touch "highway/data/log_24_12_${i}.txt"
done

# quote.mrs
echo "... .... .- .-.. .-.. / .. / .-. . ..-. ..- ... . / -- -.-- / -.. .. -. -. . .-. / -... . -.-. .- ..- ... . / .. / -.. --- / -. --- - / ..-. ..- .-.. .-.. -.-- / ..- -. -.. . .-. ... - .- -. -.. / - .... . / .--. .-. --- -.-. . ... ... / --- ..-. / -.. .. --. . ... - .. --- -. ..--.." > highway/data/quote.mrs

echo "Let's generate some data"
# people.tsv / years.tsv
cat > highway/data/dudes.tsv <<'EOF'
1	Galois
2	Abel
3	Uhlenbeck
4	Srinivasa
5	Stefan
EOF

cat > highway/data/years.tsv <<'EOF'
1	1811
2	1802
3	1942
4	1887
5	1892
6	1777
EOF

# elements.tsv
cat > highway/data/elements.tsv <<'EOF'
H	1	Hydrogen	nonmetal	gas
He	2	Helium	noble_gas	gas
Li	3	Lithium	alkali_metal	solid
B	5	Boron	metalloid	solid
O	8	Oxygen	nonmetal	gas
Al	13	Aluminium	post_transition_metal	solid
Sc	21	Scandium	transition_metal	solid
Se	34	Selenium	nonmetal	solid
EOF

# iso_mass.tsv
cat > highway/data/iso_mass.tsv <<'EOF'
1.008
4.0026
6.94
10.81
15.999
26.982
44.956
78.971
EOF

printf "%s\n" 10 5 3 10 42 5 7 7 7 99 > highway/data/numbers.txt

printf '312F32706973717274284C43290A' | xxd -r -p > highway/data/right.bin
printf '312F32706973717274284C43280A' | xxd -r -p > highway/data/left.bin

# log.txt (минимальный набор уровней)
cat > highway/data/log.txt <<'EOF'
2025-02-02T12:00:01Z INFO   Maxwell daemon has started
2025-02-02T12:00:02Z WARN   Too many hot participles. Sorting will take a lot of time
2025-02-02T12:00:03Z ERROR  Schrodinger: cat state is uncertain
EOF

# phones.txt
cat > highway/data/phones.txt <<'EOF'
+7-(314)-159-2653
+381-(271)-828-1828
+1-(161)-803-3988
(555)-666-7777 
EOF

cat > highway/data/models.txt <<'EOF'
S3XY
EOF

cat > highway/data/grocery.txt <<'EOF'
Newton's Apples
Thermodynamic Ice Cream
Archimedes' Oranges
Schrödinger's Watermelon
Planck's Pickles
Doppler Bananas
Friction-Free Butter
Thermodynamic Ice Cream
Doppler Bananas
EOF

echo "Now let's copy some files"
URL_BASE="https://raw.githubusercontent.com/chrns/highway_to_shell_book/refs/heads/main/materials"

curl -o highway/game.sh ${URL_BASE}/game.sh
chmod +x highway/game.sh

curl -o highway/chsm/README.md ${URL_BASE}/chsm/README.md
curl -o highway/chsm/Makefile ${URL_BASE}/chsm/Makefile

SRCS=(algos.h main.c main.h rtu.c rtu.h stm32.c stm32.h)
for f in "${SRCS[@]}"; do
  curl -o highway/chsm/src/$f "$URL_BASE/chsm/src/$f"
done
