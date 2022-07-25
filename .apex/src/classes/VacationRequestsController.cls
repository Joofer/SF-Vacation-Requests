public class VacationRequestsController {

	@AuraEnabled(cacheable=true)
	public static List<Vacation_Request__c> getVacationRequestList() {
		return [
				SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, Manager__c, Status__c
				FROM Vacation_Request__c
				WITH SECURITY_ENFORCED
		];
	}

}