/*
 * Connectivity space
 *
 */
#include <carlsim.h>
#include <stopwatch.h>
#include <sstream>
#include <string>

namespace patch
{
    template < typename T > std::string to_string( const T& n )
    {
        std::ostringstream stm ;
        stm << n ;
        return stm.str() ;
    }
}

int main() {
	//bool is_pstut = false;
	// keep track of execution time
	Stopwatch watch;
	// ---------------- CONFIG STATE -------------------
	int nNeurons_pstut = 100;
		
	double connProb[10] = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};
	int nrows=10; //connProb
	
	double connWeight[25]={  0,2,4,6,8,
							10,12,14,16,18,
							20,22,24,26,28,
							30,32,34,36,38,
							40,42,44,46,48};      
	int ncols=25; //connWeight	
	int randSeed = 1505420798;
	
	CARLsim network("OrderAndDisorder", GPU_MODE, SILENT, 0, randSeed);

	//pstut model : 4-012-1
		float k0=3.5916956523848826;
		float a0=0.009873755940151841;
		float b0=-10.914911940624444;
		float d0=120.0;
		float C0=195.0;
		float vr0=-63.500227564101365;
		float vt0=-46.58951988218102;
		float vpeak0=11.38098396907138;
		float c0=-50.61623937186045;

		int** pstutGroup;
		pstutGroup= new int* [nrows];

		for(int i=0;i<nrows;i++){
			pstutGroup[i]=new int[ncols];
		}

		for(int i=0; i<nrows;i++){
			for(int j=0;j<ncols;j++){
				std::cout<<i<<"  ";
				std::string pstutGrpName="PSTUT_"+patch::to_string(i)+"_"+patch::to_string(j);
				pstutGroup[i][j]=network.createGroup(pstutGrpName, nNeurons_pstut, INHIBITORY_NEURON);
				network.connect(pstutGroup[i][j], pstutGroup[i][j], 
								"random", RangeWeight(0,  connWeight[j],connWeight[j]), 
								connProb[i], 
								RangeDelay(1),
								RadiusRF(-1),
								SYN_FIXED);
				network.setNeuronParameters(pstutGroup[i][j], C0, k0, vr0, vt0, a0, b0, vpeak0, c0, d0);
			}
		}

	// ---------------- SETUP STATE -------------------
	// build the network
	watch.lap("setupNetwork");
	network.setConductances(false);

	network.setIntegrationMethod(RUNGE_KUTTA4, 100);
	network.setupNetwork();
	
	for(int i=6; i<7;i++){
		for(int j=0;j<ncols;j++){
			//I=175 for 2-periodic
			//I=200 for single-periodic
			//I=500 for chaotic
			
			network.setExternalCurrent(pstutGroup[i][j], 200);
			network.setSpikeMonitor(pstutGroup[i][j], "DEFAULT");
		}
	}

	// ---------------- RUN STATE -------------------
	watch.lap("runNetwork");
	
	network.runNetwork(120,500);
	
	watch.stop();
	return 0;
}
