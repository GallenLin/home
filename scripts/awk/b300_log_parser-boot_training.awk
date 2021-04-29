BEGIN {
	boot_count=0
	boot0_rev=""
	dram_lib_versiion=""
	firmware_version_changed=0
	model_dram_MB=1024
}
END {
	printf("reboot times : %d\n",boot_count);
	printf("boot0 revsion : %s\n",boot0_rev); 
	printf("dram lib version : %s\n",dram_lib_version); 
}


/HELLO! BOOT0/{
	boot_count++;
}

/boot0 commit/{
	if(boot_count==1) {
		boot0_rev=$6
	}
	else {
		if(boot0_rev!=$6) {
			printf("[warning] firmware changed !!??\n");
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
