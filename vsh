#!/bin/bash
ctf() {
while read ligne                                     #le meme chose comme ls
do
	grep -n '^directory .*$' > dirtotal       #make idea to get the head and tail to cut the file
											           #head tail 2paras
	if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
	then
		headtaildir=$(cat dirtotal | grep -A 1 $pathnow$|cut -d ':' -f 1)
	else
		headtaildir=$(cat dirtotal | grep -A 1 $pathnow$|cut -d ':' -f 1)
	fi					
done < archive/archive
headdir=$(echo $headtaildir|cut -d ' ' -f 1)
taildir=$(echo $headtaildir|cut -d ' ' -f 2)
((longdir=$taildir-$headdir))
cat archive/archive| head -$taildir|tail -$longdir > dirnow       #end of copy as ls
if [ $niveau -gt 0 ]
then
	cat -n archive/archive| head -$taildir|tail -$longdir|cut -d'	' -f 1  >> numligne
fi
alpha=$(echo $pathnow| sed 's#/##g')
catlist=$(cat dirnow|grep -v '^directory'|grep -v '^@'|cut -d ' ' -f 1)
echo $catlist
}
lsd() {
if [ -e numligne ]
then 
	rm -f numligne
fi
ctf $pathnow
for word in $(ctf $pathnow)
do
	if [ $niveau -eq 0 ]
	then
		echo $catlist
		charcter=$(cat dirnow|grep -v '^directory'|grep -v '^@'|grep $put |cut -d ' ' -f 2|cut -c 1)
		echo word $word its charcter is $charcter 
		if [ "$put" == "$word" ] && [ "$charcter" == "d" ]
		then
			if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
			then
				pathnow=$pathnow$word
			else	
				pathnow=$pathnow/$word
			fi
			echo $pathnow
			((niveau=$niveau+1))
			echo "next niveau is $niveau"
			lsd $word
		elif [ "$put" == "$word" ] && [ "$charcter" == "-" ]
		then
			headtailfile=$(cat dirnow| grep $word)
			headfile=$(echo $headtailfile|cut -d' ' -f4)
			longfile=$(echo $headtailfile|cut -d' ' -f5)		#le nb in contenu main		
			echo $longfile
			headcontenu=$(cat archive/archive|head -1| cut -d':' -f2)
			((headfiletrue=$headfile+$headcontenu-1))
			((tailfiletrue=$headfiletrue+$longfile-1))
			cat -n archive/archive|head -$tailfiletrue|tail -$longfile >> numligne
		fi
	elif [ $niveau -gt 0 ]
	then
		echo $catlist
		charcter=$(cat dirnow|grep -v '^directory'|grep -v '^@'|grep $word |cut -d ' ' -f 2|cut -c 1)
		echo word $word its charcter is $charcter 
		if [ "$charcter" == "d" ]
		then
			if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
			then
				pathnow=$pathnow$word
			else	
				pathnow=$pathnow/$word
			fi
			echo $pathnow
			((niveau=$niveau+1))
			echo "next niveau is $niveau"
			lsd $word
		elif [ "$charcter" == "-" ]
		then
			headtailfile=$(cat dirnow| grep $word)
			headfile=$(echo $headtailfile|cut -d' ' -f4)
			longfile=$(echo $headtailfile|cut -d' ' -f5)		#le nb in contenu main		
			echo $longfile
			headcontenu=$(cat archive/archive|head -1| cut -d':' -f2)
			((headfiletrue=$headfile+$headcontenu-1))
			((tailfiletrue=$headfiletrue+$longfile-1))
			cat -n archive/archive|head -$tailfiletrue|tail -$longfile
			cat -n archive/archive|head -$tailfiletrue|tail -$longfile| cut -d'	' -f 1 >> numligne
		fi
	fi 
done
if [ $niveau -gt 0 ]
then
	((niveau=$niveau-1))
	echo "back to niveau $niveau"
	if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
	then
		echo $pathnow
	else	
		pathnow=$(echo $pathnow| sed 's#^\(.*\)/[^/]*#\1#g')
		if [ "$pathnow/" == "$(echo $paths| cut -d ' ' -f 1)" ]
		then
			pathnow=$pathnow/
		fi
		echo $pathnow
	fi
	ctf $pathnow
fi
}       #end of function



if test -e stokage        #start of main
then
rm -r stokage
fi
etat=0 #browse etat choice to continue loop
case $1 in
-list)
cat archive/archive| sed -n '3,/\#/p' >> stokage  #read le archive/archive which in the dir archive
while read ligne
do
	echo $ligne |grep '^[^\#|\@|d]'|cut -d ' ' -f1
done < stokage;;
-browse)                                           #browse main fonction
paths=$(cat $2/archive|grep '^directory'|sed 's/^directory \([^ ]*\)/\1/g')  #all the paths
pathnow=$(echo $paths| cut -d ' ' -f 1)
nomarchive=$2
while [ $etat -eq 0 ]
do
	paths=$(cat $nomarchive/archive|grep '^directory'|sed 's/^directory \([^ ]*\)/\1/g')  #all the paths
	findresult=0
	read -p "vsh:>" cmd
	set $cmd		
		case $1 in
		pwd) echo $pathnow| sed 's#^Exemple/Test\(.*\)$#\1#g';;             #pwd
		cd)                                                                 #cd 
		if [ "$2" == ".." ]
		then
			if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
			then
				echo "/"
			else	
				pathnow=$(echo $pathnow| sed 's#^\(.*\)/[^/]*#\1#g')
				if [ "$pathnow/" == "$(echo $paths| cut -d ' ' -f 1)" ]
				then
					pathnow=$pathnow/
				fi
				echo $pathnow| sed 's#^Exemple/Test\(.*\)$#\1#g'
			fi
		elif [ "$2" == "/" ]
		then
			pathnow=$(echo $paths| cut -d ' ' -f 1)
			echo $pathnow| sed 's#^Exemple/Test\(.*\)$#\1#g'
		else
			if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
			then
				compare=$pathnow$2
			else
				compare=$pathnow/$2
			fi
			for eachpath in $paths
			do
				if [ "$compare" == "$eachpath" ]
				then
					pathnow=$compare
					echo $pathnow| sed 's#^Exemple/Test\(.*\)$#\1#g'
					findresult=1
				fi
			done
			if [ $findresult -eq 0 ]
			then
				echo "no such directory"
			fi
		fi;;
		ls)                                                     #ls fonction  to ensure that only 1 parametre or 2parametre
			while read ligne
			do
				grep -n '^directory .*$' > dirtotal       #make idea to get the head and tail to cut the file
				cat archive/archive|head -1|cut -d':' -f 2 >> dirtotal
				if [ $# == 1 ]
				then
					headtaildir=$(cat dirtotal | grep -A 1 $pathnow$|cut -d ':' -f 1)  #head and tail with 1 para
				else								           #head tail 2paras
					if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
					then
						headtaildir=$(cat dirtotal | grep -A 1 $pathnow$2$|cut -d ':' -f 1)

					else
						headtaildir=$(cat dirtotal | grep -A 1 $pathnow/$2$|cut -d ':' -f 1)
					fi					
				fi
			done < archive/archive
			headdir=$(echo $headtaildir|cut -d ' ' -f 1)
			taildir=$(echo $headtaildir|cut -d ' ' -f 2)
			echo $taildir
			((longdir=$taildir-$headdir))
			echo $longdir
			cat archive/archive| head -$taildir|tail -$longdir > dirnow  #deja cut the file 
			while read ligne                                         #ajouter le / * to file dir
			do
				filedir=$(echo $ligne |grep '^[^\#|\@|d]'|cut -d ' ' -f1)
				fileetat=$(echo $ligne| grep '^[^\#|\@|d]'|cut -d ' ' -f2) 
				if [ "$(echo $fileetat|cut -c 1)" == "d" ]
				then
					echo $filedir/
				fi
				if [ $(echo $fileetat|grep '^-'|grep 'x'|wc -c) -gt 5 ]
				then
					echo $filedir*
				fi
				if [ $(echo $fileetat|grep '^-'|grep -v 'x'|wc -c) -gt 5 ]
				then
					echo $filedir
				fi
			done < dirnow

		;;
		cat)	
			while read ligne                                     #le meme chose comme ls
			do
				grep -n '^directory .*$' > dirtotal       #make idea to get the head and tail to cut the file
											           #head tail 2paras
				if [ "$pathnow" == "$(echo $paths| cut -d ' ' -f 1)" ]
				then
					headtaildir=$(cat dirtotal | grep -A 1 $pathnow$|cut -d ':' -f 1)

				else
					headtaildir=$(cat dirtotal | grep -A 1 $pathnow$|cut -d ':' -f 1)
				fi					
			done < archive/archive
			headdir=$(echo $headtaildir|cut -d ' ' -f 1)
			taildir=$(echo $headtaildir|cut -d ' ' -f 2)
			((longdir=$taildir-$headdir))
			echo $longdir
			cat archive/archive| head -$taildir|tail -$longdir > dirnow       #end of copy as ls
			catlist=$(cat dirnow|grep -v '^directory'|grep -v '^@'|grep -v '^[^ ]* d'|cut -d ' ' -f 1) #just file
			for word in $catlist
			do
				if [ "$2" == "$word" ]
				then
					headtailfile=$(cat dirnow| grep $word)
					headfile=$(echo $headtailfile|cut -d' ' -f4)
					longfile=$(echo $headtailfile|cut -d' ' -f5)		#le nb in contenu main		
					echo $longfile
					headcontenu=$(cat archive/archive|head -1| cut -d':' -f2)
					((headfiletrue=$headfile+$headcontenu-1))
					((tailfiletrue=$headfiletrue+$longfile-1))
					cat archive/archive|head -$tailfiletrue|tail -$longfile
				fi 
			done
		;;
		rm)
			niveau=0
			put=$2
			lsd $put
			changeheadcontenu=$headcontenu
			for preparedelete in $(sort -nru numligne)
			do
				echo $preparedelete
				if [ $headcontenu -gt $preparedelete ]
				then
					((changeheadcontenu=changeheadcontenu-1))
					sed -i "$preparedelete"d $nomarchive/archive
				else
					sed -i "$preparedelete s/^.*$/ /g" $nomarchive/archive					 
				fi
				
			done	
			sed "s/^\(.*:\)[^:]*$/\1$changeheadcontenu/g"
		;;
		esc) exit; ;;
		esac
done;;
*)      echo "wrong choice please retry again";;
esac
