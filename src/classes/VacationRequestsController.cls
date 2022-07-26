public class VacationRequestsController {

	// Get all vacation requests in an ascending order
	@AuraEnabled(cacheable=true)
	public static List<Vacation_Request__c> getVacationRequestList(Boolean isOnlyMy) {
		if (!isOnlyMy) {
			return [
					SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, Manager__c, Status__c
					FROM Vacation_Request__c
					WITH SECURITY_ENFORCED
					ORDER BY Name ASC
			];
		} else {
			String currentId = UserInfo.getUserId();

			return [
					SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, Manager__c, Status__c
					FROM Vacation_Request__c
					WHERE Manager__c = :currentId
					WITH SECURITY_ENFORCED
					ORDER BY Name ASC
			];
		}
	}

	// Get user name by Id
	@AuraEnabled(cacheable=true)
	public static List<User> getUserName(String userId) {
		return [
				SELECT Name
				FROM User
				WHERE Id = :userId
				WITH SECURITY_ENFORCED
		];
	}

	// Submit vacation request with id requestId
	@AuraEnabled
	public static Boolean submitVacationRequest(String requestId) {
		List<Vacation_Request__c> vacationRequestList = [
				SELECT Name, Status__c
				FROM Vacation_Request__c
				WHERE Name = :requestId
				WITH SECURITY_ENFORCED
		];

		if (vacationRequestList.isEmpty()) {
			// No records found, throw an error
			return false;
		}

		// Changing status
		vacationRequestList[0].Status__c = 'Submitted';
		// Updating row
		update vacationRequestList;

		return true;
	}

	// Approve vacation request with id requestId
	@AuraEnabled
	public static Boolean approveVacationRequest(String requestId) {
		List<Vacation_Request__c> vacationRequestList = [
				SELECT Name, Status__c
				FROM Vacation_Request__c
				WHERE Name = :requestId
				WITH SECURITY_ENFORCED
		];

		if (vacationRequestList.isEmpty()) {
			// No records found, throw an error
			return false;
		}

		// Changing status
		vacationRequestList[0].Status__c = 'Approved';
		// Updating row
		update vacationRequestList;

		return true;
	}

	// Remove vacation request with id requestId
	@AuraEnabled
	public static Boolean removeVacationRequest(String requestId) {
		List<Vacation_Request__c> vacationRequestList = [
				SELECT Name, Status__c
				FROM Vacation_Request__c
				WHERE Name = :requestId
				WITH SECURITY_ENFORCED
		];

		if (vacationRequestList.isEmpty()) {
			// No records found, throw an error
			return false;
		}

		// Try to delete record
		try {
			delete vacationRequestList[0];
		} catch (DmlException e) {
			// Exception thrown, it's reasonable to just return false
			return false;
		}
		return true;
	}

}