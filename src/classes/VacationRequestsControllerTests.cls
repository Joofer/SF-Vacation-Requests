@IsTest
public class VacationRequestsControllerTests {

	@IsTest static void testGetRequestsWithoutFilter() {
		List<VacationRequestsController.Request> requests = VacationRequestsController.getVacationRequestList(false);
		List<Vacation_Request__c> valid = [
				SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, Owner.Name, Manager__c, Manager__r.Name, Status__c
				FROM Vacation_Request__c
		];

		System.assertEquals(valid.size(), requests.size());
	}

	@IsTest static void testGetRequestsWithFilter() {
		String currentId = UserInfo.getUserId();
		List<VacationRequestsController.Request> requests = VacationRequestsController.getVacationRequestList(true);
		List<Vacation_Request__c> valid = [
				SELECT Name, RequestType__c, StartDate__c, EndDate__c, WorkingDays__c, Owner.Name, Manager__c, Manager__r.Name, Status__c
				FROM Vacation_Request__c
				WHERE Manager__c = :currentId
		];

		System.assertEquals(valid.size(), requests.size());
	}

	@IsTest static void getCurrentUserManager() {
		String currentId = UserInfo.getUserId();
		User userManager = VacationRequestsController.getUserManager(currentId);
		User valid = [
				SELECT ManagerId
				FROM User
				WHERE Id = :currentId
				WITH SECURITY_ENFORCED
				LIMIT 1
		];

		System.assertEquals(valid.ManagerId, userManager.ManagerId);
	}

	@IsTest static void submitRequest() {
		Vacation_Request__c request = [
				SELECT Name, Status__c
				FROM Vacation_Request__c
				WHERE Status__c = 'New'
				LIMIT 1
		];
		String id = request.Name;

		System.assert(VacationRequestsController.submitVacationRequest(request.Name));

		String statusAfter = [
				SELECT Status__c
				FROM Vacation_Request__c
				WHERE Name = :id
				LIMIT 1
		].Status__c;

		System.assertEquals('Submitted', statusAfter);
	}

	@IsTest static void approveRequest() {
		Vacation_Request__c request = [
				SELECT Name, Status__c
				FROM Vacation_Request__c
				WHERE Status__c = 'Submitted'
				LIMIT 1
		];
		String id = request.Name;

		System.assert(VacationRequestsController.approveVacationRequest(request.Name));

		String statusAfter = [
				SELECT Status__c
				FROM Vacation_Request__c
				WHERE Name = :id
				LIMIT 1
		].Status__c;

		System.assertEquals('Approved', statusAfter);
	}

	@IsTest static void removeRequest() {
		Vacation_Request__c requestId = [
				SELECT Name
				FROM Vacation_Request__c
				LIMIT 1
		];
		Integer sizeBefore = [ SELECT Id FROM Vacation_Request__c ].size();

		System.assert(VacationRequestsController.removeVacationRequest(requestId.Name));

		Integer sizeAfter = [ SELECT Id FROM Vacation_Request__c ].size();

		System.assertEquals(sizeBefore - 1, sizeAfter);
	}
}