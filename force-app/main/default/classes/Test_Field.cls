@isTest
public class Test_Field {
    static testMethod void createEmptyField() {
        Field field = new Field();
        System.assertEquals(null, field.objectName);
        System.assertEquals(null, field.name);
        System.assertEquals(null, field.type);
    }
    static testMethod void createSimpleField_Address() {
        Field field = new Field('Account', 'BillingAddress');
        System.assertEquals('Account', field.objectName);
        System.assertEquals('BillingAddress', field.name);
        System.assertEquals('ADDRESS', field.type);
    }
    static testMethod void createSimpleField_Base64() {
        Field field = new Field('ContentVersion', 'VersionData');
        System.assertEquals('ContentVersion', field.objectName);
        System.assertEquals('VersionData', field.name);
        System.assertEquals('BASE64', field.type);
    }
    static testMethod void createSimpleField_Boolean() {
        Field field = new Field('Contact', 'DoNotCall');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('DoNotCall', field.name);
        System.assertEquals('BOOLEAN', field.type);
    }
    static testMethod void createSimpleField_Combobox() {
        Field field = new Field('Event', 'Subject');
        System.assertEquals('Event', field.objectName);
        System.assertEquals('Subject', field.name);
        System.assertEquals('COMBOBOX', field.type);
    }
    static testMethod void createSimpleField_DataCategoryGroupReference() {
        // NOT TESTABLE - There is no standard DataCategoryGroupReference field.
    }
    static testMethod void createSimpleField_Date() {
        Field field = new Field('Opportunity', 'CloseDate');
        System.assertEquals('Opportunity', field.objectName);
        System.assertEquals('CloseDate', field.name);
        System.assertEquals('DATE', field.type);
    }
    static testMethod void createSimpleField_DateTime() {
        Field field = new Field('Case', 'ClosedDate');
        System.assertEquals('Case', field.objectName);
        System.assertEquals('ClosedDate', field.name);
        System.assertEquals('DATETIME', field.type);
    }
    static testMethod void createSimpleField_Double() {
        Field field = new Field('Opportunity', 'TotalOpportunityQuantity');
        System.assertEquals('Opportunity', field.objectName);
        System.assertEquals('TotalOpportunityQuantity', field.name);
        System.assertEquals('DOUBLE', field.type);
    }
    static testMethod void createSimpleField_Email() {
        Field field = new Field('Contact', 'Email');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Email', field.name);
        System.assertEquals('EMAIL', field.type);
    }
    static testMethod void createSimpleField_EncryptedString() {
        // NOT TESTABLE - There is no standard EncryptedString field.
    }
    static testMethod void createSimpleField_ID() {
        Field field = new Field('Contact', 'Id');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Id', field.name);
        System.assertEquals('ID', field.type);
    }
    static testMethod void createSimpleField_Integer() {
        Field field = new Field('Account', 'NumberOfEmployees');
        System.assertEquals('Account', field.objectName);
        System.assertEquals('NumberOfEmployees', field.name);
        System.assertEquals('INTEGER', field.type);
    }
    static testMethod void createSimpleField_MultiPicklist() {
        // NOT TESTABLE - There is no standard MultiPicklist field.
    }
    static testMethod void createSimpleField_Percent() {
        Field field = new Field('Opportunity', 'Probability');
        System.assertEquals('Opportunity', field.objectName);
        System.assertEquals('Probability', field.name);
        System.assertEquals('PERCENT', field.type);
    }
    static testMethod void createSimpleField_Phone() {
        Field field = new Field('Contact', 'Phone');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Phone', field.name);
        System.assertEquals('PHONE', field.type);
    }
    static testMethod void createSimpleField_Picklist() {
        Field field = new Field('Contact', 'LeadSource');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('LeadSource', field.name);
        System.assertEquals('PICKLIST', field.type);
    }
    static testMethod void createSimpleField_Reference() {
        Field field = new Field('Contact', 'AccountId');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('AccountId', field.name);
        System.assertEquals('REFERENCE', field.type);
        System.assertEquals('Account', field.referenceObjectName);
        System.assertEquals('Account', field.referenceRelationshipName);
        System.assertEquals('Name', field.referenceNameField);
    }
    static testMethod void createSimpleField_NonReference() {
        Field field = new Field('Contact', 'FirstName');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('FirstName', field.name);
        System.assertNotEquals('REFERENCE', field.type);
        System.assertEquals(null, field.referenceObjectName);
        System.assertEquals(null, field.referenceRelationshipName);
        System.assertEquals(null, field.referenceNameField);
    }
    static testMethod void createSimpleField_String() {
        Field field = new Field('Contact', 'Title');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Title', field.name);
        System.assertEquals('STRING', field.type);
    }
    static testMethod void createSimpleField_StringAsName() {
        Field field = new Field('Contact', 'Name');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Name', field.name);
        System.assertEquals('STRING', field.type);
        System.assertEquals(true, field.isNameField);
    }
    static testMethod void createSimpleField_StringAsSubject() {
        Field field = new Field('Event', 'Subject');
        System.assertEquals('Event', field.objectName);
        System.assertEquals('Subject', field.name);
        System.assertEquals('COMBOBOX', field.type);
        System.assertEquals(true, field.isNameField);
    }
    static testMethod void createSimpleField_TextArea() {
        // NOT TESTABLE - There is no standard field with Long Text under 255 characters.
    }
    static testMethod void createSimpleField_LongTextArea() {
        Field field = new Field('Contact', 'Description');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Description', field.name);
        System.assertEquals('TEXTAREA', field.type);
        System.assertEquals(false, field.isFilterable);
    }
    static testMethod void createSimpleField_Time() {
        // NOT TESTABLE - There is no standard Time field.
    }
    static testMethod void createSimpleField_URL() {
        Field field = new Field('Account', 'Website');
        System.assertEquals('Account', field.objectName);
        System.assertEquals('Website', field.name);
        System.assertEquals('URL', field.type);
    }
    static testMethod void createSimpleField_RandomCase() {
        Field field = new Field('CoNtaCt', 'TItlE');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Title', field.name);
        System.assertEquals('STRING', field.type);
    }
    static testMethod void createSimpleField_RedundantSpaces() {
        Field field = new Field('  Contact  ', '  Title  ');
        System.assertEquals('Contact', field.objectName);
        System.assertEquals('Title', field.name);
        System.assertEquals('STRING', field.type);
    }
    static testMethod void createSimpleField_checkAccessibility () {
        String uniqueUserName = 'chatterfreeuser' + DateTime.now().getTime() + '@recordhuntertest.com';
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name='Chatter Free User'];
        if (!profiles.isEmpty()) {
            User u = new User(Alias = 'cfree', Email='cfree@recordhuntertest.com',
                              EmailEncodingKey='UTF-8', LastName='Free', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = profiles[0].Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=uniqueUserName);
            System.runAs(u) {
                Field field = new Field('Account', 'Name');
                System.assertEquals(false,  field.isAccessible);
            }
        }
    }
}