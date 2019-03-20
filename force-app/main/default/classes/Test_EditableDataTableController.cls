@IsTest
public class Test_EditableDataTableController {
    static testMethod void getFields_SingleField() {
        Object result = EditableDataTableController.getFields('Account', 'Name');
        List<Object> fields = (List<Object>)result;
        System.assertEquals(1, fields.size());
    }
    static testMethod void getFields_MultipleFields() {
        Object result = EditableDataTableController.getFields('Account', 'Name,Type,Phone');
        List<Object> fields = (List<Object>)result;
        System.assertEquals(3, fields.size());
    }
    static testMethod void getFields_RedundantSpaces() {
        Object result = EditableDataTableController.getFields('Account', ' Name  ,   Type ,Phone   ');
        List<Object> fields = (List<Object>)result;
        System.assertEquals(3, fields.size());
    }
    static testMethod void getFields_Empty() {
        Object result = EditableDataTableController.getFields('', '');
        EditableDataTableController.Error error = (EditableDataTableController.Error)result;
        System.assertEquals(true, error.hasError);
    }
    static testMethod void getFields_EmptyObject() {
        Object result = EditableDataTableController.getFields('', 'Name');
        EditableDataTableController.Error error = (EditableDataTableController.Error)result;
        System.assertEquals(true, error.hasError);
    }
    static testMethod void getFields_EmptyField() {
        Object result = EditableDataTableController.getFields('Account', '');
        EditableDataTableController.Error error = (EditableDataTableController.Error)result;
        System.assertEquals(true, error.hasError);
    }
    static testMethod void getFields_InvalidObject() {
        Object result = EditableDataTableController.getFields('XXX', 'Name');
        EditableDataTableController.Error error = (EditableDataTableController.Error)result;
        System.assertEquals(true, error.hasError);
    }
    static testMethod void getFields_InvalidField() {
        Object result = EditableDataTableController.getFields('Account', 'XXX');
        EditableDataTableController.Error error = (EditableDataTableController.Error)result;
        System.assertEquals(true, error.hasError);
    }
    static testMethod void getFields_SomeInvalidFields() {
        Object result = EditableDataTableController.getFields('Account', 'Name, XXX, AAA');
        EditableDataTableController.Error error = (EditableDataTableController.Error)result;
        System.assertEquals(true, error.hasError);
    }
    static testMethod void getRecords_NonReferenceField() {
        List<User> userList = [SELECT Id, LastName FROM User LIMIT 1];

        Field f1 = new Field('User', 'LastName');

        List<Field> fieldList = new List<Field>();
        fieldList.add(f1);

        Test.startTest();
        Object result = EditableDataTableController.getRecords('User', JSON.serialize(fieldList), JSON.serialize((new Map<Id, User>(userList)).keySet()), '1');
        List<User> resultedUsers = (List<User>)result;
        System.assertEquals(resultedUsers[0].LastName, userList[0].LastName);
        Test.stopTest();
    }
    static testMethod void getRecords_ReferenceField() {
        List<User> userList = [SELECT Id, ContactId FROM User LIMIT 1];

        Field f1 = new Field('User', 'ContactId');

        List<Field> fieldList = new List<Field>();
        fieldList.add(f1);

        Test.startTest();
        Object result = EditableDataTableController.getRecords('User', JSON.serialize(fieldList), JSON.serialize((new Map<Id, User>(userList)).keySet()), '1');
        List<User> resultedAccounts = (List<User>)result;
        System.assertEquals(resultedAccounts[0].ContactId, userList[0].ContactId);
        Test.stopTest();
    }
    static testMethod void getRecords_InvalidObjectName() {
        List<Case> caseList = [SELECT Id, AccountId FROM Case LIMIT 1];

        Field f1 = new Field('Case', 'AccountId');

        List<Field> fieldList = new List<Field>();
        fieldList.add(f1);

        Test.startTest();
        Object result = EditableDataTableController.getRecords('Ca-se', JSON.serialize(fieldList), JSON.serialize((new Map<Id, Case>(caseList)).keySet()), '1');
        EditableDataTableController.Error e = (EditableDataTableController.Error)result;
        System.assertEquals(true, e.hasError);
        System.assertNotEquals(null, e.message);
        Test.stopTest();
    }
    static testMethod void saveRecords() {
        Test.startTest();
        Case c = new Case(Subject='SaveSuccessTest');
        Insert c;
        String caseId = c.Id;
        String recordsJson = '[{"Id":"' + caseId + '","attributes":{"type":"Case"},"Subject":""}]';
        String resultJson = EditableDataTableController.saveRecords(recordsJson, 'Case');
        List<EditableDataTableController.SaveResult> result = (List<EditableDataTableController.SaveResult>)JSON.deserialize(resultJson, List<EditableDataTableController.SaveResult>.class);
        System.assertEquals(1, result.size());
        System.assertEquals(caseId, result[0].recordId);
        System.assertEquals(true, result[0].success);
        Test.stopTest();
    }
    static testMethod void saveResult_Error() {
        Contact c = new Contact(FirstName='SaveErrorTest', LastName='SaveErrorTest', Email='invalid');
        Test.startTest();
        Database.UpsertResult upsertResult = Database.upsert(c, false);
        EditableDataTableController.SaveResult saveResult = new EditableDataTableController.SaveResult(upsertResult);
        System.assertEquals(null, saveResult.recordId);
        System.assertEquals(false, saveResult.success);
        System.assertNotEquals(null, saveResult.errors[0].get('message'));
        System.assertNotEquals(null, saveResult.errors[0].get('fields'));
        Test.stopTest();
    }
    static testMethod void search_AccountName() {
        String testAccountName = 'AccountNameSearchTest';
        Account ac = new Account(Name = testAccountName);
        insert ac;
        Test.setFixedSearchResults(new List<Id> {ac.Id});
        Test.startTest();
        String result = EditableDataTableController.search('Account', 'Name', testAccountName);
        List<List<Account> > resultedAccounts = (List<List<Account> >) JSON.deserialize(result, List<List<Account> >.class);
        System.assertEquals(ac.Id, resultedAccounts[0][0].Id);
        System.assertEquals(testAccountName, resultedAccounts[0][0].Name);
        Test.stopTest();
    }
    static testMethod void search_UnsupportedLetter() {
        String testAccountName = 'AccountNameSearchTest';
        Account ac = new Account(Name = testAccountName);
        insert ac;
        Test.setFixedSearchResults(new List<Id> {ac.Id});
        Test.startTest();
        String result = EditableDataTableController.search('Account', 'Name', 'Account*');
        EditableDataTableController.Error error = (EditableDataTableController.Error) JSON.deserialize(result, EditableDataTableController.Error.class);
        System.assertEquals(true, error.hasError);
        System.assertEquals(true, error.message.contains('Following Letters are not not supported:'));
        Test.stopTest();
    }
    static testMethod void search_InvalidObjectName() {
        String testAccountName = 'AccountNameSearchTest';
        Account ac = new Account(Name = testAccountName);
        insert ac;
        Test.setFixedSearchResults(new List<Id> {ac.Id});
        Test.startTest();
        String result = EditableDataTableController.search('InvalidObjectName', 'Name', testAccountName);
        EditableDataTableController.Error error = (EditableDataTableController.Error) JSON.deserialize(result, EditableDataTableController.Error.class);
        System.assertEquals(true, error.hasError);
        System.assertEquals(true, error.message.contains('sObject type \'invalidobjectname\' is not supported.'));
        Test.stopTest();
    }
    static testMethod void search_InvalidNameField() {
        String testAccountName = 'AccountNameSearchTest';
        Account ac = new Account(Name = testAccountName);
        insert ac;
        Test.setFixedSearchResults(new List<Id> {ac.Id});
        Test.startTest();
        String result = EditableDataTableController.search('Account', 'InvalidNameField', testAccountName);
        EditableDataTableController.Error error = (EditableDataTableController.Error) JSON.deserialize(result, EditableDataTableController.Error.class);
        System.assertEquals(true, error.hasError);
        System.assertEquals(true, error.message.contains('No such column \'InvalidNameField\' on entity \'Account\''));
        Test.stopTest();
    }
}