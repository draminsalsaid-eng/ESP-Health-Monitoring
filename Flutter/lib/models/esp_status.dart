enum ESPStatus {

  idle,

  waitingFinger,

  measuring,

  processingAI,

  completed,

  error,

}



ESPStatus parseESPStatus(String value) {


  switch(value) {


    case 'waiting_finger':
      return ESPStatus.waitingFinger;


    case 'measuring':
      return ESPStatus.measuring;


    case 'processing_ai':
      return ESPStatus.processingAI;


    case 'completed':
      return ESPStatus.completed;


    default:
      return ESPStatus.idle;

  }

}
