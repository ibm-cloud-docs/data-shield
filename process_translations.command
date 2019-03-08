#! /bin/sh

cd "`dirname "$0"`"
source user_config.command

installDir="`dirname "$0"`"

# For every parameters file that exists, run the translation processing script for each
cd "$installDir"
for f in $(ls $installDir/parameters*.command)
do
	
	# Run the parameters file to set the variables.
	source $f
	
	#Get the short name for the repo
	PluginNameShort=${localPluginDir//services\//}
	PluginNameShort=${PluginNameShort//runtimes\//}
	PluginNameShort=${PluginNameShort//starters\//}
	PluginNameShort=${PluginNameShort//infrastructure\//}

	echo "------------------------"
	ECHO $PluginNameShort
	echo $f 
	echo "------------------------"
	
	#If the repo was already cloned, delete it
	if [ -d "$installDir/$PluginNameShort" ] ; then
		rm -rf "$installDir/$PluginNameShort"
	fi 

	#Clone the repo
	GIT clone https://$githubUserID:$githubPassword@github.com/IBM-Bluemix-Docs/$PluginNameShort.git
	cd $PluginNameShort
	GIT init


	cd "$installDir"
	
	languages=( "de" "es" "fr" "it" "ja" "ko" "pt_br" "zh_cn" "zh_tw" )
	
	for lang in "${languages[@]}"
	do
		echo "Language: $lang"
		if [ "$lang" = "pt_br" ] ; then 
			langDownload=pt-BR
			langDir=pt/BR
		elif [ "$lang" = "zh_cn" ] ; then 
			langDownload=zh-Hans
			langDir=zh/CN
		elif [ "$lang" = "zh_tw" ] ; then 
			langDownload=zh-Hant
			langDir=zh/TW
		else
			langDownload=$lang
			langDir=$lang
		fi
		
		
		if [[ "$mergeFiles" == "false" ]]; then
			#Delete the existing nl directory
			rm -R "$installDir/$PluginNameShort/nl/$langDir/"
		fi


		#If the nl directories don't exist, create them 
		if ! [ -d "$installDir/$PluginNameShort/nl/" ] ; then
			echo "Creating $installDir/$PluginNameShort/nl/"
			mkdir "$installDir/$PluginNameShort/nl/"
		fi 

		if [ "$lang" = "pt_br" ] ; then 
			mkdir "$installDir/$PluginNameShort/nl/pt/"
		elif [ "$lang" = "zh_cn" ] ; then 
			mkdir "$installDir/$PluginNameShort/nl/zh/"
		fi

		if ! [ -d "$installDir/$PluginNameShort/nl/$lang/" ] ; then
			echo "Creating $installDir/$PluginNameShort/nl/$lang/"
			mkdir "$installDir/$PluginNameShort/nl/$langDir/"
		fi 
		
		

		pkgURL="https://rtpgsa.ibm.com/projects/c/cfm/CentralNLV/${projectCode}/${chargetoID}/${chargetoID}_${shipmentName}_${shipmentNumber}_${langDownload}${packageExtension}" 
		 
		echo "Start downloading $lang package....."
		echo $pkgURL
		mkdir "$installDir/$PluginNameShort/nl/$lang-returns"
		cd "${installDir}/${PluginNameShort}/nl/${lang}-returns"
		curl -O -# -u $gsaUserID:$gsaUserPassword $pkgURL 

		#sleep 30
		 
		#Change the package extension to zip
		mv "${installDir}/${PluginNameShort}/nl/${lang}-returns/${chargetoID}_${shipmentName}_${shipmentNumber}_${langDownload}${packageExtension}" "${installDir}/${PluginNameShort}/nl/$lang-returns/package.zip"
		 
		#Extract the zip
		unzip "${installDir}/${PluginNameShort}/nl/$lang-returns/package.zip"   
		
	
		

	#Copy the new translated files 
		if [ -d "${installDir}/${PluginNameShort}/nl/$lang-returns/package/${PluginNameShort}/" ]; then
			cp -fR "${installDir}/${PluginNameShort}/nl/$lang-returns/package/${PluginNameShort}"/* "$installDir/$PluginNameShort/nl/$langDir/"
		elif [ -d "${installDir}/${PluginNameShort}/nl/$lang-returns/${PluginNameShort}/" ] ; then
			cp -fR "${installDir}/${PluginNameShort}/nl/$lang-returns/${PluginNameShort}"/* "$installDir/$PluginNameShort/nl/$langDir/"
		elif [ -d "${installDir}/${PluginNameShort}/nl/$lang-returns/package/" ] ; then
			cp -fR "${installDir}/${PluginNameShort}/nl/$lang-returns/package"/* "$installDir/$PluginNameShort/nl/$langDir"
		else
			cp -fR "${installDir}/${PluginNameShort}/nl/$lang-returns"/* "$installDir/$PluginNameShort/nl/$langDir/"
		fi
     
		#Clean up
		find $installDir/$PluginNameShort/nl/$langDir -name '*.tpt' -delete
		find $installDir/$PluginNameShort/nl/$langDir -name 'package.zip' -delete
		find $installDir/$PluginNameShort/nl/$langDir -name 'AITH*.xml' -delete
		cd "${installDir}/${PluginNameShort}"
		rm -rf "$installDir/$PluginNameShort/nl/$lang-returns/"

	done


	ECHO GIT pull https://github.com/IBM-Bluemix-Docs/$PluginNameShort.git
	GIT pull https://$githubUserID:$githubPassword@github.com/IBM-Bluemix-Docs/$PluginNameShort.git

	ECHO GIT add --all
	GIT add --all
	 
	ECHO GIT status
	GIT status

	ECHO GIT commit
	GIT commit -m "$checkInComment"

	ECHO GIT merge
	GIT merge

	ECHO GIT remote add
	GIT remote add $PluginNameShort https://github.com/IBM-Bluemix-Docs/$PluginNameShort.git

	ECHO GIT push $PluginNameShort
	GIT push $PluginNameShort

	cd "$installDir/"
	
done

