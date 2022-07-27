trigger VacationRequestsTrigger on Vacation_Request__c (before insert) {
	for (Vacation_Request__c request : Trigger.new) {
		Datetime startDate = request.StartDate__c, endDate = request.EndDate__c;
		Integer workingDays = 0;

		while (startDate < endDate) {
			if (startDate.format('E') != 'Sat' && startDate.format('E') != 'Sun') {
				workingDays += 1;
			}
			startDate = startDate.addDays(1);
		}

		request.WorkingDays__c = workingDays;
	}
}