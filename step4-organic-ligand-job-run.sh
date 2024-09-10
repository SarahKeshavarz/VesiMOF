#!/bin/sh
echo "This script prepares Gaussian input files for optimization and frequency calculation at the HSEH1PBE/6-31+G* level for a neutral system."
echo "Warning: Don't forget putting the *.com files of your structures (containing complete Gaussian input data, even the connectivity data) in the same directory."
echo "Warning2: For changing the method or computational level, please change line 19 of this script file."  
echo "Warning3: For a non-neutral or non-singlet system, please change line 15 or 16 of this script file."  


for a in *.com
do 
   sed -i '1,6d' "$a" # delete the first to sixth lines of the *.com files automatically created by GaussView
done 

for i in *.com
do 
    j=0 # total system charge is 0
    k=1 # singlet system
    echo "%nprocshared=16" > "${i%.com}.temp"
    echo "%mem=16GB" >> "${i%.com}.temp"
    echo "# opt freq HSEH1PBE/6-31+G* scf=xqc geom=connectivity" >> "${i%.com}.temp"
    echo "      " >> "${i%.com}.temp"
    echo "Title card" >> "${i%.com}.temp"
    echo "      " >> "${i%.com}.temp"
    echo "$j $k " >> "${i%.com}.temp"
    cat "$i" >> "${i%.com}.temp"
done

for f in *.temp
do
           cat $f > "${f%.temp}-optimal.com"
           rm $f
done

 

# module load gaussian/G16RevA.03
# for x in *optimal.com
# do 
# subg16 72:00:00 "${x%.com}" project_2001034
# done 
echo "Organic ligand jobs at the optimal computational level created and submitted! ;)" 


