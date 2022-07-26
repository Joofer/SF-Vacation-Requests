public class VacationRequestsController {

	// Class for returning requests as a single object containing requests and actions visibility settings
	public class Request {
		@AuraEnabled
		public Vacation_Request__c request { get; set; }
		@AuraEnabled
		public Boolean isSubmitVisible { get; set; }
		@AuraEnabled
		public Boolean isApproveVisible { get; set; }
		@AuraEnabled
		public Boolean isRemoveVisible { get; set; }

		public Request(Vacation_Request__c request, Boolean isSubmitVisible, Boolean isApproveVisible, Boolean isRemoveVisible) {
			this.request = request;
			this.isSubmitVisible = isSubmitVisible;
			this.isApproveVisible = isApproveVisible;
			this.isRemoveVisible = isRemoveVisible;
		}
	}

	// Get user's manager
	@AuraEnabled(cacheable=true)
	public static User getUserManager(String userId) {
		return [
				SELECT ManagerId
				FROM User
				WHERE Id = :userId
				WITH SECURITY_ENFORCED
				LIMIT 1
		];
	}

	// Get all vacation requests in an ascending order
	@AuraEnabled(cacheable=true)
	public static List<Request> getVacationRequestList(Boolean isOnlyMy) {
		List<Request> vacationRequests = new List<Request>();
		List<Vacation_Request__c> requests = new List<Vacation_Request__c>();

		// Get current user id
		String currentId = UserInfo.getUserId();

		// Get filtered requests
		if (!isOnlyMy) {
			requests = [
					SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, RecordOwner__c, OwnerId, Manager__c, Manager__r.Name, Status__c
					FROM Vacation_Request__c
					WITH SECURITY_ENFORCED
					ORDER BY Name DESC
			];
		} else {
			requests = [
					SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, OwnerId, Manager__c, Manager__r.Name, Status__c
					FROM Vacation_Request__c
					WHERE Manager__c = :currentId
					WITH SECURITY_ENFORCED
					ORDER BY Name DESC
			];
		}

		// Assign actions visibility settings for each request
		for (Vacation_Request__c request : requests) {
			Boolean isSubmitVisible, isApproveVisible, isRemoveVisible;

			if (request.Status__c == 'Submitted' || request.Status__c == 'Approved' || request.OwnerId != currentId) {
				isSubmitVisible = false;
			} else {
				isSubmitVisible = true;
			}

			if (request.Status__c == 'Approved' || request.Manager__c != currentId) {
				isApproveVisible = false;
			} else {
				isApproveVisible = true;
			}

			if (request.Status__c != 'New' || request.OwnerId != currentId) {
				isRemoveVisible = false;
			} else {
				isRemoveVisible = true;
			}

			// Create list of request and visibility settings pairs
			vacationRequests.add(new Request(request, isSubmitVisible, isApproveVisible, isRemoveVisible));
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