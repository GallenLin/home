BEGIN {
	boot_count=0
	boot0_rev=""
	dram_lib_versiion=""
	firmware_version_changed=0
	model_dram_MB=1024
	dram_MB=0
}
END {
	printf("reboot times : %d\n",boot_count);
	printf("boot0 revsion : %s\n",boot0_rev); 
	printf("dram lib version : %s\n",dram_lib_version); 
}


/HELLO! BOOT0/{
	boot_count++;
	dram_MB=0
}

/boot0 commit/{
	if(boot_count==1) {
		boot0_rev=$6
	}
	else {
		if(boot0_rev!=$6) {
			printf("[warning] firmware changed !!?? @line%d\n",NR);
		}
	}
}

/DRAM BOOT DRIVE INFO/{
	if(boot_count==1) {
		dram_lib_version=$7
	}
	else {
	}
}

/initializing SDRAM Fail/{
	printf("initializing SDRAM fail @ line %d , reboot #%d\n",NR,boot_count);
}

/dram size =/{
	dram_MB = strtonum(substr($5,2))
	if(dram_MB!=model_dram_MB) {
		printf("[WARNING] : dram size=%d, it should be %d !\n",dram_MB,model_dram_MB);
	}
	#printf("dram_MB=%d\n",dram_MB);
}

