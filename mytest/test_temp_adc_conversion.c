#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int giTemp2ADC_test_dataA[] = {

	-80, -55  , -12, 0 , 134 , 228 , 306 , 387 ,450, 481 , 503 , 609,690, 734 
};
#if 1
int giADC2Temp_test_dataA[] = {

	1518 , 3260 , 3061 ,3534,3406, 2079 , 1822,1588 ,  1598 ,1609 , 1613 ,1619, 1625 , 1631 ,1630 
};
#else
int giADC2Temp_test_dataA[] = {

	214 , 329 , 339 ,384,405, 568 , 788,  1020 , 2222, 3205 ,3158, 3500
};
#endif


typedef struct tagBAT_TEMP_ADC {
	int iDegree;
	int iADC_val;
} BAT_TEMP_ADC;

#if 1
static BAT_TEMP_ADC gtBatTempADCA[]={
	{-20,3230},
	{0,3158},
	{50,2978},
	{80,2841},
	{150,2494},
	{250,1988},
	{350,1492},
	{400,1280},
	{450,1079},
	{480,981},
	{500,912},
	{550,766},
	{600,637},
	{650,531},
	{700,443},
};
#else
static BAT_TEMP_ADC gtBatTempADCA[]={
	{-20,3230},
	{0,3158},
	{50,2894},
	{80,2768},
	{150,2413},
	{250,1859},
	{350,1501},
	{400,1435},
	{480,1425},
	{500,1420},
	{600,620},
	{700,384},
};
#endif 

#define BAT_ADC_CONV_ADC2TEMP	1
#define BAT_ADC_CONV_TEMP2ADC	2
static int _battery_adctemp_convert(int convert_val,int convert_type)
{
	int i;
	int iTemp10D=-1;
	int iGot;

	int bat_temp_adc;

	if(BAT_ADC_CONV_ADC2TEMP==convert_type) {
		int iStepDegree10000;

		bat_temp_adc = convert_val;

		iGot=0;
		for(i=1;i<sizeof(gtBatTempADCA)/sizeof(gtBatTempADCA[0]);i++)
		{
			iStepDegree10000 = 
				(gtBatTempADCA[i].iDegree-gtBatTempADCA[i-1].iDegree)*10000/
				(gtBatTempADCA[i-1].iADC_val-gtBatTempADCA[i].iADC_val);
			
#if 0
			printf("temp(%d~%d),adc(%d~%d),iStepDegree1000=%d\n",
				gtBatTempADCA[i-1].iDegree,gtBatTempADCA[i].iDegree,
				gtBatTempADCA[i-1].iADC_val,gtBatTempADCA[i].iADC_val,
				iStepDegree10000);
#endif

			if( bat_temp_adc >= gtBatTempADCA[i-1].iADC_val ) {
				iTemp10D = (gtBatTempADCA[i-1].iDegree)-((bat_temp_adc-gtBatTempADCA[i-1].iADC_val)*iStepDegree10000/10000);
				iGot = 1;
				break;
			}
			else if( bat_temp_adc >= gtBatTempADCA[i].iADC_val ) {
				iTemp10D = (gtBatTempADCA[i].iDegree)-((bat_temp_adc-gtBatTempADCA[i].iADC_val)*iStepDegree10000/10000);
				iGot = 1;
				break;
			}
			
		}

		if(!iGot) {
			// ADC < min value , max termperature .
			//iTemp10D = gtBatTempADCA[i-1].iDegree; // limited with max temperature .
			iTemp10D = (gtBatTempADCA[i-1].iDegree)+((gtBatTempADCA[i-1].iADC_val-bat_temp_adc)*iStepDegree10000/10000);
		}

		return iTemp10D;

	}
	else if(BAT_ADC_CONV_TEMP2ADC==convert_type) {
		int iStepADCper0p1D;

		iTemp10D = convert_val;

		iGot = 0;
		for(i=1;i<sizeof(gtBatTempADCA)/sizeof(gtBatTempADCA[0]);i++)
		{
			
			iStepADCper0p1D = 
				(gtBatTempADCA[i-1].iADC_val-gtBatTempADCA[i].iADC_val)/
				((gtBatTempADCA[i].iDegree)-(gtBatTempADCA[i-1].iDegree));
#if 0
			printf("temp(%d~%d),adc(%d~%d),iStepADCper0p1D=%d\n",
				gtBatTempADCA[i-1].iDegree,gtBatTempADCA[i].iDegree,
				gtBatTempADCA[i-1].iADC_val,gtBatTempADCA[i].iADC_val,
				iStepADCper0p1D);
#endif

			if( iTemp10D <= gtBatTempADCA[i-1].iDegree ) {
				bat_temp_adc = (gtBatTempADCA[i-1].iADC_val)+(((gtBatTempADCA[i-1].iDegree)-iTemp10D)*iStepADCper0p1D);
				iGot = 1;
				break;
			}

			if( iTemp10D <= gtBatTempADCA[i].iDegree ) {
				bat_temp_adc = (gtBatTempADCA[i].iADC_val)+(((gtBatTempADCA[i].iDegree)-iTemp10D)*iStepADCper0p1D);
				iGot = 1;
				break;
			}
		}

		if(!iGot) {
			// Temperature > max value . 
			bat_temp_adc = (gtBatTempADCA[i-1].iADC_val)-((iTemp10D-(gtBatTempADCA[i-1].iDegree))*iStepADCper0p1D);
		}


		return bat_temp_adc;
	}
	else {
		return -1;
	}

}

typedef struct tagConvType {
	int iConvType;
	char *szConvTypeName;
}ConvType;

static ConvType gtConvTypeA[] = {
	{BAT_ADC_CONV_ADC2TEMP,"ADC2TEMP"},
	{BAT_ADC_CONV_TEMP2ADC,"TEMP2ADC"},
};

static int GetConvTypeByName(const char *szConvTypeName)
{
	int i;
	int iConvType = -1;
	for(i=0;i<sizeof(gtConvTypeA)/sizeof(gtConvTypeA[0]);i++) {
		if(0==strcmp(gtConvTypeA[i].szConvTypeName,szConvTypeName)) {
			iConvType = gtConvTypeA[i].iConvType; 
		}
	}
	return iConvType;
}


int main(int argc,char **argv)
{
	int i;
	

	//printf("%s, argc=%d\n",__func__,argc);
	if(argc==1) {

		printf("\n==== test adc convert to temp ====>\n");
		for(i=0;i<sizeof(giADC2Temp_test_dataA)/sizeof(giADC2Temp_test_dataA[0]);i++) {
			printf("temp adc=%d,temp=%d\n",giADC2Temp_test_dataA[i],_battery_adctemp_convert(giADC2Temp_test_dataA[i],BAT_ADC_CONV_ADC2TEMP));
		}

		printf("\n==== test temp convert to adc ====>\n");
		for(i=0;i<sizeof(giTemp2ADC_test_dataA)/sizeof(giTemp2ADC_test_dataA[0]);i++) {
			printf("temp=%d,adc=%d\n",giTemp2ADC_test_dataA[i],_battery_adctemp_convert(giTemp2ADC_test_dataA[i],BAT_ADC_CONV_TEMP2ADC));
		}
	}
	else if( argc==3 ) {
		int iConvType ;
		int iVal;

		iConvType = GetConvTypeByName(argv[1]);
		if(-1==iConvType) {
			printf("Cannot find ConvTypeName \"%s\"\n",argv[1]);
		}
		else {

			iVal = atoi(argv[2]);

			switch (iConvType) {
			case BAT_ADC_CONV_ADC2TEMP:
				printf("adc = %d , temp = %d\n",iVal,_battery_adctemp_convert(iVal,BAT_ADC_CONV_ADC2TEMP));
				break;
			case BAT_ADC_CONV_TEMP2ADC:
				printf("temp = %d , adc = %d\n",iVal,_battery_adctemp_convert(iVal,BAT_ADC_CONV_TEMP2ADC));
				break;
			}
		}
		
	}
	return 0;
}

