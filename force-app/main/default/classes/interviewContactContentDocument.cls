public class interviewContactContentDocument {
    public static void addContentDocument(List<Contact> newContacts) {
        if (newContacts.isEmpty()) {
            return;
        }
        
        List<Id> contactIds = new List<Id>();
        for (Contact newContact : newContacts) {
            contactIds.add(newContact.Id);
        }

        List<Interview__c> interviewsToUpdate = new List<Interview__c>();
        List<Attachment> attachmentsToInsert = new List<Attachment>();

        // get the documents from the contact obejct record
        Map<Id, List<Note>> contactNotesMap = new Map<Id, List<Note>>();
        Map<Id, List<Attachment>> contactAttachmentsMap = new Map<Id, List<Attachment>>();

        for (Note note : [SELECT Id, ParentId, Title, Body FROM Note WHERE ParentId IN :contactIds]) {
            if (!contactNotesMap.containsKey(note.ParentId)) {
                contactNotesMap.put(note.ParentId, new List<Note>());
            }
            contactNotesMap.get(note.ParentId).add(note);
        }

        for (Attachment attachment : [SELECT Id, ParentId, Name, Body FROM Attachment WHERE ParentId IN :contactIds]) {
            if (!contactAttachmentsMap.containsKey(attachment.ParentId)) {
                contactAttachmentsMap.put(attachment.ParentId, new List<Attachment>());
            }
            contactAttachmentsMap.get(attachment.ParentId).add(attachment);
        }

        // insert/update the documents in the interview record related to the contact record
        for (Contact newContact : newContacts) {
            if (contactNotesMap.containsKey(newContact.Id) || contactAttachmentsMap.containsKey(newContact.Id)) {
                for (Interview__c relatedInterview : [SELECT Id FROM Interview__c WHERE Contact__c = :newContact.Id]) {
                    List<Attachment> contactAttachments = contactAttachmentsMap.get(newContact.Id);


                    for (Attachment attachment : contactAttachments) {
                        attachmentsToInsert.add(new Attachment(
                            ParentId = relatedInterview.Id,
                            Name = attachment.Name,
                            Body = attachment.Body
                        ));
                    }
                }
            }
        }

        // Insert documents
        if (!attachmentsToInsert.isEmpty()) {
            insert attachmentsToInsert;
        }
    }
}