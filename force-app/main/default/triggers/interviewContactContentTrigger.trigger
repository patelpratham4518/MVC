trigger interviewContactContentTrigger on Contact (after insert) {
    interviewContactContentDocument.addContentDocument(Trigger.new);
}