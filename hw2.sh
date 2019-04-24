#!/bin/bash
if [[ $# -ne 4 ]] 
then
    echo "Not enough arguments passed"
else
    lastwavend=0
    lfrom=0
    mkdir -p $4
    ticks=$(grep -oP '<tick>(.*)</tick>' $2)
    ticktime=$((1000/$(grep -oP '<SamplingRate>(.*)</SamplingRate>' $2 |cut -d ">" -f 2 | cut -d " " -f 1)))
    egstartt=$(grep -oP '<StartRecordingTime>(.*)</StartRecordingTime>' $2 |cut -d ">" -f 2 | cut -d "<" -f 1)
    egstartd=$(grep -oP '<StartRecordingDate>(.*)</StartRecordingDate>' $2 |cut -d ">" -f 2 | cut -d "<" -f 1)
    egstartdt=$egstartd" "$egstartt
    if [[ $EEG_TZ == " " ]]
    then
	egstartu=$(date --date="TZ=\"UTC\" $egstartdt" +"%s")
    else
	egstartu=$(date --date="TZ=\"$EEG_TZ\" $egstartdt" +"%s")
    fi
    egstartu=$(date --date="$egstartdt" +"%s")
    cat $1 | while read p; do
        stimul=$(echo "$p" | cut -d ' ' -f1)
	start=$(echo "$p" | cut -d ' ' -f2)
	end=$(echo "$p" | cut -d ' ' -f3)
	lengthsec=$(echo "($end-$start)" |bc)
	lengthm=$(echo "($end-$start)*100000/1" |bc)
	start=$(echo "($start+0.5)/1" |bc)
	end=$(echo "($end+0.5)/1" |bc)
	if [[ $lengthm -lt 200 ]]
	then
	echo "Stimul length less than 0.2s"
	else
	    if [[ start -ge egstartu ]] && [[ $stimul != "beep" ]]
	    then
	        tocut=$((lengthm/ticktime))
		lto=$(($lfrom + $tocut))
		echo "$ticks" | head -n $lto | tail -n $lfrom > "$4/${stimul}_eeg.xml"
		lfrom=$lto
		cuttime=$(echo "$lengthsec+$lastwavend" | bc)
		outfilew=$(echo "$4/${stimul}_lar.wav")
		sox $3 $outfilew trim $lastwavend $cutttime
		lastwavend=$cuttime
	    else
		echo "stimul outside time boundaries"
	    fi
	fi
    done
fi


