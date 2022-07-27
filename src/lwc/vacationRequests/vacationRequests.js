import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// User info
import Id from '@salesforce/user/Id';

// VacationRequestsController imports
import getUserManager from '@salesforce/apex/VacationRequestsController.getUserManager';
import getVacationRequestList from '@salesforce/apex/VacationRequestsController.getVacationRequestList';
import submitVacationRequest from '@salesforce/apex/VacationRequestsController.submitVacationRequest';
import approveVacationRequest from '@salesforce/apex/VacationRequestsController.approveVacationRequest';
import removeVacationRequest from '@salesforce/apex/VacationRequestsController.removeVacationRequest';

// Schema imports
import REQUEST_OBJECT from '@salesforce/schema/Vacation_Request__c';
import REQUEST_REQUESTTYPE_FIELD from '@salesforce/schema/Vacation_Request__c.RequestType__c';
import REQUEST_STARTDATE_FIELD from '@salesforce/schema/Vacation_Request__c.StartDate__c';
import REQUEST_ENDDATE_FIELD from '@salesforce/schema/Vacation_Request__c.EndDate__c';
import REQUEST_MANAGER_FIELD from '@salesforce/schema/Vacation_Request__c.Manager__c';

export default class VacationRequests extends LightningElement {

    @track vacationRequests;
    @track error;
    @track isModalAddRequestShown = false;

    objectApiName = REQUEST_OBJECT;
    typeField = REQUEST_REQUESTTYPE_FIELD;
    startDateField = REQUEST_STARTDATE_FIELD;
    endDateField = REQUEST_ENDDATE_FIELD;
    managerField = REQUEST_MANAGER_FIELD;

    @wire(getVacationRequestList, { isOnlyMy: '$isOnlyMyRequests' })
    vacationRequests;

    handleSuccess(event) {
        this.closeModalAddRequest();
        this.showSuccessMessage("Success", "Vacation request was successfully created!");
        this.updateRequestRecords();
    }

    updateRequestRecords(object) {
        refreshApex(this.vacationRequests);
    }

    // Requests filter

    isOnlyMyRequests = false;

    getOnlyMyRequests(event) {
        this.isOnlyMyRequests = event.target.checked;
        this.updateRequestRecords();
    }

    // Toast messages

    showSuccessMessage(title, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }

    showErrorMessage(title, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        });
        this.dispatchEvent(toastEvent);
    }

    // Request creation modal

    openModalAddRequest() {
        this.isModalAddRequestShown = true;
    }

    closeModalAddRequest() {
        this.isModalAddRequestShown = false;
    }

    // Request actions

    submitRequest(event) {
        let selectedRequestId = event.currentTarget.dataset.id;
        submitVacationRequest({ requestId: selectedRequestId })
            .then((result) => {
                if (result === true) {
                    this.showSuccessMessage("Success", "Vacation request #" + selectedRequestId + " was submitted.");
                    this.updateRequestRecords();
                } else {
                    this.showErrorMessage("Error", "Something went wrong when submitting request #" + selectedRequestId + ".");
                }
            })
            .catch((error) => {
                this.showErrorMessage("Error", "Something went wrong when submitting request #" + selectedRequestId + " (" + error.message + ").");
                this.error = error;
            });
    }

    approveRequest(event) {
        let selectedRequestId = event.currentTarget.dataset.id;
        approveVacationRequest({ requestId: selectedRequestId })
            .then((result) => {
                if (result === true) {
                    this.showSuccessMessage("Success", "Vacation request #" + selectedRequestId + " was approved.");
                    this.updateRequestRecords();
                } else {
                    this.showErrorMessage("Error", "Something went wrong when approving request #" + selectedRequestId + ".");
                }
            })
            .catch((error) => {
                this.showErrorMessage("Error", "Something went wrong when approving request #" + selectedRequestId + " (" + error.message + ").");
                this.error = error;
            });
    }

    removeRequest(event) {
        let selectedRequestId = event.currentTarget.dataset.id;
        removeVacationRequest({ requestId: selectedRequestId })
            .then((result) => {
                if (result === true) {
                    this.showSuccessMessage("Success", "Vacation request #" + selectedRequestId + " was removed.");
                    this.updateRequestRecords();
                } else {
                    this.showErrorMessage("Error", "Something went wrong when removing request #" + selectedRequestId + ".");
                }
            })
            .catch((error) => {
                this.showErrorMessage("Error", "Something went wrong when removing request #" + selectedRequestId + " (" + error.message + ").");
                this.error = error;
            });
    }

    // Request processing

    @track userId = Id;
    @track userManager;

    getManager() {
        getUserManager({ userId: Id })
            .then((result) => {
                if (result != null) {
                    this.userManager = result.ManagerId;
                } else {
                    this.showErrorMessage("Error", "Manager is not specified for current user.");
                }
            })
            .catch((error) => {
                this.showErrorMessage("Error", "Something went wrong when getting user's manager.");
                this.error = error;
            });
    }

    @wire(getVacationRequestList)
    processUnits({data, error}){
        if(data) {
            this.vacationRequests.data = data.map(request => {
                return {
                    ...request,
                    badgeStyle: (request.Status__c === 'New'? '.slds-badge': (request.Status__c === 'Submitted'? '.slds-badge .slds-theme_warning': '.slds-badge .slds-theme_success'))
                }
            });
        }
    }

}