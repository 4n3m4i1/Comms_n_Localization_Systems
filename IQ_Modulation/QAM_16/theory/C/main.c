#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <inttypes.h>
#include "Q15.h"

#define USE_MATH_DEFINES

// Speed of sound in water
#define SPEED_OF_SOUND      1500    // m/s
// Distance between TX and RX
#define DEFAULT_DISTANCE    10      // m
// Length of simulation
#define SIM_LENGTH_SECONDS  0.1     // s

#define DFL_FS              (1000 * 1000)   // Hz
#define DFL_FC              (100 * 1000)    // Hz
#define DFL_SYMS            (1000)          // Sym/s

struct Transceiver_Properties {
    double Fs;      // Sampling rate of ADC/DAC
    double Ws;
    double Fc;      // Hz of carrier
    double Wc;      // rad/s of carrier
    
    double SymRate; // Symbols per second
    double SymTime; // Time between Symbols
    double Sampling_Point;

    // Distance between TX and RX
    double distance;

    double tx_rx_offset;    // seconds per tx to rx
    double tx_rx_offset_phi;    // radian phase offset
    // Discrete time index offset between tx and rx,
    //  RX referenced
    uint32_t tx_rx_offset_idx;
};

void init_txvr(struct Transceiver_Properties *txvr,
                double Fs,
                double Fc,
                double SymbolRate,
                double speed_of_sound,
                double distance,
                double sampling_point);
void print_txvr_specs(struct Transceiver_Properties *txvr);

  //////////////////////////////////////////////////
 //////////////////////////////////////////////////
//////////////////////////////////////////////////
void main(int argc, char **argv){
    struct Transceiver_Properties txvr;

    double distance = DEFAULT_DISTANCE;
    if(argc > 1){
        distance = strtod(argv[1], NULL);
    }

    init_txvr(&txvr, 
                DFL_FS,
                DFL_FC,
                DFL_SYMS,
                SPEED_OF_SOUND,
                distance,
                0.5);

    print_txvr_specs(&txvr);
}






/*
    Init Functions
*/
void init_txvr(struct Transceiver_Properties *txvr,
                double Fs,
                double Fc,
                double SymbolRate,
                double speed_of_sound,
                double distance,
                double sampling_point){
    if(txvr){
        txvr->Fs = Fs;
        txvr->Ws = 2.0 * M_PI * Fs;
        txvr->Fc = Fc;
        txvr->Wc = 2 * M_PI * Fc;
        txvr->SymRate = SymbolRate;
        txvr->distance = distance;
        txvr->tx_rx_offset = distance / speed_of_sound; // s
        txvr->tx_rx_offset_phi = txvr->Wc * txvr->tx_rx_offset;
        txvr->tx_rx_offset_idx =
                (uint32_t)(round(Fs * txvr->tx_rx_offset));

        txvr->Sampling_Point = sampling_point;
        txvr->SymTime = 1.0 / SymbolRate;
    }
}

void print_txvr_specs(struct Transceiver_Properties *txvr){
    if(txvr){
        printf("\nDistance:\t%lf meters\n", txvr->distance);
        printf("Carrier:\t%lf Hz\n\t\t%lf rad/s\n",
                    txvr->Fc, 
                    txvr->Wc
                    );
        printf("Sampling:\t%lf Hz\n\t\t%lf rad/s\n",
                    txvr->Fs, 
                    txvr->Ws
                    );
        printf("ToA Offset:\t%lf s\n\t\t%lu samples\n\t\t%lf radians\n",
                    txvr->tx_rx_offset, 
                    txvr->tx_rx_offset_idx, 
                    txvr->tx_rx_offset_phi
                    );
        printf("Symbol Rate:\t%lf sym/s\n", txvr->SymRate);
        printf("Symbol Time:\t%lf s\n", txvr->SymTime);
        printf("Sym. Sampling:\t%lf %%\n\n", txvr->Sampling_Point * 100);
    }
}
