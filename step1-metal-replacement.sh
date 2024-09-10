#!/bin/sh
echo "This script prepares metal spicific *.xyz files."
echo "Warning: Don't forget putting the *.xyz files of your structures (containing just atom type and coordinates of the atoms in Angestrom) in the same directory."
echo "Warning2: In the *.xyz files, the metal atom names should be indicated as the general name 'Me'."
echo "Run this script once for each metal type and structural group!"

# Can I run for all metal ions simultaneously? like m1 m2 m3....

read -p 'metal name: ' m

for j in *.xyz
do 
awk -v m="$m" '$1=="Me" { sub("Me", m) } 1' "$j" > "${j%.xyz}-$m.xyz"
done 

echo "$m-specific files generated! ;)" 


