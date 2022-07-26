public class VacationRequestsController {

	// Class for storing visibility settings for all requests
	private class ActionsVisibility {
		public Boolean isSubmitVisible;
		public Boolean isApproveVisible;
		public Boolean isRemoveVisible;
	}

	// Class for returning requests as a single object containing requests and actions visibility settings
	private class RequestPair {
		public Vacation_Request__c request;
		public ActionsVisibility visibility;

		public RequestPair(Vacation_Request__c request, ActionsVisibility visibility) {
			this.request = request;
			this.visibility = visibility;
		}
	}

	// Get all vacation requests in an ascending order
	@AuraEnabled(cacheable=true)
	public static List<RequestPair> getVacationRequestList(Boolean isOnlyMy) {
		List<RequestPair> vacationRequests = new List<RequestPair>();
		List<Vacation_Request__c> result = new List<Vacation_Request__c>();
		List<ActionsVisibility> visibilities = new List<ActionsVisibility>();

		// Get current user id
		String currentId = UserInfo.getUserId();

		// Get filtered requests
		if (!isOnlyMy) {
			result = [
					SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, Manager__c, Status__c
					FROM Vacation_Request__c
					WITH SECURITY_ENFORCED
					ORDER BY Name ASC
			];
		} else {
			result = [
					SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, Manager__c, Status__c
					FROM Vacation_Request__c
					WHERE Manager__c = :currentId
					WITH SECURITY_ENFORCED
					ORDER BY Name ASC
			];
		}

		// Assign actions visibility settings for each request
		for (Vacation_Request__c request : result) {
			ActionsVisibility actionsVisibility = new ActionsVisibility();

			if (request.Status__c == 'Submitted' || request.CreatedById != currentId) {
				actionsVisibility.isSubmitVisible = false;
			} else {
				actionsVisibility.isSubmitVisible = true;
			}

			if (request.Manager__c != currentId) {
				actionsVisibility.isApproveVisible = false;
			} else {
				actionsVisibility.isSubmitVisible = true;
			}

			if (request.CreatedById != currentId || request.Status__c != 'New') {
				actionsVisibility.isRemoveVisible = false;
			} else {
				actionsVisibility.isRemoveVisible = true;
			}

			visibilities.add(actionsVisibility);
		}

		// Create list of request and visibility settings pairs
		for (Integer i = 0; i < result.size(); i++) {
			vacationRequests.add(new RequestPair(result[i], visibilities[i]));
		}

		return vacationRequests;
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