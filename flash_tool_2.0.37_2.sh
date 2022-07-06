#!/bin/bash

# 210108 Fix cann't flash Nano AN110 bug.
# 210111 Add two PN AJSC-00000000EE2F0 and AJSC-00000000EF1F2.
# 210112 Add two PN AJSC-00000000RA2H0 and AJSC-00000000RA2H1.
# 210121 Fix R32_4_4_Nano_AN110_Camera_IMX179_J13_1 cann't flash.
# 210126 Add massFlash function.
# 210127 Add PN AJSC-00000000RC3F5 for R32_4_3_Xavier_AX710_No_Camera_function_1.
# Add change folder name function for R32_4_3_Xavier_AX710_No_Camera_function_1.
# 210205 Add PN AJSC-00000000RTCF0 for R32_4_3_Xavier_ACE-T012_V2_1.
# 210208 Release 2.0.17.
# 210219 Fix cann't flash patch for R32_4_3_Xavier_AX710_No_Camera_function_1 Release 2.0.18.
# 210304 Add new PN and release 2.0.19
# 210310 Add new PN for R32_4_4_Xavier_AX720_1.
# 210408 Release 2.0.20.
# 210414 Keep R32_3_1_Xavier_AX720_Camera_IMX290THCV_six_1.
# 20210608 Add R32_5_1_Xavier-NX_AN810_Camera_IMX290_six_1、R32_5_1_Xavier-NX_AN110_1、R32_5_1_Xavier_AX710_1、R32_5_1_Xavier_AX720_1.
# 20210621 Add R32_4_3_Xavier-NX_AN810_Camera_IMX290THCV_six_1 and 20210625 release 2.0.21.
# 20210706 Release R32_5_1_Nano_AN110_1 92-6AN110-4000、92-6AN110-2005、92-6AN110-2006 92-CAN110-2001
# R32_5_1_Xavier_AX720_1 92-6AX720-4000、92-6AX720-4001、92-CAX720-3000
# R32_5_1_Xavier_AX710_1 92-6AX710-4005
# R32_4_4_NANO_AN110_SDK_1 92-6AN110-4003
# 20210707 R32_5_1_Xavier-NX_AN110_1 92-6AN110-4001、92-6AN110-2000、92-6AN110-2001、92-CAN110-2002,20210719 release.
# 20210804 R32_4_4_Xavier-NX_AN810_InnoAGE_1 92-6AN810-3004
# 20210806 Release R32_5_1_Nano_AN110_1、R32_5_1_Xavier-NX_AN110_1
# 20210812 Relesase R32_5_1_Xavier-NX_AN810_Camera_IMX290_six_1 92-6AN810-3003、92-6AN810-3000、92-6AN810-3001、92-6AN810-3002、92-CAN810-3000
# 20211208 Release 2.0.28 add BSP_R32_5_1_Xavier_NX_AIE-CN11_3 FOR MINI M1-NX
# 20211210 Release 2.0.29 add BSP_R32_5_1_Xavier_NX_AIE-CN12_2 For MINI M2-NX
# 20220211 Release 2.0.31 add PN 92-6AN110-3003, 92-6AX720-3000, 92-6AX720-4005. For M1-NX add PN 90-CECN11-9000 & 90-CECN11-9002
# 20220218 Release 2.0.32 for R32_6_1_XAVIER_AX720_1
# 20220218 Release 2.0.33 for R32_6_1_Xavier-NX_AN810_1
# 20220418 Release 2.0.34 for R32_7_1_Xavier-NX_AN810_1
# 20220517 Release 2.0.35 for PATCH_R32_6_1_TX2-NX_AIE-CT41_1.tar.gz
# 20220620 Release 2.0.36 for PATCH_R32_6_1_Xavier-NX_JCF01_1
# 20220630 Release 2.0.37 for PATCH_R32_7_1_XAVIER_AX720_1

tool_version=2.0.37

BASEDIR=$(pwd)

Initrd(){

	if ! grep -q "\#INITRD\=\"\"\;" flash.sh
	then
		sed -i 's/INITRD="";/#INITRD="";/' flash.sh
	fi
}

unmount(){

	sudo umount -fl  /media/upload/ > /dev/null 2>&1
	sudo rm -r /media/upload/ > /dev/null 2>&1
}

upload_log(){

	if [ ! -d /media/upload/ ];then
		sudo mkdir /media/upload/ > /dev/null 2>&1
		sudo chmod -R 777 /media/upload/ > /dev/null 2>&1
	fi
	if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
	
		timeout 3 sudo curlftpfs fs02.aetina.corp /media/upload/ -o user=Jetson:Aetina111111,allow_other > /dev/null 2>&1
		echo -e "No timeout"
		
		if [ $? == 124 ] || [ ! -d /media/upload/A000-200101001 ]; then
			echo -e "\n\033[0;031mFTP連線失敗\033[0m\n"
			unmount
			exit 1
		fi
		if [ $? -eq 0 ]; then
			if [ ! -d /media/upload/$orderid ];then
				mkdir /media/upload/$orderid > /dev/null 2>&1
				echo -e "mkdir /media/upload/$orderid > /dev/null 2>&1 finish"
			fi
			sudo chmod -R 777 /media/upload/$orderid > /dev/null 2>&1
			FTPLog=/media/upload/$orderid/Log_${orderid}.txt
			echo -e "FTPLog seting finish"
			if [ -f ${FTPLog} ]; then
				echo "FTPLog exist"
				fileSize=$(stat -c%s ${FTPLog})
				if [ "$(stat -c%s ${FTPLog})" != 0 ]; then
					echo "$(stat -c%s ${FTPLog}) != 0"
					cp $FTPLog $uploadLog
					echo -e "cp $FTPLog $uploadLog finish"
					checkUpload
					echo -e "checkUpload finish"
					unmount
				else
					echo -e "\n\033[0;031mFTP的log檔案毀損\033[0m\n"
					echo -e "若要上傳目前log檔案，請按y\n"
					read cpLog
					if [ $cpLog == "y" ] || [ $cpLog == "Y" ]; then
						checkUpload
						unmount
					fi
				fi
			else
				checkUpload
				unmount
			fi
		else
			echo -e "\n\033[0;031m上傳log檔案失敗\033[0m\n"
			unmount
		fi
	else
		echo -e "\n\033[0;031m請確認網路是否正常\033[0m\n"
		exit 1
	fi

}

checkUpload(){

	cat $addLog >> $uploadLog
	cp -f $uploadLog $FTPLog
	if [ $? -eq 0 ]; then
		echo "" > $addLog
	fi
}

checkPN(){
	setup=""
	case ${PN} in
		AJSC-00000000RE2F2 | AJSC-00000000RE2F3 | 92-6AX720-4002 | 92-CAX720-2004)
		 	dtsName="R32_3_1_Xavier_AX720_Camera_IMX290THCV_six_1"
			;;	
		AJSC-00000000RD303 | AJSC-00000000RA200 | 92-CAN110-2000 | 92-CAT017-2000)
		 	# dtsName="R32_3_1_Nano_AN110_AUO_1"
			dtsName="R32_3_1_Nano_AT017_AUO_1"
			;;
		# New setup file
		AJSC-00000000CA200 | AJSC-00000000EA200 | AJSC-00000000CA2F0 | AJSC-00000000EA2F0 | AJSC-00000000CA2F1 | AJSC-00000000EA2F2 | AJSC-00000000EA2F1 | 92-6AN510-1001 | 92-6AN510-3001 | 92-6AN510-1002 | 92-6AN510-3003 | 92-6AN510-1003 | 92-6AN510-3004 | 92-CAN510-3000)
			dtsName="R32_4_2_TX2_N510_1"
			;;
		AJSC-00000000CA300 | AJSC-00000000EA300 | AJSC-00000000CA3F0 | AJSC-00000000EA3F0 | 92-6AN622-1001 | 92-6AN622-3001 | 92-6AN622-1004 | 92-6AN622-3002)
			dtsName="R32_4_2_TX2_N622_1"
			;;
		MJSC-00000000WD300 | 92-6AN110-5000)
			dtsName="R32_4_3_Xavier-NX_AN110_Camera_IMX290_Dual_1"
			;;
		MJSC-00000000WF100 | AJSC-00000000RF1F0 | 92-6AN810-5000 | 92-CAN810-2000)
			dtsName="R32_4_3_Xavier-NX_AN810_1"
			;;	
		AJSC-00000000RB200 | AJSC-00000000RB201 | AJSC-00000000RB202 | AJSC-00000000RB203 | AJSC-00000000RB204 | AJSC-00000000RB205 | AJSC-00000000MB200 | 92-6AN310-4001 | 92-6AN310-4002 | 92-CAN310-4000 | 92-6AN310-4003 | 92-6AN310-4004 | 92-6AN310-4005 | 92-6AN310-4000)
			dtsName="R32_4_3_TX2_N310_Camera_IMX290_six_1"
			;;
		AJSC-00000000RB206 | 92-6AN310-4006)
			dtsName="R32_4_3_TX2_N310_Camera_IMX334ISP_1"
			;;
		AJSC-00000000AT017 | AJSC-00000000RA201 | 92-CAT017-2001)
			dtsName="R32_4_3_Xavier-NX_AT017_AUO_1"
			;;
		AJSC-00000000RD3F3 | 92-6AN110-2003 )
			dtsName="R32_4_4_Xavier-NX_AN110_Camera_IMX290_Dual_1"
			;;
		AJSC-00000000RD3F2 | 92-6AN110-2002)
			dtsName="R32_4_4_Xavier-NX_AN110_Camera_IMX179_J13_1"
			;;
		AJSC-00000000RD3H2 | 92-6AN110-2007)
			dtsName="R32_4_4_Nano_AN110_Camera_IMX179_J13_1"
			;;
		AJSC-00000000RD3H3 | 92-6AN110-2008)
			dtsName="R32_4_4_Nano_AN110_Camera_IMX290_Dual_1"
			;;
		AJSC-00000000RA2H1 | 92-CAT017-2003)
			dtsName="R32_4_4_Xavier-NX_AT017_1"
			;;
		AJSC-00000000RA2H0 | 92-CAT017-2002)
			dtsName="R32_4_4_Nano_AT017_1"
			;;
		# AJSC-00000000RC3F5 | 92-6AX710-4005)
		# 	dtsName="R32_4_3_Xavier_AX710_No_Camera_function_1"
		# 	;;
		AJSC-00000000RTCF0 | 92-6AT122-4001)
			dtsName="R32_4_3_Xavier_ACE-T012_V2_1"
			;;
		92-6AN110-4003)
			dtsName="R32_4_4_Nano_AN110_SDK_1"
			;;
		92-6AN810-3004)
			dtsName="R32_4_4_Xavier-NX_AN810_InnoAGE_1"
			;;
		# AJSC-00000000RC3F5 | 92-6AX710-4005)
		#  	dtsName="R32_5_1_Xavier_AX710_1"
		# 	;;
		# AJSC-00000000RE2F0 | AJSC-00000000RE2F1 | AJSC-00000000EE2F0 | 92-6AX720-4000 | 92-6AX720-4001 | 92-CAX720-3000 | 92-6AX720-3000 | 92-6AX720-4005)
		#  	dtsName="R32_5_1_Xavier_AX720_1"
		# 	;;
		AJSC-00000000RD301 | AJSC-00000000RD305 | AJSC-00000000RD3F0 | AJSC-00000000RD3F1 | 92-6AN110-4001 | 92-CAN110-2002 | 92-6AN110-2000 | 92-6AN110-2001 | 92-6AN110-3003)
		 	dtsName="R32_5_1_Xavier-NX_AN110_1"
			;;	
		AJSC-00000000EF100 | AJSC-00000000EF1F0 | AJSC-00000000EF1F1 | AJSC-00000000EF1F2 | 92-6AN810-3000 | 92-6AN810-3001 | 92-6AN810-3002 | 92-CAN810-3000 |92-6AN810-3003)
		 	dtsName="R32_5_1_Xavier-NX_AN810_Camera_IMX290_six_1"
			;;
		AJSC-00000000RD300 | AJSC-00000000RD3H0 | AJSC-00000000RD3H1 | AJSC-00000000RD304 | 92-6AN110-4000 | 92-6AN110-2005 | 92-6AN110-2006 | 92-CAN110-2001)
			dtsName="R32_5_1_Nano_AN110_1"
			;;
		41-780000-CBD1 | 41-880801-CBD1)
			dtsName="R32_6_1_TX2-NX_AT017_1"
			;;
		41-770901-CB33 | 90-CECN11-9000 | 90-CECN11-9002)
			dtsName="R32_5_1_Xavier_NX_AIE-CN11_3"
			;;
		41-770C01-CB32)
			dtsName="R32_5_1_Xavier_NX_AIE-CN12_2"
			;;
		41-730000-CBD0 | 41-831201-CBD1)
			dtsName="R32_6_1_XAVIER_AX720_PNY_1"
			;;
		41-830601-CBD1)
			dtsName="R32_6_1_XAVIER_AX720_1"
			;;
        41-870701-CBD1)
            dtsName="R32_6_1_Xavier-NX_AN810_1"
            ;;
        41-870701-CC71)
            dtsName="R32_7_1_Xavier-NX_AN810_1"
            ;;
        92-CECT41-9001)
            dtsName="R32_6_1_TX2-NX_AIE-CT41_1"
            ;;
		41-871501-CBD1)
			dtsName="R32_6_1_Xavier-NX_JCF01_1"
			;;
        41-830601-CC71 | 92-6AX720-4001 | A513-220615002 | 92-CAX720-3002)
            dtsName="R32_7_1_XAVIER_AX720_1"
            ;;
		*)
			echo -e "\n\033[0;31m不支援品號 ${PN}\033[0m"
			unmount
			exit 1
			;;
	esac
}

changeFolder(){

	if [ $dtsName == "R32_3_1_Nano_AT017_AUO_1" ]; then
		mv JetPack_4.3_Linux_P3448-0020 JetPack_4.3_Linux_JETSON_NANO
	fi
}

Check_file(){

	echo "工單號碼	:" $orderid | tee -a $log $addLog
	echo "品號		:" $PN | tee -a $log $addLog

	Version=${dtsName:0:7}

	# Patch file path
	patchPath=$BASEDIR/${dtsName}.tar.gz
	
	case ${id} in
		7721)
			echo "Module      : TX1" | tee -a $log $addLog
			Module="tx1"
			mfiName=mfi_jetson-tx1
			boardName=t210ref			
			tx=1
			sdkFolder=64_TX$tx
			Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra_tx$tx
			oldPN="old"

			case $dtsName in
				R24_2_1_TX1_N621_1)
					BSP="R24_2_1_TX1.tar.gz"
					Patch="R24_2_1_TX1_N621_1.tar.gz"
					;;
				R28_1_0_TX1_N510_1)
					BSP="R28_1_0_TX1_1.tar.gz"
					Patch="R28_1_0_TX1_N510_1.tar.gz"
					;;
				R28_2_TX2_N62X_cfg3_1)
					BSP="R28_2_1_TX2.tar.gz"
					Patch="R28_2_TX2_N62X_cfg3_1.tar.gz"
					;;
				*)
					echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
					unmount
					exit 1
					;;
			esac
			;;

		7c18)
			echo "Module      : TX2" | tee -a $log $addLog
			Module="tx2"
			mfiName=mfi_jetson-tx2
			boardName=t186ref
			nvDtb=tegra186-quill-p3310-1000-c03-00-base
			patchDfDTB=R32_3_1_TX2_N310_Camera_IMX334_1

			case $Version in
				R28_1_1)
					tx=2
					oldPN="old"
					sdkFolder=64_TX$tx
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra_tx$tx

					case $dtsName in
						R28_1_1_TX2_N510_1)
							BSP="R28_1_1_TX2.tar.gz"
							Patch="R28_1_1_TX2_N510_1.tar.gz"
							;;
						R28_1_1_TX2_N621_cfg3_1)
							BSP="R28_1_1_TX2.tar.gz"
							Patch="R28_1_1_TX2_N621_cfg3_1.tar.gz"
							;;
						R28_1_1_TX2_N621_cfg4_1)
							BSP="R28_1_1_TX2.tar.gz"
							Patch="R28_1_1_TX2_N621_cfg4_1.tar.gz"
							;;
						R28_1_2_TX2_N510_1)
							BSP="R28_1_2_TX2.tar.gz"
							Patch="R28_1_2_TX2_N510_1.tar.gz"
							;;
						R28_1_2_TX2_N62X_cfg3_1)
							BSP="R28_1_2_TX2.tar.gz"
							Patch="R28_1_2_TX2_N62X_cfg3_1.tar.gz"
							echo
							;;
						R28_1_2_TX2_N621_cfg4_1)
							BSP="R28_1_2_TX2.tar.gz"
							Patch="R28_1_2_TX2_N621_cfg4_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;

				R28_2_1)
					tx=2
					sdkFolder=64_TX$tx
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					case $dtsName in
							R28_2_1_TX2_N310_Camera_IMX290_2)
							BSP="R28_2_1_TX2_Camera_IMX290_1.tar.gz"
							Patch="R28_2_1_TX2_N310_Camera_IMX290_2.tar.gz"
							;;
						R28_2_1_TX2_N310_Camera_IMX334_0)
							BSP="R28_2_1_TX2_Camera_IMX290_1.tar.gz"
							Patch="R28_2_1_TX2_N310_Camera_IMX334_0.tar.gz"
							;;
						R28_2_1_TX2_N310_Camera_IMX334_M12MO_0)
							BSP="R28_2_1_TX2_Camera_IMX290_1.tar.gz"
							Patch="R28_2_1_TX2_N310_Camera_IMX334_M12MO_0.tar.gz"
							;;		
						R28_2_1_TX2_N510_1)
							BSP="R28_2_1_TX2_1.tar.gz"
							Patch="R28_2_1_TX2_N510_1.tar.gz"
							;;
						R28_2_1_TX2_N62X_1)
							BSP="R28_2_1_TX2_1.tar.gz"
							Patch="R28_2_1_TX2_N62X_1.tar.gz"
							;;

						R28_2_1_TX2_N622_Avalue_2)
							BSP="R28_2_1_TX2_N622_Avalue_2.tar.gz"
							flash_BSP=y
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;

				R32_3_1)
					sdkFolder=JetPack_4.3_Linux_P3310
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_3_1_TX2.tar.gz"
					Patch="R32_3_1_TX2_N310_1.tar.gz"
					case $dtsName in
						R32_3_1_TX2_N310_Camera_IMX290_1)
							;;
						R32_3_1_TX2_N310_Camera_IMX290_six_1)
							;;
						R32_3_1_TX2_N310_Camera_IMX334_M12MO_1)
							;;
						R32_3_1_TX2_N510_1)
							Patch="R32_3_1_TX2_N510_1.tar.gz"
							;;
						R32_3_1_TX2_N622_1)
							Patch="R32_3_1_TX2_N622_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					patchPath=$BASEDIR/${Patch}
					;;
				R32_4_2)
					sdkFolder=JetPack_4.4_DP_Linux_DP_JETSON_TX2
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra
					BSP="R32_4_2_TX2.tar.gz"

					case $dtsName in
						R32_4_2_TX2_N510_1)
							Patch="R32_4_2_TX2_N510_1.tar.gz"
							;;
						R32_4_2_TX2_N622_1)
							Patch="R32_4_2_TX2_N622_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				R32_4_3)
					sdkFolder=JetPack_4.4_Linux_JETSON_TX2
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_4_3_TX2.tar.gz"
					Patch="R32_3_1_TX2_N310_1.tar.gz"

					case $dtsName in
						R32_4_3_TX2_N310_Camera_IMX290_six_1)
							Patch="R32_4_3_TX2_N310_Camera_IMX290_six_1.tar.gz"
							;;
						R32_4_3_TX2_N310_Camera_IMX334ISP_1)
							Patch="R32_4_3_TX2_N310_Camera_IMX334ISP_1.tar.gz"
							;;	
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				R32_6_1)
					sdkFolder=JetPack_4.6_Linux_JETSON_TX2_TARGETS
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra
					
					case $dtsName in
						R32_6_1_TX2-NX_AT017_1)
							Module="tx2-nx"
							BSP="BSP_R32_6_1_TX2-NX_1.tar.gz"
							Patch="R32_6_1_TX2-NX_AT017_1.tar.gz"
							#mfiName & patchDfDTB & boardName don't have to care
							;;
                        R32_6_1_TX2-NX_AIE-CT41_1)
                            Module="tx2-nx"
                            BSP="BSP_R32_6_1_TX2-NX_1.tar.gz"
                            Patch="PATCH_R32_6_1_TX2-NX_AIE-CT41_1.tar.gz"
                            ;;
                        *)
                            echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				*)
					echo -e "\n\033[0;31m${Module} 不支援 ${Version}\033[0m"
					unmount
					exit 1
					;;
			esac		
			;;
		7418)
			echo "Module      : TX2-4GB" | tee -a $log $addLog
			Module="tx2-4GB"
			mfiName=mfi_jetson-tx2-4gb
			boardName=t186ref
			nvDtb=tegra186-quill-p3489-0888-a00-00-base
			patchDfDTB=R32_2_1_TX2-4GB_N310_0

			case $Version in
				R32_2_1)
					sdkFolder=JetPack_4.3_Linux_P3489-0080
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_2_1_TX2-4GB.tar.gz"
					Patch="R32_2_1_TX2-4GB_N310_1.tar.gz"
					case $dtsName in
						R32_2_1_TX2-4GB_N310_1)
							;;									
						R32_2_1_TX2-4GB_N510_1)
							Patch="R32_2_1_TX2-4GB_N510_1.tar.gz"						
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				*)
					echo -e "\n\033[0;31m${Module} 不支援 ${Version}\033[0m"
					unmount
					exit 1
					;;
			esac
			patchPath=$BASEDIR/${Patch}
			;;

		7018)
			echo "Module      : TX2i" | tee -a $log $addLog
			Module="tx2i"
			mfiName=mfi_jetson-tx2i
			boardName=t186ref
			nvDtb=tegra186-quill-p3489-1000-a00-00-ucm1
			patchDfDTB=R32_3_1_TX2i_N310_Camera_IMX334_1
			case $Version in
				R28_2_1)
					tx=2
					sdkFolder=64_TX$tx
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					case $dtsName in
						R28_2_1_TX2i_N310_1)
							BSP="R28_2_1_TX2i_1.tar.gz"
							Patch="R28_2_1_TX2i_N310_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;

				R32_3_1)
					sdkFolder=JetPack_4.3_Linux_P3489
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_3_1_TX2i.tar.gz"
					Patch="R32_3_1_TX2i_N310_1.tar.gz"

					case $dtsName in
						R32_3_1_TX2i_N310_1)
							;;					
						R32_3_1_TX2i_N510_1)
							Patch="R32_3_1_TX2i_N510_1.tar.gz"
							;;
						R32_3_1_TX2i_N622_1)
							Patch="R32_3_1_TX2i_N622_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				*)
					echo -e "\n\033[0;31m${Module} 不支援 ${Version}\033[0m"
					unmount
					exit 1
			esac
			patchPath=$BASEDIR/${Patch}
			;;

		7019)
	#		7e19 for Xavier-8GB
			echo "Module      : Xavier" | tee -a $log $addLog
			Module="xavier"
			mfiName=mfi_jetson-xavier
			boardName=t186ref
			nvDtb=tegra194-p2888-0001-p2822-0000
			patchDfDTB=R32_3_1_Xavier_AX710_Camera_IMX334_1
			case $Version in
				R32_3_1)
					sdkFolder=JetPack_4.3_Linux_JETSON_AGX_XAVIER
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_3_1_Xavier.tar.gz"

					case $dtsName in
						# R32_3_1_Xavier_AX710_1 | R32_3_1_Xavier_AX710_Camera_IMX334_1)
						# 	Patch="R32_3_1_Xavier_AX710_1.tar.gz"
						# 	;;
						# R32_3_1_Xavier_AX720_1)
						# 	Patch="R32_3_1_Xavier_AX720_1.tar.gz"
						# 	;;
						R32_3_1_Xavier_AX720_Camera_IMX290THCV_six_1)
							Patch="R32_3_1_Xavier_AX720_Camera_IMX290THCV_six_1.tar.gz"
							;;						
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				R32_4_3)
					sdkFolder=JetPack_4.4_Linux_JETSON_AGX_XAVIER
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_4_3_Xavier.tar.gz"

					case $dtsName in
						R32_4_3_Xavier_AX710_No_Camera_function_1)
							Patch="R32_4_3_Xavier_AX710_No_Camera_function_1.tar.gz"
							;;
						R32_4_3_Xavier_ACE-T012_V2_1)
							Patch="R32_4_3_Xavier_ACE-T012_V2_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				R32_4_4)
					sdkFolder=JetPack_4.4.1_Linux_JETSON_AGX_XAVIER
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_4_4_Xavier.tar.gz"

					case $dtsName in
						R32_4_4_Xavier_AX720_1)
							Patch="R32_4_4_Xavier_AX720_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				R32_5_1)
					sdkFolder=JetPack_4.5.1_Linux_JETSON_AGX_XAVIER
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_5_1_Xavier.tar.gz"

					case $dtsName in
						R32_5_1_Xavier_AX710_1)
							Patch="R32_5_1_Xavier_AX710_1.tar.gz"
							;;
						R32_5_1_Xavier_AX720_1)
							Patch="R32_5_1_Xavier_AX720_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;								
				R32_6_1)
					sdkFolder=JetPack_4.6_Linux_JETSON_AGX_XAVIER_TARGETS
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					case $dtsName in
						R32_6_1_XAVIER_AX720_PNY_1)
							BSP="BSP_R32_6_1_XAVIER.tar.gz"
							Patch="R32_6_1_XAVIER_AX720_PNY_1.tar.gz"
							Module="agx-xavier"
							;;
						R32_6_1_XAVIER_AX720_1)
							BSP="BSP_R32_6_1_XAVIER.tar.gz"
							Patch="R32_6_1_XAVIER_AX720_1.tar.gz"
							Module="agx-xavier"
							;;
					esac
					;;
                R32_7_1)
                    sdkFolder=JetPack_4.6.1_Linux_JETSON_AGX_XAVIER_TARGETS
                    Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

                    case $dtsName in
                        R32_7_1_XAVIER_AX720_1)
                            BSP="BSP_R32_7_1_XAVIER.tar.gz"
                            Patch="PATCH_R32_7_1_XAVIER_AX720_1.tar.gz"
                            Module="agx-xavier"
                            ;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				*)
					echo -e "\n\033[0;31m${Module} 不支援 ${Version}\033[0m"
					unmount
					exit 1
			esac
			;;
		7e19)
			echo "Module      : Xavier-NX" | tee -a $log $addLog
			Module="xavier-nx"
			mfiName=mfi_jetson-xavier-nx-devkit-emmc
			boardName=t186ref
			nvDtb=tegra194-p3668-all-p3509-0000
			case $Version in
				R32_4_2)
					patchDfDTB=R32_4_2_NX_AN110_Camera_IMX290_Dual_1
					sdkFolder=JetPack_4.4_DP_Linux_DP_JETSON_XAVIER_NX
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_4_2_Xavier-NX.tar.gz"
					Patch="R32_4_2_Xavier-NX_AN110_1.tar.gz"

					case $dtsName in
						R32_4_2_Xavier-NX_AN110_Camera_IMX179_J13_1)
							Patch="R32_4_2_Xavier-NX_AN110_Camera_IMX179_J13_1.tar.gz"
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;
				R32_4_3)
					patchDfDTB=R32_4_3_NX_AN810_1
					sdkFolder=JetPack_4.4_Linux_JETSON_XAVIER_NX
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_4_3_Xavier-NX.tar.gz"
					Patch="R32_4_3_Xavier-NX_AN810_1.tar.gz"

					case $dtsName in
						R32_4_3_Xavier-NX_AN810_1)
							;;
						R32_4_3_Xavier-NX_AN110_1)
							Patch="R32_4_3_Xavier-NX_AN110_1.tar.gz"
							;;	
						R32_4_3_Xavier-NX_AN110_Camera_IMX290_Dual_1)
							Patch="R32_4_3_Xavier-NX_AN110_Camera_IMX290_Dual_1.tar.gz"
							;;
						R32_4_3_Xavier-NX_AN110_Camera_IMX179_J13_1)
							Patch="R32_4_3_Xavier-NX_AN110_Camera_IMX179_J13_1.tar.gz"
							;;
						R32_4_3_Xavier-NX_AT017_AUO_1)
							Patch="R32_4_3_Xavier-NX_AT017_AUO_1.tar.gz"
							;;
						R32_4_3_Xavier-NX_AN810_Camera_IMX290THCV_six_1)
							Patch="R32_4_3_Xavier-NX_AN810_Camera_IMX290THCV_six_1.tar.gz"
							;;				
						*)
							echo -e "\n\033[0;31m${Module}不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
					esac
					;;							
				R32_4_4)
					sdkFolder=JetPack_4.4.1_Linux_JETSON_XAVIER_NX
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_4_4_Xavier-NX.tar.gz"
					Patch="R32_4_4_Xavier-NX_AN810_1.tar.gz"

					case $dtsName in
						R32_4_4_Xavier-NX_AN810_1)
							;;
						R32_4_4_Xavier-NX_AN110_1)
							Patch="R32_4_4_Xavier-NX_AN110_1.tar.gz"
							;;						
						R32_4_4_Xavier-NX_AN110_Camera_IMX290_Dual_1)
							Patch="R32_4_4_Xavier-NX_AN110_Camera_IMX290_Dual_1.tar.gz"
							;;
						R32_4_4_Xavier-NX_AN110_Camera_IMX179_J13_1)
							Patch="R32_4_4_Xavier-NX_AN110_Camera_IMX179_J13_1.tar.gz"
							;;
						R32_4_4_Xavier-NX_AT017_AUO_1)
							Patch="R32_4_4_Xavier-NX_AT017_AUO_1.tar.gz"
							;;
						R32_4_4_Xavier-NX_AT017_1)
							Patch="R32_4_4_Xavier-NX_AT017_1.tar.gz"
							;;
						R32_4_4_Xavier-NX_AN810_InnoAGE_1)
							Patch="R32_4_4_Xavier-NX_AN810_InnoAGE_1.tar.gz"
							;;																		
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;							
					esac
					;;
				R32_5_1)
					sdkFolder=JetPack_4.5.1_Linux_JETSON_XAVIER_NX
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_5_1_Xavier-NX.tar.gz"
					Patch="R32_5_1_Xavier-NX_AN810_Camera_IMX290_six_1.tar.gz"

					case $dtsName in
						R32_5_1_Xavier-NX_AN110_1)
							Patch="R32_5_1_Xavier-NX_AN110_1.tar.gz"
							;;						
						R32_5_1_Xavier-NX_AN810_Camera_IMX290_six_1)
							Patch="R32_5_1_Xavier-NX_AN810_Camera_IMX290_six_1.tar.gz"
							;;							
						R32_5_1_Xavier_NX_AIE-CN11_3)
							BSP="BSP_R32_5_1_Xavier_NX_AIE-CN11_3.tar.gz"
							flash_BSP=y
							;;
						R32_5_1_Xavier_NX_AIE-CN12_2)
							BSP="BSP_R32_5_1_Xavier_NX_AIE-CN12_2.tar.gz"
							flash_BSP=y
							;;
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;							
					esac
					;;								
                R32_6_1)
                    sdkFolder=JetPack_4.6_Linux_JETSON_XAVIER_NX_TARGETS
                    Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

                    BSP="BSP_R32_6_1_Xavier-NX_1.tar.gz"

                    case $dtsName in
                        R32_6_1_Xavier-NX_AN810_1)
                            Patch="R32_6_1_Xavier-NX_AN810_1.tar.gz"
                            ;;
						R32_6_1_Xavier-NX_JCF01_1)
							Patch="PATCH_R32_6_1_Xavier-NX_JCF01_1.tar.gz"
							;;
                        *)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;				
                    esac
                    ;;
                R32_7_1)
                    sdkFolder=JetPack_4.6.1_Linux_JETSON_XAVIER_NX_TARGETS
                    Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra
                    BSP="BSP_R32_7_1_Xavier-NX.tar.gz"

                    case $dtsName in
                        R32_7_1_Xavier-NX_AN810_1)
                            Patch="PATCH_R32_7_1_Xavier-NX_AN810_1.tar.gz"
                            ;;
                        *)
                            echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;
                    esac
                    ;;
				*)
					echo -e "\n\033[0;31m${Module} 不支援 ${Version}\033[0m"
					unmount
					exit 1
					;;
			esac
			;;
		7f21)
			echo "Module      : Nano" | tee -a $log $addLog
			Module="nano"
			mfiName=mfi_jetson-nano-emmc
			boardName=t210ref
			nvDtb=tegra210-p3448-0002-p3449-0000-b00
			patchDfDTB=R32_3_1_Nano_AN110_Camera_IMX334_J8_1
			case $Version in
				R32_3_1)
					sdkFolder=JetPack_4.3_Linux_P3448-0020
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_3_1_Nano.tar.gz"
					Patch="R32_3_1_Nano_AN110_Fan_1.tar.gz"

					case $dtsName in				
						R32_3_1_Nano_AN110_Fan_1 | R32_3_1_Nano_AN110_Camera_IMX290_Dual_Fan_1)
							Patch="R32_3_1_Nano_AN110_Fan_1.tar.gz"
							;;
						R32_3_1_Nano_AN110_Camera_IMX179_J13_Fan_1)
							Patch="R32_3_1_Nano_AN110_Fan_1.tar.gz"
							;;
						R32_3_1_Nano_AT017_AUO_1)
							sdkFolder=JetPack_4.3_Linux_JETSON_NANO
							Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra
							Patch="R32_3_1_Nano_AT017_AUO_1.tar.gz"
							;;							
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"$
							unmount
							exit 1
							;;
					esac
					patchPath=$BASEDIR/${Patch}
					;;
				R32_4_4)
					patchDfDTB=R32_4_4_Nano_AN110_Camera_IMX290_Dual_1
					sdkFolder=JetPack_4.4.1_Linux_JETSON_NANO
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_4_4_Nano.tar.gz"
					Patch="R32_4_4_Nano_AN110_Camera_IMX290_Dual_1.tar.gz"

					case $dtsName in
						R32_4_4_Nano_AN110_Camera_IMX179_J13_1)
							Patch="R32_4_4_Nano_AN110_Camera_IMX179_J13_1.tar.gz"
							;;
						R32_4_4_Nano_AN110_Camera_IMX290_Dual_1)
							Patch="R32_4_4_Nano_AN110_Camera_IMX290_Dual_1.tar.gz"
							;;						
						R32_4_4_Nano_AT017_1)
							Patch="R32_4_4_Nano_AT017_1.tar.gz"
							;;
						R32_4_4_Nano_AN110_SDK_1)
							BSP="R32_4_4_Nano_AN110_SDK_1.tar.gz"
							flash_BSP=y
							;;						
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;							
					esac
					;;
				R32_5_1)
					sdkFolder=JetPack_4.5.1_Linux_JETSON_NANO
					Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra

					BSP="R32_5_1_Nano.tar.gz"
					Patch="R32_5_1_Nano_AN110_1.tar.gz"

					case $dtsName in
						R32_5_1_Nano_AN110_1)
							Patch="R32_5_1_Nano_AN110_1.tar.gz"
							;;						
						*)
							echo -e "\n\033[0;31m不支援 ${dtsName}\033[0m"
							unmount
							exit 1
							;;							
					esac
					;;				
				*)
					echo -e "\n\033[0;31m${Module} 不支援 ${Version}\033[0m"
					unmount
					exit 1
					;;
			esac
			;;
		*)
			echo -e "\n\033[1;31m不支援此module\033[0m"
			unmount
			exit 1
			;;
	esac
	untar ${BSP} ${Patch} ${nvDtb} ${patchDfDTB} ${Linux_for_Tegra} ${dtsName} ${Version}
}

untar(){
 
	BSPName=${BSP%%.tar.gz*}
    if [ ${Version} == "R32_7_1" ]; then
        PatchName=${Patch%%.tar.gz}
    else
        if [ ${dtsName} == "R32_6_1_TX2-NX_AIE-CT41_1" ] || [ ${dtsName} == "R32_6_1_Xavier-NX_JCF01_1" ]
        then
            PatchName=${Patch%%.tar.gz}
        elif [ ${dtsName} == "R32_7_1_XAVIER_AX720_1" ]
        then
            PatchName=${Patch%%.tar.gz}
        else
            PatchName=${dtsName}
        fi
    fi

    echo "BSP = ${BSP}"
    echo "PATCH = ${Patch}"
	imgPath=$BASEDIR/${Linux_for_Tegra}/bootloader/system.img.raw
    oldimgPath=$BASEDIR/${Linux_for_Tegra}/bootloader/system.img.raw # for old version

	if [ -f $imgPath ] && [ -f $patchPath ] # system.img.raw and patch folder are exist.
	then
		echo -e "\n壓縮檔驗證...開始...請稍後!\n"
		if md5sum -c $PatchName.md5sum | egrep -w -q '正確|OK' #Check md5 is right
		then
			cd $BASEDIR
			# 刪除殘留camera overrides isp與test_tool
			sudo rm -rf $BASEDIR/${Linux_for_Tegra}/rootfs/var/nvidia/nvcam/settings/
			sudo rm -rf $BASEDIR/${Linux_for_Tegra}/rootfs/opt/aetina/
			sudo chmod +x $Patch
			echo -e "\n解壓縮...開始...請稍後!\n"
			sudo tar -xvpzf $Patch -C . --numeric-owner
			changeFolder
			echo -e "\n已解壓縮完成\n"
			check_flash ${Version} ${flash_BSP} ${BSP} ${dtsName}
		else
			echo -e "\n\033[0;31m壓縮檔驗證錯誤\033[0m\n"
			unmount
			exit 1
		fi
	elif [ -f $BASEDIR/$BSP ] && [ -f $BASEDIR/$Patch ]
	then
		echo -e "\n壓縮檔驗證...開始...請稍後!\n"
		echo "PatchName: ${PatchName}"
		if md5sum -c $BSPName.md5sum && md5sum -c $PatchName.md5sum | egrep -w -q '正確|OK'
		then
			cd $BASEDIR
			sudo chmod +x $BSP $Patch
			echo -e "\n解壓縮...開始...請稍後!\n"
			sudo tar -xvpzf $BSP -C . --numeric-owner
			changeFolder
			sudo tar -xvpzf $Patch
			echo -e "\n已解壓縮完成\n"
			check_flash ${Version} ${flash_BSP} ${BSP} ${dtsName}
		else
			echo -e "\n\033[0;31m壓縮檔驗證錯誤\033[0m\n"
			unmount
			exit 1
		fi
	elif [ -f $BASEDIR/$BSP ] && [ ! -f $BASEDIR/$Patch ]
	then
		if  [ "$flash_BSP" == "y" ]
		then
			if md5sum -c $BSPName.md5sum | egrep -w -q '正確|OK'
			then
				cd $BASEDIR
				sudo chmod +x $BSP
				echo -e "\n解壓縮...開始...請稍後!\n"
				sudo tar -xvpzf $BSP -C . --numeric-owner
				changeFolder
				echo -e "\n已解壓縮完成\n"
				check_flash ${Version} ${flash_BSP} ${BSP} ${dtsName}
			fi
		else
			echo -e "\n\033[0;31m$Patch patch壓縮檔不存在\033[0m\n"
			unmount
			exit 1
		fi
	elif [ ! -f $BASEDIR/$BSP ] && [ -f $BASEDIR/$Patch ]
	then
		echo -e "\n\033[0;31m$BSP BSP壓縮檔不存在\033[0m\n"
		unmount
		exit 1
	else
		echo -e "\n\033[0;31mBSP & Patch壓縮檔不存在\033[0m\n"
		unmount
		exit 1
	fi
}

check_flash(){
	if [ "$oldPN" == "old" ]
	then
		Flash_old ${Version} ${flash_BSP}
	else
		Flash ${Version} ${flash_BSP} ${BSP} ${dtsName}
	fi
}

Flash_old(){
	md5_BSP=${BSP%%.*} 
	md5_Patch=${Patch%%.*}
	setup_n=${md5_Patch:12}
	setup_n=${setup_n%_*}
	cd $BASEDIR
	
	tx_=tx$tx
	if [ $tx_ == "tx1" ]
	then
		if  [ $BSP == "y" ]
		then
			cd ${Linux_for_Tegra}
			chmod +x flash.sh
			sudo ./flash.sh jetson-tx$tx mmcblk0p1
			echo -e "$(date +"Finish time : %Y-%m-%d %H:%M.%S")\n" | tee -a $log $addLog
			sudo gedit $log
		else
			chmod +x setup.sh
			if ./setup.sh $tx_ $setup_n"_cfg4" | egrep -w -q 'Done'
			then
				echo -e "\nPatch檔案安裝完成\n"
				sudo rm -rf "64_TX"$tx"_patch" setup.sh
				cd ${Linux_for_Tegra}
				chmod +x flash.sh
				sudo ./flash.sh jetson-tx$tx mmcblk0p1
				echo -e "$(date +"Finish time : %Y-%m-%d %H:%M.%S")\n" | tee -a $log $addLog
				sudo gedit $log

			else
				echo -e "\n\033[0;31mPatch檔案安裝失敗\033[0m\n"
				unmount
				exit 1
			fi
		fi
	else
		if  [ "$flash_BSP" == "y" ]
		then
			cd ${Linux_for_Tegra}
			chmod +x flash.sh
			sudo ./flash.sh jetson-tx$tx mmcblk0p1
			echo -e "$(date +"Finish time : %Y-%m-%d %H:%M.%S")\n" | tee -a $log $addLog
			sudo gedit $log
		else
			chmod +x setup.sh
			if ./setup.sh $tx_ $setup_n | egrep -w -q 'Done'
			then
				echo -e "\nPatch檔案安裝完成\n"
				sudo rm -rf "64_TX"$tx"_patch" setup.sh
				cd ${Linux_for_Tegra}
				chmod +x flash.sh
				sudo ./flash.sh jetson-tx$tx mmcblk0p1
				echo -e "$(date +"Finish time : %Y-%m-%d %H:%M.%S")\n" | tee -a $log $addLog
				sudo gedit $log
			else
				echo -e "\n\033[0;31mPatch檔案安裝失敗\033[0m\n"
				unmount
				exit 1
			fi
		fi
	fi
}

Flash(){
	if [ ${Version} == "R32_7_1" ]; then
        patch_file=$dtsName
        if [ $dtsName == "R32_7_1_XAVIER_AX720_1" ]; then
            patch_file="R32_7_1_XAVIER_64G_AX720_1"
        fi
    elif [ ${dtsName} == "R32_6_1_TX2-NX_AIE-CT41_1" ]; then
        patch_file="R32_6_1_TX2_NX_AIE-CT41"
	elif [ ${dtsName} == "R32_6_1_Xavier-NX_JCF01_1" ]; then
		patch_file="R32_6_1_Xavier-NX_JCF01_1"
    else
        patch_file=${Patch%%.*}
    fi

	if [ $dtsName == "R32_4_3_Xavier_AX710_No_Camera_function_1" ]; then
		patch_file=R32_4_3_Xavier_AX710_1
	elif [ $dtsName == "R32_4_3_Xavier_ACE-T012_V2_1" ]; then
		patch_file=R32_4_3_Xavier_T012_V2_1
	elif [ $dtsName == "R32_6_1_XAVIER_AX720_PNY_1" ]; then
		patch_file="BSP_R32_6_1_XAVIER_AX720_PNY_1"
	elif [ $dtsName == "R32_6_1_XAVIER_AX720_1" ]; then
		patch_file="BSP_R32_6_1_XAVIER_AX720_1"
	fi

	# if [ "${flash_BSP}" != "y" ]; then
    # 	cd $BASEDIR/$patch_file
	# fi

	if  [ "${flash_BSP}" == "y" ]
	then
		cd ${Linux_for_Tegra}
		chmod +x flash.sh
		if [ ${BSP%%_*} == "R28" ]
		then
			Initrd
		fi
		if [ $Module == "nano" ]
		then
			sudo ./flash.sh jetson-${Module}-emmc mmcblk0p1
		elif [ $Module == "xavier-nx" ]
		then
			sudo ./flash.sh jetson-${Module}-devkit-emmc mmcblk0p1			
		elif [ $Module == "agx-xavier" ]
		then
			sudo ./flash.sh jetson-${Module}-devkit mmcblk0p1		
		else
			sudo ./flash.sh jetson-$Module mmcblk0p1
		fi
		echo -e "$(date +"Finish time : %Y-%m-%d %H:%M.%S")\n" | tee -a $log $addLog
		upload_log ${FTPLog} ${fileSize} # For Aetina Xizhi
		sudo gedit $log
		echo
		read -s -n1 -p "請按任一鍵繼續燒錄..."
		echo
		cd ../../ 
	else
		cd $BASEDIR/$patch_file
		chmod +x setup.sh
		setupMsg="successfully"
		if [ "${setup}" == "old" ] ; then
			setupMsg="Done"
		fi

		if ./setup.sh | egrep -i -w -q "${setupMsg}"
		then
			echo -e "\nPatch檔案安裝完成\n"
			sudo rm -rf setup.sh
			cd ../
			sudo rm -rf $patch_file
			cd ${Linux_for_Tegra}
			chmod +x flash.sh

			VersionSeries=${Version%%_*}

			if [ $Version == "R32_3_1" ]
			then
				if [ $dtsName != "R32_3_1_Xavier_AX720_Camera_IMX290THCV_six_1" ] || [ $dtsName != "R32_3_1_Nano_AT017_AUO_1" ]
				then
					if [ -f $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${nvDtb}.dtb ]
					then
						cp $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${nvDtb}.dtb $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${patchDfDTB}.dtb
						cp -f $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${dtsName}.dtb $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${nvDtb}.dtb
					else
						echo -e "\n\033[0;31mCopy DTB fail.\033[0m\n"
						unmount
						exit 1
					fi
				fi
			fi			

			# Old PN & description use Flash_old
			# if old products are phaseout,then can delete check flash & Flash_old

			echo
			echo "BSP         : ${BSPName}" | tee -a $log $addLog
			echo "Patch       : ${PatchName}" | tee -a $log $addLog
			echo
			#read -s -n1 -p "請按任一鍵繼續..."
			echo
			
			if [ $Module == "nano" ]
			then
				# read -p "nano"
				sudo ./flash.sh jetson-${Module}-emmc mmcblk0p1
			elif [ $Module == "xavier-nx" ]
			then
				# read -p "xavier-nx"
				sudo ./flash.sh jetson-${Module}-devkit-emmc mmcblk0p1
			elif [ $Module == "tx2-nx" ]
			then
				# read -p "tx2-nx"
				sudo ./flash.sh jetson-xavier-nx-devkit-${Module} mmcblk0p1
			elif [ $Module == "agx-xavier" ]
			then
				# read -p "agx-xavier"
				sudo ./flash.sh jetson-${Module}-devkit mmcblk0p1
			else
				# read -p "othres."
				sudo ./flash.sh jetson-$Module mmcblk0p1
			fi

			if [ $? -eq 0 ]; then
				#massFlash
				echo -e "$(date +"Finish time : %Y-%m-%d %H:%M.%S")\n" | tee -a $log $addLog
				upload_log  ${log} ${addLog} ${uploadLog} ${FTPLog} ${fileSize} # For Aetina Xizhi
				echo "upload_log finish"
				sudo gedit $log
				echo "sudo gedit log finish"
				echo
				read -s -n1 -p "請按任一鍵繼續燒錄..."
				echo
				cd ../../
			else
				echo -e "\n燒錄失敗\n" | tee -a $log $addLog
				echo -e "\n\033[0;31m燒錄失敗\033[0m\n"
				unmount
				exit 1
			fi
		else
			echo -e "\n\033[0;31mPatch檔案安裝失敗\033[0m\n"
			unmount
			exit 1
		fi
	fi
}

massFlash(){

	if [ ${Version} == "R32_4_3" ]; then
		cd bootloader/$boardName/cfg/
		sudo mv -f gnu_linux_tegraboot_emmc_full.xml gnu_linux_tegraboot_emmc_full.xml.sav
		cd ../../
		./mkbctpart -G new_config.xml
		mv -f new_config.xml $boardName/cfg/gnu_linux_tegraboot_emmc_full.xml
		cd ../
	fi
	if [ ! -f $BASEDIR/${Linux_for_Tegra}/mfi_${dtsName}.tbz2 ]; then
		usbDevCt=$(lsusb |grep -i "NVIDIA Corp." | wc -l)
		while [ $usbDevCt -gt 2 ]
		do
			echo -e "\n\033[0;31m請勿接上其他Jetson裝置\033[0m\n"
			sleep 3
			usbDevCt=$(lsusb |grep -i "NVIDIA Corp." | wc -l)		
		done
		sudo ./nvmassflashgen.sh ${mfiName} mmcblk0p1
		mv ${mfiName}.tbz2 mfi_${dtsName}.tbz2
	fi
    sudo tar xvjf ${dtsName}.tbz2
    cd ${mfiName}
	while [ $usbDevCt -lt 8 ]
	do
		echo -e "\n\033[0;31m請接上其他Jetson裝置\033[0m\n"
		sleep 3
		usbDevCt=$(lsusb |grep -i "NVIDIA Corp." | wc -l)		
	done	
    sudo ./nvmflash.sh [--showlogs]
}

# Main function

echo
echo Flash tool version $tool_version
echo

sudo rm /var/lib/apt/lists/lock > /dev/null 2>&1
curlftpfs=$(dpkg --list |grep -i curlftpfs) > /dev/null 2>&1

if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
	if [ "$curlftpfs" == "" ];then
		sudo apt-get install curlftpfs -y
	fi
#else
	#echo -e "\n\033[0;031m請確認網路是否正常\033[0m\n"
	#exit 1
fi

while :
do
	if lsusb | egrep -i -w -q "NVidia Corp" #"NVidia Corp"
	then
		until [[ "${scan_ct}" == "29" || "${scan_ct}" == "33" ]]
		do
			echo -e "\n請掃描工單及品號 QR code: \c"
			read scan
			scan_ct=${#scan}
			PN=${scan#* }
			if [ "${PN}" == "test" ]; then
				break
			fi
		done

		if [ "${PN}" == "test" ]; then
			echo -e "請輸入Patch名稱: \c"
			read dtsName
			dtsName=${dtsName} | sed 's/ //g'
		else
			checkPN ${PN}
		fi
		
		id=$(lsusb |grep -i "NVidia Corp.")
		id=${id% NVidia Corp.*}
		id=${id:28:4}
		orderid=${scan%%" "*}
		log=$BASEDIR/Log_${orderid}.txt
		addLog=$BASEDIR/.addLog_${orderid}.txt
		uploadLog=$BASEDIR/.Log_${orderid}.txt
		Check_file ${PN} ${dtsName} ${Version} ${log} ${addLog} ${uploadLog}

	else
		echo -e "\n\033[1;31m尚未進入recovery模式\033[0m\n"
		unmount
		exit 1
	fi

done
