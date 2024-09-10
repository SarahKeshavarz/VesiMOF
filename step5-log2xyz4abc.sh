#!/bin/bash
############################################################
## JAKUB KUBECKA 2018                                     ##
## Program for analysis of pulling str from gaussian .log ##
## To understand program run help:                        ##
##        JKlog2xyz -help                                 ##
############################################################

### THIS IS HELP
function help {
  echo "THIS IS HELP:"
  echo "Program for analysis of pulling str from gaussian .log"
  echo """
  JKlog2xyz [OPTIONS] [FILES]
  OPTIONS:
   -help ....... print this help and exit
   -abc ........ print structure in format of ABCluster
   -new \"XX\" ... new name of file [e.q.: test]
   -xtb ........ structure is from XTB output
  FILES:
   gaussian (G16) output is expected
  EXAMPLES:
     JKlog2xyz
     JKlog2xyz 2.log 3.log
     JKlog2xyz -abc guanidine.log
  """
  exit
}
### PREPARING WHAT AND HOW
what=""
Qabc=0
Qnewname=""
Qnew=0
QdipXTB=0
Qxtb=0
next=0
last=""
for i in $*
do
  if [ "$i" == "-help" ] || [ "$i" == "--help" ]; then help;exit;fi
  firstletter=`echo $i | cut -c 1`
  if [ $firstletter == "-" ] || [ $next -eq 1 ]
  then
    ### CHECK IF ABC INPUT IS REQUIRED
    if [ $i == "-abc" ]
    then 
      Qabc=1
    fi
    ### -new XX
    if [ "$last" == "-new" ]
    then
      Qnew=1
      Qnewname=$i
      last=""
      next=0
    fi
    if [ "$i" == "-new" ]
    then
      next=1
      last="-new"
    fi
    ###
    if [ $i == "-dip" ]
    then
      QdipXTB=1
    fi
    ###
    if [ $i == "-xtb" ]
    then
      Qxtb=1
    fi
    ###
  else
    what+="$i "
  fi
done
### CHECK WHAT
#if [ -z "$what" ]; then what=`ls *.log`;fi

### MAIN PROGRAM // in the case a lot of file might take a few seconds
     read -p 'charge: ' ch ##read charge of the systems from command line 

echo "JKlog2xyz: Wait a moment ..." 

for file in *.log
do
  if [ $Qxtb -eq 0 ]
  then
    ### Finding information about number of atoms
    test=`grep -c 'NAtoms=' $file`
    if [ $test -eq 0 ] 
    then
      #D=`grep "Deg. of freedom" $file | head -n 1 | awk '{print $4}'`
      #if [ $D -eq 0 ]; then N=1;fi
      #if [ $D -eq 1 ]; then N=2;fi
      #if [ $D -eq 3 ]; then N=3;fi
      #if [ $D -gt 3 ]; then N0=`echo $D+6|bc`;N=`echo $N0/3|bc`;fi
  
      # this is better because of some symmetry shits:
      #N=`grep -C 2 "Distance matrix (angstroms):" $file | head -n 1 | awk '{print $1}'`
      N=`grep -C 2 "Rotational constants" $file | tail -n 5 | head -n 1 | awk '{print $1}'`
    else 
      N=`grep 'NAtoms=' $file | head -n 1 | awk '{print $2}'`
    fi
    N1=`echo $N+1 |bc`
    N2=`echo $N+2 |bc`
    
    grep -C $N1 "Symbolic Z-matrix:" $file | tail -n $N | awk '{print $1}' > helpingfile1
    grep -C $N2 " Center     Atomic      Atomic             Coordinates (Angstroms)" $file | tail -n $N | awk '{print $4,$5,$6}' > helpingfile2
    
    ### CREATING NEW FILE
    if [ $Qnew -eq 1 ]
    then  
      newfile=$(basename $Qnewname .xyz).xyz
    else
      newfile=${prepos}$(basename $file .log).xyz
    fi
    if [ -e $newfile ]; then rm $newfile;fi
    
    echo "$N" >> $newfile
#    # Let us save energy on 2. row
#    freqQ=`grep -c "Free Energies" $file`
#    if [ "$freqQ" -eq 1 ]
#    then
#      energy=" Free_Energy: `grep "Free Energies" $file | awk '{print $8}'`"
#      energy+=" Electronic_Energy: `grep "SCF Done" $file | tail -n 1 | awk '{print $5}'`"
#    else 
#      energy=" Electronic_Energy: `grep "SCF Done" $file | tail -n 1 | awk '{print $5}'`"
#    fi
#    if [ $QdipXTB -eq 1 ]
#    then
#      energy+=" Dipole_moment: `grep "molecular dipole:" $file | tail -n 1 | awk '{print $5}'`" 
#    fi
#    echo "$energy" >> $newfile
## writing the name of file and its charge to the output. The charge is read interactively from the command line! 
     echo "${file%.log}($ch)" >> $newfile
  
    paste helpingfile1 helpingfile2 >> $newfile
    ### ABC input ###
    if [ $Qabc -eq 1 ];
    then 
      # add comment line line 
      echo "all32_cgenff q  epsilon (kJ/mol) sigma (AA)" >> $newfile 
  
      ### START LOOP ###
      # loop over all atoms (you need to know amount of atoms N)
      for i in `seq 1 $N`
      do 
        # (APT) or (Mulliken) charges? 
        test=`grep -c "Summary of Natural Population Analysis" $file`
        if [ $test -gt 0 ]
        then
          text="Summary of Natural Population Analysis"
          N1new=`echo $N1+4 |bc`
          elem=1
        else 
          text=" APT charges:"
          N1new=$N1
          elem=2
        fi
        # taking charge
        q=`grep -C $N1new "$text" $file | tail -n $N | awk '{print $3}' | head -n $i | tail -n 1`
        # asking for element
        e=`grep -C $N1new "$text" $file | tail -n $N | awk -v var=$elem '{print $var}' | head -n $i | tail -n 1`
        # giving some valeus (LJ parameters) to the element according to UFF/UFF4MOF       !!!! these values are not set up properly !!!!!! 
        text=""
        if [ $e == "H" ] || [ $e == "h" ]; then text=" 0.1841     2.8860    ";fi
        if [ $e == "C" ] || [ $e == "c" ]; then text=" 0.4393     3.8510    ";fi
        if [ $e == "N" ] || [ $e == "n" ]; then text=" 0.2887     3.6600    ";fi
        if [ $e == "O" ] || [ $e == "o" ]; then text=" 0.2510     3.5000    ";fi
        if [ $e == "S" ] || [ $e == "s" ]; then text=" 1.1464     4.0350    ";fi
        if [ $e == "P" ] || [ $e == "p" ]; then text=" 1.2761     4.1470    ";fi
        if [ $e == "F" ] || [ $e == "f" ]; then text=" 0.2092     3.3640    ";fi
        if [ $e == "Cl" ] || [ $e == "cl" ]; then text=" 0.9498     3.9470    ";fi
        if [ $e == "Br" ] || [ $e == "br" ]; then text=" 1.0502     4.1890    ";fi
        if [ $e == "Al" ] || [ $e == "al" ]; then text=" 2.1129     4.4990    ";fi
        if [ $e == "Cu" ] || [ $e == "cu" ]; then text=" 0.0209     3.4950    ";fi
        if [ $e == "Fe" ] || [ $e == "fe" ]; then text=" 0.0544     2.9120    ";fi
        if [ $e == "Mn" ] || [ $e == "mn" ]; then text=" 0.0544     3.9610    ";fi
        if [ $e == "Zn" ] || [ $e == "zn" ]; then text=" 0.5188     2.7630    ";fi
        #if missing element then you have to upgrade this code
        if [ -z "$text" ]; then echo "element potential coefficients are missing. Contact Jacob, he can fix it very easily.";fi
        # put it in the end of the strABC.xyz
        echo "$q $text" >> $newfile
      done
      ### END LOOP ###
    fi
    ### END ABC INPUT ###
  else
    output=`echo $file | rev | cut -c4- | rev`xyz
    if [ -e "$output" ]
      then
      #echo "xyz file exists, is gonna be deleted."
      rm $output
    fi
    Natoms=`grep 'number of atoms' $file | awk '{print $5}'`
    echo "   $Natoms" >> $output
    echo $file >> $output
    Natoms2=`echo $Natoms+2 | bc`
    grep -C $Natoms2 'final structure' $file | tail -n $Natoms | awk '{print $4 "\t " $1*0.529177249 "\t " $2*0.529177249 "\t " $3*0.529177249}' >> $output
  fi
done

if [ -e helpingfile1 ]; then rm helpingfile1; fi
if [ -e helpingfile2 ]; then rm helpingfile2; fi

echo "JKlog2xyz: Done :-D"