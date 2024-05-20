#include <Trade\Trade.mqh>

//--- Input variables accessible to the user
input double lotSize = 1;
input double stopLoss = 1;
input int numberOfPositions = 5;

//--- Service variables accessible from the IDE
CTrade trade;
datetime startTime;
const int atrPeriod = 14;
double atrControlPanel;
double atrData[];
bool isGateOpen = true;
double currentATR, previousATR;

//---Initialization function
int OnInit() {
    //--- Set up the indicator handler
    ArraySetAsSeries(atrData, true);
    atrControlPanel = iATR(_Symbol, PERIOD_M1, atrPeriod);
    return(INIT_SUCCEEDED);
}

//---Deinitialization function
void OnDeinit(const int reason) {
    IndicatorRelease(atrControlPanel);
}

void OnTick() {
    double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  
    //---Collect ATR data every second
    int copiedElements = CopyBuffer(atrControlPanel, 0, 0, 2, atrData);
    if (copiedElements > 0) {
        double getCurrATR = NormalizeDouble(atrData[0], 4);
        double getPrevATR = NormalizeDouble(atrData[1], 4);
        currentATR = getCurrATR;
        previousATR = getPrevATR;
    }
    Comment(currentATR);


    //+------------------------------------------------------------------+
    //| Sweet Spot                                                       |
    //+------------------------------------------------------------------+
   
   if (previousATR < currentATR) {
      if ((currentATR >= 2.05) && (currentATR <= 2.32)){
         if (isGateOpen){
         int i = 0;
         do {
         trade.Buy(lotSize);
         i++;
         } while (i < numberOfPositions);
         }
         isGateOpen = false;
         Sleep(150000);
      }
      int totalPositions = PositionsTotal();
      for (int i = totalPositions - 1; i >= 0; i--) {
        if (trade.PositionClose(PositionGetSymbol(i))) {
            totalPositions--;
         }
       }
   }

     if (currentATR < 2.05 || currentATR > 2.32){
     isGateOpen = true;
     }

}
