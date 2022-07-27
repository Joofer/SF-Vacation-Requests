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

}