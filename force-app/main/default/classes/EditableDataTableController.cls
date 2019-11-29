public with sharing  class EditableDataTableController {
    public class EditableDataTableControllerException extends Exception {}
    public class Error {
        @AuraEnabled public String message;
        @AuraEnabled public Boolean hasError = true;
        public Error(String message){
            this.message = message;
        }
    }
    public class SaveResult {
        @AuraEnabled public String recordId;
        @AuraEnabled public Boolean success;
        @AuraEnabled public List<Map<String,Object> > errors = new List<Map<String,Object> >();
        public SaveResult(Database.UpsertResult res){
            this.recordId = res.getId();
            this.success = res.isSuccess();
            for(Database.Error err: res.getErrors()) {
                Map<String,Object> errorDetail = new Map<String,Object>();
                errordetail.put('message', err.getMessage());
                errordetail.put('fields', err.getFields());
                this.errors.add(errorDetail);
            }
        }
    }
    @AuraEnabled
    public static Object getRecords(String objectName, String fieldsJson, String recordIdsJson, String rowsLimit) {
        // System.debug(objectName);
        // System.debug(fieldsJson);
        // System.debug(recordIdsJson);
        try {
            List<Sobject> ret = new List<Sobject>();
            List<Field> fields = (List<Field>)JSON.deserialize(fieldsJson, List<Field>.class);
            recordIdsJson = String.escapeSingleQuotes(recordIdsJson);
            List<String> recordIds = (List<String>)JSON.deserialize(recordIdsJson, List<String>.class);

            String query = 'SELECT Id';
            for (Field field : fields) {
                // System.debug(field.name);
                if ((field.name.toLowerCase() != 'id')
                    && field.isObjectAccessible && field.isObjectUpdateable && field.isAccessible && field.isUpdateable) {
                    if (field.type.toUpperCase() == 'REFERENCE') {
                        query += ',' + field.name + ',' + field.referenceRelationshipName + '.' + field.referenceNameField;
                    }
                    else {
                        query += ',' + field.name;
                    }
                }
            }

            List<RecordType> recordTypes = [SELECT SobjectType FROM RecordType WHERE SobjectType = :objectName];
            if (recordTypes.size() > 0) {
                query += ', RecordTypeId';
            }
            query += ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE Id IN (\'' + String.join(recordIds, '\',\'') + '\') LIMIT ' + String.escapeSingleQuotes(rowsLimit);
            // System.debug(query);
            ret = Database.query(query);
            return ret;
        } catch (Exception e) {
            return new Error(e.getMessage());
        }
    }
    @AuraEnabled
    public static Object getFields(String objectName, String fieldNames) {
        try {
            if (String.isBlank(objectName)) throw new EditableDataTableControllerException('Object name is not specified');
            if (String.isBlank(fieldNames)) throw new EditableDataTableControllerException('Field name is not specified');
            List<Object> ret = new List<Object>();
            List<String> fieldNameList = fieldNames.split(',');
            for (String fieldName : fieldNameList) {
                ret.add(String.isBlank(fieldName) ? (Object)'' : new Field(objectName.trim(), fieldName.trim()));
            }
            return ret;
        } catch (Exception e) {
            return new Error(e.getMessage());
        }
    }
    @AuraEnabled
    public static string search(String objectName, String nameField, String keyword){
        try {
            Field field = new Field(objectName, nameField);
            if (!field.isObjectAccessible || !field.isAccessible) {
                throw new EditableDataTableControllerException(nameField + ' field of ' + objectName + ' is not accessbile');
            }
            if (isUnsafeStringForSearch(objectName) || isUnsafeStringForSearch(nameField) || isUnsafeStringForSearch(keyword)) {
                throw new EditableDataTableControllerException('Following Letters are not not supported: ?&|!{}[]()^~*:\\+-');
            }
            String searchquery = 'FIND \'' + String.escapeSingleQuotes(keyword) + '\' IN ALL FIELDS RETURNING ' + String.escapeSingleQuotes(objectName) + '(id, ' + String.escapeSingleQuotes(nameField) + ')';
            // System.debug(searchquery);
            List<List<SObject>> result = search.query(searchquery);
            return JSON.serialize(result);
        } catch (Exception e) {
            return JSON.serialize(new Error(e.getMessage()));
        }
    }
    private static Boolean isUnsafeStringForSearch(String paramStr){
        return !Pattern.matches('[^?&|!{}\\[\\]()^~*:\\+-]+', paramStr);
    }
    @AuraEnabled
    public static string saveRecords(String recordsJson, String sObjectName){
        try{
            List<SObject> records = (List<SObject>) JSON.deserialize(recordsJson, Type.forName('List<' + sObjectName + '>'));
            Set<String> fieldList = new Set<String>();
            for (SObject record : records) {
                fieldList.addAll(new List<String>(record.getPopulatedFieldsAsMap().keySet()));
            }
            for (String fieldName : fieldList) {
                Field field = new Field(sObjectName, fieldName);
                if ((field.name.toLowerCase() != 'id')
                    && (!field.isObjectAccessible || !field.isObjectUpdateable || !field.isAccessible || !field.isUpdateable)) {
                    throw new EditableDataTableControllerException(fieldName + ' field of ' + sObjectName + ' is not either accessbile or updateable');
                }
            }
            List<Database.UpsertResult> upsertResults = Database.upsert(records, false);
            List<SaveResult> saveResultsForJson = new List<SaveResult>();
            for(Database.UpsertResult res : upsertResults) {
                saveResultsForJson.add(new SaveResult(res));
            }
            return JSON.serialize(saveResultsForJson);
        }catch(Exception e) {
            // System.debug(e.getTypeName());
            // System.debug(e.getMessage());
            return JSON.serialize(new Error(e.getMessage()));
        }
    }
}