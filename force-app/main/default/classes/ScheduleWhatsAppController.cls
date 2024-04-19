global class ScheduleWhatsAppController implements Schedulable {
   global void execute(SchedulableContext SC) {
      WhatsAppController.doget();
   }
}