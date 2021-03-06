#!/bin/tcsh

set ObjName=$1 
set theLabel=$2

setenv CMSSW_DIR ${CMSSW_BASE}/src/Alignment/OfflineValidation/test/PVValResults
#cp ${CMSSW_DIR}/PlotPVValidation_forDevel.C .
#cp ${CMSSW_DIR}/check.C .

foreach filetostudy (`ls ${PWD} | grep .root`)

     set namebase=`echo $filetostudy |awk '{split($0,a,"_"); print a[2]}'`
     echo "Studying $namebase file"
     if ($namebase == $ObjName) then
       set datebase=`echo $filetostudy |awk '{split($0,b,"_"); print b[3]}'` 
       set theDate=`echo $datebase |awk '{split($0,c,"."); print c[1]}'`  

       rm -f FittedDeltaZ.tx
	
       #root -b -q  $PWD/PlotPVValidation_forDevel.C++\(\"${PWD}/$filetostudy=${theDate}\"\,1\,\"\)
       root -b -q  $PWD/PlotPVValidation_forDevel.C++\(\"${PWD}/$filetostudy=${theLabel}\"\,1\,\"\"\,\"${theDate}\"\)

       rm -f numevents.out 
       root -b -q  $PWD/check.C\(\"${PWD}/$filetostudy\"\) > numevents.out
       set rawnumevents=`tail -1 numevents.out`
       set numevents=`echo $rawnumevents | awk '{split($0,a,")"); print a[2]}'` 
    
       set rawfits=`tail -1 FittedDeltaZ.txt`
       set deltaz=`echo $rawfits | awk '{split($0,a,"|"); print a[1]}'`
       set sigmadeltaz=`echo $rawfits | awk '{split($0,a,"|"); print a[2]}'` 
 
       setenv flag "BAD"

       if (! -d summary.txt ) then
	 touch summary.txt 
       endif
    
       if (${numevents} > 1000) then
	setenv flag "GOOD"
       endif

       echo "- File $namebase had ${numevents} events. Fit separation: $deltaz \pm $sigmadeltaz"

       echo $theDate $deltaz $sigmadeltaz ${numevents} $flag >> summary.txt
    endif
end

mv summary.txt summary_${ObjName}.txt
mkdir ./${ObjName}
mv histos*.root ./${ObjName}
mv *.png ./${ObjName}




