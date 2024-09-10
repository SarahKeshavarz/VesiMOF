#!/bin/sh
echo "This script prepares input files to evaluate several spin states at a specific computational level for a neutral system."
echo "Warning: Don't forget putting the *.xyz files of your structures (containing just atom type and coordinates of the atom in Angestrom) in the same directory."
echo "Warning2: For changing the method or computational level, please change line 33 of this script file."  
echo "Warning3: For a non-neutral system, please change line 27 of this script file."  

read -p 'Metal name: ' m 
echo "Note: You can find the number of unpaired electrons for the selected metal ion from the "metal-unpaired-electrons.txt" file." 
read -p 'Number of unpaired electrons per metal ion: ' e 

for i in *-$m.xyz
do 
    nm=$(grep -cow "$m" "$i") # Count the number of m metal atoms in the structure and report it to variable "nm" 
    spmax=$((nm * e + 1)) 
    # The following part says that if spmax is an even number, then the lowest spin is 2, otherwise 1 (singlet system). 
    rs='expr $spmax % 2' 
    if [ $rs == 0 ]
       then spmin=2
       else spmin=1
    fi 
    j=0 # total system charge is 0
        for k in $(seq $spmin 2 $spmax) # spin state alteration
        do 
           echo "%nprocshared=16" > "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "%mem=16GB" >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "# opt freq PBEPBE/def2tzvp** scf=xqc  EmpiricalDispersion=GD3" >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "      " >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "Title card" >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "      " >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "$j $k " >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           cat $i >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "      " >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
           echo "      " >> "${i%.xyz}-PBEdef-ch$j-sp$k.com"
        done      
done


# module load gaussian/G16RevA.03
# for l in *$m*.com
# do 
# subg16 72:00:00 "${l%.com}" project_2001034
# done 
echo "Spin state evaluation jobs created and submitted! ;)" 


