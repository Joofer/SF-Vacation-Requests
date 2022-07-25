import {LightningElement, track} from 'lwc';
import getVacationRequestList from '@salesforce/apex/VacationRequestsController.getVacationRequestList';

import REQUEST_OBJECT from '@salesforce/schema/Vacation_Request__c';
import REQUEST_REQUESTTYPE_FIELD from '@salesforce/schema/Vacation_Request__c.RequestType__c';
import REQUEST_STARTDATE_FIELD from '@salesforce/schema/Vacation_Request__c.StartDate__c';
import REQUEST_ENDDATE_FIELD from '@salesforce/schema/Vacation_Request__c.EndDate__c';
import REQUEST_WORKINGDAYS_FIELD from '@salesforce/schema/Vacation_Request__c.WorkingDays__c';
import REQUEST_MANAGER_FIELD from '@salesforce/schema/Vacation_Request__c.Manager__c';
import REQUEST_STATUS_FIELD from '@salesforce/schema/Vacation_Request__c.Status__c';

export default class VacationRequests extends LightningElement {

    @track vacationRequests;
    @track error;
    @track isModalAddRequestShown = false;
    @track isSucceed = false;

    objectApiName = REQUEST_OBJECT;
    fields = [REQUEST_REQUESTTYPE_FIELD, REQUEST_STARTDATE_FIELD, REQUEST_ENDDATE_FIELD, REQUEST_WORKINGDAYS_FIELD, REQUEST_MANAGER_FIELD, REQUEST_STATUS_FIELD];

    handleLoad() {
        getVacationRequestList()
            .then(result => {
                this.vacationRequests = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleSuccess(event) {
        this.isSucceed = true;
    }

    connectedCallback() {
        this.handleLoad();
    }

    openModalAddRequest() {
        this.isSucceed = false;
        this.isModalAddRequestShown = true;
    }

    closeModalAddRequest() {
        this.isModalAddRequestShown = false;
    }

}