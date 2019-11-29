// Logic is based on
// https://github.com/hrk623/record-hunter/blob/master/src/classes/RecordHunterField.cls

public class Field {
    public class FieldException extends Exception {}

    @AuraEnabled public String objectLabel;
    @AuraEnabled public String objectName;
    @AuraEnabled public String label;
    @AuraEnabled public String name;
    @AuraEnabled public String type;
    @AuraEnabled public String referenceObjectName;
    @AuraEnabled public String referenceRelationshipName;
    @AuraEnabled public String referenceNameField;

    @AuraEnabled public Boolean isObjectAccessible;
    @AuraEnabled public Boolean isObjectUpdateable;
    @AuraEnabled public Boolean isNameField;
    @AuraEnabled public Boolean isFilterable;
    @AuraEnabled public Boolean isAccessible;
    @AuraEnabled public Boolean isUpdateable;
    @AuraEnabled public Integer scale;
    @AuraEnabled public Integer precision;

    @AuraEnabled public String value;
    @AuraEnabled public String minValue;
    @AuraEnabled public String maxValue;
    @AuraEnabled public String latitude;
    @AuraEnabled public String longitude;
    @AuraEnabled public String distance;
    @AuraEnabled public String index;

    @AuraEnabled public Boolean isValid;

    public Field() {
        this.objectName = null;
        this.name = null;
        this.Label = null;
        this.type = null;
        this.isNameField = false;
        this.scale = 0;
        this.isObjectAccessible = false;
        this.isObjectUpdateable = false;
        this.isFilterable = false;
        this.isAccessible = false;
        this.isUpdateable = false;
    }

    public Field(String objectName, String fieldName) {
        objectName = objectName.trim();
        fieldName = fieldName.trim();
        if (!isValidObjectName(objectName)) throw new FieldException('\'' + objectName + '\' is not valid object type');
        if (!isValidFieldName(objectName, fieldName)) throw new FieldException('\''+fieldName + '\' of \'' + objectName + '\' is not a valid field. Valid fields are ' + String.join(getFieldNames(objectName), ', '));
        init(objectName, fieldName);
    }

    private void init(String objectName, String fieldName) {
        this.objectName = getObjectName(objectName);
        this.objectLabel = getObjectLabel(objectName);
        this.isObjectAccessible = isObjectAccessible(objectName);
        this.isObjectUpdateable = isObjectUpdateable(objectName);
        this.name = getFieldName(objectName, fieldName);
        this.Label = getFieldLabel(objectName, fieldName);
        this.type = getFieldType(objectName, fieldName).name();
        this.isNameField = isNameField(objectName, fieldName);

        this.isFilterable = isFilterable(objectName, fieldName);
        this.isValid = true;
        this.isAccessible = isAccessible(objectName, fieldName);
        this.isUpdateable = isUpdateable(objectName, fieldName);
        this.scale = getScale(objectName, fieldName);
        this.precision = getPrecision(objectName, fieldName);

        if(this.type == 'REFERENCE') {
            this.referenceObjectName = getReferencedObjectName(objectName, fieldName);
            this.referenceRelationshipName  = getRelationshipName(objectName, fieldName);
            Map<String, Schema.SObjectField> parentFieldMap = Schema.getGlobalDescribe().get(this.referenceObjectName).getDescribe().fields.getMap();
            for (String parentFieldName : parentFieldMap.keySet()) {
                if (parentFieldMap.get(parentFieldName).getDescribe().isNameField()) {
                    this.referenceNameField = parentFieldMap.get(parentFieldName).getDescribe().getName();
                    break;
                }
            }
        }
    }

    private List<String> getFieldNames(String objectName){
        return new List<String>(Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet());
    }
    private String getFieldName(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getName();
    }
    private String getFieldLabel(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
    }
    private String getObjectName(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getName();
    }
    private String getObjectLabel(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getLabel();
    }
    private Boolean isObjectAccessible(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().isAccessible();
    }
    private Boolean isObjectUpdateable(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().isUpdateable();
    }
    private Boolean isNameField(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().isNameField();
    }
    private Boolean isAccessible(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().isAccessible();
    }
    private Boolean isUpdateable(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().isUpdateable();
    }
    private Integer getScale(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getScale();
    }
    private Integer getPrecision(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPrecision();
    }
    private Schema.DisplayType getFieldType(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
    }
    private String getReferencedObjectName (String objectName, String fieldName){
        List <Schema.sObjectType> refObjList = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getReferenceTo();
        if (refObjList.size() > 0) return refObjList[0].getDescribe().getName();
        else return '';
    }
    private String getRelationshipName(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getRelationshipName();
    }
    private Boolean isValidObjectName(String objectName){
        return !String.isEmpty(objectName) && Schema.getGlobalDescribe().containsKey(objectName);
    }
    private Boolean isValidFieldName(String objectName, String fieldName){
        return isValidObjectName(objectName) && !String.isEmpty(fieldName)
               && Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().containsKey(fieldName);
    }
    private Boolean isFilterable(String objectName, String fieldName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().isFilterable();
    }
}