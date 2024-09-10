#!/bin/sh
echo "This script extracts the data required to find the most stable structures."
echo "Warning: Don't forget putting the *.log files created by the Gaussian package."

echo "System's Name" >> extracted-data.txt
grep "Sum of electronic and zero-point Energies= " *.log | cut -d' ' -f1,14 >> extracted-data.txt
echo "			" >> extracted-data.txt

echo "Sum of electronic and zero-point Energies" >> extracted-data.txt
grep "Sum of electronic and zero-point Energies= " *.log | cut -d " " -f 8- >> extracted-data.txt
#cut -d " " -f 8- extracted-data.txt >> extracted-data.txt
echo "			" >> extracted-data.txt

echo "Sum of electronic and thermal Free Energies" >> extracted-data.txt
grep "Sum of electronic and thermal Free Energies= " *.log | cut -d " " -f 9- >> extracted-data.txt
echo "			" >> extracted-data.txt

echo "Number of imaginary frequencies" >> extracted-data.txt
grep "NImag=" *.log >> extracted-data.txt
echo "			" >> extracted-data.txt

grep "S2="  *.log >> extracted-data.txt
grep "S2A="  *.log >> extracted-data.txt

echo "Data extracted, successfully! ;)" 


