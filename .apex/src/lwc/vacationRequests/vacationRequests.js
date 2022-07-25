import {LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getVacationRequestList from '@salesforce/apex/VacationRequestsController.getVacationRequestList';

import REQUEST_OBJECT from '@salesforce/schema/Vacation_Request__c';
import TYPE_FIELD from '@salesforce/schema/Vacation_Request__c.RequestType__c';

export default class VacationRequests extends LightningElement {

    @track vacationRequests;
    @track error;
    @track isModalAddRequestShown = false;

    objectApiName = REQUEST_OBJECT;
    objectFields = [TYPE_FIELD];

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

}