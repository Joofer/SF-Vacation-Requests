import {LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getVacationRequestList from '@salesforce/apex/VacationRequestsController.getVacationRequestList';

import REQUEST_OBJECT from '@salesforce/schema/Vacation_Request__c';
import ID_FIELD from '@salesforce/schema/Vacation_Request__c.Name';
import TYPE_FIELD from '@salesforce/schema/Vacation_Request__c.RequestType__c';
import START_DATE_FIELD from '@salesforce/schema/Vacation_Request__c.StartDate__c';
import END_DATE_FIELD from '@salesforce/schema/Vacation_Request__c.EndDate__c';
import WORKING_DAYS_FIELD from '@salesforce/schema/Vacation_Request__c.WorkingDays__c';
import MANAGER_FIELD from '@salesforce/schema/Vacation_Request__c.Manager__c';
import STATUS_FIELD from '@salesforce/schema/Vacation_Request__c.Status__c';

export default class VacationRequests extends LightningElement {

    @track vacationRequests;
    @track error;
    @track isModalAddRequestShown = false;

    objectApiName = REQUEST_OBJECT;
    fields = [ID_FIELD, TYPE_FIELD, START_DATE_FIELD, END_DATE_FIELD, WORKING_DAYS_FIELD, MANAGER_FIELD, STATUS_FIELD];

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
        const toastEvent = new ShowToastEvent({
            title: "Request created",
            message: "Vacation Request id: " + event.details.id,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }

    connectedCallback() {
        this.handleLoad();
    }

    openModalAddRequest() {
        this.isModalAddRequestShown = true;
    }

    closeModalAddRequest() {
        this.isModalAddRequestShown = false;
    }

    addRequest() {

    }

}