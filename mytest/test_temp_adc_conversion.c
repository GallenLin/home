#include <stdio.h>
#include <stdlib.h>

int giTemp2ADC_test_dataA[] = {

	-80, -55  , -12, 0 , 134 , 228 , 306 , 387 ,450, 481 , 503 , 609,690, 734 
};
int giADC2Temp_test_dataA[] = {

	214 , 329 , 339 ,384,405, 568 , 788,  1020 , 2222, 3205 ,3158, 3500
};


typedef struct tagBAT_TEMP_ADC {
	int iDegree;
	int iADC_val;
} BAT_TEMP_ADC;


static BAT_TEMP_ADC gtBatTempADCA[]={
	{-20,3230},
	{0,3158},
	{50,2894},
	{400,1435},
	{480,1425},
	{500,1420},
	{700,384},
};
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



int main(int argc,char **argv)
{
	int i;

	printf("\n==== test adc convert to temp ====>\n");
	for(i=0;i<sizeof(giADC2Temp_test_dataA)/sizeof(giADC2Temp_test_dataA[0]);i++) {
		printf("temp adc=%d,temp=%d\n",giADC2Temp_test_dataA[i],_battery_adctemp_convert(giADC2Temp_test_dataA[i],BAT_ADC_CONV_ADC2TEMP));
	}

	printf("\n==== test temp convert to adc ====>\n");
	for(i=0;i<sizeof(giTemp2ADC_test_dataA)/sizeof(giTemp2ADC_test_dataA[0]);i++) {
		printf("temp=%d,adc=%d\n",giTemp2ADC_test_dataA[i],_battery_adctemp_convert(giTemp2ADC_test_dataA[i],BAT_ADC_CONV_TEMP2ADC));
	}
	return 0;
}

